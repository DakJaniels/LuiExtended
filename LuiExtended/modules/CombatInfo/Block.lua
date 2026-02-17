-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- Block indicator, remaining-block count, and Bloodlord's Embrace tracker.
--- @class (partial) LUIE.CombatInfo.Block

local LUIE = LUIE
local UI = LUIE.UI
--- @class (partial) LUIE.CombatInfo
local CombatInfo = LUIE.CombatInfo
--- @class (partial) Block
local Block = CombatInfo.Block

local GetSlotTrueBoundId = LUIE.GetSlotTrueBoundId
local eventManager = GetEventManager()
local windowManager = GetWindowManager()
local zo_strformat = zo_strformat
local zo_floor = zo_floor
local pairs = pairs

local moduleName = Block.name

-- ---------------------------------------------------------------------------
-- Constants
-- ---------------------------------------------------------------------------

local BASE_BLOCK_COST = 1730
local BLOCK_INDICATOR_SIZE = 64
local BLOCK_INDICATOR_INACTIVE_ALPHA = 0.3
local DEBOUNCE_DELAY_MS = 500
local BLOODLORD_EMBRACE_DEBUFF_ABILITY_ID = 139903
local BLOODLORD_EMBRACE_ENERGIZE_ABILITY_ID = 139914
local BLOODLORD_EMBRACE_EFFECT_FADE_GRACE_MS = 200
local BLOODLORD_EMBRACE_MIN_SET_PIECES = 1
local BLOODLORD_EMBRACE_ABILITY_ICON_SIZE = 50
local BLOODLORD_EMBRACE_BORDER_INSET = -2
local BLOODLORD_EMBRACE_BORDER_SIZE = 54
local PANEL_WIDTH = 130
local PANEL_HEIGHT = 30
local PANEL_PADDING = 5
local BLOODLORD_EMBRACE_GAP = 8
local BLOODLORD_EMBRACE_PANEL_GAP = 4
local BLOODLORD_EMBRACE_WINDOW_WIDTH = BLOODLORD_EMBRACE_ABILITY_ICON_SIZE + BLOODLORD_EMBRACE_GAP + PANEL_WIDTH
local BLOODLORD_EMBRACE_WINDOW_HEIGHT = (2 * PANEL_HEIGHT) + BLOODLORD_EMBRACE_PANEL_GAP
local EQUIP_SLOT_EXCLUDE_FROM_ITEM_UPDATE = { [13] = true, [14] = true }
local BLOCK_SHIELD_MEDIA = LUIE_MEDIA_COMBATINFO_BLOCK_SHIELD_DDS
local BLOCK_SHIELD_GREY_MEDIA = LUIE_MEDIA_COMBATINFO_BLOCK_SHIELD_GREY_DDS

--- Bloodlord's Embrace set item link(s) for detection.
local BLOODLORD_EMBRACE_SET_ITEM_LINKS =
{
    "|H1:item:165899:364:50:0:0:0:0:0:0:0:0:0:0:0:1:10:0:1:0:9800:0|h|h",
}

-- ---------------------------------------------------------------------------
-- Module state
-- ---------------------------------------------------------------------------

local cachedBlockCost = BASE_BLOCK_COST
local debounceInventoryPending = false
local debounceActionSlotsPending = false
local blockIndicatorFragment = nil
local bloodlordEmbraceFragment = nil
local bloodlordEmbraceTargetUnitId = 0
local bloodlordEmbraceLastApplyTime = 0
local bloodlordEmbraceTotalMagickaReturned = 0
local bloodlordEmbraceIsEquipped = false

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

---
--- @return string font
local function GetUsableFont()
    local font
    if IsInGamepadPreferredMode() or IsConsoleUI() then
        font = "$(GAMEPAD_MEDIUM_FONT)|$(GP_14)|soft-shadow-thick"
    else
        font = "$(BOLD_FONT)|$(KB_12)|soft-shadow-thin"
    end
    return font
end

