-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- Block indicator, remaining-block count, and Bloodlord's Embrace tracker.
--- @class (partial) LUIE.CombatInfo.Block

local LUIE = LUIE
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
local BLOCK_INDICATOR_SIZE = 48
local BLOCK_INDICATOR_INACTIVE_ALPHA = 0.3
local DEBOUNCE_DELAY_MS = 500
local BLOODLORD_EMBRACE_DEBUFF_ABILITY_ID = 139903
local BLOODLORD_EMBRACE_ENERGIZE_ABILITY_ID = 139914
local BLOODLORD_EMBRACE_EFFECT_FADE_GRACE_MS = 200
local BLOODLORD_EMBRACE_MIN_SET_PIECES = 1
local BLOODLORD_EMBRACE_ABILITY_ICON_SIZE = 50
local BLOODLORD_EMBRACE_BORDER_INSET = -6
local BLOODLORD_EMBRACE_BORDER_SIZE = 62
local PANEL_WIDTH = 130
local PANEL_HEIGHT = 30
local PANEL_PADDING = 5
local BLOODLORD_EMBRACE_WINDOW_SIZE = 50
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

    local activeWeaponPair = GetActiveWeaponPairInfo()
    local offHandSlot = (activeWeaponPair == 1) and EQUIP_SLOT_OFF_HAND or EQUIP_SLOT_BACKUP_OFF
    local mainHandSlot = (activeWeaponPair == 1) and EQUIP_SLOT_MAIN_HAND or EQUIP_SLOT_BACKUP_MAIN

    -- Sturdy trait (body + active off-hand)
    local sturdyMultiplier = 1
    local bodySlots =
    {
        offHandSlot,
        EQUIP_SLOT_HEAD,
        EQUIP_SLOT_SHOULDERS,
        EQUIP_SLOT_CHEST,
        EQUIP_SLOT_WAIST,
        EQUIP_SLOT_LEGS,
        EQUIP_SLOT_HAND,
        EQUIP_SLOT_FEET,
    }
    for _, slotIndex in pairs(bodySlots) do
        local link = GetItemLink(BAG_WORN, slotIndex, LINK_STYLE_DEFAULT)
        local traitType, traitDesc = GetItemLinkTraitInfo(link)
        if traitType == ITEM_TRAIT_TYPE_ARMOR_STURDY and traitDesc then
            local s1, s2 = string.find(traitDesc, "%d%.%d")
            local value = tonumber(s1 and string.sub(traitDesc, s1, s2) or string.match(traitDesc, "[0-9]+"))
            if value then
                sturdyMultiplier = sturdyMultiplier - value / 100
            end
        end
    end

    -- Bracing enchant (jewelry)
    local bracingFlatReduction = 0
    local jewelrySlots = { EQUIP_SLOT_NECK, EQUIP_SLOT_RING1, EQUIP_SLOT_RING2 }
    for _, slotIndex in pairs(jewelrySlots) do
        local _, enchantName, enchantDesc = GetItemLinkEnchantInfo(GetItemLink(BAG_WORN, slotIndex, LINK_STYLE_DEFAULT))
        if enchantName == "Bracing Enchantment" and enchantDesc then
            local s1, s2 = string.find(enchantDesc, "[0-9]+")
            if s1 then
                local value = tonumber(string.sub(enchantDesc, s1, s2))
                if value then
                    bracingFlatReduction = bracingFlatReduction + value
                end
            end
        end
    end

    -- Weapon passives and slotted ability (Frost Staff or Shield)
    local passiveMultiplier = 1
    local abilityMultiplier = 1
    local mainWeaponType = GetItemWeaponType(BAG_WORN, mainHandSlot)
    local offWeaponType = GetItemWeaponType(BAG_WORN, offHandSlot)

    if mainWeaponType == WEAPONTYPE_FROST_STAFF then
        local upgradeInfo = GetSkillAbilityUpgradeInfo(SKILL_TYPE_WEAPON, 5, 10)
        if upgradeInfo then
            passiveMultiplier = 1 - (upgradeInfo * 18) / 100
        end
    elseif offWeaponType == WEAPONTYPE_SHIELD then
        local upgradeInfo = GetSkillAbilityUpgradeInfo(SKILL_TYPE_WEAPON, 2, 7)
        if upgradeInfo then
            passiveMultiplier = 1 - (upgradeInfo * 18) / 100
        end
        local defensivePostureAbilityId = GetSkillAbilityId(SKILL_TYPE_WEAPON, 2, 4, true)
        local hotbarCategory = GetActiveHotbarCategory()
        for slot = 3, 7 do
            if GetSlotTrueBoundId(slot, hotbarCategory) == defensivePostureAbilityId then
                abilityMultiplier = abilityMultiplier - 8 / 100
            end
        end
    end

    -- Champion points (block cost reduction star)
    local cpSpent = GetNumPointsSpentOnChampionSkill(8) * 0.01
    local cpMultiplier = 1 - zo_floor(0.25 * cpSpent * (2 - cpSpent) * 100) / 100

    cachedBlockCost = zo_floor((BASE_BLOCK_COST * cpMultiplier - bracingFlatReduction) * sturdyMultiplier * passiveMultiplier * abilityMultiplier)
    if cachedBlockCost < 1 then
        cachedBlockCost = 1
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
        Block.bloodlordGui.icon:SetAlpha(BLOCK_INDICATOR_INACTIVE_ALPHA)
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
        return
    end
    local powerType = staminaRegen > 0 and POWERTYPE_MAGICKA or POWERTYPE_STAMINA
    local current, _, _ = GetUnitPower("player", powerType)
    local numBlocks = (current > 0 and cachedBlockCost > 0) and zo_floor(current / cachedBlockCost) or 0
    Block.remainingBlocksLabel:SetText(tostring(numBlocks))
