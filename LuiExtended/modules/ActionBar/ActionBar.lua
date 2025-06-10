-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local LuiData = LuiData
local Data = LuiData.Data
local Effects = Data.Effects
local printToChat = LUIE.PrintToChat

--- @class (partial) LUIE_ActionBar : ZO_Object
LUIE.ActionBar = ZO_Object:Subclass()
--- @class (partial) LUIE_ActionBar
local ActionBar = LUIE.ActionBar

local moduleName = LUIE.name .. "ActionBar"

ActionBar.Defaults =
{
    staticBars = true,
    showHotkeys = false,
    showHighlight = true,
    showArrow = true,
    arrowColor = { 0, 1, 0, 1 },
    -- Backbar.
    backBarDesaturation = 0.8,
    backBarAlpha = 0.8,
    -- Numbers.
    timerColor = { 1, 1, 1, 1 },
    decimalColor = { 1, 1, 0, 1 },
    zeroColor = { 1, 1, 0, 1 },
    decimalThreshold = 0,
}

ActionBar.SV = {}

local eventManager = GetEventManager()
local windowManager = GetWindowManager()

local ACTIVATED = false -- addon activated and EVENT_PLAYER_ACTIVATED triggered
local strformat = string.format
local time = GetFrameTimeSeconds
local MIN_INDEX = 3                          -- first ability index
local MAX_INDEX = 7                          -- last ability index
local SLOT_INDEX_OFFSET = 20                 -- offset for backbar abilities indices
local SLOT_COUNT = MAX_INDEX - MIN_INDEX + 1 -- total number of slots
local ACTION_BAR = _G["ZO_ActionBar1"]
local abilityConfig = {}                     -- parsed LUIE.ActionBar.abilityConfig
local stacks = {}                            -- ability id => current stack count

-- Backbar buttons.
local buttons = {} --- @type {[integer]:ActionButton}

-- Button overlay controls contain abilities duration, number of stacks and visual effects.
local overlays = {} --- @type {[integer]:object}

-- This is the table of all effects (buffs, debuffs, damage abilities) we need to track, because their respective skills
-- have been slotted: effect_id => effect_info (table, see SlotEffect()).
-- We have to track some effects using EVENT_EFFECT_CHANGED event, because there can be a big delay between using a skill and showing its duration, e.g.
-- for Scalding Rune, which takes 2 seconds to arm, we want to track the fire dot, not the tooltip duration.
-- At the time of writing this comment ZOS function GetActionSlotEffectDuration() didn't provide any information about fire dot duration (there are issues with some other skills too).
local effects = {}

-- Primary bar, back bar or special bar (different special bars have different categories).
local currentHotbarCategory = GetActiveHotbarCategory()

local debug = false -- debug mode

-- if LUIE.IsDevDebugEnabled() then
--     debug = true
-- end

local function dbg(msg, ...)
    if debug then
        printToChat(strformat(msg, ...), true)
    end
end

local GAMEPAD_CONSTANTS =
{
    anchor = ZO_Anchor:New(BOTTOM, GuiRoot, BOTTOM, 0, -25),
    abilitySlotWidth = 64,
    abilitySlotOffsetX = 10,
    buttonTextOffsetY = 60,
    actionBarOffset = -52,
    attributesOffset = -152,
    quickslotOffsetXFromFirstSlot = 5,
    quickslotOffsetXFromCompanionUltimate = 50,
}

local KEYBOARD_CONSTANTS =
{
    anchor = ZO_Anchor:New(BOTTOM, GuiRoot, BOTTOM, 0, 0),
    abilitySlotWidth = 50,
    abilitySlotOffsetX = 2,
    buttonTextOffsetY = 50,
    actionBarOffset = -22,
    attributesOffset = -112,
    quickslotOffsetXFromFirstSlot = 5,
    quickslotOffsetXFromCompanionUltimate = 18,
}

function ActionBar:GetName()
    return moduleName
end