local function GetTitleFont()
    local sv = CombatInfo.SV.block
    local fontFaceChoice = sv.bloodlordEmbraceFontFace or CombatInfo.Defaults.block.bloodlordEmbraceFontFace
    local fontFace = LUIE.Fonts[fontFaceChoice]
    if not fontFace then
        fontFace = "LUIE Default Font"
    end
    local fontSize = sv.bloodlordEmbraceTitleSize or CombatInfo.Defaults.block.bloodlordEmbraceTitleSize
    local fontStyle = sv.bloodlordEmbraceFontStyle or CombatInfo.Defaults.block.bloodlordEmbraceFontStyle
    return LUIE.CreateFontString(fontFace, fontSize, fontStyle)
end

local function GetValueFont()
    local sv = CombatInfo.SV.block
    local fontFaceChoice = sv.bloodlordEmbraceFontFace or CombatInfo.Defaults.block.bloodlordEmbraceFontFace
    local fontFace = LUIE.Fonts[fontFaceChoice]
    if not fontFace then
        fontFace = "LUIE Default Font"
    end
    local fontSize = sv.bloodlordEmbraceValueSize or CombatInfo.Defaults.block.bloodlordEmbraceValueSize
    local fontStyle = sv.bloodlordEmbraceFontStyle or CombatInfo.Defaults.block.bloodlordEmbraceFontStyle
    return LUIE.CreateFontString(fontFace, fontSize, fontStyle)
end

local function GetBlockIndicatorFont()
    local sv = CombatInfo.SV.block
    local fontFaceChoice = sv.blockIndicatorFontFace or CombatInfo.Defaults.block.blockIndicatorFontFace
    local fontFace = LUIE.Fonts[fontFaceChoice]
    if not fontFace then
        fontFace = "LUIE Default Font"
    end
    local fontSize = sv.blockIndicatorFontSize or CombatInfo.Defaults.block.blockIndicatorFontSize
    local fontStyle = sv.blockIndicatorFontStyle or CombatInfo.Defaults.block.blockIndicatorFontStyle
    return LUIE.CreateFontString(fontFace, fontSize, fontStyle)
end

--- Returns whether any of the given set links are equipped with at least minPieces.
--- @param setLinks table Array of item links
--- @param minPieces number Minimum equipped pieces (default 1)
--- @return boolean
local function IsSetEquipped(setLinks, minPieces)
    minPieces = minPieces or 1
    for _, setLink in pairs(setLinks) do
        local hasSet, _, _, numEquipped = GetItemLinkSetInfo(setLink, true)
        if hasSet and numEquipped >= minPieces then
            return true
        end
    end
    return false
end

-- ---------------------------------------------------------------------------
-- Block cost calculation
-- ---------------------------------------------------------------------------

function Block.RefreshBlockCost()
    local sv = CombatInfo.SV.block
    if not sv.showRemainingBlocks then
        return
    end

    local _, flatValue = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_BLOCK_COST)

    if flatValue and flatValue > 0 then
        cachedBlockCost = flatValue
    end
end

-- ---------------------------------------------------------------------------
-- Bloodlord's Embrace visibility and state
-- ---------------------------------------------------------------------------

function Block.RefreshBloodlordEmbraceVisibility()
    local equipped = IsSetEquipped(BLOODLORD_EMBRACE_SET_ITEM_LINKS, BLOODLORD_EMBRACE_MIN_SET_PIECES)
    if equipped == bloodlordEmbraceIsEquipped then
        return
    end
    bloodlordEmbraceIsEquipped = equipped
    if bloodlordEmbraceFragment then
        if equipped then
            HUD_UI_SCENE:AddFragment(bloodlordEmbraceFragment)
            HUD_SCENE:AddFragment(bloodlordEmbraceFragment)
        else
            HUD_UI_SCENE:RemoveFragment(bloodlordEmbraceFragment)
            HUD_SCENE:RemoveFragment(bloodlordEmbraceFragment)
        end
    end
end

