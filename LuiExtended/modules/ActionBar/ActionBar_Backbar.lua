-- -----------------------------------------------------------------------------
--  LuiExtended — ActionBar backbar (inactive hotbar row, DnD, layout)
--  Distributed under The MIT License (MIT) (see LICENSE file)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.ActionBar
local ActionBar = LUIE.ActionBar
--- @class (partial) LUIE.ActionBar.Backbar
local Backbar = ActionBar.Backbar

local LuiData = LuiData
local Data = LuiData.Data
local Effects = Data.Effects

local GetSlotTrueBoundId = LUIE.GetSlotTrueBoundId
local eventManager = GetEventManager()
local animationManager = GetAnimationManager()
local moduleName = ActionBar.ModuleName

local BAR_INDEX_START = ActionBar.BAR_INDEX_START
local BAR_INDEX_END = ActionBar.BAR_INDEX_END
local BACKBAR_INDEX_END = ActionBar.BACKBAR_INDEX_END
local BACKBAR_INDEX_OFFSET = ActionBar.BACKBAR_INDEX_OFFSET
local OAKENSOUL_RING_ITEM_ID = ActionBar.OAKENSOUL_RING_ITEM_ID
local DROP_CALLOUT_VALIDITY_BY_ACTION_TYPE = ActionBar.DROP_CALLOUT_VALIDITY_BY_ACTION_TYPE
local GAMEPAD_CONSTANTS = ActionBar.GAMEPAD_CONSTANTS
local KEYBOARD_CONSTANTS = ActionBar.KEYBOARD_CONSTANTS
local ACTION_BUTTON_BORDERS = ActionBar.ACTION_BUTTON_BORDERS
local BOUNCE_DURATION_MS = ActionBar.BOUNCE_DURATION_MS

--- @type {[integer]:ActionButton}
local g_backbarButtons = {}
local g_backbarContainer

local function GetActionBarControl()
    return ZO_ActionBar1
end

local function GetPlatformConstants()
    return IsInGamepadPreferredMode() and GAMEPAD_CONSTANTS or KEYBOARD_CONSTANTS
end

local function GetInactiveHotbarCategory(activeHotbarCategory)
    if activeHotbarCategory == HOTBAR_CATEGORY_PRIMARY then
        return HOTBAR_CATEGORY_BACKUP
    end
    if activeHotbarCategory == HOTBAR_CATEGORY_BACKUP then
        return HOTBAR_CATEGORY_PRIMARY
    end
    if ActionBar.GetHeldWeaponPair() == ACTIVE_WEAPON_PAIR_BACKUP then
        return HOTBAR_CATEGORY_PRIMARY
    end
    return HOTBAR_CATEGORY_BACKUP
end
--- Create a single backbar ActionButton (mirrors ESO ActionBar.lua MakeActionButton pattern).
--- @param slotNum integer
--- @param parent Control
--- @param template string
--- @param hotbarCategory number
--- @return integer|ZO_InitializingObject|ActionButton
function Backbar.MakeActionButton(slotNum, parent, template, hotbarCategory)
    local button = ActionButton:New(slotNum, ACTION_BUTTON_TYPE_VISIBLE, parent, template, hotbarCategory)
    return button
end

--- @return boolean
function Backbar.OakensoulEquipped()
    return GetItemLinkItemId(GetItemLink(BAG_WORN, EQUIP_SLOT_RING1, LINK_STYLE_DEFAULT)) == OAKENSOUL_RING_ITEM_ID
        or GetItemLinkItemId(GetItemLink(BAG_WORN, EQUIP_SLOT_RING2, LINK_STYLE_DEFAULT)) == OAKENSOUL_RING_ITEM_ID
end

local function AttemptPlacement(slotNum, hotbarCategory)
    CallSecureProtected("PlaceInActionBar", slotNum, hotbarCategory)
end