-- Parse ActionBar.abilityConfig for faster access.
function ActionBar:BuildAbilityConfig()
    for id, cfg in pairs(self.abilityConfig) do
        if type(cfg) == "table" then
            abilityConfig[id] = { cfg[1] or id, cfg[2] }
        elseif cfg then
            abilityConfig[id] = { id, type(cfg) == "number" and cfg or nil, true }
        elseif cfg == false then
            abilityConfig[id] = false
        else
            abilityConfig[id] = nil
        end
    end
end

-- Get ActionButton by index.
---
--- @param index integer
--- @return ActionButton
function ActionBar:GetActionButton(index)
    if index > SLOT_INDEX_OFFSET then
        return buttons[index]
    else
        return ZO_ActionBar_GetButton(index)
    end
end

-- Show/hide hotkeys.
function ActionBar:ToggleHotkeys()
    for i = MIN_INDEX, MAX_INDEX do
        ZO_ActionBar_GetButton(i).buttonText:SetHidden(not self.SV.showHotkeys)
    end
end

function ActionBar:IsDebugMode()
    return debug
end

function ActionBar:SetDebugMode(mode)
    assert(type(mode) == "boolean", "Debug mode must be boolean.")
    debug = mode
end

--- @param actionSlotIndex integer
--- @param hotbarCategory HotBarCategory?
--- @return integer actionId
function ActionBar:GetSlotTrueBoundId(actionSlotIndex, hotbarCategory)
    hotbarCategory = hotbarCategory or GetActiveHotbarCategory()
    local actionId = GetSlotBoundId(actionSlotIndex, hotbarCategory)
    local actionType = GetSlotType(actionSlotIndex, hotbarCategory)
    if actionType == ACTION_TYPE_CRAFTED_ABILITY then
        actionId = GetAbilityIdForCraftedAbilityId(actionId)
    end
    return actionId
end

--[[ --- Gets corrected ability ID based on weapon type and special cases
--- @param abilityId integer Original ability ID
--- @param hotbarCategory HotBarCategory Hotbar category
--- @return integer Corrected ability ID
local function GetCorrectedAbilityId(abilityId, hotbarCategory)
    local correctedAbilityId = abilityId

    -- Handle staff weapon types for backbar
    if hotbarCategory == HOTBAR_CATEGORY_BACKUP then
        -- Check backbar weapon type
        local weaponSlot = hotbarCategory == HOTBAR_CATEGORY_BACKUP and 4 or 20
        local weaponType = GetItemWeaponType(BAG_WORN, weaponSlot)

        -- Fix tracking for Staff Backbar
        if weaponType == WEAPONTYPE_FIRE_STAFF or weaponType == WEAPONTYPE_FROST_STAFF or weaponType == WEAPONTYPE_LIGHTNING_STAFF then
            if Effects.BarHighlightDestroFix[abilityId] and Effects.BarHighlightDestroFix[abilityId][weaponType] then
                correctedAbilityId = Effects.BarHighlightDestroFix[abilityId][weaponType]
            end
        end
    end

    -- Special case for certain skills
    local specialCases =
    {
        [114716] = 46324, -- Crystal Fragments --> Crystal Fragments
        [20824] = 20816,  -- Power Lash --> Flame Lash
        [35445] = 35441,  -- Shadow Image Teleport --> Shadow Image
        [126659] = 38910, -- Flying Blade --> Flying Blade
    }

    if specialCases[correctedAbilityId] then
        correctedAbilityId = specialCases[correctedAbilityId]
    end

    return correctedAbilityId
end ]]

---
--- @param alpha number
--- @param desaturation number
function ActionBar:SetBackBarAlphaAndDesaturation(alpha, desaturation)
    if alpha < 0.2 or alpha > 1 then
        alpha = self.Defaults.backBarAlpha
    end
    self.SV.backBarAlpha = alpha
    if desaturation < 0 or desaturation > 1 then
        desaturation = self.Defaults.backBarDesaturation
    end
    self.SV.backBarDesaturation = desaturation
    for _, button in pairs(buttons) do
        button.icon:SetAlpha(self.SV.backBarAlpha)
        button.icon:SetDesaturation(self.SV.backBarDesaturation)
    end
end