function Block.ResetBloodlordEmbraceState()
    bloodlordEmbraceTargetUnitId = 0
    if Block.bloodlordGui then
        -- Stop flicker effect for inactive state
        FLICKER_EFFECT:UnregisterControl(Block.bloodlordGui.icon)

        -- Reset to inactive state
        Block.bloodlordGui.icon:SetAlpha(BLOCK_INDICATOR_INACTIVE_ALPHA)
        Block.bloodlordGui.icon:SetColor(1, 1, 1, BLOCK_INDICATOR_INACTIVE_ALPHA)
        Block.bloodlordGui.border:SetEdgeColor(1, 0, 0, 1)
        Block.bloodlordGui.targetLabel:SetColor(1, 0, 0, 1)
        Block.bloodlordGui.targetLabel:SetText("None")
    end
end

-- ---------------------------------------------------------------------------
-- Debounce
-- ---------------------------------------------------------------------------

function Block.DebounceInventory()
    if debounceInventoryPending then
        return
    end
    debounceInventoryPending = true
    LUIE_callLater(function ()
                       Block.RefreshBlockCost()
                       Block.RefreshBloodlordEmbraceVisibility()
                       debounceInventoryPending = false
                   end, DEBOUNCE_DELAY_MS)
end

function Block.DebounceActionSlots()
    if debounceActionSlotsPending then
        return
    end
    debounceActionSlotsPending = true
    LUIE_callLater(function ()
                       Block.RefreshBlockCost()
                       debounceActionSlotsPending = false
                   end, DEBOUNCE_DELAY_MS)
end

-- ---------------------------------------------------------------------------
-- Update (block indicator + remaining count)
-- ---------------------------------------------------------------------------

function Block.OnBlockUpdate()
    local isSprinting = IsPlayerMoving() and IsShiftKeyDown()
    local isBlocking = IsBlockActive() and not isSprinting
    local inCombat = IsUnitInCombat("player")
    local staminaRegen = GetPlayerStat(inCombat and STAT_STAMINA_REGEN_COMBAT or STAT_STAMINA_REGEN_IDLE, STAT_BONUS_OPTION_APPLY_BONUS)
    local magickaRegen = GetPlayerStat(inCombat and STAT_MAGICKA_REGEN_COMBAT or STAT_MAGICKA_REGEN_IDLE, STAT_BONUS_OPTION_APPLY_BONUS)
    local bothRegen = staminaRegen > 0 and magickaRegen > 0

    if not Block.blockIndicatorTexture then
        return
    end

    Block.blockIndicatorTexture:SetHidden(bothRegen or not isBlocking)

    local sv = CombatInfo.SV.block
    if sv.colorShieldByResource then
        Block.blockIndicatorTexture:SetColor(0, staminaRegen > 0 and 0.5 or 1, magickaRegen > 0 and 0 or 1, 1)
    else
        Block.blockIndicatorTexture:SetColor(1, 1, 1, 1)
    end

    if not Block.remainingBlocksLabel then
        return
    end
    if bothRegen or not sv.showRemainingBlocks then
        Block.remainingBlocksLabel:SetText("")
        Block.remainingBlocksLabel:Clean()
        return
    end
    local powerType = staminaRegen > 0 and COMBAT_MECHANIC_FLAGS_MAGICKA or COMBAT_MECHANIC_FLAGS_STAMINA
    local current, max, effectiveMax = GetUnitPower("player", powerType)
    local numBlocks = (current > 0 and cachedBlockCost > 0) and zo_floor(current / cachedBlockCost) or 0
    Block.remainingBlocksLabel:SetText(tostring(numBlocks))
end

-- ---------------------------------------------------------------------------
-- Event handlers
-- ---------------------------------------------------------------------------