local function AttemptPickup(slotNum, hotbarCategory)
    if ZO_ActionBar_AreActionBarsLocked() then
        return
    end
    CallSecureProtected("PickupAction", slotNum, hotbarCategory)
    ClearTooltip(AbilityTooltip)
end

-- Update actionId for backbar buttons
function Backbar._updateButtonActionIds()
    local inactiveHotbarCategory = GetInactiveHotbarCategory(ActionBar.GetHotbarCategory())
    for i = BAR_INDEX_START + BACKBAR_INDEX_OFFSET, BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET do
        local button = g_backbarButtons[i]
        if button and button.button then
            button.button.actionId = GetSlotTrueBoundId(i - BACKBAR_INDEX_OFFSET, inactiveHotbarCategory)
            button.button.hotbarCategory = inactiveHotbarCategory
        end
    end
end

--- Hide drop callouts on main bar and backbar (mirrors ZOS ActionBar drop callout behavior)
function Backbar.HideAllAbilityActionButtonDropCallouts()
    for i = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1, ACTION_BAR_ULTIMATE_SLOT_INDEX + 1 do
        local actionButton = ZO_ActionBar_GetButton(i)
        if actionButton and actionButton.slot then
            local callout = actionButton.slot:GetNamedChild("DropCallout")
            if callout then
                callout:SetHidden(true)
            end
        end
    end
    if ActionBar.SV.BarShowBack and g_backbarContainer and not g_backbarContainer:IsHidden() then
        for i = BAR_INDEX_START, BACKBAR_INDEX_END do
            local backbarButton = g_backbarButtons[i + BACKBAR_INDEX_OFFSET]
            if backbarButton and backbarButton.slot then
                local callout = backbarButton.slot:GetNamedChild("DropCallout")
                if callout then
                    callout:SetHidden(true)
                end
            end
        end
    end
end

--- Show drop callouts with validity coloring when dragging ability (white=valid, red=invalid)
--- @param actionType number
--- @param actionValue number abilityId or craftedAbilityId
function Backbar.ShowAppropriateAbilityActionButtonDropCallouts(actionType, actionValue)
    local validityFunction = DROP_CALLOUT_VALIDITY_BY_ACTION_TYPE[actionType]
    if not validityFunction then
        return
    end

    Backbar.HideAllAbilityActionButtonDropCallouts()

    -- Main bar
    for i = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1, ACTION_BAR_ULTIMATE_SLOT_INDEX + 1 do
        local actionButton = ZO_ActionBar_GetButton(i)
        if actionButton and actionButton.slot then
            local callout = actionButton.slot:GetNamedChild("DropCallout")
            if callout then
                local isValid = validityFunction(actionValue, i)
                callout:SetColor(1, isValid and 1 or 0, isValid and 1 or 0, 1)
                callout:SetHidden(false)
            end
        end
    end

    if ActionBar.SV.BarShowBack and g_backbarContainer and not g_backbarContainer:IsHidden() then
        for i = BAR_INDEX_START, BACKBAR_INDEX_END do
            local esoSlotIndex = i - 1
            local backbarButton = g_backbarButtons[i + BACKBAR_INDEX_OFFSET]
            if backbarButton and backbarButton.slot then
                local callout = backbarButton.slot:GetNamedChild("DropCallout")
                if callout then
                    local isValid = validityFunction(actionValue, esoSlotIndex)
                    callout:SetColor(1, isValid and 1 or 0, isValid and 1 or 0, 1)
                    callout:SetHidden(false)
                end
            end
        end
    end
end