-- Move action bar and attributes up a bit.
function ActionBar:AdjustControlsPositions()
    local style = IsInGamepadPreferredMode() and GAMEPAD_CONSTANTS or KEYBOARD_CONSTANTS
    local anchor = style.anchor
    anchor:SetFromControlAnchor(ACTION_BAR)
    anchor:SetOffsets(nil, style.actionBarOffset)
    anchor:Set(ACTION_BAR)

    anchor:SetFromControlAnchor(ZO_PlayerAttribute)
    anchor:SetOffsets(nil, style.attributesOffset)
    anchor:Set(ZO_PlayerAttribute)
end

-- Backbar control initialized.
---
--- @param control LUIE_ActionBar
function ActionBar:OnActionBarInitialized(control)
    -- Set active bar as a parent to make inactive bar show/hide automatically.
    control:SetParent(ACTION_BAR)

    -- Need to adjust it here instead of in ApplyStyle(), otherwise it won't properly work with Azurah.
    self:AdjustControlsPositions()

    -- Create inactive bar buttons.
    for i = MIN_INDEX + SLOT_INDEX_OFFSET, MAX_INDEX + SLOT_INDEX_OFFSET do
        local button = ActionButton:New(i, ACTION_BUTTON_TYPE_VISIBLE, control, "ZO_ActionButton")
        button:SetShowBindingText(false)
        button.icon:SetHidden(true)
        button:SetupBounceAnimation()
        buttons[i] = button
    end
end

-- Create button overlay.
---
--- @param index integer
--- @return object
function ActionBar:CreateOverlay(index)
    local template = ZO_GetPlatformTemplate("LUIE_ActionButtonOverlay")
    local overlay = overlays[index]
    if overlay then
        windowManager:ApplyTemplateToControl(overlay, template)
        overlay:ClearAnchors()
    else
        overlay = windowManager:CreateControlFromVirtual("ActionButtonOverlay", ACTION_BAR, template, index)
        overlays[index] = overlay
    end
    return overlay
end

-- Update overlay controls.
---
--- @param index integer
function ActionBar:UpdateOverlay(index)
    local overlay = overlays[index]
    if overlay then
        local effect = overlay.effect
        -- Get controls to update.
        local durationControl = overlay:GetNamedChild("Duration")
        local stacksControl = overlay:GetNamedChild("Stacks")
        local bgControl = overlay:GetNamedChild("BG")
        if effect then
            -- Update duration.
            local duration = effect.endTime - time()
            -- duration = GetActionSlotEffectTimeRemaining(index, index < SLOT_INDEX_OFFSET and HOTBAR_CATEGORY_PRIMARY or HOTBAR_CATEGORY_BACKUP) / 1000
            if duration > -3 then
                if self.SV.decimalThreshold > 0 and duration < self.SV.decimalThreshold then
                    durationControl:SetText(strformat("%0.1f", zo_max(0, duration)))
                    durationControl:SetColor(unpack(duration > 0 and self.SV.decimalColor or self.SV.zeroColor))
                else
                    durationControl:SetText(zo_max(0, zo_ceil(duration)))
                    if duration > 0 then
                        durationControl:SetColor(unpack(self.SV.timerColor))
                    else
                        durationControl:SetColor(unpack(self.SV.zeroColor))
                    end
                end
                bgControl:SetHidden(duration <= 0 or not self.SV.showHighlight)
            else
                bgControl:SetHidden(true)
                durationControl:SetText("")
            end
            -- Update stacks.
            if stacks[effect.id] and stacks[effect.id] > 0 then
                stacksControl:SetText(stacks[effect.id])
            else
                stacksControl:SetText("")
            end
        else
            bgControl:SetHidden(true)
            durationControl:SetText("")
        end
    end
end

-- Remove effect from overlay index.
function ActionBar:UnslotEffect(index)
    local overlay = overlays[index]
    if overlay then
        local effect = overlay.effect
        if effect then
            if index < SLOT_INDEX_OFFSET then
                effect.slot1 = nil
            else
                effect.slot2 = nil
            end
            overlay.effect = nil
        end
    end
end

--[[ hstructure LUIE_ActionBarEffectData
    custom: boolean
    duration: number
    endTime: number
    id: number
    simple: boolean
    slot1: number
    slot2: number
end ]]