--- - **EVENT_COMBAT_EVENT **
---
--- @param eventId integer
--- @param result ActionResult
--- @param isError boolean
--- @param abilityName string
--- @param abilityGraphic integer
--- @param abilityActionSlotType ActionSlotType
--- @param sourceName string
--- @param sourceType CombatUnitType
--- @param targetName string
--- @param targetType CombatUnitType
--- @param hitValue integer
--- @param powerType CombatMechanicFlags
--- @param damageType DamageType
--- @param log boolean
--- @param sourceUnitId integer
--- @param targetUnitId integer
--- @param abilityId integer
--- @param overflow integer
function Block.OnCombatEvent(eventId, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    local now = GetGameTimeMilliseconds()

    if abilityId == BLOODLORD_EMBRACE_DEBUFF_ABILITY_ID then
        if result == ACTION_RESULT_EFFECT_GAINED and sourceType == COMBAT_UNIT_TYPE_PLAYER then
            bloodlordEmbraceLastApplyTime = now
            bloodlordEmbraceTargetUnitId = targetUnitId
            if Block.bloodlordGui then
                -- Start vampiric flicker effect for active state
                local SPEED_MULTIPLIER = 0.8
                local ALPHA_STRENGTH = 0.3
                local COLOR_STRENGTH = 0.2
                FLICKER_EFFECT:RegisterControl(Block.bloodlordGui.icon, SPEED_MULTIPLIER, ALPHA_STRENGTH, COLOR_STRENGTH)
                FLICKER_EFFECT:SetControlBaseColor(Block.bloodlordGui.icon, ZO_ColorDef:New(1, 0.2, 0.2, 1)) -- Blood red tint

                -- Update border and label colors
                Block.bloodlordGui.border:SetEdgeColor(0, 1, 0, 1)
                Block.bloodlordGui.targetLabel:SetColor(0, 1, 0, 1)
                Block.bloodlordGui.targetLabel:SetText(zo_strformat(SI_UNIT_NAME, targetName))
            end
        elseif result == ACTION_RESULT_EFFECT_FADED and targetUnitId == bloodlordEmbraceTargetUnitId and (now - bloodlordEmbraceLastApplyTime) > BLOODLORD_EMBRACE_EFFECT_FADE_GRACE_MS then
            Block.ResetBloodlordEmbraceState()
        end
    end

    if abilityId == BLOODLORD_EMBRACE_ENERGIZE_ABILITY_ID and result == ACTION_RESULT_POWER_ENERGIZE and targetType == COMBAT_UNIT_TYPE_PLAYER then
        bloodlordEmbraceTotalMagickaReturned = bloodlordEmbraceTotalMagickaReturned + hitValue
        if Block.bloodlordGui and Block.bloodlordGui.magickaLabel then
            Block.bloodlordGui.magickaLabel:SetText(tostring(bloodlordEmbraceTotalMagickaReturned))
        end
    end

    if (result == ACTION_RESULT_DIED or result == ACTION_RESULT_DIED_XP) and targetUnitId == bloodlordEmbraceTargetUnitId then
        Block.ResetBloodlordEmbraceState()
    end
end

--- - **EVENT_PLAYER_COMBAT_STATE **
---
--- @param eventId integer
--- @param inCombat boolean
function Block.OnCombatStateChanged(eventId, inCombat)
    if inCombat then
        bloodlordEmbraceTotalMagickaReturned = 0
        if Block.bloodlordGui and Block.bloodlordGui.magickaLabel then
            Block.bloodlordGui.magickaLabel:SetText("0")
        end
    else
        Block.ResetBloodlordEmbraceState()
    end
end

--- - **EVENT_INVENTORY_SINGLE_SLOT_UPDATE **
---
--- @param eventId integer
--- @param bagId Bag
--- @param slotIndex integer
--- @param isNewItem boolean
--- @param itemSoundCategory ItemUISoundCategory
--- @param inventoryUpdateReason integer
--- @param stackCountChange integer
--- @param triggeredByCharacterName string?
--- @param triggeredByDisplayName string?
--- @param isLastUpdateForMessage boolean
--- @param bonusDropSource BonusDropSource
function Block.OnInventorySlotUpdate(eventId, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
    if bagId ~= BAG_WORN or inventoryUpdateReason ~= 0 then
        return
    end
    if EQUIP_SLOT_EXCLUDE_FROM_ITEM_UPDATE[slotIndex] then
        return
    end
    Block.DebounceInventory()
end

--- - **EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED **
---
--- @param eventId integer
--- @param didActiveHotbarChange boolean
--- @param shouldUpdateAbilityAssignments boolean
--- @param activeHotbarCategory HotBarCategory
function Block.OnActiveHotbarUpdated(eventId, didActiveHotbarChange, shouldUpdateAbilityAssignments, activeHotbarCategory)
    if didActiveHotbarChange then
        Block.DebounceActionSlots()
    end
end

function Block.OnActionSlotUpdated(hotbarCategory, actionSlotIndex, isChangedByPlayer)
    if isChangedByPlayer then
        Block.DebounceActionSlots()
    end
end

-- ---------------------------------------------------------------------------
-- UI construction
-- ---------------------------------------------------------------------------

function Block.RegisterUpdateLoop()
    eventManager:UnregisterForUpdate(moduleName .. "Update")
    local intervalMs = CombatInfo.SV.block.updateIntervalMs or CombatInfo.Defaults.block.updateIntervalMs
    eventManager:RegisterForUpdate(moduleName .. "Update", intervalMs, Block.OnBlockUpdate)
end

--- Applies shield texture and default color from settings (full-color vs grey for tinting).
function Block.ApplyBlockShieldTexture()
    if not Block.blockIndicatorTexture then
        return
    end
    local sv = CombatInfo.SV.block
    local useGrey = sv.colorShieldByResource
    Block.blockIndicatorTexture:SetTexture(useGrey and BLOCK_SHIELD_GREY_MEDIA or BLOCK_SHIELD_MEDIA)
    Block.blockIndicatorTexture:SetColor(1, 1, 1, 1)
end

--- Applies saved Bloodlord's Embrace window position from SV
function Block.ApplyBloodlordEmbracePosition()
    if not Block.bloodlordWindow then
        return
    end
    local pos = CombatInfo.SV.block.bloodlordEmbracePosition or CombatInfo.Defaults.block.bloodlordEmbracePosition
    Block.bloodlordWindow:ClearAnchors()
    Block.bloodlordWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, pos.left, pos.top)
end

function Block.ApplyBlockIndicatorFont()
    if not Block.remainingBlocksLabel then
        return
    end
    local font = GetBlockIndicatorFont()
    Block.remainingBlocksLabel:SetFont(font)
    if Block.remainingBlocksShadowLabel then
        Block.remainingBlocksShadowLabel:SetFont(font)
    end
end

function Block.ApplyBloodlordEmbraceFonts()
    if not Block.bloodlordGui then
        return
    end
    local titleFont = GetTitleFont()
    local valueFont = GetValueFont()
    if Block.bloodlordGui.targetTitle then
        Block.bloodlordGui.targetTitle:SetFont(titleFont)
    end
    if Block.bloodlordGui.targetLabel then
        Block.bloodlordGui.targetLabel:SetFont(valueFont)
    end
    if Block.bloodlordGui.magickaTitle then
        Block.bloodlordGui.magickaTitle:SetFont(titleFont)
    end
    if Block.bloodlordGui.magickaLabel then
        Block.bloodlordGui.magickaLabel:SetFont(valueFont)
    end
end

local function CreateBlockIndicatorWindow()
    local win = windowManager:CreateTopLevelWindow(moduleName .. "BlockIndicator")
    win:SetClampedToScreen(true)
    win:ClearAnchors()
    win:SetAnchor(RIGHT, GuiRoot, CENTER, -BLOCK_INDICATOR_SIZE, 0)
    win:SetDimensions(BLOCK_INDICATOR_SIZE, BLOCK_INDICATOR_SIZE)
    win:SetHidden(true)

    local texture = windowManager:CreateControl(moduleName .. "BlockIndicatorTexture", win, CT_TEXTURE)
    texture:ClearAnchors()
    texture:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 0)
    texture:SetDimensions(BLOCK_INDICATOR_SIZE, BLOCK_INDICATOR_SIZE)
    texture:SetHidden(true)
    texture:SetBlendMode(TEX_BLEND_MODE_ADD)
    texture:SetPixelRoundingEnabled(true)
    texture:SetShaderEffectType(SHADER_EFFECT_TYPE_CAUSTIC)
    Block.blockIndicatorTexture = texture
    Block.ApplyBlockShieldTexture()

    local label = windowManager:CreateControlFromVirtual(moduleName .. "BlockIndicatorCount", texture, "ZO_MapBlobName")
    label:ClearAnchors()
    label:SetAnchor(TOPLEFT, texture, TOPLEFT, 1, -2)
    label:SetDimensions(BLOCK_INDICATOR_SIZE, BLOCK_INDICATOR_SIZE)
    label:SetColor(1, 1, 1, 1)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local blockIndicatorFont = GetBlockIndicatorFont()
    label:SetFont(blockIndicatorFont)

    local shadowLabel = label:GetNamedChild("Shadow")
    shadowLabel:SetColor(0, 0, 0, 1)
    shadowLabel:SetFont(blockIndicatorFont)

    blockIndicatorFragment = ZO_HUDFadeSceneFragment:New(win, 0, 0)
    HUD_UI_SCENE:AddFragment(blockIndicatorFragment)
    HUD_SCENE:AddFragment(blockIndicatorFragment)

    Block.blockIndicatorWindow = win
    Block.blockIndicatorTexture = texture
    Block.remainingBlocksLabel = label
    Block.remainingBlocksShadowLabel = shadowLabel