--- Setup drag/drop handlers for backbar
--- @param button ActionButton
function Backbar.SetupBackbarDragDropHandlers(button)
    local dragButtonControl = button.button
    if not dragButtonControl then return end

    local function getActionBarSlotAndCategory()
        local slotNum = button.slot.slotNum
        local actionBarSlotIndex = slotNum - BACKBAR_INDEX_OFFSET
        local hotbarCategory = GetInactiveHotbarCategory(ActionBar.GetHotbarCategory())
        return actionBarSlotIndex, hotbarCategory
    end

    dragButtonControl:SetHandler("OnReceiveDrag", function (control, mouseButton)
        if GetCursorContentType() == MOUSE_CONTENT_EMPTY then return end
        local actionBarSlotIndex, hotbarCategory = getActionBarSlotAndCategory()
        AttemptPlacement(actionBarSlotIndex, hotbarCategory)
    end)

    dragButtonControl:SetHandler("OnDragStart", function (control, mouseButton)
        if GetCursorContentType() ~= MOUSE_CONTENT_EMPTY then return false end
        if ZO_ActionBar_AreActionBarsLocked() then return false end
        local actionBarSlotIndex, hotbarCategory = getActionBarSlotAndCategory()
        AttemptPickup(actionBarSlotIndex, hotbarCategory)
        ClearTooltip(AbilityTooltip)
        return true
    end)

    -- Tooltip on hover
    dragButtonControl:SetHandler("OnMouseEnter", function ()
        if IsInGamepadPreferredMode() then return end
        local actionBarSlotIndex, hotbarCategory = getActionBarSlotAndCategory()
        if GetSlotType(actionBarSlotIndex, hotbarCategory) ~= ACTION_TYPE_NOTHING then
            InitializeTooltip(AbilityTooltip, dragButtonControl, BOTTOM, 0, -5, TOP)
            AbilityTooltip:SetAbilityId(GetSlotTrueBoundId(actionBarSlotIndex, hotbarCategory))
        end
    end)

    dragButtonControl:SetHandler("OnMouseExit", function ()
        ClearTooltip(AbilityTooltip)
    end)

    -- Right-click context menu (Clear Slot)
    dragButtonControl:SetHandler("OnClicked", function (control, mouseButton)
        local actionBarSlotIndex, hotbarCategory = getActionBarSlotAndCategory()
        if mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
            if IsSlotUsed(actionBarSlotIndex, hotbarCategory) and not IsActionSlotRestricted(actionBarSlotIndex, hotbarCategory) then
                ClearMenu()
                AddMenuItem(GetString(SI_ABILITY_ACTION_CLEAR_SLOT), function ()
                    local slotType = GetSlotType(actionBarSlotIndex, hotbarCategory)
                    if slotType == ACTION_TYPE_ITEM then
                        local soundCategory = GetSlotItemSound(actionBarSlotIndex, hotbarCategory)
                        if soundCategory ~= ITEM_SOUND_CATEGORY_NONE then
                            PlayItemSound(soundCategory, ITEM_SOUND_ACTION_UNEQUIP)
                        end
                    end
                    CallSecureProtected("ClearSlot", actionBarSlotIndex, hotbarCategory)
                end)
                ShowMenu(control)
            end
        elseif mouseButton == MOUSE_BUTTON_INDEX_LEFT and GetCursorContentType() ~= MOUSE_CONTENT_EMPTY then
            AttemptPlacement(actionBarSlotIndex, hotbarCategory)
        end
    end)
end