--- @alias LUIE_ActionBarEffectData {
--- custom: boolean,
--- duration : number,
--- endTime : number,
--- id : number,
--- simple : boolean,
--- slot1:  number,
--- slot2 : number,
--- }

-- Assign effect to overlay index.
function ActionBar:SlotEffect(index, abilityId)
    if not abilityId or abilityId == 0 then -- or GetAbilityCastInfo(abilityId) then
        self:UnslotEffect(index)
    else
        local cfg = abilityConfig[abilityId]
        local effectId, duration, simple, custom
        if cfg == false then
            return
        elseif cfg then
            effectId = cfg[1] or abilityId
            simple = cfg[3] or false
            duration = cfg[2] or (simple and GetAbilityDuration(abilityId) / 1000)
            custom = true
        else
            effectId = abilityId
        end
        --- @type LUIE_ActionBarEffectData
        local effect --[[: LUIE_ActionBarEffectData]] = effects[effectId]
        if not effect then
            effect = --[[hmake LUIE_ActionBarEffectData]] {}
            effect.id = effectId
            effect.simple = simple
            effect.endTime = 0
            effect.custom = custom
            effects[effectId] = effect
        end
        effect.duration = duration and duration > 0 and duration or nil
        if index < SLOT_INDEX_OFFSET then
            effect.slot1 = index
        else
            effect.slot2 = index
        end
        -- Assign effect to overlay.
        local overlay = overlays[index]
        if overlay then
            overlay.effect = effect
        end
        return effect
    end
end

-- Slot effects for primary and backup bars.
function ActionBar:SlotEffects()
    if currentHotbarCategory == HOTBAR_CATEGORY_PRIMARY or currentHotbarCategory == HOTBAR_CATEGORY_BACKUP then
        for i = MIN_INDEX, MAX_INDEX do
            self:SlotEffect(i, self:GetSlotTrueBoundId(i, HOTBAR_CATEGORY_PRIMARY))
            self:SlotEffect(i + SLOT_INDEX_OFFSET, self:GetSlotTrueBoundId(i, HOTBAR_CATEGORY_BACKUP))
        end
    else
        -- Unslot all effects, if we are on a special bar.
        for i = MIN_INDEX, MAX_INDEX do
            self:UnslotEffect(i)
            self:UnslotEffect(i + SLOT_INDEX_OFFSET)
        end
    end
end

-- Update overlays linked to the effect.
function ActionBar:UpdateEffect(effect)
    if effect then
        if effect.slot1 then
            self:UpdateOverlay(effect.slot1)
        end
        if effect.slot2 then
            self:UpdateOverlay(effect.slot2)
        end
    end
end