end

local function CreateBloodlordEmbraceAbilityControl(parent, baseName, offsetX, showBorder)
    local ctrl = windowManager:CreateControl(baseName, parent, CT_CONTROL)
    ctrl:ClearAnchors()
    ctrl:SetAnchor(TOPLEFT, parent, TOPLEFT, offsetX, 0)
    ctrl:SetDimensions(BLOODLORD_EMBRACE_ABILITY_ICON_SIZE, BLOODLORD_EMBRACE_ABILITY_ICON_SIZE)
    ctrl:SetHidden(false)

    local border = windowManager:CreateControl(baseName .. "Border", ctrl, CT_BACKDROP)
    border:ClearAnchors()
    border:SetAnchor(TOPLEFT, ctrl, TOPLEFT, BLOODLORD_EMBRACE_BORDER_INSET, BLOODLORD_EMBRACE_BORDER_INSET)
    border:SetDimensions(BLOODLORD_EMBRACE_BORDER_SIZE, BLOODLORD_EMBRACE_BORDER_SIZE)
    border:SetEdgeColor(1, 0, 0, 1)
    border:SetCenterColor(0, 0, 0, 0)
    border:SetEdgeTexture("", 2, 2, 4, 0)
    border:SetHidden(not showBorder)

    local back = windowManager:CreateControl(baseName .. "Back", ctrl, CT_BACKDROP)
    back:ClearAnchors()
    back:SetAnchor(TOPLEFT, ctrl, TOPLEFT, 0, 0)
    back:SetDimensions(BLOODLORD_EMBRACE_ABILITY_ICON_SIZE, BLOODLORD_EMBRACE_ABILITY_ICON_SIZE)
    back:SetEdgeColor(0, 0, 0, 0)
    back:SetCenterColor(0, 0, 0, 1)

    local icon = windowManager:CreateControl(baseName .. "Icon", ctrl, CT_TEXTURE)
    local fileName = [[/esoui/art/icons/achievement_u23_qualifiedblooddonor.dds]]
    icon:SetTexture(fileName)
    icon:ClearAnchors()
    icon:SetAnchor(TOPLEFT, ctrl, TOPLEFT, 0, 0)
    icon:SetAlpha(BLOCK_INDICATOR_INACTIVE_ALPHA)
    icon:SetDimensions(BLOODLORD_EMBRACE_ABILITY_ICON_SIZE, BLOODLORD_EMBRACE_ABILITY_ICON_SIZE)

    return { ctrl = ctrl, icon = icon, border = border }