function Backbar.SetupBackBarIcons(button, flip)
    -- Setup icons for backbar
    local hotbarCategory = ActionBar.GetHotbarCategory() == HOTBAR_CATEGORY_BACKUP and HOTBAR_CATEGORY_PRIMARY or HOTBAR_CATEGORY_BACKUP
    local slotNum = button.slot.slotNum
    local slotId = GetSlotTrueBoundId(slotNum - BACKBAR_INDEX_OFFSET, hotbarCategory)
    local physicalSlotNum = slotNum - BACKBAR_INDEX_OFFSET

    if GetSlotType(physicalSlotNum, hotbarCategory) == ACTION_TYPE_NOTHING then
        button.icon:SetHidden(true)
    else
        -- Check backbar weapon type
        local weaponSlot = ActionBar.GetHotbarCategory() == HOTBAR_CATEGORY_BACKUP and 4 or 20
        local weaponType = GetItemWeaponType(BAG_WORN, weaponSlot)

        -- Fix tracking for Staff Backbar
        if weaponType == WEAPONTYPE_FIRE_STAFF or weaponType == WEAPONTYPE_FROST_STAFF or weaponType == WEAPONTYPE_LIGHTNING_STAFF then
            if Effects.BarHighlightDestroFix[slotId] and Effects.BarHighlightDestroFix[slotId][weaponType] then
                slotId = Effects.BarHighlightDestroFix[slotId][weaponType]
            end
        end

        -- Special case for certain skills, so the proc icon doesn't get stuck.
        local specialCases =
        {
            [114716] = 46324, -- Crystal Fragments --> Crystal Fragments
            [20824] = 20816,  -- Power Lash --> Flame Lash
            [35445] = 35441,  -- Shadow Image Teleport --> Shadow Image
            [126659] = 38910, -- Flying Blade --> Flying Blade
        }

        if specialCases[slotId] then
            slotId = specialCases[slotId]
        end

        -- Check if something is in this action bar slot and if not hide the slot
        if slotId > 0 then
            button.icon:SetTexture(GetAbilityIcon(slotId))
            button.icon:SetHidden(false)
        else
            button.icon:SetHidden(true)
        end
    end

    if flip then
        local desaturate = true

        local customToggle = ActionBar.GetCustomToggleControl(slotNum)
        if customToggle then
            desaturate = false

            if customToggle:IsHidden() then
                Backbar.BackbarHideSlot(slotNum)
                desaturate = true
            end
        end

        Backbar.ToggleBackbarSaturation(slotNum, desaturate)
    end
end

function Backbar.BackbarHideSlot(slotNum)
    if ActionBar.SV.BarHideUnused then
        if g_backbarButtons[slotNum] then
            g_backbarButtons[slotNum].slot:SetHidden(true)
        end
    end
end

-- -----------------------------------------------------------------------------
--- Shows the backbar slot control when BarShowBack is enabled.
--- @param slotNum integer
function Backbar.BackbarShowSlot(slotNum)
    -- Unhide the slot
    if ActionBar.SV.BarShowBack then
        if g_backbarButtons[slotNum] then
            g_backbarButtons[slotNum].slot:SetHidden(false)
        end
    end
end

-- -----------------------------------------------------------------------------
--- Sets backbar slot icon desaturation/dark unused state per SV.
--- @param slotNum integer
--- @param desaturate boolean
function Backbar.ToggleBackbarSaturation(slotNum, desaturate)
    local button = g_backbarButtons[slotNum]
    if ActionBar.SV.BarDarkUnused then
        ZO_ActionSlot_SetUnusable(button.icon, desaturate, false)
    end
    if ActionBar.SV.BarDesaturateUnused then
        local saturation = desaturate and 1 or 0
        button.icon:SetDesaturation(saturation)
    end
end

-- -----------------------------------------------------------------------------

local function ApplyStyle(self, template)
    WINDOW_MANAGER:ApplyTemplateToControl(self.slot, template)

    local isGamepad = IsInGamepadPreferredMode()
    self.button:SetNormalTexture(isGamepad and "" or ACTION_BUTTON_BORDERS.normal)
    self.button:SetPressedTexture(isGamepad and "" or ACTION_BUTTON_BORDERS.mouseDown)
    self.countText:SetFont(isGamepad and "ZoFontGamepadBold27" or "ZoFontGameShadow")
    self:ApplySwapAnimationStyle()

    if ZO_ActionBar_IsUltimateSlot(self:GetSlot(), self:GetHotbarCategory()) then
        local decoration = self.slot:GetNamedChild("Decoration")
        if decoration then
            decoration:SetHidden(isGamepad)
        end
    end

    if self.showingCooldown then
        self.cooldown:SetHidden(isGamepad)

        if isGamepad then
            local slotNum = self:GetSlot()
            local hotbarCategory = self:GetHotbarCategory()
            local remain = GetSlotCooldownInfo(slotNum, hotbarCategory)
            self:PlayAbilityUsedBounce(BOUNCE_DURATION_MS + remain)

            if not self.itemQtyFailure then
                self.icon:SetDesaturation(0)
            end
        else
            self:ResetBounceAnimation()
        end
    else
        self:ResetBounceAnimation()
    end

    self:SetCooldownEdgeState(self.showingCooldown)
    self:UpdateUsable()