end

-- ---------------------------------------------------------------------------
-- Event handlers
-- ---------------------------------------------------------------------------

function Block.OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    local now = GetGameTimeMilliseconds()

    if abilityId == BLOODLORD_EMBRACE_DEBUFF_ABILITY_ID then
        if result == ACTION_RESULT_EFFECT_GAINED and sourceType == COMBAT_UNIT_TYPE_PLAYER then
            bloodlordEmbraceLastApplyTime = now
            bloodlordEmbraceTargetUnitId = targetUnitId
            if Block.bloodlordGui then
                Block.bloodlordGui.icon:SetAlpha(1)
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

function Block.OnCombatStateChanged(eventCode, inCombat)
    if inCombat then
        bloodlordEmbraceTotalMagickaReturned = 0
        if Block.bloodlordGui and Block.bloodlordGui.magickaLabel then
            Block.bloodlordGui.magickaLabel:SetText("0")
        end
    else
        Block.ResetBloodlordEmbraceState()
    end
end

function Block.OnInventorySlotUpdate(eventCode, bagId, slotId, isNewItem, itemSound, updateReason, countChange)
    if bagId ~= BAG_WORN or updateReason ~= 0 then
        return
    end
    if EQUIP_SLOT_EXCLUDE_FROM_ITEM_UPDATE[slotId] then
        return
    end
    Block.DebounceInventory()
end

function Block.OnActiveHotbarUpdated(eventCode, didChange, shouldUpdate, category)
    if didChange then
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

--- Applies saved Bloodlord's Embrace window position from SV (e.g. after console slider change).
function Block.ApplyBloodlordEmbracePosition()
    if not Block.bloodlordWindow then
        return
    end
    local pos = CombatInfo.SV.block.bloodlordEmbracePosition or CombatInfo.Defaults.block.bloodlordEmbracePosition
    Block.bloodlordWindow:ClearAnchors()
    Block.bloodlordWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, pos.left, pos.top)
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
    Block.blockIndicatorTexture = texture
    Block.ApplyBlockShieldTexture()

    local label = windowManager:CreateControlFromVirtual(moduleName .. "BlockIndicatorCount", texture, "ZO_MapBlobName")
    label:ClearAnchors()
    label:SetAnchor(TOPLEFT, texture, TOPLEFT, 1, -2)
    label:SetDimensions(BLOCK_INDICATOR_SIZE, BLOCK_INDICATOR_SIZE)
    label:SetColor(1, 1, 1, 1)
    label:SetStyleColor(255, 0, 0, 0)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    blockIndicatorFragment = ZO_HUDFadeSceneFragment:New(win, 0, 0)
    HUD_UI_SCENE:AddFragment(blockIndicatorFragment)
    HUD_SCENE:AddFragment(blockIndicatorFragment)

    Block.blockIndicatorWindow = win
    Block.blockIndicatorTexture = texture
    Block.remainingBlocksLabel = label