end

local function CreateBloodlordEmbracePanel(parent, baseName, offsetX, offsetY, titleText, valueText, valueR, valueG, valueB)
    local titleFont = GetTitleFont()
    local valueFont = GetValueFont()
    local ctrl = windowManager:CreateControl(baseName, parent, CT_CONTROL)
    ctrl:ClearAnchors()
    ctrl:SetAnchor(TOPLEFT, parent, TOPLEFT, offsetX, offsetY)
    ctrl:SetDimensions(PANEL_WIDTH, PANEL_HEIGHT)
    ctrl:SetHidden(false)

    local back = windowManager:CreateControl(baseName .. "Back", ctrl, CT_BACKDROP)
    back:ClearAnchors()
    back:SetAnchor(TOPLEFT, ctrl, TOPLEFT, 0, 0)
    back:SetDimensions(PANEL_WIDTH, PANEL_HEIGHT)
    back:SetEdgeColor(0, 0, 0, 0)
    back:SetCenterColor(0, 0, 0, 0.5)

    local title = windowManager:CreateControl(baseName .. "Title", ctrl, CT_LABEL)
    title:ClearAnchors()
    title:SetAnchor(TOPLEFT, ctrl, TOPLEFT, PANEL_PADDING, 1)
    title:SetDimensions(PANEL_WIDTH - 2 * PANEL_PADDING, PANEL_HEIGHT - 1)
    title:SetColor(1, 1, 1, 1)
    title:SetFont(titleFont)
    title:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
    title:SetVerticalAlignment(TEXT_ALIGN_TOP)
    title:SetText(titleText)

    local label = windowManager:CreateControl(baseName .. "Label", ctrl, CT_LABEL)
    label:ClearAnchors()
    label:SetAnchor(TOPLEFT, ctrl, TOPLEFT, PANEL_PADDING, 0)
    label:SetDimensions(PANEL_WIDTH - 2 * PANEL_PADDING, PANEL_HEIGHT)
    label:SetColor(valueR, valueG, valueB, 1)
    label:SetFont(valueFont)
    label:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
    label:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    label:SetText(valueText)

    return { ctrl = ctrl, title = title, label = label }