end

-- Called on initialization and when swapping in and out of Gamepad mode
--- Applies platform style (keyboard/gamepad) to backbar button layout and anchors.
function Backbar.BackbarSetupTemplate()
    local style = GetPlatformConstants()
    local weaponSwapControl = style.weaponSwapControl

    -- Set positions for new buttons, modified from actionbar.lua - function ApplyStyle(style) )
    local lastButton
    local buttonTemplate = ZO_GetPlatformTemplate("ZO_ActionButton")
    for i = BAR_INDEX_START, BAR_INDEX_END do
        -- Get our backbar button
        local targetButton = g_backbarButtons[i + BACKBAR_INDEX_OFFSET]

        -- Normal slots
        if i > 2 and i < 8 then
            local anchorTarget = lastButton and lastButton.slot
            if not lastButton then
                anchorTarget = weaponSwapControl
            end
            targetButton:ApplyAnchor(anchorTarget, style.abilitySlotOffsetX)
            ApplyStyle(targetButton, buttonTemplate)
        end

        lastButton = targetButton
    end

    -- Anchor the backbar to the normal action bar with spacing
    local offsetY = GetActionBarControl():GetHeight() * style.backbarHeightMultiplier
    local finalOffset = -(offsetY * style.backbarOffsetMultiplier)
    local ActionButton3 = GetControl("ActionButton3")
    local ActionButton53 = GetControl("ActionButton53")
    if ActionButton53 then
        ActionButton53:ClearAnchors()
        ActionButton53:SetAnchor(CENTER, ActionButton3, CENTER, 0, finalOffset)
    end

    ActionBar.RefreshCompanionQuickslotAnchors()
    ActionBar.ApplyDisplayAlpha()
end

-- -----------------------------------------------------------------------------
-- Called from the menu and on init
--- Shows/hides backbar container and slots per SV (BarShowBack, BarHideUnused, BarDarkUnused, etc.).
function Backbar.BackbarToggleSettings()
    -- If BarShowBack is on, check for bar-swap disablers - keep backbar hidden while active
    if ActionBar.SV.BarShowBack and g_backbarContainer then
        if GetUnitLevel("player") < GetWeaponSwapUnlockedLevel() then
            g_backbarContainer:SetHidden(true)
            return
        elseif Backbar.OakensoulEquipped() then
            g_backbarContainer:SetHidden(true)
            return
        end
        for i = 1, GetNumBuffs("player") do
            local _, _, _, _, _, _, _, _, abilityType = GetUnitBuffInfo("player", i)
            if abilityType == ABILITY_TYPE_SETHOTBAR then
                g_backbarContainer:SetHidden(true)
                return
            end
        end
    end

    if g_backbarContainer then
        g_backbarContainer:SetHidden(false)
    end

    for i = BAR_INDEX_START, BACKBAR_INDEX_END do
        -- Get our backbar button
        local targetButton = g_backbarButtons[i + BACKBAR_INDEX_OFFSET]

        if ActionBar.SV.BarShowBack and not ActionBar.SV.BarHideUnused then
            targetButton.slot:SetHidden(false)
        end
        ZO_ActionSlot_SetUnusable(targetButton.icon, ActionBar.SV.BarDarkUnused, false)
        local saturation = ActionBar.SV.BarDesaturateUnused and 1 or 0
        targetButton.icon:SetDesaturation(saturation)

        if ActionBar.SV.BarHideUnused or not ActionBar.SV.BarShowBack then
            targetButton.slot:SetHidden(true)
        end
    end