-- Apply style to action bars depending on keyboard/gamepad mode.
function ActionBar:ApplyStyle()
    local style = IsInGamepadPreferredMode() and GAMEPAD_CONSTANTS or KEYBOARD_CONSTANTS
    local scale = ACTION_BAR:GetScale()

    -- Most alignments are relative to weapon swap button.
    local weaponSwapControl = ACTION_BAR:GetNamedChild("WeaponSwap")

    -- Hide default background.
    ACTION_BAR:GetNamedChild("KeybindBG"):SetHidden(true)

    -- Hide weapon swap button.
    weaponSwapControl:SetAlpha(self.SV.staticBars and 0 or 1)

    -- Arrow style.
    _G["LUIE_ActionBarArrow"]:SetHidden(not self.SV.staticBars or not self.SV.showArrow)
    _G["LUIE_ActionBarArrow"]:SetColor(unpack(self.SV.arrowColor))

    -- Set positions for buttons and overlays.
    local lastButton
    local buttonTemplate = ZO_GetPlatformTemplate("ZO_ActionButton")
    local overlayTemplate = ZO_GetPlatformTemplate("LUIE_ActionButtonOverlay")
    for i = MIN_INDEX, MAX_INDEX do
        local button = ZO_ActionBar_GetButton(i)
        local overlayOffsetX = (i - MIN_INDEX) * (style.abilitySlotWidth + style.abilitySlotOffsetX)

        -- Hotkey position.
        button.buttonText:ClearAnchors()
        button.buttonText:SetAnchor(TOP, weaponSwapControl, RIGHT, (overlayOffsetX + style.abilitySlotWidth / 2) * scale, style.buttonTextOffsetY * scale)
        button.buttonText:SetHidden(not self.SV.showHotkeys)

        -- Main button overlay.
        local overlay = self:CreateOverlay(i)
        if i == MIN_INDEX then
            overlay:SetAnchor(BOTTOMLEFT, weaponSwapControl, RIGHT, 0, -4)
        else
            overlay:SetAnchor(LEFT, overlays[i - 1], RIGHT, style.abilitySlotOffsetX, 0)
        end

        -- Backbar button style and position.
        button = buttons[i + SLOT_INDEX_OFFSET]
        button:ApplyStyle(buttonTemplate)
        if lastButton then
            button:ApplyAnchor(lastButton.slot, style.abilitySlotOffsetX)
        end
        lastButton = button

        -- Back button overlay.
        overlay = self:CreateOverlay(i + SLOT_INDEX_OFFSET)
        if i == MIN_INDEX then
            overlay:SetAnchor(TOPLEFT, weaponSwapControl, RIGHT, 0, 0)
        else
            overlay:SetAnchor(LEFT, overlays[i + SLOT_INDEX_OFFSET - 1], RIGHT, style.abilitySlotOffsetX, 0)
        end
    end

    self:SetBackBarAlphaAndDesaturation(self.SV.backBarAlpha, self.SV.backBarDesaturation)

    -- Reposition ultimate slot.
    _G["ActionButton8"]:ClearAnchors()
    _G["ActionButton8"]:SetAnchor(LEFT, weaponSwapControl, RIGHT, SLOT_COUNT * (style.abilitySlotWidth + 2 * style.abilitySlotOffsetX) * scale)

    -- Lock quickslot and companion buttons in place.
    _G["CompanionUltimateButton"]:ClearAnchors()
    _G["CompanionUltimateButton"]:SetAnchor(RIGHT, weaponSwapControl, LEFT, -style.quickslotOffsetXFromFirstSlot * scale)
end

-- Refresh action bars positions.
function ActionBar:SwapControls()
    -- Set new anchors for the first buttons.
    local weaponSwapControl = ACTION_BAR:GetNamedChild("WeaponSwap")
    _G["ActionButton3"]:ClearAnchors()
    _G["ActionButton23"]:ClearAnchors()
    if self.SV.staticBars and currentHotbarCategory == HOTBAR_CATEGORY_BACKUP then
        _G["ActionButton3"]:SetAnchor(TOPLEFT, weaponSwapControl, RIGHT, 0, 0)
        _G["ActionButton23"]:SetAnchor(BOTTOMLEFT, weaponSwapControl, RIGHT, 0, -4)
    else
        _G["ActionButton3"]:SetAnchor(BOTTOMLEFT, weaponSwapControl, RIGHT, 0, -4)
        _G["ActionButton23"]:SetAnchor(TOPLEFT, weaponSwapControl, RIGHT, 0, 0)
    end

    -- Set new anchors for overlays.
    _G["ActionButtonOverlay3"]:ClearAnchors()
    _G["ActionButtonOverlay23"]:ClearAnchors()
    if not self.SV.staticBars and currentHotbarCategory == HOTBAR_CATEGORY_BACKUP then
        _G["ActionButtonOverlay3"]:SetAnchor(TOPLEFT, weaponSwapControl, RIGHT, 0, 0)
        _G["ActionButtonOverlay23"]:SetAnchor(BOTTOMLEFT, weaponSwapControl, RIGHT, 0, -4)
    else
        _G["ActionButtonOverlay3"]:SetAnchor(BOTTOMLEFT, weaponSwapControl, RIGHT, 0, -4)
        _G["ActionButtonOverlay23"]:SetAnchor(TOPLEFT, weaponSwapControl, RIGHT, 0, 0)
    end

    -- Update icons for inactive bar.
    for i = MIN_INDEX, MAX_INDEX do
        local btnBackSlotId = self:GetSlotTrueBoundId(i, currentHotbarCategory == HOTBAR_CATEGORY_BACKUP and HOTBAR_CATEGORY_PRIMARY or HOTBAR_CATEGORY_BACKUP)
        -- local id = GetCorrectedAbilityId(btnBackSlotId, currentHotbarCategory == HOTBAR_CATEGORY_BACKUP and HOTBAR_CATEGORY_PRIMARY or HOTBAR_CATEGORY_BACKUP)
        local btnBack = buttons[i + SLOT_INDEX_OFFSET]
        if btnBackSlotId > 0 then
            btnBack.icon:SetTexture(GetAbilityIcon(btnBackSlotId))
            btnBack.icon:SetHidden(false)
        else
            btnBack.icon:SetHidden(true)
        end
        -- Need to update main buttons manually, because by default it is done when animation ends.
        local btnMain = ZO_ActionBar_GetButton(i)
        btnMain:HandleSlotChanged()
    end

    -- Unslot effects from the main bar if it's currently a special bar.
    if currentHotbarCategory ~= HOTBAR_CATEGORY_PRIMARY and currentHotbarCategory ~= HOTBAR_CATEGORY_BACKUP then
        for i = MIN_INDEX, MAX_INDEX do
            self:UnslotEffect(i)
        end
    end