end

local function CreateBloodlordEmbraceWindow()
    local pos = CombatInfo.SV.block.bloodlordEmbracePosition or CombatInfo.Defaults.block.bloodlordEmbracePosition

    local win = windowManager:CreateTopLevelWindow(moduleName .. "BloodlordEmbrace")
    win:SetExcludeFromFlexbox(true)
    win:SetClampedToScreen(true)
    win:SetDimensions(BLOODLORD_EMBRACE_WINDOW_WIDTH, BLOODLORD_EMBRACE_WINDOW_HEIGHT)
    win:ClearAnchors()
    win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, pos.left, pos.top)
    win:SetMouseEnabled(true)
    win:SetMovable(true)
    win:SetHidden(true)

    win:SetHandler("OnMoveStop", function (control)
        local x, y = control:GetScreenRect()
        CombatInfo.SV.block.bloodlordEmbracePosition = { left = x, top = y }
    end)

    local rootFlex = UI:FlexControl(win, "fill", "inherit", false, { container = { direction = FLEX_DIRECTION_ROW } })

    local abilityGui = CreateBloodlordEmbraceAbilityControl(rootFlex, moduleName .. "BloodlordIcon", 0, true)
    abilityGui.ctrl:SetFlexBasis(BLOODLORD_EMBRACE_ABILITY_ICON_SIZE)
    abilityGui.ctrl:SetFlexShrink(0)
    abilityGui.ctrl:SetFlexMargins(0, 0, BLOODLORD_EMBRACE_GAP, 0)

    local columnFlex = UI:FlexControl(rootFlex, nil, nil, false,
                                      {
                                          container = { direction = FLEX_DIRECTION_COLUMN, itemAlignment = FLEX_ALIGNMENT_FLEX_START },
                                          item = { basis = PANEL_WIDTH, shrink = 0 },
                                      })

    local targetPanel = CreateBloodlordEmbracePanel(columnFlex, moduleName .. "BloodlordTarget", 0, 0, "Current Target", "None", 1, 0, 0)
    targetPanel.ctrl:SetFlexBasis(PANEL_HEIGHT)
    targetPanel.ctrl:SetFlexShrink(0)
    targetPanel.ctrl:SetFlexMargins(0, 0, 0, BLOODLORD_EMBRACE_PANEL_GAP)

    local magickaPanel = CreateBloodlordEmbracePanel(columnFlex, moduleName .. "BloodlordMagicka", 0, 0, "Magicka returned", "0", 0.5, 0.5, 1)
    magickaPanel.ctrl:SetFlexBasis(PANEL_HEIGHT)
    magickaPanel.ctrl:SetFlexShrink(0)
    magickaPanel.ctrl:SetFlexMargins(0, 0, 0, 0)

    bloodlordEmbraceFragment = ZO_HUDFadeSceneFragment:New(win, 0, 0)
    -- Fragment added/removed by RefreshBloodlordEmbraceVisibility when set is equipped

    Block.bloodlordWindow = win
    Block.bloodlordGui =
    {
        icon = abilityGui.icon,
        border = abilityGui.border,
        targetTitle = targetPanel.title,
        targetLabel = targetPanel.label,
        magickaTitle = magickaPanel.title,
        magickaLabel = magickaPanel.label,
    }
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------