end

function Backbar.CreateUI()
    local actionBarParent = GetActionBarControl()
    local backbarContainerControl = actionBarParent:CreateControl("LUIE_Backbar", CT_CONTROL)
    backbarContainerControl:SetParent(actionBarParent)
    g_backbarContainer = backbarContainerControl

    for i = BAR_INDEX_START + BACKBAR_INDEX_OFFSET, BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET do
        local button = Backbar.MakeActionButton(i, backbarContainerControl, "ZO_ActionButton", HOTBAR_CATEGORY_BACKUP)
        ActionBar.SetupBackbarButtonAnimations(button)
        Backbar.SetupBackbarDragDropHandlers(button)
        Backbar.UpdateButtonActionIds()
        g_backbarButtons[i] = button
    end

    Backbar.BackbarSetupTemplate()
    Backbar.BackbarToggleSettings()
end

function Backbar.RegisterPlatformStyle()
    ZO_PlatformStyle:New(Backbar.BackbarSetupTemplate, KEYBOARD_CONSTANTS, GAMEPAD_CONSTANTS)
end

function Backbar.RegisterEvents()
    eventManager:RegisterForEvent(moduleName .. "OakensoulBackbar", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function (_, bagId, slotIndex)
        if ActionBar.SV.BarShowBack and bagId == BAG_WORN and (slotIndex == EQUIP_SLOT_RING1 or slotIndex == EQUIP_SLOT_RING2) then
            Backbar.BackbarToggleSettings()
        end
    end)
    eventManager:AddFilterForEvent(moduleName .. "OakensoulBackbar", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
    eventManager:RegisterForEvent(moduleName .. "wolf", EVENT_WEREWOLF_STATE_CHANGED, function (_, werewolf)
        if g_backbarContainer then
            g_backbarContainer:SetHidden(werewolf)
        end
    end)
    eventManager:RegisterForEvent(moduleName, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, Backbar.BackbarToggleSettings)
end

function Backbar.GetButton(slotNum)
    return g_backbarButtons[slotNum]
end

function Backbar.GetContainer()
    return g_backbarContainer
end

function Backbar.GetButtons()
    return g_backbarButtons
end

function Backbar.UpdateButtonActionIds()
    Backbar._updateButtonActionIds()
end

function Backbar.OnPlayerActivatedScan()
    if not ActionBar.SV.BarShowBack or not g_backbarContainer then
        return
    end
    if GetUnitLevel("player") < GetWeaponSwapUnlockedLevel() then
        g_backbarContainer:SetHidden(true)
    elseif Backbar.OakensoulEquipped() then
        g_backbarContainer:SetHidden(true)
    else
        for i = 1, GetNumBuffs("player") do
            local _, _, _, _, _, _, _, _, abilityType = GetUnitBuffInfo("player", i)
            if abilityType == ABILITY_TYPE_SETHOTBAR then
                g_backbarContainer:SetHidden(true)
                break
            end
        end
    end
end

function Backbar.OnSetHotbarEffect(changeType)
    if not ActionBar.SV.BarShowBack then
        return false
    end
    if changeType == EFFECT_RESULT_GAINED then
        if g_backbarContainer then
            g_backbarContainer:SetHidden(true)
        end
    elseif changeType == EFFECT_RESULT_FADED then
        if g_backbarContainer then
            g_backbarContainer:SetHidden(false)
        end
        Backbar.BackbarToggleSettings()
    end
    return true
end

local forward =
{
    "SetupBackBarIcons", "BackbarHideSlot", "BackbarShowSlot", "ToggleBackbarSaturation",
    "BackbarSetupTemplate", "BackbarToggleSettings",
    "HideAllAbilityActionButtonDropCallouts", "ShowAppropriateAbilityActionButtonDropCallouts",
    "OakensoulEquipped",
}
for _, name in ipairs(forward) do
    ActionBar[name] = Backbar[name]
end