end

local function CreateBloodlordEmbraceAbilityControl(parent, baseName, offsetX, abilityId, showBorder)
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
    icon:SetTexture(LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SET_BLOODLORDS_EMBRACE_DDS)
    icon:ClearAnchors()
    icon:SetAnchor(TOPLEFT, ctrl, TOPLEFT, 0, 0)
    icon:SetAlpha(BLOCK_INDICATOR_INACTIVE_ALPHA)
    icon:SetDimensions(BLOODLORD_EMBRACE_ABILITY_ICON_SIZE, BLOODLORD_EMBRACE_ABILITY_ICON_SIZE)

    return { ctrl = ctrl, icon = icon, border = border }
end

local function CreateBloodlordEmbracePanel(parent, baseName, offsetX, offsetY, titleText, valueText, valueR, valueG, valueB)
    local font = GetUsableFont()
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
    title:SetFont(font)
    title:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
    title:SetVerticalAlignment(TEXT_ALIGN_TOP)
    title:SetText(titleText)

    local label = windowManager:CreateControl(baseName .. "Label", ctrl, CT_LABEL)
    label:ClearAnchors()
    label:SetAnchor(TOPLEFT, ctrl, TOPLEFT, PANEL_PADDING, 0)
    label:SetDimensions(PANEL_WIDTH - 2 * PANEL_PADDING, PANEL_HEIGHT)
    label:SetColor(valueR, valueG, valueB, 1)
    label:SetFont(font)
    label:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
    label:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    label:SetText(valueText)

    return { ctrl = ctrl, label = label }
end

local function CreateBloodlordEmbraceWindow()
    local pos = CombatInfo.SV.block.bloodlordEmbracePosition or CombatInfo.Defaults.block.bloodlordEmbracePosition

    local win = windowManager:CreateTopLevelWindow(moduleName .. "BloodlordEmbrace")
    win:SetClampedToScreen(true)
    win:SetDimensions(BLOODLORD_EMBRACE_WINDOW_SIZE, BLOODLORD_EMBRACE_WINDOW_SIZE)
    win:ClearAnchors()
    win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, pos.left, pos.top)
    win:SetMouseEnabled(true)
    win:SetMovable(true)
    win:SetHidden(true)

    win:SetHandler("OnMoveStop", function (control)
        local x, y = control:GetScreenRect()
        CombatInfo.SV.block.bloodlordEmbracePosition = { left = x, top = y }
    end)

    local abilityGui = CreateBloodlordEmbraceAbilityControl(win, moduleName .. "BloodlordIcon", 0, BLOODLORD_EMBRACE_DEBUFF_ABILITY_ID, true)
    local targetPanel = CreateBloodlordEmbracePanel(win, moduleName .. "BloodlordTarget", 58, -6, "Current Target", "None", 1, 0, 0)
    local magickaPanel = CreateBloodlordEmbracePanel(win, moduleName .. "BloodlordMagicka", 58, PANEL_HEIGHT - 4, "Magicka returned", "0", 0.5, 0.5, 1)

    bloodlordEmbraceFragment = ZO_HUDFadeSceneFragment:New(win, 0, 0)
    -- Fragment added/removed by RefreshBloodlordEmbraceVisibility when set is equipped

    Block.bloodlordWindow = win
    Block.bloodlordGui =
    {
        icon = abilityGui.icon,
        border = abilityGui.border,
        targetLabel = targetPanel.label,
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
    CreateBlockIndicatorWindow()
    CreateBloodlordEmbraceWindow()
    eventManager:RegisterForEvent(moduleName .. "Activated", EVENT_PLAYER_ACTIVATED, Block.OnPlayerActivated)
end