function Block.OnPlayerActivated()
    eventManager:UnregisterForEvent(moduleName .. "Activated", EVENT_PLAYER_ACTIVATED)

    Block.RefreshBlockCost()
    Block.RefreshBloodlordEmbraceVisibility()

    ACTION_BAR_ASSIGNMENT_MANAGER:RegisterCallback("SlotUpdated", Block.OnActionSlotUpdated)

    eventManager:RegisterForEvent(moduleName .. "CombatDebuff", EVENT_COMBAT_EVENT, Block.OnCombatEvent)
    eventManager:AddFilterForEvent(moduleName .. "CombatDebuff", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, BLOODLORD_EMBRACE_DEBUFF_ABILITY_ID)

    eventManager:RegisterForEvent(moduleName .. "CombatEnergize", EVENT_COMBAT_EVENT, Block.OnCombatEvent)
    eventManager:AddFilterForEvent(moduleName .. "CombatEnergize", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, BLOODLORD_EMBRACE_ENERGIZE_ABILITY_ID)

    eventManager:RegisterForEvent(moduleName .. "CombatDied", EVENT_COMBAT_EVENT, Block.OnCombatEvent)
    eventManager:AddFilterForEvent(moduleName .. "CombatDied", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED)
    eventManager:RegisterForEvent(moduleName .. "CombatDiedXP", EVENT_COMBAT_EVENT, Block.OnCombatEvent)
    eventManager:AddFilterForEvent(moduleName .. "CombatDiedXP", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED_XP)

    eventManager:RegisterForEvent(moduleName .. "CombatState", EVENT_PLAYER_COMBAT_STATE, Block.OnCombatStateChanged)
    eventManager:RegisterForEvent(moduleName .. "InventorySlot", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, Block.OnInventorySlotUpdate)
    eventManager:RegisterForEvent(moduleName .. "HotbarUpdated", EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, Block.OnActiveHotbarUpdated)
    eventManager:AddFilterForEvent(moduleName .. "HotbarUpdated", EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, REGISTER_FILTER_UNIT_TAG, "player")

    Block.RegisterUpdateLoop()
end

function Block.Initialize()
    if not CombatInfo.Enabled then
        return
    end
    if not CombatInfo.SV.block.enabled then
        return
    end
    CreateBlockIndicatorWindow()
    CreateBloodlordEmbraceWindow()
    eventManager:RegisterForEvent(moduleName .. "Activated", EVENT_PLAYER_ACTIVATED, Block.OnPlayerActivated)
end