end

local function SetAbilityBarTimersEnabled()
    if tonumber(GetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_ACTION_BAR_TIMERS)) == 0 then
        SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_ACTION_BAR_TIMERS, "true")
    end
end

--- @param enabled boolean
function ActionBar:Initialize(enabled)
    -- Load settings
    local isCharacterSpecific = LUIESV["Default"][GetDisplayName()]["$AccountWide"].CharacterSpecificSV
    if isCharacterSpecific then
        self.SV = ZO_SavedVars:New(LUIE.SVName, LUIE.SVVer, "ActionBar", self.Defaults)
    else
        self.SV = ZO_SavedVars:NewAccountWide(LUIE.SVName, LUIE.SVVer, "ActionBar", self.Defaults)
    end

    -- Disable module if setting not toggled on
    if not enabled then
        return
    end
    self.Enabled = true

    self:BuildAbilityConfig()

    -- Slot ability changed, e.g. summoned a pet, procced crystal, etc.
    --- - **EVENT_ACTION_SLOT_UPDATED **
    ---
    --- @param eventId integer
    --- @param actionSlotIndex luaindex
    local function OnSlotChanged(eventId, actionSlotIndex)
        local button = ZO_ActionBar_GetButton(actionSlotIndex)
        if button then
            button:HandleSlotChanged()
        end
    end

    -- Button (usable) state changed.
    --- - **EVENT_ACTION_SLOT_STATE_UPDATED **
    ---
    --- @param eventId integer
    --- @param actionSlotIndex luaindex
    local function OnSlotStateChanged(eventId, actionSlotIndex)
        local button = ZO_ActionBar_GetButton(actionSlotIndex)
        if button then
            button:UpdateState()
        end
    end

    -- Any skill swapped. Setup buttons and slot effects.
    --- - **EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED**
    ---
    --- @param eventId? integer
    local function OnAllHotbarsUpdated(eventId)
        for i = MIN_INDEX, MAX_INDEX + 1 do
            local button = ZO_ActionBar_GetButton(i)
            if button then
                button.showTimer = false -- disable default timer
                button.stackCountText:SetHidden(true)
                button.timerText:SetHidden(true)
                if i <= MAX_INDEX then               -- non ult only
                    button.hotbarSwapAnimation = nil -- delete default animation
                    button.noUpdates = true          -- disable animation updates
                    button:HandleSlotChanged()       -- update slot manually
                end
            end
            -- Hide default backbar button.
            if currentHotbarCategory == HOTBAR_CATEGORY_PRIMARY or currentHotbarCategory == HOTBAR_CATEGORY_BACKUP then
                local targetbutton = ZO_ActionBar_GetButton(i, currentHotbarCategory == HOTBAR_CATEGORY_PRIMARY and HOTBAR_CATEGORY_BACKUP or HOTBAR_CATEGORY_PRIMARY)
                if targetbutton then
                    -- targetbutton.backBarSwapAnimation = nil -- breaks console ui
                    targetbutton.showTimer = false
                    targetbutton.showBackRowSlot = false
                    if i <= MAX_INDEX then -- non ult only
                        targetbutton.noUpdates = true
                    end
                end
            end
        end
        self:SlotEffects()
    end

    -- Hotbar changed. Can be primary bar, back bar or special bar: werewolf, relic, etc.
    --- - **EVENT_ACTIVE_WEAPON_PAIR_CHANGED **
    ---
    --- @param eventId integer
    --- @param activeWeaponPair ActiveWeaponPair
    --- @param locked boolean
    local function OnActiveWeaponPairChanged(eventId, activeWeaponPair, locked)
        currentHotbarCategory = GetActiveHotbarCategory()
        self:SwapControls()
    end

    --- - **EVENT_ACTION_SLOT_ABILITY_USED **
    ---
    --- @param eventId integer
    --- @param actionSlotIndex luaindex
    local function OnAbilityUsed(eventId, actionSlotIndex)
        if actionSlotIndex >= MIN_INDEX and actionSlotIndex <= MAX_INDEX then
            local index = currentHotbarCategory == HOTBAR_CATEGORY_BACKUP and actionSlotIndex + SLOT_INDEX_OFFSET or actionSlotIndex
            local id = self:GetSlotTrueBoundId(actionSlotIndex, currentHotbarCategory)
            local duration = GetAbilityDuration(id) / 1000
            local effect = self:SlotEffect(index, id)
            if effect and effect.simple then
                effect.endTime = time() + effect.duration
            end
            dbg("[ActionButton%d] #%d: %0.1fs", index, id, duration)
        end
    end

    -- Any effect duration gained.
    --- - **EVENT_ACTION_SLOT_EFFECT_UPDATE **
    ---
    --- @param eventId integer
    --- @param hotbar HotBarCategory
    --- @param actionSlot luaindex
    local function OnActionSlotEffectUpdated(eventId, hotbar, actionSlot)
        local effect = effects[self:GetSlotTrueBoundId(actionSlot, hotbar)]
        -- Effect must be slotted and not have custom duration specified in config.lua
        if effect and not effect.custom then
            local duration = GetActionSlotEffectDuration(actionSlot, hotbar)
            if duration > 1500 and duration < 1000000 then
                local remain = GetActionSlotEffectTimeRemaining(actionSlot, hotbar) / 1000
                effect.endTime = time() + remain
                self:UpdateEffect(effect)
            end
        end
    end

    --- - **EVENT_EFFECT_CHANGED **
    ---
    --- @param eventId integer
    --- @param changeType EffectResult
    --- @param effectSlot integer
    --- @param effectName string
    --- @param unitTag string
    --- @param beginTime number
    --- @param endTime number
    --- @param stackCount integer
    --- @param iconName string
    --- @param deprecatedBuffType string
    --- @param effectType BuffEffectType
    --- @param abilityType AbilityType
    --- @param statusEffectType StatusEffectType
    --- @param unitName string
    --- @param unitId integer
    --- @param abilityId integer
    --- @param sourceType CombatUnitType
    local function OnEffectChanged(eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
        if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
            local effect = effects[abilityId]
            if effect and effect.custom then
                local t = time()
                if effect.duration then
                    endTime = t + effect.duration
                end
                -- Ignore abilities that will end in less than 2s or longer than 100s.
                if endTime > t + 2 and endTime < t + 1000 then
                    effect.endTime = endTime
                    self:UpdateEffect(effect)
                else
                    effect.endTime = 0
                end
            end
            dbg("%s #%d - %d (%s)", changeType == EFFECT_RESULT_GAINED and "+" or "*", abilityId, endTime - beginTime, effectName)
        elseif changeType == EFFECT_RESULT_FADED then
            -- A fix for fake Crystal Fragments proc, which can start and suddenly end.
            if abilityId == 46327 then
                local effect = effects[abilityId]
                if effect then
                    effect.endTime = 0
                end
            end
        end
    end

    -- Update overlays.
    ---
    --- @param currentTimeMs integer
    local function Update(currentTimeMs)
        for i, overlay in pairs(overlays) do
            self:UpdateOverlay(i)
        end
    end
    --- - **EVENT_EFFECT_CHANGED **
    ---
    --- @param eventId integer
    --- @param changeType EffectResult
    --- @param effectSlot integer
    --- @param effectName string
    --- @param unitTag string
    --- @param beginTime number
    --- @param endTime number
    --- @param stackCount integer
    --- @param iconName string
    --- @param deprecatedBuffType string
    --- @param effectType BuffEffectType
    --- @param abilityType AbilityType
    --- @param statusEffectType StatusEffectType
    --- @param unitName string
    --- @param unitId integer
    --- @param abilityId integer
    --- @param sourceType CombatUnitType
    local function OnStackChanged(eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
        local numStacks = changeType == EFFECT_RESULT_FADED and 0 or stackCount
        local stackMapData = self.stackMap[abilityId]
        if (type(stackMapData) == "number") then
            stacks[stackMapData] = numStacks
        elseif (type(stackMapData == "table")) then
            for _, dataId in pairs(stackMapData) do
                stacks[dataId] = numStacks
            end
        end
        -- Remove Seething Fury effect manually, otherwise it will keep counting down.
        if stackCount == 0 and abilityId == 122658 and effects[122658] then
            effects[122658].endTime = time()
        end
    end

    for abilityId in pairs(self.stackMap) do
        eventManager:RegisterForEvent(moduleName .. abilityId, EVENT_EFFECT_CHANGED, OnStackChanged)
        eventManager:AddFilterForEvent(moduleName .. abilityId, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)
        eventManager:AddFilterForEvent(moduleName .. abilityId, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    end

    eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOT_UPDATED, OnSlotChanged)
    eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOT_STATE_UPDATED, OnSlotStateChanged)
    eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, OnAllHotbarsUpdated)
    eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOT_ABILITY_USED, OnAbilityUsed)
    eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOT_EFFECT_UPDATE, OnActionSlotEffectUpdated)

    --- - **EVENT_GAMEPAD_PREFERRED_MODE_CHANGED **
    ---
    --- @param eventId integer
    --- @param gamepadPreferred boolean
    local function OnGamepadPreferredModeChanged(eventId, gamepadPreferred)
        self:ApplyStyle()
        self:SwapControls()
        self:AdjustControlsPositions()
    end
    eventManager:RegisterForEvent(moduleName, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, OnGamepadPreferredModeChanged)

    --- - **EVENT_PLAYER_ACTIVATED **
    ---
    --- @param eventId integer
    --- @param initial boolean
    local function OnPlayerActivated(eventId, initial)
        if IsPlayerActivated() then
            -- Enable Ability Bar Timers if they are disabled, otherwise EVENT_ACTION_SLOT_EFFECT_UPDATE won't fire :(
            SetAbilityBarTimersEnabled()
            -- The following stuff only needs to run once.
            if not ACTIVATED then
                currentHotbarCategory = GetActiveHotbarCategory()
                self:ApplyStyle()
                OnAllHotbarsUpdated()
                self:SwapControls()
                eventManager:UnregisterForUpdate(moduleName .. "Update")
                eventManager:RegisterForUpdate(moduleName .. "Update", 100, Update)
                -- If placed outside, then triggers once on character log in before player activated, causing UI error...
                eventManager:RegisterForEvent(moduleName, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, OnActiveWeaponPairChanged)
                ACTIVATED = true
            end
        end
    end

    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    eventManager:RegisterForEvent(moduleName, EVENT_EFFECT_CHANGED, OnEffectChanged)
    eventManager:AddFilterForEvent(moduleName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    eventManager:RegisterForEvent(moduleName .. "Pet", EVENT_EFFECT_CHANGED, OnEffectChanged)
    eventManager:AddFilterForEvent(moduleName .. "Pet", EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER_PET)

    -- Unregister some default stuff from action buttons.
    eventManager:UnregisterForEvent("ZO_ActionBar", EVENT_ACTION_SLOT_EFFECT_UPDATE)
    for i = MIN_INDEX, MAX_INDEX + 1 do
        eventManager:UnregisterForEvent("ActionButton" .. i, EVENT_INTERFACE_SETTING_CHANGED)
        eventManager:UnregisterForEvent("ActionBarTimer" .. i, EVENT_INTERFACE_SETTING_CHANGED)
    end
end
