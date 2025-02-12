-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.CombatInfo
--- @field SV LUIE.CombatInfo.SV
local CombatInfo = LUIE.CombatInfo

local UI = LUIE.UI
local Effects = LUIE.Data.Effects
local Abilities = LUIE.Data.Abilities
local Castbar = LUIE.Data.CastBarTable

local pairs = pairs
local ipairs = ipairs
local printToChat = LUIE.PrintToChat
local zo_strformat = zo_strformat
local string_format = string.format
local eventManager = GetEventManager()
local sceneManager = SCENE_MANAGER
local windowManager = GetWindowManager()
local ANIMATION_MANAGER = GetAnimationManager()

local moduleName = LUIE.name .. "CombatInfo"

local ACTION_RESULT_AREA_EFFECT = 669966

local uiTlw = {}                                              -- GUI
local castbar = {}                                            -- castbar
local g_casting = false                                       -- Toggled when casting - prevents additional events from creating a cast bar until finished
local g_ultimateCost = 0                                      -- Cost of ultimate Ability in Slot
local g_ultimateCurrent = 0                                   -- Current ultimate value
local g_ultimateSlot = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1     -- Ultimate slot number
local g_uiProcAnimation = {}                                  -- Animation for bar slots
local g_uiCustomToggle = {}                                   -- Toggle slots for bar Slots
local g_triggeredSlotsFront = {}                              -- Triggered bar highlight slots
local g_triggeredSlotsBack = {}                               -- Triggered bar highlight slots
local g_triggeredSlotsRemain = {}                             -- Table of remaining durations on proc abilities
local g_toggledSlotsBack = {}                                 -- Toggled bar highlight slots
local g_toggledSlotsFront = {}                                -- Toggled bar highlight slots
local g_toggledSlotsRemain = {}                               -- Table of remaining durations on active abilities
local g_toggledSlotsStack = {}                                -- Table of stacks for active abilities
local g_toggledSlotsPlayer = {}                               -- Table of abilities that target the player (bar highlight doesn't fade on reticleover change)
local g_potionUsed = false                                    -- Toggled on when a potion is used to prevent OnSlotsFullUpdate from updating timers.
local g_barOverrideCI = {}                                    -- Table for storing abilityId's from Effects.BarHighlightOverride that should show as an aura
local g_barFakeAura = {}                                      -- Table for storing abilityId's that only display a fakeaura
local g_barDurationOverride = {}                              -- Table for storing abilitiyId's that ignore ending event
local g_barNoRemove = {}                                      -- Table of abilities we don't remove from bar highlight
local g_protectAbilityRemoval = {}                            -- AbilityId's set to a timestamp here to prevent removal of bar highlight when refreshing ground auras from causing the highlight to fade.
local g_mineStacks = {}                                       -- Individual AbilityId ground mine stack information
local g_mineNoTurnOff = {}                                    -- When this variable is true for an abilityId - don't remove the bar highlight for a mine (We we have reticleover target and the mine effect applies on the enemy)
local g_barFont                                               -- Font for Ability Highlight Label
local g_potionFont                                            -- Font for Potion Timer Label
local g_ultimateFont                                          -- Font for Ultimate Percentage Label
local g_castbarFont                                           -- Font for Castbar Label & Timer
local g_ProcSound                                             -- Proc Sound
local g_boundArmamentsPlayed = false                          -- Specific variable to lockout Bound Armaments/Grim Focus from playing a proc sound at 5 stacks to only once per 5 seconds.
local g_disableProcSound = {}                                 -- When we play a proc sound from a bar ability changing (like power lash) we put a 3 sec ICD on it so it doesn't spam when mousing on/off a target, etc
local g_hotbarCategory = GetActiveHotbarCategory()            -- Set on initialization and when we swap weapons to determine the current hotbar category
local g_actionBarActiveWeaponPair = GetActiveWeaponPairInfo() -- Toggled on when weapon swapping, TODO: maybe not needed
local g_backbarButtons = {}                                   -- Table to hold backbar buttons
local g_activeWeaponSwapInProgress = false                    -- Toggled on when weapon swapping, TODO: maybe not needed
local g_castbarWorldMapFix = false                            -- Fix for viewing the World Map changing the player coordinates for some reason
local ACTION_BAR_META = ZO_ActionBar1
local ACTION_BAR = ACTION_BAR_META
local BAR_INDEX_START = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1
local BAR_INDEX_END = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1
local BACKBAR_INDEX_END = ACTION_BAR_ULTIMATE_SLOT_INDEX -- Separate index for backbar as long as we're not using an ultimate button.
local BACKBAR_INDEX_OFFSET = 50

-- Quickslot
local uiQuickSlot =
{
    color = { 0.941, 0.565, 0.251 },
    timeColors =
    {
        [1] = { remain = 15000, color = { 0.878, 0.941, 0.251 } },
        [2] = { remain = 5000, color = { 0.251, 0.941, 0.125 } },
    },
}

-- Ultimate slot
local uiUltimate =
{
    color = { 0.941, 0.973, 0.957 },
    pctColors =
    {
        [1] = { pct = 100, color = { 0.878, 0.941, 0.251 } },
        [2] = { pct = 80, color = { 0.941, 0.565, 0.251 } },
        [3] = { pct = 50, color = { 0.941, 0.251, 0.125 } },
    },
    FadeTime = 0,
    NotFull = false,
}

-- Cooldown Animation Types for GCD Tracking
local CooldownMethod =
{
    [1] = CD_TYPE_VERTICAL_REVEAL,
    [2] = CD_TYPE_VERTICAL,
    [3] = CD_TYPE_RADIAL,
}

-- Constants from actionbar.lua with only the information we need
local GAMEPAD_CONSTANTS =
{
    abilitySlotOffsetX = 10,
    ultimateSlotOffsetX = 65,
}
local KEYBOARD_CONSTANTS =
{
    abilitySlotOffsetX = 2,
    ultimateSlotOffsetX = 62,
}

-- Set Marker - Called by the menu & EVENT_PLAYER_ACTIVATED (needs to be reset on the player changing zones)
-- @param removeMarker boolean: Remove the marker by making an empty dummy marker (only called from the menu toggle)
function CombatInfo.SetMarker(removeMarker)
    -- Only call with removeMarker param from menu toggle setting - there doesn't appear to be any way to remove floating markers so we only do this so the player doesn't have to reloadUI after toggling the setting off
    -- We don't wanna draw a pointless marker with no texture otherwise.
    if removeMarker then
        eventManager:UnregisterForEvent(moduleName .. "Marker", EVENT_PLAYER_ACTIVATED)
        SetFloatingMarkerInfo(MAP_PIN_TYPE_AGGRO, CombatInfo.SV.markerSize, "", "", true, false)
    end
    -- If Marker is not enabled, return
    if CombatInfo.SV.showMarker ~= true then
        return
    end
    -- Otherwise, setup the marker texture & register EVENT_PLAYER_ACTIVATED handler
    local LUIE_MARKER = "/LuiExtended/media/combatinfo/floatingicon/redarrow.dds"
    SetFloatingMarkerInfo(MAP_PIN_TYPE_AGGRO, CombatInfo.SV.markerSize, LUIE_MARKER, "", true, false)
    eventManager:RegisterForEvent(moduleName .. "Marker", EVENT_PLAYER_ACTIVATED, CombatInfo.OnPlayerActivatedMarker)
end

local slotsUpdated = {}

local function OnSwapAnimationHalfDone(animation, button, isBackBarSlot)
    for i = BAR_INDEX_START, BAR_INDEX_END do
        if not slotsUpdated[i] then
            local targetButton = g_backbarButtons[i + BACKBAR_INDEX_OFFSET]
            CombatInfo.BarSlotUpdate(i, false, false)
            CombatInfo.BarSlotUpdate(i + BACKBAR_INDEX_OFFSET, false, false)
            -- Don't try to setup back bar ultimate
            if i < 8 then
                CombatInfo.SetupBackBarIcons(targetButton, true)
            end
            if i == 8 then
                CombatInfo.UpdateUltimateLabel()
            end
            slotsUpdated[i] = true
        end
    end
end

local function OnSwapAnimationDone(animation, button)
    button.noUpdates = false
    if button:GetSlot() == ACTION_BAR_ULTIMATE_SLOT_INDEX + 1 then
        g_activeWeaponSwapInProgress = false
    end
    slotsUpdated = {}
end

local function SetupSwapAnimation(button)
    button:SetupSwapAnimation(OnSwapAnimationHalfDone, OnSwapAnimationDone)
end

local function FormatDurationSeconds(remain)
    return string_format((CombatInfo.SV.BarMillis and ((remain < CombatInfo.SV.BarMillisThreshold * 1000) or CombatInfo.SV.BarMillisAboveTen)) and "%.1f" or "%.1d", remain / 1000)
end

-- Module initialization
function CombatInfo.Initialize(enabled)
    -- Load settings
    local isCharacterSpecific = LUIESV.Default[GetDisplayName()]["$AccountWide"].CharacterSpecificSV
    if isCharacterSpecific then
        CombatInfo.SV = ZO_SavedVars:New(LUIE.SVName, LUIE.SVVer, "CombatInfo", CombatInfo.Defaults)
    else
        CombatInfo.SV = ZO_SavedVars:NewAccountWide(LUIE.SVName, LUIE.SVVer, "CombatInfo", CombatInfo.Defaults)
    end

    -- Disable module if setting not toggled on
    if not enabled then
        return
    end
    CombatInfo.Enabled = true

    CombatInfo.ApplyFont()
    CombatInfo.ApplyProcSound()
    local QSB = _G["QuickslotButton"]
    uiQuickSlot.label = UI:Label(QSB, { CENTER, CENTER }, nil, nil, g_potionFont, nil, true)
    uiQuickSlot.label:SetFont(g_potionFont)
    if CombatInfo.SV.PotionTimerColor then
        uiQuickSlot.label:SetColor(unpack(uiQuickSlot.color))
    else
        uiQuickSlot.label:SetColor(1, 1, 1, 1)
    end
    uiQuickSlot.label:SetDrawLayer(DL_OVERLAY)
    uiQuickSlot.label:SetDrawTier(DT_HIGH)
    CombatInfo.ResetPotionTimerLabel() -- Set the label position

    -- Create Ultimate overlay labels
    local AB8 = _G["ActionButton8"]
    uiUltimate.LabelVal = UI:Label(AB8, { BOTTOM, TOP, 0, -3 }, nil, { 1, 2 }, "$(BOLD_FONT)|16|soft-shadow-thick", nil, true)
    uiUltimate.LabelPct = UI:Label(AB8, nil, nil, nil, g_ultimateFont, nil, true)
    local actionButton = ZO_ActionBar_GetButton(g_ultimateSlot, g_hotbarCategory)
    uiUltimate.LabelPct:SetAnchor(TOPLEFT, actionButton.slot, nil, 0, 0)
    uiUltimate.LabelPct:SetAnchor(BOTTOMRIGHT, actionButton.slot, nil, 0, -CombatInfo.SV.UltimateLabelPosition)

    uiUltimate.LabelPct:SetColor(unpack(uiUltimate.color))
    -- And buff texture
    uiUltimate.Texture = UI:Texture(AB8, { CENTER, CENTER }, { 160, 160 }, "/esoui/art/crafting/white_burst.dds", DL_BACKGROUND, true)

    -- Create a top level window for backbar buttons using UI:Control
    local tlw = UI:Control(
        ACTION_BAR,    -- parent
        "fill",        -- anchors
        "inherit",     -- dims
        false,         -- hidden
        "LUIE_Backbar" -- name
    )


    for i = BAR_INDEX_START + BACKBAR_INDEX_OFFSET, BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET do
        local button = ActionButton:New(i, ACTION_BUTTON_TYPE_VISIBLE, tlw, "ZO_ActionButton")
        SetupSwapAnimation(button)
        button:SetupBounceAnimation()
        g_backbarButtons[i] = button
    end

    CombatInfo.BackbarSetupTemplate()
    CombatInfo.BackbarToggleSettings()
    -------------------------------------------------------------------------------------

    CombatInfo.RegisterCombatInfo()

    if CombatInfo.SV.GlobalShowGCD then
        CombatInfo.HookGCD()
    end

    -- Setup Floating Marker
    CombatInfo.SetMarker()

    -- Create and update Cast Bar
    CombatInfo.CreateCastBar()
    CombatInfo.UpdateCastBar()
    CombatInfo.SetCastBarPosition()

    -- Setup Alerts
    CombatInfo.AbilityAlerts.CreateAlertFrame()
    CombatInfo.AbilityAlerts.SetAlertFramePosition()
    CombatInfo.AbilityAlerts.SetAlertColors()

    -- Setup CCT
    CombatInfo.CrowdControlTracker.UpdateAOEList()
    CombatInfo.CrowdControlTracker.Initialize()

    -- Variable adjustment if needed
    if not LUIESV.Default[GetDisplayName()]["$AccountWide"].AdjustVarsCI then
        LUIESV.Default[GetDisplayName()]["$AccountWide"].AdjustVarsCI = 0
    end
    if LUIESV.Default[GetDisplayName()]["$AccountWide"].AdjustVarsCI < 2 then
        -- Set ability alert default colors
        CombatInfo.SV.alerts.colors.stunColor = CombatInfo.Defaults.alerts.colors.stunColor
        CombatInfo.SV.alerts.colors.knockbackColor = CombatInfo.Defaults.alerts.colors.knockbackColor
        CombatInfo.SV.alerts.colors.levitateColor = CombatInfo.Defaults.alerts.colors.levitateColor
        CombatInfo.SV.alerts.colors.disorientColor = CombatInfo.Defaults.alerts.colors.disorientColor
        CombatInfo.SV.alerts.colors.fearColor = CombatInfo.Defaults.alerts.colors.fearColor
        CombatInfo.SV.alerts.colors.charmColor = CombatInfo.Defaults.alerts.colors.charmColor
        CombatInfo.SV.alerts.colors.silenceColor = CombatInfo.Defaults.alerts.colors.silenceColor
        CombatInfo.SV.alerts.colors.staggerColor = CombatInfo.Defaults.alerts.colors.staggerColor
        CombatInfo.SV.alerts.colors.unbreakableColor = CombatInfo.Defaults.alerts.colors.unbreakableColor
        CombatInfo.SV.alerts.colors.snareColor = CombatInfo.Defaults.alerts.colors.snareColor
        CombatInfo.SV.alerts.colors.rootColor = CombatInfo.Defaults.alerts.colors.rootColor
        -- Set CCT default colors
        CombatInfo.SV.cct.colors[ACTION_RESULT_STUNNED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_STUNNED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_KNOCKBACK] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_KNOCKBACK]
        CombatInfo.SV.cct.colors[ACTION_RESULT_LEVITATED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_LEVITATED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_DISORIENTED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_DISORIENTED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_FEARED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_FEARED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_CHARMED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_CHARMED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_SILENCED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_SILENCED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_STAGGERED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_STAGGERED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_IMMUNE] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_IMMUNE]
        CombatInfo.SV.cct.colors[ACTION_RESULT_DODGED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_DODGED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_BLOCKED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_BLOCKED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_BLOCKED_DAMAGE] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_BLOCKED_DAMAGE]
        CombatInfo.SV.cct.colors[ACTION_RESULT_AREA_EFFECT] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_AREA_EFFECT]
        CombatInfo.SV.cct.colors.unbreakable = CombatInfo.Defaults.cct.colors.unbreakable
    end
    -- Increment so this doesn't occur again.
    LUIESV.Default[GetDisplayName()]["$AccountWide"].AdjustVarsCI = 2
end

-- Called on initialization and on full update to swap icons on backbar
function CombatInfo.SetupBackBarIcons(button, flip)
    -- Setup icons for backbar
    local hotbarCategory = g_hotbarCategory == HOTBAR_CATEGORY_BACKUP and HOTBAR_CATEGORY_PRIMARY or HOTBAR_CATEGORY_BACKUP
    local slotNum = button.slot.slotNum
    local slotId = LUIE.GetSlotTrueBoundId(slotNum - BACKBAR_INDEX_OFFSET, hotbarCategory)

    -- Check backbar weapon type
    local weaponSlot = g_hotbarCategory == HOTBAR_CATEGORY_BACKUP and 4 or 20
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

    if flip then
        CombatInfo.handleFlip(slotNum)
    end
end

function CombatInfo.handleFlip(slotNum)
    local desaturate = true

    if g_uiCustomToggle and g_uiCustomToggle[slotNum] then
        desaturate = false

        if g_uiCustomToggle[slotNum]:IsHidden() then
            CombatInfo.BackbarHideSlot(slotNum)
            desaturate = true
        end
    end

    CombatInfo.ToggleBackbarSaturation(slotNum, desaturate)
end

function CombatInfo.OnActiveWeaponPairChanged(eventCode, activeWeaponPair)
    if activeWeaponPair ~= g_actionBarActiveWeaponPair then
        g_hotbarCategory = GetActiveHotbarCategory()
        g_activeWeaponSwapInProgress = true
        g_actionBarActiveWeaponPair = activeWeaponPair
    end
end

function CombatInfo.HookGCD()
    -- Helper functions for UpdateCooldown
    local function ShouldShowCooldownAnimation(slotNum, hotbarCategory, duration)
        return not IsSlotItemConsumable(slotNum, hotbarCategory) or duration > 1000 or CombatInfo.SV.GlobalPotion
    end

    local function HandleCooldownAnimation(self, slotNum, hotbarCategory, remain, duration, updateChromaQuickslot)
        self.cooldown:StartCooldown(remain, duration, CooldownMethod[CombatInfo.SV.GlobalMethod], nil, false)

        if self.cooldownCompleteAnim.animation then
            self.cooldownCompleteAnim.animation:GetTimeline():PlayInstantlyToStart()
        end

        if IsInGamepadPreferredMode() then
            self.cooldown:SetHidden(true)
            if not self.showingCooldown then
                self:SetNeedsAnimationParameterUpdate(true)
                self:PlayAbilityUsedBounce()
            end
        else
            self.cooldown:SetHidden(false)
        end

        self.slot:SetHandler("OnUpdate", function () self:RefreshCooldown() end, "CooldownUpdate")

        if updateChromaQuickslot then
            ZO_RZCHROMA_EFFECTS:RemoveKeybindActionEffect("ACTION_BUTTON_9")
        end
    end

    local function HandleCooldownComplete(self, slotNum, hotbarCategory, duration, updateChromaQuickslot, options)
        if CombatInfo.SV.GlobalFlash and self.showingCooldown and ShouldShowCooldownAnimation(slotNum, hotbarCategory, duration) then
            if options ~= CombatInfo.SV.ProcEnableSound then
                PlaySound(SOUNDS.ABILITY_READY)
            end

            self.cooldownCompleteAnim.animation = self.cooldownCompleteAnim.animation or CreateSimpleAnimation(ANIMATION_TEXTURE, self.cooldownCompleteAnim)
            local anim = self.cooldownCompleteAnim.animation

            self.cooldownCompleteAnim:SetHidden(false)
            self.cooldown:SetHidden(false)

            anim:SetImageData(16, 1)
            anim:SetFramerate(30)
            anim:GetTimeline():PlayFromStart()

            if updateChromaQuickslot then
                ZO_RZCHROMA_EFFECTS:AddKeybindActionEffect("ACTION_BUTTON_9")
            end
        end

        self.icon.percentComplete = 1
        self.slot:SetHandler("OnUpdate", nil, "CooldownUpdate")
        self.cooldown:ResetCooldown()
    end

    -- Main UpdateCooldown hook
    local ActionButton_UpdateCooldown = ActionButton["UpdateCooldown"]
    local UpdateCooldown = function (self, options)
        local slotNum = self:GetSlot()
        local hotbarCategory = self.slot.slotNum == 1 and HOTBAR_CATEGORY_QUICKSLOT_WHEEL or g_hotbarCategory
        local remain, duration, global, globalSlotType = GetSlotCooldownInfo(slotNum, hotbarCategory)
        local slotType = GetSlotType(slotNum, hotbarCategory)

        local isInCooldown = duration > 0
        local showGlobalCooldownForCollectible = global and slotType == ACTION_TYPE_COLLECTIBLE and globalSlotType == ACTION_TYPE_COLLECTIBLE
        local showCooldown = isInCooldown and (CombatInfo.SV.GlobalShowGCD or not global or showGlobalCooldownForCollectible)
        local updateChromaQuickslot = (slotType ~= ACTION_TYPE_ABILITY or slotType ~= ACTION_TYPE_CRAFTED_ABILITY) and ZO_RZCHROMA_EFFECTS

        self.cooldown:SetHidden(not showCooldown)

        if showCooldown then
            if ShouldShowCooldownAnimation(slotNum, hotbarCategory, duration) then
                HandleCooldownAnimation(self, slotNum, hotbarCategory, remain, duration, updateChromaQuickslot)
            end
        else
            HandleCooldownComplete(self, slotNum, hotbarCategory, duration, updateChromaQuickslot, options)
        end

        -- Update visual states
        if showCooldown ~= self.showingCooldown then
            self:SetShowCooldown(showCooldown)
            self:UpdateActivationHighlight()

            if IsInGamepadPreferredMode() then
                self:SetCooldownPercentComplete(self.icon.percentComplete)
            end
        end

        self.icon:SetDesaturation((showCooldown or self.itemQtyFailure) and 1 or 0)

        local textColor = CombatInfo.SV.GlobalLabelColor and
            (showCooldown and INTERFACE_TEXT_COLOR_FAILED or INTERFACE_TEXT_COLOR_SELECTED) or
            INTERFACE_TEXT_COLOR_SELECTED
        self.buttonText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, textColor))

        self.isGlobalCooldown = global
        self:UpdateUsable()
    end
    ActionButton["UpdateCooldown"] = UpdateCooldown

    -- Helper function for UpdateUsable
    local function IsSlotUsable(self, slotNum, hotbarCategory, isShowingCooldown, isKeyboardUltimateSlot)
        if not self.useFailure and not isShowingCooldown then
            return true
        elseif isKeyboardUltimateSlot and self.costFailureOnly and not isShowingCooldown then
            return true
        elseif IsSlotItemConsumable(slotNum, hotbarCategory) and not self.useFailure then
            local remain, duration = GetSlotCooldownInfo(slotNum, hotbarCategory)
            return duration <= 1000
        end
        return false
    end

    -- Main UpdateUsable hook
    local ActionButton_UpdateUsable = ActionButton["UpdateUsable"]
    local UpdateUsable = function (self)
        local slotNum = self:GetSlot()
        local hotbarCategory = self.slot.slotNum == 1 and HOTBAR_CATEGORY_QUICKSLOT_WHEEL or g_hotbarCategory
        local isGamepad = IsInGamepadPreferredMode()
        local isShowingCooldown = self.showingCooldown
        local isKeyboardUltimateSlot = not isGamepad and ZO_ActionBar_IsUltimateSlot(slotNum, hotbarCategory)

        local usable = IsSlotUsable(self, slotNum, hotbarCategory, isShowingCooldown, isKeyboardUltimateSlot)
        local stackEmpty = false

        -- Check stack count for items
        if GetSlotType(slotNum, hotbarCategory) == ACTION_TYPE_ITEM then
            stackEmpty = GetSlotItemCount(slotNum, hotbarCategory) <= 0
            usable = not stackEmpty and usable
        end

        -- Update state if changed
        if usable ~= self.usable or isGamepad ~= self.isGamepad then
            self.usable = usable
            self.isGamepad = isGamepad
        end

        -- Apply desaturation
        ZO_ActionSlot_SetUnusable(self.icon, not usable, (isShowingCooldown and CombatInfo.SV.GlobalDesat) or stackEmpty)
    end
    ActionButton["UpdateUsable"] = UpdateUsable
end

-- Helper function to get override ability duration.
---
--- @param abilityId number
--- @param overrideRank number?
--- @param casterUnitTag string?
--- @return integer  duration
local function GetUpdatedAbilityDuration(abilityId, overrideRank, casterUnitTag)
    overrideRank = overrideRank or nil
    casterUnitTag = casterUnitTag or "player"
    local duration = g_barDurationOverride[abilityId] or LUIE.GetAbilityDuration(abilityId, overrideRank, casterUnitTag) or 0
    return duration
end

-- Called on initialization and menu changes
-- Pull data from Effects.BarHighlightOverride Tables to filter the display of Bar Highlight abilities based off menu settings.
function CombatInfo.UpdateBarHighlightTables()
    -- Reset all tables using ZO_ClearTable
    for _, table in ipairs(
        {
            g_uiProcAnimation, g_uiCustomToggle, g_triggeredSlotsFront, g_triggeredSlotsBack,
            g_triggeredSlotsRemain, g_toggledSlotsFront, g_toggledSlotsBack, g_toggledSlotsRemain,
            g_toggledSlotsStack, g_toggledSlotsPlayer, g_barOverrideCI, g_barFakeAura,
            g_barDurationOverride, g_barNoRemove
        }) do
        ZO_ClearTable(table)
    end

    if not (CombatInfo.SV.ShowTriggered or CombatInfo.SV.ShowToggled) then
        return
    end

    -- Process BarHighlightOverride entries
    for abilityId, value in pairs(Effects.BarHighlightOverride) do
        local targetId = value.newId or abilityId

        -- Handle fake aura entries
        if value.showFakeAura then
            g_barOverrideCI[targetId] = true
            g_barFakeAura[targetId] = true

            if value.duration then
                g_barDurationOverride[targetId] = value.duration
            end
        end

        -- Handle noRemove flag
        if value.noRemove then
            g_barNoRemove[targetId] = true
        end
    end

    -- Register combat events for each ability
    local counter = 0
    for abilityId in pairs(g_barOverrideCI) do
        counter = counter + 1
        local eventName = moduleName .. "CombatEventBar" .. counter
        eventManager:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, CombatInfo.OnCombatEventBar)
        eventManager:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId, REGISTER_FILTER_IS_ERROR, false)
    end
end

-- Clear and then (maybe) re-register event listeners for Combat/Power/Slot Updates
function CombatInfo.RegisterCombatInfo()
    eventManager:RegisterForUpdate(moduleName .. "OnUpdate", 100, CombatInfo.OnUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED, CombatInfo.OnPlayerActivated)

    eventManager:UnregisterForEvent(moduleName, EVENT_COMBAT_EVENT)
    eventManager:UnregisterForEvent(moduleName, EVENT_POWER_UPDATE)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOT_UPDATED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_ITEM_USED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOT_ABILITY_USED)
    if CombatInfo.SV.UltimateLabelEnabled or CombatInfo.SV.UltimatePctEnabled then
        eventManager:RegisterForEvent(moduleName .. "CombatEvent1", EVENT_COMBAT_EVENT, CombatInfo.OnCombatEvent)
        eventManager:AddFilterForEvent(moduleName .. "CombatEvent1", REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BLOCKED_DAMAGE)
        eventManager:RegisterForEvent(moduleName .. "PowerUpdate", EVENT_POWER_UPDATE, CombatInfo.OnPowerUpdatePlayer)
        eventManager:AddFilterForEvent(moduleName .. "PowerUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
        eventManager:RegisterForEvent(moduleName .. "InventoryUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, CombatInfo.OnInventorySlotUpdate)
        eventManager:AddFilterForEvent(moduleName .. "InventoryUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT, REGISTER_FILTER_IS_NEW_ITEM, false)
    end
    if CombatInfo.SV.UltimateLabelEnabled or CombatInfo.SV.UltimatePctEnabled or CombatInfo.SV.CastBarEnable then
        eventManager:RegisterForEvent(moduleName .. "CombatEvent2", EVENT_COMBAT_EVENT, CombatInfo.OnCombatEvent)
        eventManager:AddFilterForEvent(moduleName .. "CombatEvent2", REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false)
    end
    if CombatInfo.SV.CastBarEnable then
        local counter = 0
        for result, _ in pairs(Castbar.CastBreakingStatus) do
            counter = counter + 1
            local eventName = (moduleName .. "CombatEventCC" .. counter)
            eventManager:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, CombatInfo.OnCombatEventBreakCast)
            eventManager:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false, REGISTER_FILTER_COMBAT_RESULT, result)
        end
        eventManager:RegisterForEvent(moduleName, EVENT_START_SOUL_GEM_RESURRECTION, CombatInfo.SoulGemResurrectionStart)
        eventManager:RegisterForEvent(moduleName, EVENT_END_SOUL_GEM_RESURRECTION, CombatInfo.SoulGemResurrectionEnd)
        eventManager:RegisterForEvent(moduleName, EVENT_GAME_CAMERA_UI_MODE_CHANGED, CombatInfo.OnGameCameraUIModeChanged)
        eventManager:RegisterForEvent(moduleName, EVENT_END_SIEGE_CONTROL, CombatInfo.OnSiegeEnd)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOT_ABILITY_USED, CombatInfo.OnAbilityUsed)
        -- eventManager:RegisterForEvent(moduleName, EVENT_CLIENT_INTERACT_RESULT, CombatInfo.ClientInteractResult)
        --[[counter = 0
        for id, _ in pairs (Effects.CastBreakOnRemoveEvent) do
            counter = counter + 1
            local eventName = (moduleName.. "LUIE_CI_CombatEventCastBreak" .. counter)
            eventManager:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, CombatInfo.OnCombatEventSpecialFilters )
            eventManager:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_ABILITY_ID, id, REGISTER_FILTER_IS_ERROR, false, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)
        end]]
        --
    end
    if CombatInfo.SV.ShowTriggered or CombatInfo.SV.ShowToggled or CombatInfo.SV.UltimateLabelEnabled or CombatInfo.SV.UltimatePctEnabled then
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, CombatInfo.OnActiveHotbarUpdate)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, CombatInfo.OnSlotsFullUpdate)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOT_UPDATED, CombatInfo.OnSlotUpdated)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, CombatInfo.OnActiveWeaponPairChanged)
    end
    if CombatInfo.SV.ShowTriggered or CombatInfo.SV.ShowToggled then
        eventManager:RegisterForEvent(moduleName, EVENT_UNIT_DEATH_STATE_CHANGED, CombatInfo.OnDeath)
        eventManager:RegisterForEvent(moduleName, EVENT_TARGET_CHANGED, CombatInfo.OnTargetChange)
        eventManager:RegisterForEvent(moduleName, EVENT_RETICLE_TARGET_CHANGED, CombatInfo.OnReticleTargetChanged)
        eventManager:RegisterForEvent(moduleName, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, CombatInfo.BackbarSetupTemplate)

        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_ITEM_USED, CombatInfo.InventoryItemUsed)

        -- Setup bar highlight
        CombatInfo.UpdateBarHighlightTables()
    end
    -- Have to register EVENT_EFFECT_CHANGED for werewolf as well - Stop devour cast bar when devour fades / also handles updating Vampire Ultimate cost on stage change
    if CombatInfo.SV.ShowTriggered or CombatInfo.SV.ShowToggled or CombatInfo.SV.CastBarEnable or CombatInfo.SV.UltimateLabelEnabled or CombatInfo.SV.UltimatePctEnabled then
        eventManager:RegisterForEvent(moduleName, EVENT_EFFECT_CHANGED, CombatInfo.OnEffectChanged)
    end

    -- Display default UI ultimate text if the LUIE option is enabled.
    if CombatInfo.SV.UltimateLabelEnabled or CombatInfo.SV.UltimatePctEnabled then
        SetSetting(SETTING_TYPE_UI, UI_SETTING_ULTIMATE_NUMBER, 0)
    end
end

function CombatInfo.ClearCustomList(list)
    local listRef = list == CombatInfo.SV.blacklist and GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST) or ""
    for k, v in pairs(list) do
        list[k] = nil
    end
    CHAT_SYSTEM:Maximize()
    CHAT_SYSTEM.primaryContainer:FadeIn()
    printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_CLEARED), listRef), true)
end

-- List Handling (Add) for Prominent Auras & Blacklist
function CombatInfo.AddToCustomList(list, input)
    local id = tonumber(input)
    local listRef = list == CombatInfo.SV.blacklist and GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST) or ""
    if id and id > 0 then
        local cachedName = ZO_CachedStrFormat(SI_ABILITY_NAME, GetAbilityName(id))
        local name = cachedName -- zo_strformat("<<C:1>>", GetAbilityName(id))
        if name ~= nil and name ~= "" then
            local icon = zo_iconFormat(GetAbilityIcon(id), 16, 16)
            list[id] = true
            CHAT_SYSTEM:Maximize()
            CHAT_SYSTEM.primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_ID), icon, id, name, listRef), true)
        else
            CHAT_SYSTEM:Maximize()
            CHAT_SYSTEM.primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_FAILED), input, listRef), true)
        end
    else
        if input ~= "" then
            list[input] = true
            CHAT_SYSTEM:Maximize()
            CHAT_SYSTEM.primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_NAME), input, listRef), true)
        end
    end
end

-- List Handling (Remove) for Prominent Auras & Blacklist
function CombatInfo.RemoveFromCustomList(list, input)
    local id = tonumber(input)
    local listRef = list == CombatInfo.SV.blacklist and GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST) or ""
    if id and id > 0 then
        local cachedName = ZO_CachedStrFormat(SI_ABILITY_NAME, GetAbilityName(id))
        local name = cachedName -- zo_strformat("<<C:1>>", GetAbilityName(id))
        local icon = zo_iconFormat(GetAbilityIcon(id), 16, 16)
        list[id] = nil
        CHAT_SYSTEM:Maximize()
        CHAT_SYSTEM.primaryContainer:FadeIn()
        printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_REMOVED_ID), icon, id, name, listRef), true)
    else
        if input ~= "" then
            list[input] = nil
            CHAT_SYSTEM:Maximize()
            CHAT_SYSTEM.primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_REMOVED_NAME), input, listRef), true)
        end
    end
end

function CombatInfo.OnPlayerActivatedMarker(eventCode)
    CombatInfo.SetMarker()
end

-- Used to populate abilities icons after the user has logged on
function CombatInfo.OnPlayerActivated(eventCode)
    -- do not call this function for the second time
    eventManager:UnregisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED)

    -- Manually trigger event to update stats
    g_hotbarCategory = GetActiveHotbarCategory()
    CombatInfo.OnSlotsFullUpdate()
    for i = (BAR_INDEX_START + BACKBAR_INDEX_OFFSET), (BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET) do
        -- Update Bar Slots on initial load (don't want to do it normally when we do a slot update)
        CombatInfo.BarSlotUpdate(i, true, false)
    end
    CombatInfo.OnPowerUpdatePlayer(EVENT_POWER_UPDATE, "player", nil, COMBAT_MECHANIC_FLAGS_ULTIMATE, GetUnitPower("player", COMBAT_MECHANIC_FLAGS_ULTIMATE))
end

local savedPlayerX = 0
local savedPlayerZ = 0
local playerX
local playerZ

-- Hide duration label if the ability is Grim Focus or one of its morphs
local function SetBarRemainLabel(remain, abilityId)
    if Effects.IsGrimFocus[abilityId] or Effects.IsBloodFrenzy[abilityId] then
        return ""
    else
        return FormatDurationSeconds(remain)
    end
end

-- Procs
local doProcs = function (currentTime)
    for k, v in pairs(g_triggeredSlotsRemain) do
        local remain = v - currentTime
        local front = g_triggeredSlotsFront[k]
        local back = g_triggeredSlotsBack[k]
        local frontAnim = front and g_uiProcAnimation[front]
        local backAnim = back and g_uiProcAnimation[back]
        -- If duration reaches 0 then remove effect
        if v < currentTime then
            if frontAnim then
                frontAnim:Stop()
            end
            if backAnim then
                backAnim:Stop()
            end
            g_triggeredSlotsRemain[k] = nil
        end
        -- Update Label (FRONT)(BACK)
        if CombatInfo.SV.BarShowLabel and remain then
            if frontAnim then
                frontAnim.procLoopTexture.label:SetText(SetBarRemainLabel(remain, k))
            end
            if backAnim then
                backAnim.procLoopTexture.label:SetText(SetBarRemainLabel(remain, k))
            end
        end
    end
end

-- Ability Highlight
local doHighlights = function (currentTime)
    for k, v in pairs(g_toggledSlotsRemain) do
        local remain = v - currentTime
        local front = g_toggledSlotsFront[k]
        local back = g_toggledSlotsBack[k]
        local frontToggle = front and g_uiCustomToggle[front]
        local backToggle = back and g_uiCustomToggle[back]
        -- Update Label (FRONT)
        if v < currentTime then
            if frontToggle then
                CombatInfo.HideSlot(front, k)
            end
            if backToggle then
                CombatInfo.HideSlot(back, k)
            end
            g_toggledSlotsRemain[k] = nil
            g_toggledSlotsStack[k] = nil
        end
        -- Update Label (BACK)
        if CombatInfo.SV.BarShowLabel and remain then
            if frontToggle then
                frontToggle.label:SetText(SetBarRemainLabel(remain, k))
            end
            if backToggle then
                backToggle.label:SetText(SetBarRemainLabel(remain, k))
            end
        end
    end
end

-- Quickslot cooldown
local doQuickslot = function ()
    if CombatInfo.SV.PotionTimerShow then
        local slotIndex = GetCurrentQuickslot()
        local remain, duration, _ = GetSlotCooldownInfo(slotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
        local label = uiQuickSlot.label
        local timeColors = uiQuickSlot.timeColors
        if duration > 5000 then
            label:SetHidden(false)
            if not CombatInfo.SV.PotionTimerColor then
                label:SetColor(1, 1, 1, 1)
            else
                local color = uiQuickSlot.color
                for i = #timeColors, 1, -1 do
                    if remain < timeColors[i].remain then
                        color = timeColors[i].color
                        break
                    end
                end
                label:SetColor(unpack(color))
            end
            local text
            if remain > 86400000 then
                text = zo_floor(remain / 86400000) .. " d"
            elseif remain > 6000000 then
                text = zo_floor(remain / 3600000) .. "h"
            elseif remain > 600000 then
                text = zo_floor(remain / 60000) .. "m"
            elseif remain > 60000 then
                local m = zo_floor(remain / 60000)
                local s = remain / 1000 - 60 * m
                text = m .. ":" .. string_format("%.2d", s)
            else
                text = string_format(CombatInfo.SV.PotionTimerMillis and "%.1f" or "%.1d", 0.001 * remain)
            end
            label:SetText(text)
        else
            label:SetHidden(true)
        end
    end
end

-- Break castbar when movement interrupt is detected for certain effects.
local doBreakCast = function ()
    savedPlayerX = playerX
    savedPlayerZ = playerZ
    playerX, playerZ = GetMapPlayerPosition("player")
    if savedPlayerX == playerX and savedPlayerZ == playerZ then
        return
    else
        -- Fix if the player clicks on a Wayshrine in the World Map
        if g_castbarWorldMapFix == false then
            if Castbar.BreakCastOnMove[castbar.id] then
                CombatInfo.StopCastBar()
                -- TODO: Note probably should make StopCastBar event clear the id on it too. Not doing this right now due to not wanting to troubleshoot possible issues before update release.
            end
        end
        -- Only have this enabled for 1 tick max (the players coordinates only update 1 time after the World Map is closed so if the player moves before 500 ms we want to cancel the cast bar still)
        if g_castbarWorldMapFix == true then
            g_castbarWorldMapFix = false
        end
    end
end

-- Updates all floating labels. Called every 100ms
function CombatInfo.OnUpdate(currentTime)
    -- Procs
    doProcs(currentTime)

    -- Ability Highlight
    doHighlights(currentTime)

    -- Quickslot cooldown
    doQuickslot()

    -- Hide Ultimate generation texture if it is time to do so
    if CombatInfo.SV.UltimateGeneration then
        if not uiUltimate.Texture:IsHidden() and uiUltimate.FadeTime < currentTime then
            uiUltimate.Texture:SetHidden(true)
        end
    end

    -- Break castbar when block is used for certain effects.
    if not Castbar.IgnoreCastBreakingActions[castbar.id] then
        if IsBlockActive() then
            if not IsPlayerStunned() then
                -- Is Block Active returns true when the player is stunned currently.
                CombatInfo.StopCastBar()
            end
        end
    end

    -- Break castbar when movement interrupt is detected for certain effects.
    doBreakCast()
end

local function CastBarWorldMapFix()
    g_castbarWorldMapFix = false
    eventManager:UnregisterForEvent(moduleName .. "CastBarFix")
end

-- Run on the EVENT_GAME_CAMERA_UI_MODE_CHANGED handler
function CombatInfo.OnGameCameraUIModeChanged(eventCode)
    -- Changing zones in the World Map for some reason changes the player coordinates so when the player clicks on a Wayshrine to teleport the cast gets interrupted
    -- This buffer fixes this issue
    g_castbarWorldMapFix = true
    eventManager:RegisterForUpdate(moduleName .. "CastBarFix", 500, CastBarWorldMapFix)
    -- Break Siege Deployment casts when opening UI windows
    if Castbar.BreakSiegeOnWindowOpen[castbar.id] then
        CombatInfo.StopCastBar()
    end
end

-- Run on the EVENT_END_SIEGE_CONTROL handler
-- Used to break the cast for Stow Siege Weapon if the player exits siege control.
function CombatInfo.OnSiegeEnd(eventCode)
    if castbar.id == 12256 then
        CombatInfo.StopCastBar()
    end
end

-- Stops Attack Cast when releasing heavy attacks
function CombatInfo.OnAbilityUsed(eventCode, actionSlotIndex)
    if actionSlotIndex == 2 then
        CombatInfo.StopCastBar()
    end
end

function CombatInfo.StopCastBar()
    local state = CombatInfo.CastBarUnlocked
    -- Don't hide the cast bar if we have it unlocked to move.
    castbar.bar.name:SetHidden(true)
    castbar.bar.timer:SetHidden(true)
    castbar:SetHidden(true)
    castbar.remain = nil
    castbar.starts = nil
    castbar.ends = nil
    g_casting = false
    eventManager:UnregisterForUpdate(moduleName .. "CastBar")

    if state then
        CombatInfo.GenerateCastbarPreview(state)
    end
end

-- Updates Cast Bar - only enabled when Cast Bar is unhidden
function CombatInfo.OnUpdateCastbar(currentTime)
    -- Update castbar
    local castStarts = castbar.starts
    local castEnds = castbar.ends
    local remain = castbar.remain - currentTime
    if remain <= 0 then
        CombatInfo.StopCastBar()
    else
        if CombatInfo.SV.CastBarTimer then
            castbar.bar.timer:SetText(string_format("%.1f", remain / 1000))
        end
        if castbar.type == 1 then
            castbar.bar.bar:SetValue((currentTime - castStarts) / (castEnds - castStarts))
        else
            castbar.bar.bar:SetValue(1 - ((currentTime - castStarts) / (castEnds - castStarts)))
        end
    end
end

-- Updates local variables with new font
function CombatInfo.ApplyFont()
    if not CombatInfo.Enabled then
        return
    end

    local function setupFont(fontNameKey, fontStyleKey, fontSizeKey, defaultFontStyle, defaultFontSize)
        local fontName = LUIE.Fonts[CombatInfo.SV[fontNameKey]]
        if not fontName or fontName == "" then
            LUIE.Debug(GetString(LUIE_STRING_ERROR_FONT))
            fontName = "Univers 67"
        end
        local fontStyle = (CombatInfo.SV[fontStyleKey] and CombatInfo.SV[fontStyleKey] ~= "") and CombatInfo.SV[fontStyleKey] or defaultFontStyle
        local fontSize = (CombatInfo.SV[fontSizeKey] and CombatInfo.SV[fontSizeKey] > 0) and CombatInfo.SV[fontSizeKey] or defaultFontSize
        return fontName .. "|" .. fontSize .. "|" .. fontStyle
    end

    g_barFont = setupFont("BarFontFace", "BarFontStyle", "BarFontSize", "outline", 17)
    for k, _ in pairs(g_uiProcAnimation) do
        g_uiProcAnimation[k].procLoopTexture.label:SetFont(g_barFont)
    end
    for k, _ in pairs(g_uiCustomToggle) do
        g_uiCustomToggle[k].label:SetFont(g_barFont)
        g_uiCustomToggle[k].stack:SetFont(g_barFont)
    end

    g_potionFont = setupFont("PotionTimerFontFace", "PotionTimerFontStyle", "PotionTimerFontSize", "outline", 17)
    if uiQuickSlot.label then
        uiQuickSlot.label:SetFont(g_potionFont)
    end

    g_ultimateFont = setupFont("UltimateFontFace", "UltimateFontStyle", "UltimateFontSize", "outline", 17)
    if uiUltimate.LabelPct then
        uiUltimate.LabelPct:SetFont(g_ultimateFont)
    end

    g_castbarFont = setupFont("CastBarFontFace", "CastBarFontStyle", "CastBarFontSize", "soft-shadow-thin", 16)
end

-- Updates Proc Sound - called on initialization and menu changes
function CombatInfo.ApplyProcSound(menu)
    local barProcSound = LUIE.Sounds[CombatInfo.SV.ProcSoundName]
    if not barProcSound or barProcSound == "" then
        printToChat(GetString(LUIE_STRING_ERROR_SOUND), true)
        barProcSound = "DeathRecap_KillingBlowShown"
    end

    g_ProcSound = barProcSound

    if menu then
        PlaySound(g_ProcSound)
    end
end

-- Resets the ultimate labels on menu option change
function CombatInfo.ResetUltimateLabel()
    uiUltimate.LabelPct:ClearAnchors()
    local actionButton = ZO_ActionBar_GetButton(8)
    uiUltimate.LabelPct:SetAnchor(TOPLEFT, actionButton.slot)
    uiUltimate.LabelPct:SetAnchor(BOTTOMRIGHT, actionButton.slot, nil, 0, -CombatInfo.SV.UltimateLabelPosition)
end

-- Resets bar labels on menu option change
function CombatInfo.ResetBarLabel()
    for k, _ in pairs(g_uiProcAnimation) do
        g_uiProcAnimation[k].procLoopTexture.label:SetText("")
    end

    for k, _ in pairs(g_uiCustomToggle) do
        g_uiCustomToggle[k].label:SetText("")
    end

    for i = BAR_INDEX_START, BAR_INDEX_END do
        -- Clear base action bars
        local actionButton = ZO_ActionBar_GetButton(i)
        if g_uiCustomToggle[i] then
            g_uiCustomToggle[i].label:ClearAnchors()
            g_uiCustomToggle[i].label:SetAnchor(TOPLEFT, actionButton.slot)
            g_uiCustomToggle[i].label:SetAnchor(BOTTOMRIGHT, actionButton.slot, nil, 0, -CombatInfo.SV.BarLabelPosition)
        elseif g_uiProcAnimation[i] then
            g_uiProcAnimation[i].procLoopTexture.label:ClearAnchors()
            g_uiProcAnimation[i].procLoopTexture.label:SetAnchor(TOPLEFT, actionButton.slot)
            g_uiProcAnimation[i].procLoopTexture.label:SetAnchor(BOTTOMRIGHT, actionButton.slot, nil, 0, -CombatInfo.SV.BarLabelPosition)
        end

        local backIndex = i + BACKBAR_INDEX_OFFSET
        local actionButtonBB = g_backbarButtons[backIndex]
        if g_uiCustomToggle[backIndex] then
            g_uiCustomToggle[backIndex].label:ClearAnchors()
            g_uiCustomToggle[backIndex].label:SetAnchor(TOPLEFT, actionButtonBB.slot)
            g_uiCustomToggle[backIndex].label:SetAnchor(BOTTOMRIGHT, actionButtonBB.slot, nil, 0, -CombatInfo.SV.BarLabelPosition)
        elseif g_uiProcAnimation[backIndex] then
            g_uiProcAnimation[backIndex].procLoopTexture.label:ClearAnchors()
            g_uiProcAnimation[backIndex].procLoopTexture.label:SetAnchor(TOPLEFT, actionButtonBB.slot)
            g_uiProcAnimation[backIndex].procLoopTexture.label:SetAnchor(BOTTOMRIGHT, actionButtonBB.slot, nil, 0, -CombatInfo.SV.BarLabelPosition)
        end
    end
end

-- Resets Potion Timer label - called on initialization and menu changes
function CombatInfo.ResetPotionTimerLabel()
    local QSB = ACTION_BAR:GetNamedChild("QuickslotButtonButton")
    uiQuickSlot.label:ClearAnchors()
    uiQuickSlot.label:SetAnchor(TOPLEFT, QSB, nil, 0, 0)
    uiQuickSlot.label:SetAnchor(BOTTOMRIGHT, QSB, nil, 0, -CombatInfo.SV.PotionTimerLabelPosition)
end

-- Runs on the EVENT_TARGET_CHANGE listener.
-- This handler fires every time the someone target changes.
-- This function is needed in case the player teleports via Way Shrine
function CombatInfo.OnTargetChange(eventCode, unitTag)
    if unitTag ~= "player" then
        return
    end
    CombatInfo.OnReticleTargetChanged(eventCode)
end

-- Runs on the EVENT_RETICLE_TARGET_CHANGED listener.
-- This handler fires every time the player's reticle target changes
function CombatInfo.OnReticleTargetChanged(eventCode)
    if not eventCode then return end
    -- Clear existing toggles that should be removed on target change
    for k, _ in pairs(g_toggledSlotsRemain) do
        local frontSlot = g_toggledSlotsFront[k]
        local backSlot = g_toggledSlotsBack[k]

        if  ((frontSlot and g_uiCustomToggle[frontSlot]) or (backSlot and g_uiCustomToggle[backSlot]))
        and not (g_toggledSlotsPlayer[k] or g_barNoRemove[k]) then
            if frontSlot and g_uiCustomToggle[frontSlot] then
                CombatInfo.HideSlot(frontSlot, k)
            end

            if backSlot and g_uiCustomToggle[backSlot] then
                CombatInfo.HideSlot(backSlot, k)
            end

            g_toggledSlotsRemain[k] = nil
            g_toggledSlotsStack[k] = nil

            if Effects.BarHighlightCheckOnFade[k] then
                CombatInfo.BarHighlightSwap(k)
            end
        end
    end

    -- Process buffs for reticle unit tag
    local unitTag = "reticleover"
    if DoesUnitExist(unitTag) then
        -- -- Debug: Print the actual unit tag when processing buffs for "reticleover"
        -- if unitTag == "reticleover" then
        --     printToChat(string.format("[DEBUG] Processing buffs for %s", zo_strformat("<<1>>", GetRawUnitName(unitTag)), true))
        -- end

        local numBuffs = GetNumBuffs(unitTag)
        for i = 1, numBuffs do
            local unitName = GetRawUnitName(unitTag)
            local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo(unitTag, i)

            local castByPlayerNumeric = castByPlayer and 1 or 5

            if not IsUnitDead(unitTag) then
                CombatInfo.OnEffectChanged(
                    0, -- eventCode
                    EFFECT_RESULT_UPDATED,
                    buffSlot,
                    buffName,
                    unitTag,
                    timeStarted,
                    timeEnding,
                    stackCount,
                    iconFilename,
                    buffType,
                    effectType,
                    abilityType,
                    statusEffectType,
                    unitName,
                    0, -- unitId
                    abilityId,
                    castByPlayerNumeric,
                    false, -- passThrough
                    0      -- savedId
                )
            end
        end
    end
end

function CombatInfo.BarHighlightSwap(abilityId, overrideRank, casterUnitTag)
    local effect = Effects.BarHighlightCheckOnFade[abilityId]
    local ids = { effect.id1 or 0, effect.id2 or 0, effect.id3 or 0 }
    local tags = { effect.unitTag, effect.id2Tag, effect.id3Tag }
    local duration = effect.duration or 0
    local durationMod = effect.durationMod or 0

    for i, id in ipairs(ids) do
        local unitTag = tags[i]
        if not DoesUnitExist(unitTag) then
            return
        end

        if duration > 0 then
            duration = ((LUIE.GetAbilityDuration(duration, overrideRank, casterUnitTag) or 0) - (LUIE.GetAbilityDuration(durationMod, overrideRank, casterUnitTag) or 0))
            local timeStarted = GetGameTimeSeconds()
            local timeEnding = timeStarted + (duration / 1000)
            CombatInfo.OnEffectChanged(nil, EFFECT_RESULT_GAINED, nil, nil, unitTag, timeStarted, timeEnding, 0, nil, nil, 1, ABILITY_TYPE_BONUS, 0, nil, nil, abilityId, 1, true)
            return
        end

        if id ~= 0 then
            for j = 1, GetNumBuffs(unitTag) do
                local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityIdNew, canClickOff, castByPlayer = GetUnitBuffInfo(unitTag, j)
                if id == abilityIdNew and castByPlayer then
                    -- Custom stack count for certain abilities
                    CombatInfo.OnEffectChanged(nil, EFFECT_RESULT_GAINED, nil, nil, unitTag, timeStarted, timeEnding, stackCount, nil, buffType, effectType, abilityType, statusEffectType, nil, nil, abilityId, 1, true, abilityIdNew)
                    return
                end
            end
        end
    end
end

-- Extra returns here - passThrough & savedId
function CombatInfo.OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, castByPlayer, passThrough, savedId)
    -- If we're displaying a fake bar highlight then bail out here (sometimes we need a fake aura that doesn't end to simulate effects that can be overwritten, such as Major/Minor buffs. Technically we don't want to stop the
    -- highlight of the original ability since we can only track one buff per slot and overwriting the buff with a longer duration buff shouldn't throw the player off by making the glow disappear earlier.
    if g_barFakeAura[abilityId] and not passThrough then
        return
    end
    -- Bail out if this effect wasn't cast by the player.
    if castByPlayer ~= COMBAT_UNIT_TYPE_PLAYER then
        return
    end

    -- Update ultimate label on vampire stage change.
    if Effects.IsVamp[abilityId] and changeType == EFFECT_RESULT_GAINED then
        CombatInfo.UpdateUltimateLabel()
    end

    if Castbar.CastBreakOnRemoveEffect[abilityId] and changeType == EFFECT_RESULT_FADED then
        CombatInfo.StopCastBar()
        if abilityId == 33208 then
            return
        end -- Devour (Werewolf)
    end

    -- If this effect is on the player than as long as it remains it won't fade when we mouseover another target.
    if unitTag == "player" then
        if changeType ~= EFFECT_RESULT_FADED then
            g_toggledSlotsPlayer[abilityId] = true
        else
            g_toggledSlotsPlayer[abilityId] = nil
        end
    end

    if (Effects.EffectGroundDisplay[abilityId] or Effects.LinkedGroundMine[abilityId]) and not passThrough then
        if Effects.LinkedGroundMine[abilityId] then
            abilityId = Effects.LinkedGroundMine[abilityId]
        end

        if changeType == EFFECT_RESULT_FADED then
            if abilityId == 32958 then
                return
            end -- Ignore Shifting Standard
            local currentTime = GetGameTimeMilliseconds()
            if not g_protectAbilityRemoval[abilityId] or g_protectAbilityRemoval[abilityId] < currentTime then
                if Effects.IsGroundMineAura[abilityId] or Effects.IsGroundMineStack[abilityId] then
                    if g_mineStacks[abilityId] then
                        g_mineStacks[abilityId] = g_mineStacks[abilityId] - Effects.EffectGroundDisplay[abilityId].stackRemove

                        -- Set Stacks label if changed
                        if CombatInfo.SV.BarShowLabel then
                            if g_toggledSlotsFront[abilityId] and g_uiCustomToggle[g_toggledSlotsFront[abilityId]] then
                                if not Effects.HideGroundMineStacks[abilityId] then
                                    local slotNum = g_toggledSlotsFront[abilityId]
                                    if g_uiCustomToggle[slotNum] then
                                        if g_mineStacks[abilityId] > 0 then
                                            g_uiCustomToggle[slotNum].stack:SetText(g_mineStacks[abilityId])
                                        else
                                            g_uiCustomToggle[slotNum].stack:SetText("")
                                        end
                                    end
                                end
                            end
                            if g_toggledSlotsBack[abilityId] and g_uiCustomToggle[g_toggledSlotsBack[abilityId]] then
                                if not Effects.HideGroundMineStacks[abilityId] then
                                    local slotNum = g_toggledSlotsBack[abilityId]
                                    if g_uiCustomToggle[slotNum] then
                                        if g_mineStacks[abilityId] > 0 then
                                            g_uiCustomToggle[slotNum].stack:SetText(g_mineStacks[abilityId])
                                        else
                                            g_uiCustomToggle[slotNum].stack:SetText("")
                                        end
                                    end
                                end
                            end
                        end

                        -- Handle stacks reaching 0
                        if g_mineStacks[abilityId] == 0 and not g_mineNoTurnOff[abilityId] then
                            if g_toggledSlotsRemain[abilityId] then
                                if g_toggledSlotsFront[abilityId] and g_uiCustomToggle[g_toggledSlotsFront[abilityId]] then
                                    local slotNum = g_toggledSlotsFront[abilityId]
                                    CombatInfo.HideSlot(slotNum, abilityId)
                                end
                                if g_toggledSlotsBack[abilityId] and g_uiCustomToggle[g_toggledSlotsBack[abilityId]] then
                                    local slotNum = g_toggledSlotsBack[abilityId]
                                    CombatInfo.HideSlot(slotNum, abilityId)
                                end
                            end
                            g_toggledSlotsRemain[abilityId] = nil
                            g_toggledSlotsStack[abilityId] = nil
                            if Effects.BarHighlightCheckOnFade[abilityId] then
                                CombatInfo.BarHighlightSwap(abilityId)
                            end
                        end
                    end
                else
                    -- Ignore fading event if override is true
                    if g_barNoRemove[abilityId] then
                        return
                    end
                    -- Stop any toggle animation associated with this effect
                    if g_toggledSlotsRemain[abilityId] then
                        if g_toggledSlotsFront[abilityId] and g_uiCustomToggle[g_toggledSlotsFront[abilityId]] then
                            local slotNum = g_toggledSlotsFront[abilityId]
                            CombatInfo.HideSlot(slotNum, abilityId)
                        end
                        if g_toggledSlotsBack[abilityId] and g_uiCustomToggle[g_toggledSlotsBack[abilityId]] then
                            local slotNum = g_toggledSlotsBack[abilityId]
                            CombatInfo.HideSlot(slotNum, abilityId)
                        end
                    end
                    g_toggledSlotsRemain[abilityId] = nil
                    g_toggledSlotsStack[abilityId] = nil
                end
            end
        elseif changeType == EFFECT_RESULT_GAINED then
            if g_mineNoTurnOff[abilityId] then
                g_mineNoTurnOff[abilityId] = nil
            end

            local currentTime = GetGameTimeMilliseconds()
            g_protectAbilityRemoval[abilityId] = currentTime + 150

            if Effects.IsGroundMineAura[abilityId] then
                g_mineStacks[abilityId] = Effects.EffectGroundDisplay[abilityId].stackReset
            elseif Effects.IsGroundMineStack[abilityId] then
                -- Check if this is an existing mine with stacks
                if g_mineStacks[abilityId] then
                    g_mineStacks[abilityId] = g_mineStacks[abilityId] + Effects.EffectGroundDisplay[abilityId].stackRemove
                    -- Otherwise set the count to 1
                else
                    g_mineStacks[abilityId] = 1
                end
                -- If the stack counter is higher than a manual limit we set then override it to that value
                if g_mineStacks[abilityId] > Effects.EffectGroundDisplay[abilityId].stackReset then
                    g_mineStacks[abilityId] = Effects.EffectGroundDisplay[abilityId].stackReset
                end
            end

            -- Bar Tracker
            if CombatInfo.SV.ShowToggled then
                -- We set this to true but never set remove it, this is effectively an on the fly way to create an indentifier for ground effects that shouldn't be removed on reticle target change, only on fade.
                g_toggledSlotsPlayer[abilityId] = true
                local currentTimeST = GetGameTimeMilliseconds()
                if g_toggledSlotsFront[abilityId] or g_toggledSlotsBack[abilityId] then
                    g_toggledSlotsRemain[abilityId] = 1000 * endTime
                    g_toggledSlotsStack[abilityId] = stackCount
                    if g_toggledSlotsFront[abilityId] then
                        local slotNum = g_toggledSlotsFront[abilityId]
                        CombatInfo.ShowSlot(slotNum, abilityId, currentTimeST, false)
                    end
                    if g_toggledSlotsBack[abilityId] then
                        local slotNum = g_toggledSlotsBack[abilityId]
                        CombatInfo.ShowSlot(slotNum, abilityId, currentTimeST, false)
                    end
                end
            end
        end
    end

    -- Custom stack count for certain abilities
    if savedId and Effects.BarHighlightStack[savedId] then
        -- Grab the stack count from the saved id if this is a "BarHighlightCheckOnFade"
        stackCount = Effects.BarHighlightStack[savedId]
    elseif Effects.BarHighlightStack[abilityId] then
        stackCount = Effects.BarHighlightStack[abilityId]
    end

    -- Only proceed with ability ID hijacking if FancyActionBar is not active
    if not FancyActionBar then
        -- Hijack the abilityId here if we have it in the override for extra bar highlights
        if Effects.BarHighlightExtraId[abilityId] then
            for k, v in pairs(Effects.BarHighlightExtraId) do
                if k == abilityId then
                    abilityId = v
                    if Effects.IsGroundMineAura[abilityId] then
                        -- This prevents debuffs from ground mines from not fading when mouseover is changed.
                        g_toggledSlotsPlayer[abilityId] = nil
                        if unitTag == "reticleover" then
                            g_mineNoTurnOff[abilityId] = true
                        end
                    end
                    break
                end
            end
        end
    end

    if unitTag ~= "player" and unitTag ~= "reticleover" then
        return
    end

    -- delete Effect
    if changeType == EFFECT_RESULT_FADED then
        -- Ignore fading event if override is true
        if g_barNoRemove[abilityId] then
            if Effects.BarHighlightCheckOnFade[abilityId] then
                CombatInfo.BarHighlightSwap(abilityId)
            end
            return
        end

        -- Stop any proc animation associated with this effect
        if g_triggeredSlotsRemain[abilityId] then
            if g_triggeredSlotsFront[abilityId] and g_uiProcAnimation[g_triggeredSlotsFront[abilityId]] then
                g_uiProcAnimation[g_triggeredSlotsFront[abilityId]]:Stop()
            end
            if g_triggeredSlotsBack[abilityId] and g_uiProcAnimation[g_triggeredSlotsBack[abilityId]] then
                g_uiProcAnimation[g_triggeredSlotsBack[abilityId]]:Stop()
            end
            g_triggeredSlotsRemain[abilityId] = nil
        end
        -- Stop any toggle animation associated with this effect
        if g_toggledSlotsRemain[abilityId] then
            if g_toggledSlotsFront[abilityId] and g_uiCustomToggle[g_toggledSlotsFront[abilityId]] then
                local slotNum = g_toggledSlotsFront[abilityId]
                CombatInfo.HideSlot(slotNum, abilityId)
            end
            if g_toggledSlotsBack[abilityId] and g_uiCustomToggle[g_toggledSlotsBack[abilityId]] then
                local slotNum = g_toggledSlotsBack[abilityId]
                CombatInfo.HideSlot(slotNum, abilityId)
            end
            g_toggledSlotsRemain[abilityId] = nil
            g_toggledSlotsStack[abilityId] = nil
        end

        if Effects.BarHighlightCheckOnFade[abilityId] then
            CombatInfo.BarHighlightSwap(abilityId)
        end
    else
        -- Also create visual enhancements from skill bar
        -- Handle proc sound for Bound Armaments / Grim Focus
        if abilityId == 203447 or Effects.IsGrimFocus[abilityId] then
            if CombatInfo.SV.ShowTriggered and CombatInfo.SV.ProcEnableSound then
                local stack = Effects.IsGrimFocus[abilityId] and 5 or 4
                if stackCount ~= stack then
                    g_boundArmamentsPlayed = false
                end
                if stackCount == stack and not g_boundArmamentsPlayed then
                    PlaySound(g_ProcSound)
                    PlaySound(g_ProcSound)
                    g_boundArmamentsPlayed = true
                end
            end
        end
        -- start any proc animation associated with this effect
        if g_triggeredSlotsFront[abilityId] or g_triggeredSlotsBack[abilityId] then
            local currentTime = GetGameTimeMilliseconds()
            if CombatInfo.SV.ShowTriggered then
                -- Play sound twice so its a little louder.
                if CombatInfo.SV.ProcEnableSound and unitTag == "player" and g_triggeredSlotsFront[abilityId] then
                    if abilityId == 46327 then
                        if changeType == EFFECT_RESULT_GAINED then
                            PlaySound(g_ProcSound)
                            PlaySound(g_ProcSound)
                        end
                    else
                        PlaySound(g_ProcSound)
                        PlaySound(g_ProcSound)
                    end
                end
                g_triggeredSlotsRemain[abilityId] = 1000 * endTime
                local remain = g_triggeredSlotsRemain[abilityId] - currentTime
                -- Front
                if g_triggeredSlotsFront[abilityId] then
                    CombatInfo.PlayProcAnimations(g_triggeredSlotsFront[abilityId])
                    if CombatInfo.SV.BarShowLabel and g_uiProcAnimation[g_triggeredSlotsFront[abilityId]] then
                        g_uiProcAnimation[g_triggeredSlotsFront[abilityId]].procLoopTexture.label:SetText(SetBarRemainLabel(remain, abilityId))
                    end
                end
                -- Back
                if g_triggeredSlotsBack[abilityId] then
                    CombatInfo.PlayProcAnimations(g_triggeredSlotsBack[abilityId])
                    if CombatInfo.SV.BarShowLabel and g_uiProcAnimation[g_triggeredSlotsBack[abilityId]] then
                        g_uiProcAnimation[g_triggeredSlotsBack[abilityId]].procLoopTexture.label:SetText(SetBarRemainLabel(remain, abilityId))
                    end
                end
            end
        end
        -- Display active effects
        if g_toggledSlotsFront[abilityId] or g_toggledSlotsBack[abilityId] then
            local currentTime = GetGameTimeMilliseconds()
            if CombatInfo.SV.ShowToggled then
                -- Add fake duration to Grim Focus so the highlight stays
                if Effects.IsGrimFocus[abilityId] or Effects.IsBloodFrenzy[abilityId] then
                    g_toggledSlotsRemain[abilityId] = currentTime + 90000000
                else
                    g_toggledSlotsRemain[abilityId] = 1000 * endTime
                end
                g_toggledSlotsStack[abilityId] = stackCount
                if g_toggledSlotsFront[abilityId] then
                    local slotNum = g_toggledSlotsFront[abilityId]
                    CombatInfo.ShowSlot(slotNum, abilityId, currentTime, false)
                end
                if g_toggledSlotsBack[abilityId] then
                    local slotNum = g_toggledSlotsBack[abilityId]
                    CombatInfo.ShowSlot(slotNum, abilityId, currentTime, false)
                end
            end
        end
    end
end

function CombatInfo.HideSlot(slotNum, abilityId)
    g_uiCustomToggle[slotNum]:SetHidden(true)
    if slotNum > BACKBAR_INDEX_OFFSET then
        if slotNum ~= BAR_INDEX_END + BACKBAR_INDEX_OFFSET then
            CombatInfo.BackbarHideSlot(slotNum)
            CombatInfo.ToggleBackbarSaturation(slotNum, CombatInfo.SV.BarDarkUnused)
        end
    end
    if slotNum == g_ultimateSlot and CombatInfo.SV.UltimatePctEnabled and IsSlotUsed(g_ultimateSlot, g_hotbarCategory) then
        uiUltimate.LabelPct:SetHidden(false)
    end
end

function CombatInfo.ShowSlot(slotNum, abilityId, currentTime, desaturate)
    CombatInfo.ShowCustomToggle(slotNum)
    if slotNum > BACKBAR_INDEX_OFFSET then
        if slotNum ~= BAR_INDEX_END + BACKBAR_INDEX_OFFSET then
            CombatInfo.BackbarShowSlot(slotNum)
            CombatInfo.ToggleBackbarSaturation(slotNum, desaturate)
        end
    end
    if slotNum == 8 and CombatInfo.SV.UltimatePctEnabled then
        uiUltimate.LabelPct:SetHidden(true)
    end
    if CombatInfo.SV.BarShowLabel then
        if not g_uiCustomToggle[slotNum] then
            return
        end
        local remain = g_toggledSlotsRemain[abilityId] - currentTime
        g_uiCustomToggle[slotNum].label:SetText(SetBarRemainLabel(remain, abilityId))
        if g_toggledSlotsStack[abilityId] and g_toggledSlotsStack[abilityId] > 0 then
            g_uiCustomToggle[slotNum].stack:SetText(g_toggledSlotsStack[abilityId])
        elseif g_mineStacks[abilityId] and g_mineStacks[abilityId] > 0 then
            -- No stack for Time Freeze
            if not Effects.HideGroundMineStacks[abilityId] then
                g_uiCustomToggle[slotNum].stack:SetText(g_mineStacks[abilityId])
            end
        else
            g_uiCustomToggle[slotNum].stack:SetText("")
        end
    end
end

function CombatInfo.BackbarHideSlot(slotNum)
    if CombatInfo.SV.BarHideUnused then
        if g_backbarButtons[slotNum] then
            g_backbarButtons[slotNum].slot:SetHidden(true)
        end
    end
end

function CombatInfo.BackbarShowSlot(slotNum)
    -- Unhide the slot
    if CombatInfo.SV.BarShowBack then
        if g_backbarButtons[slotNum] then
            g_backbarButtons[slotNum].slot:SetHidden(false)
        end
    end
end

function CombatInfo.ToggleBackbarSaturation(slotNum, desaturate)
    local button = g_backbarButtons[slotNum]
    if CombatInfo.SV.BarDarkUnused then
        ZO_ActionSlot_SetUnusable(button.icon, desaturate, false)
    end
    if CombatInfo.SV.BarDesaturateUnused then
        local saturation = desaturate and 1 or 0
        button.icon:SetDesaturation(saturation)
    end
end

-- Called on initialization and when swapping in and out of Gamepad mode
function CombatInfo.BackbarSetupTemplate()
    local style = IsInGamepadPreferredMode() and GAMEPAD_CONSTANTS or KEYBOARD_CONSTANTS
    local weaponSwapControl = ACTION_BAR:GetNamedChild("WeaponSwap")

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
            targetButton:ApplyStyle(buttonTemplate)
        end

        lastButton = targetButton
    end

    -- Anchor the backbar to the normal action bar with spacing
    local offsetY = IsInGamepadPreferredMode() and ACTION_BAR:GetHeight() * 1.6 or ACTION_BAR:GetHeight()
    local ActionButton53 = GetControl("ActionButton53")
    local AB3 = _G["ActionButton3"]
    ActionButton53:ClearAnchors()
    ActionButton53:SetAnchor(CENTER, AB3, CENTER, 0, -(offsetY * 0.8))
end

-- Called from the menu and on init
function CombatInfo.BackbarToggleSettings()
    for i = BAR_INDEX_START, BACKBAR_INDEX_END do
        -- Get our backbar button
        local targetButton = g_backbarButtons[i + BACKBAR_INDEX_OFFSET]

        if CombatInfo.SV.BarShowBack and not CombatInfo.SV.BarHideUnused then
            targetButton.slot:SetHidden(false)
        end
        ZO_ActionSlot_SetUnusable(targetButton.icon, CombatInfo.SV.BarDarkUnused, false)
        local saturation = CombatInfo.SV.BarDesaturateUnused and 1 or 0
        targetButton.icon:SetDesaturation(saturation)

        if CombatInfo.SV.BarHideUnused or not CombatInfo.SV.BarShowBack then
            targetButton.slot:SetHidden(true)
        end
    end
end

function CombatInfo.CreateCastBar()
    uiTlw.castBar = UI:TopLevel(nil, nil)

    uiTlw.castBar:SetDimensions(CombatInfo.SV.CastBarSizeW + CombatInfo.SV.CastBarIconSize + 4, CombatInfo.SV.CastBarSizeH)

    -- Setup Preview
    uiTlw.castBar.preview = UI:Backdrop(uiTlw.castBar, "fill", nil, nil, nil, true)
    uiTlw.castBar.previewLabel = UI:Label(uiTlw.castBar.preview, { CENTER, CENTER }, nil, nil, "ZoFontGameMedium", "Cast Bar", false)

    -- Callback used to hide anchor coords preview label on movement start
    local tlwOnMoveStart = function (self)
        eventManager:RegisterForUpdate(moduleName .. "PreviewMove", 200, function ()
            self.preview.anchorLabel:SetText(zo_strformat("<<1>>, <<2>>", self:GetLeft(), self:GetTop()))
        end)
    end
    -- Callback used to save new position of frames
    local tlwOnMoveStop = function (self)
        eventManager:UnregisterForUpdate(moduleName .. "PreviewMove")
        CombatInfo.SV.CastbarOffsetX = self:GetLeft()
        CombatInfo.SV.CastbarOffsetY = self:GetTop()
        CombatInfo.SV.CastBarCustomPosition = { self:GetLeft(), self:GetTop() }
    end

    uiTlw.castBar:SetHandler("OnMoveStart", tlwOnMoveStart)
    uiTlw.castBar:SetHandler("OnMoveStop", tlwOnMoveStop)

    uiTlw.castBar.preview.anchorTexture = UI:Texture(uiTlw.castBar.preview, { TOPLEFT, TOPLEFT }, { 16, 16 }, "/esoui/art/reticle/border_topleft.dds", DL_OVERLAY, false)
    uiTlw.castBar.preview.anchorTexture:SetColor(1, 1, 0, 0.9)

    uiTlw.castBar.preview.anchorLabel = UI:Label(uiTlw.castBar.preview, { BOTTOMLEFT, TOPLEFT, 0, -1 }, nil, { 0, 2 }, "ZoFontGameSmall", "xxx, yyy", false)
    uiTlw.castBar.preview.anchorLabel:SetColor(1, 1, 0, 1)
    uiTlw.castBar.preview.anchorLabel:SetDrawLayer(DL_OVERLAY)
    uiTlw.castBar.preview.anchorLabel:SetDrawTier(DT_MEDIUM)
    uiTlw.castBar.preview.anchorLabelBg = UI:Backdrop(uiTlw.castBar.preview.anchorLabel, "fill", nil, { 0, 0, 0, 1 }, { 0, 0, 0, 1 }, false)
    uiTlw.castBar.preview.anchorLabelBg:SetDrawLayer(DL_OVERLAY)
    uiTlw.castBar.preview.anchorLabelBg:SetDrawTier(DT_LOW)

    local fragment = ZO_HUDFadeSceneFragment:New(uiTlw.castBar, 0, 0)

    sceneManager:GetScene("hud"):AddFragment(fragment)
    sceneManager:GetScene("hudui"):AddFragment(fragment)
    sceneManager:GetScene("siegeBar"):AddFragment(fragment)
    sceneManager:GetScene("siegeBarUI"):AddFragment(fragment)

    castbar = UI:Backdrop(uiTlw.castBar, nil, nil, { 0, 0, 0, 0.5 }, { 0, 0, 0, 1 }, false)
    castbar:SetAnchor(LEFT, uiTlw.castBar, LEFT, 0, 0)

    castbar.starts = 0
    castbar.ends = 0
    castbar.remain = 0

    castbar:SetDimensions(CombatInfo.SV.CastBarIconSize, CombatInfo.SV.CastBarIconSize)

    castbar.back = UI:Texture(castbar, nil, nil, "LuiExtended/media/icons/icon_border/icon-border.dds", nil, false)
    castbar.back:SetAnchor(TOPLEFT, castbar, TOPLEFT, 0, 0)
    castbar.back:SetAnchor(BOTTOMRIGHT, castbar, BOTTOMRIGHT, 0, 0)

    castbar.iconbg = UI:Texture(castbar, nil, nil, "/esoui/art/actionbar/abilityinset.dds", DL_CONTROLS, false)
    castbar.iconbg = UI:Backdrop(castbar, nil, nil, { 0, 0, 0, 0.9 }, { 0, 0, 0, 0.9 }, false)
    castbar.iconbg:SetDrawLevel(DL_CONTROLS)
    castbar.iconbg:SetAnchor(TOPLEFT, castbar, TOPLEFT, 3, 3)
    castbar.iconbg:SetAnchor(BOTTOMRIGHT, castbar, BOTTOMRIGHT, -3, -3)

    castbar.icon = UI:Texture(castbar, nil, nil, "/esoui/art/icons/icon_missing.dds", DL_CONTROLS, false)
    castbar.icon:SetAnchor(TOPLEFT, castbar, TOPLEFT, 3, 3)
    castbar.icon:SetAnchor(BOTTOMRIGHT, castbar, BOTTOMRIGHT, -3, -3)

    castbar.bar =
    {
        ["backdrop"] = UI:Backdrop(castbar, nil, { CombatInfo.SV.CastBarSizeW, CombatInfo.SV.CastBarSizeH }, nil, nil, false),
        ["bar"] = UI:StatusBar(castbar, nil, { CombatInfo.SV.CastBarSizeW - 4, CombatInfo.SV.CastBarSizeH - 4 }, nil, false),
        ["name"] = UI:Label(castbar, nil, nil, nil, nil, g_castbarFont, false),
        ["timer"] = UI:Label(castbar, nil, nil, nil, nil, g_castbarFont, false),
    }
    castbar.id = 0

    castbar.bar.backdrop:SetEdgeTexture("", 8, 2, 2, 2)
    castbar.bar.backdrop:SetDrawLayer(DL_BACKGROUND)
    castbar.bar.backdrop:SetDrawLevel(DL_CONTROLS)
    castbar.bar.bar:SetMinMax(0, 1)
    castbar.bar.backdrop:SetCenterColor((0.1 * 0.50), (0.1 * 0.50), (0.1 * 0.50), 0.75)
    castbar.bar.bar:SetGradientColors(0, 47 / 255, 130 / 255, 1, 82 / 255, 215 / 255, 1, 1)
    castbar.bar.backdrop:SetCenterColor((0.1 * CombatInfo.SV.CastBarGradientC1[1]), (0.1 * CombatInfo.SV.CastBarGradientC1[2]), (0.1 * CombatInfo.SV.CastBarGradientC1[3]), 0.75)
    castbar.bar.bar:SetGradientColors(CombatInfo.SV.CastBarGradientC1[1], CombatInfo.SV.CastBarGradientC1[2], CombatInfo.SV.CastBarGradientC1[3], 1, CombatInfo.SV.CastBarGradientC2[1], CombatInfo.SV.CastBarGradientC2[2], CombatInfo.SV.CastBarGradientC2[3], 1)

    castbar.bar.backdrop:ClearAnchors()
    castbar.bar.backdrop:SetAnchor(LEFT, castbar, RIGHT, 4, 0)

    castbar.bar.timer:ClearAnchors()
    castbar.bar.timer:SetAnchor(RIGHT, castbar.bar.backdrop, RIGHT, -4, 0)
    castbar.bar.timer:SetHidden(true)

    castbar.bar.name:ClearAnchors()
    castbar.bar.name:SetAnchor(LEFT, castbar.bar.backdrop, LEFT, 4, 0)
    castbar.bar.name:SetHidden(true)

    castbar.bar.bar:SetTexture(LUIE.StatusbarTextures[CombatInfo.SV.CastBarTexture])
    castbar.bar.bar:ClearAnchors()
    castbar.bar.bar:SetAnchor(CENTER, castbar.bar.backdrop, CENTER, 0, 0)
    castbar.bar.bar:SetAnchor(CENTER, castbar.bar.backdrop, CENTER, 0, 0)

    castbar.bar.timer:SetText("Timer")
    castbar.bar.name:SetText("Name")

    castbar:SetHidden(true)
end

function CombatInfo.ResizeCastBar()
    uiTlw.castBar:SetDimensions(CombatInfo.SV.CastBarSizeW + CombatInfo.SV.CastBarIconSize + 4, CombatInfo.SV.CastBarSizeH)
    castbar:ClearAnchors()
    castbar:SetAnchor(LEFT, uiTlw.castBar, LEFT)

    castbar:SetDimensions(CombatInfo.SV.CastBarIconSize, CombatInfo.SV.CastBarIconSize)
    castbar.bar.backdrop:SetDimensions(CombatInfo.SV.CastBarSizeW, CombatInfo.SV.CastBarSizeH)
    castbar.bar.bar:SetDimensions(CombatInfo.SV.CastBarSizeW - 4, CombatInfo.SV.CastBarSizeH - 4)

    castbar.bar.backdrop:ClearAnchors()
    castbar.bar.backdrop:SetAnchor(LEFT, castbar, RIGHT, 4, 0)

    castbar.bar.timer:ClearAnchors()
    castbar.bar.timer:SetAnchor(RIGHT, castbar.bar.backdrop, RIGHT, -4, 0)

    castbar.bar.name:ClearAnchors()
    castbar.bar.name:SetAnchor(LEFT, castbar.bar.backdrop, LEFT, 4, 0)

    castbar.bar.bar:ClearAnchors()
    castbar.bar.bar:SetAnchor(CENTER, castbar.bar.backdrop, CENTER, 0, 0)
    castbar.bar.bar:SetAnchor(CENTER, castbar.bar.backdrop, CENTER, 0, 0)

    CombatInfo.SetCastBarPosition()
end

function CombatInfo.UpdateCastBar()
    castbar.bar.name:SetFont(g_castbarFont)
    castbar.bar.timer:SetFont(g_castbarFont)
    castbar.bar.bar:SetTexture(LUIE.StatusbarTextures[CombatInfo.SV.CastBarTexture])
    castbar.bar.backdrop:SetCenterColor((0.1 * CombatInfo.SV.CastBarGradientC1[1]), (0.1 * CombatInfo.SV.CastBarGradientC1[2]), (0.1 * CombatInfo.SV.CastBarGradientC1[3]), 0.75)
    castbar.bar.bar:SetGradientColors(CombatInfo.SV.CastBarGradientC1[1], CombatInfo.SV.CastBarGradientC1[2], CombatInfo.SV.CastBarGradientC1[3], 1, CombatInfo.SV.CastBarGradientC2[1], CombatInfo.SV.CastBarGradientC2[2], CombatInfo.SV.CastBarGradientC2[3], 1)
end

function CombatInfo.ResetCastBarPosition()
    if not CombatInfo.Enabled then
        return
    end
    CombatInfo.SV.CastbarOffsetX = nil
    CombatInfo.SV.CastbarOffsetY = nil
    CombatInfo.SV.CastBarCustomPosition = nil
    CombatInfo.SetCastBarPosition()
    CombatInfo.SetMovingState(false)
end

function CombatInfo.SetCastBarPosition()
    if uiTlw.castBar and uiTlw.castBar:GetType() == CT_TOPLEVELCONTROL then
        uiTlw.castBar:ClearAnchors()

        if CombatInfo.SV.CastbarOffsetX ~= nil and CombatInfo.SV.CastbarOffsetY ~= nil then
            uiTlw.castBar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CombatInfo.SV.CastbarOffsetX, CombatInfo.SV.CastbarOffsetY)
        else
            uiTlw.castBar:SetAnchor(CENTER, GuiRoot, CENTER, 0, 320)
        end
    end

    local savedPos = CombatInfo.SV.CastBarCustomPosition
    uiTlw.castBar.preview.anchorLabel:SetText((savedPos ~= nil and #savedPos == 2) and zo_strformat("<<1>>, <<2>>", savedPos[1], savedPos[2]) or "default")
end

function CombatInfo.SetMovingState(state)
    if not CombatInfo.Enabled then
        return
    end
    CombatInfo.CastBarUnlocked = state
    if uiTlw.castBar and uiTlw.castBar:GetType() == CT_TOPLEVELCONTROL then
        CombatInfo.GenerateCastbarPreview(state)
        uiTlw.castBar:SetMouseEnabled(state)
        uiTlw.castBar:SetMovable(state)
    end
end

-- Called by CombatInfo.SetMovingState from the menu as well as by CombatInfo.OnUpdateCastbar when preview is enabled
function CombatInfo.GenerateCastbarPreview(state)
    local previewIcon = "/esoui/art/icons/icon_missing.dds"
    castbar.icon:SetTexture(previewIcon)
    if CombatInfo.SV.CastBarLabel then
        local previewName = "Test"
        castbar.bar.name:SetText(previewName)
        castbar.bar.name:SetHidden(not state)
    end
    if CombatInfo.SV.CastBarTimer then
        castbar.bar.timer:SetText(string_format("1.0"))
        castbar.bar.timer:SetHidden(not state)
    end
    castbar.bar.bar:SetValue(1)

    uiTlw.castBar.preview:SetHidden(not state)
    uiTlw.castBar:SetHidden(not state)
    castbar:SetHidden(not state)
end

--[[
function CombatInfo.ClientInteractResult(eventCode, result, interactTargetName)

    local function DisplayInteractCast(icon, name, duration)
        local currentTime = GetGameTimeMilliseconds()
        local endTime = currentTime + duration
        local remain = endTime - currentTime

        castbar.remain = endTime
        castbar.starts = currentTime
        castbar.ends = endTime
        castbar.icon:SetTexture(icon)
        castbar.type = 1 -- CAST
        castbar.bar.bar:SetValue(0)
        castbar.id = 999999

        if CombatInfo.SV.CastBarLabel then
            castbar.bar.name:SetText(name)
            castbar.bar.name:SetHidden(false)
        end
        if CombatInfo.SV.CastBarTimer then
            castbar.bar.timer:SetText(string_format("%.1f", remain/1000))
            castbar.bar.timer:SetHidden(false)
        end

        castbar:SetHidden(false)
        g_casting = true
        eventManager:RegisterForUpdate(moduleName .. "CastBar", 20, CombatInfo.OnUpdateCastbar)
    end

    -- If we succesfully interact then...
    if result == CLIENT_INTERACT_RESULT_SUCCESS then
        -- Check if the interact object name is in our table
        if Castbar.InteractCast[interactTargetName] then
            -- Get the map id and check if there is an entry for this id
            index = GetZoneId(GetCurrentMapZoneIndex())
            if Castbar.InteractCast[interactTargetName][index] then
                local data = Castbar.InteractCast[interactTargetName][index]
                local icon = data.icon
                local name = data.name
                local duration = data.duration
                local delay = data.delay
                zo_callLater(function() DisplayInteractCast(icon, name, duration) end, delay)
            end
        end
    end

end
]]
--

function CombatInfo.SoulGemResurrectionStart(eventCode, durationMs)
    -- Just in case any other casts are present - stop them first
    CombatInfo.StopCastBar()

    -- Set all parameters and start cast bar
    local icon = "/esoui/art/icons/achievement_frostvault_death_challenge.dds"
    local name = Abilities.Innate_Soul_Gem_Resurrection
    local duration = durationMs

    local currentTime = GetGameTimeMilliseconds()
    local endTime = currentTime + duration
    local remain = endTime - currentTime

    castbar.remain = endTime
    castbar.starts = currentTime
    castbar.ends = endTime
    castbar.icon:SetTexture(icon)
    castbar.type = 1 -- CAST
    castbar.bar.bar:SetValue(0)

    if CombatInfo.SV.CastBarLabel then
        castbar.bar.name:SetText(name)
        castbar.bar.name:SetHidden(false)
    end
    if CombatInfo.SV.CastBarTimer then
        castbar.bar.timer:SetText(string_format("%.1f", remain / 1000))
        castbar.bar.timer:SetHidden(false)
    end

    castbar:SetHidden(false)
    g_casting = true
    eventManager:RegisterForUpdate(moduleName .. "CastBar", 20, CombatInfo.OnUpdateCastbar)
end

function CombatInfo.SoulGemResurrectionEnd(eventCode)
    CombatInfo.StopCastBar()
end

-- Very basic handler registered to only read CC events on the player
function CombatInfo.OnCombatEventBreakCast(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    -- Some cast/channel abilities (or effects we use to simulate this) stun the player - ignore the effects of these ids when this happens.
    if Castbar.IgnoreCastBarStun[abilityId] or Castbar.IgnoreCastBreakingActions[castbar.id] then
        return
    end

    if not Castbar.IsCast[abilityId] then
        CombatInfo.StopCastBar()
    end
end

local function isValidDamageResult(result)
    if result == ACTION_RESULT_BLOCKED or result == ACTION_RESULT_BLOCKED_DAMAGE or result == ACTION_RESULT_CRITICAL_DAMAGE or result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_DAMAGE_SHIELDED or result == ACTION_RESULT_IMMUNE or result == ACTION_RESULT_MISS or result == ACTION_RESULT_PARTIAL_RESIST or result == ACTION_RESULT_REFLECTED or result == ACTION_RESULT_RESIST or result == ACTION_RESULT_WRECKING_DAMAGE or result == ACTION_RESULT_DODGED then
        return true
    end
end

-- Listens to EVENT_COMBAT_EVENT
function CombatInfo.OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overrideRank, casterUnitTag)
    -- Track ultimate generation when we block an attack or hit a target with a light/medium/heavy attack.
    if CombatInfo.SV.UltimateGeneration and uiUltimate.NotFull and ((result == ACTION_RESULT_BLOCKED_DAMAGE and targetType == COMBAT_UNIT_TYPE_PLAYER) or (Effects.IsWeaponAttack[abilityName] and sourceType == COMBAT_UNIT_TYPE_PLAYER and targetName ~= "")) then
        uiUltimate.Texture:SetHidden(false)
        uiUltimate.FadeTime = GetGameTimeMilliseconds() + 8000
    end

    -- Trap Beast aura removal helper function since there is no aura for it
    if Effects.IsGroundMineDamage[abilityId] then
        if isValidDamageResult(result) then
            local compareId
            if abilityId == 35754 then
                compareId = 35750
            elseif abilityId == 40389 then
                compareId = 40382
            elseif abilityId == 40376 then
                compareId = 40372
            end
            if compareId then
                if g_barNoRemove[compareId] then
                    if Effects.BarHighlightCheckOnFade[compareId] then
                        CombatInfo.BarHighlightSwap(compareId)
                    end
                    return
                end
            end
        end
    end

    -- Bail out past here if the cast bar is disabled or
    if
    not CombatInfo.SV.CastBarEnable or (
        (sourceType ~= COMBAT_UNIT_TYPE_PLAYER and not Castbar.CastOverride[abilityId]) -- source isn't the player and the ability is not on the list of abilities to show the cast bar for
        and (targetType ~= COMBAT_UNIT_TYPE_PLAYER or result ~= ACTION_RESULT_EFFECT_FADED)
    )                                                                                   -- target isn't the player with effect faded
    then
        return
    end

    -- Stop when a cast breaking action is detected
    if Castbar.CastBreakingActions[abilityId] then
        if not Castbar.IgnoreCastBreakingActions[castbar.id] then
            CombatInfo.StopCastBar()
        end
    end

    local icon = GetAbilityIcon(abilityId)
    local cachedName = ZO_CachedStrFormat(SI_ABILITY_NAME, GetAbilityName(abilityId))
    local name = cachedName -- zo_strformat("<<C:1>>", GetAbilityName(abilityId))

    -- Return if ability not marked as cast or ability is blacklisted
    if not Castbar.IsCast[abilityId] or CombatInfo.SV.blacklist[abilityId] or CombatInfo.SV.blacklist[name] then
        return
    end

    -- Don't show heavy attacks if the option is disabled
    if Castbar.IsHeavy[abilityId] and not CombatInfo.SV.CastBarHeavy then
        return
    end

    local duration
    local channeled, durationValue = GetAbilityCastInfo(abilityId, overrideRank, casterUnitTag)
    local forceChanneled = false

    -- Override certain things to display as a channel rather than cast.
    -- Note only works for events where we override the duration.
    if Castbar.CastChannelOverride[abilityId] then
        channeled = true
    end

    if channeled then
        duration = Castbar.CastDurationFix[abilityId] or result == ACTION_RESULT_EFFECT_GAINED_DURATION and hitValue or durationValue
    else
        duration = Castbar.CastDurationFix[abilityId] or durationValue
    end

    -- End the cast bar and restart if a new begin event is detected and the effect isn't a channel or fake cast
    if result == ACTION_RESULT_BEGIN and not channeled and not Castbar.CastDurationFix[abilityId] then
        CombatInfo.StopCastBar()
    elseif result == ACTION_RESULT_EFFECT_GAINED_DURATION and channeled then
        CombatInfo.StopCastBar()
    elseif result == ACTION_RESULT_EFFECT_GAINED and channeled then
        CombatInfo.StopCastBar()
    elseif result == ACTION_RESULT_EFFECT_FADED and channeled then
        CombatInfo.StopCastBar()
    end

    if Castbar.CastChannelConvert[abilityId] then
        channeled = true
        forceChanneled = true
        duration = Castbar.CastDurationFix[abilityId] or durationValue
    end

    -- Some abilities cast into a channeled stun effect - we want these abilities to display the cast and channel if flagged.
    -- Only flags on ACTION_RESULT_BEGIN so this won't interfere with the stun result that is converted to dissplay a channeled cast.
    if Castbar.MultiCast[abilityId] then
        if result == 2200 then
            channeled = false
            duration = durationValue or 0
        elseif result == 2240 then
            CombatInfo.StopCastBar() -- Stop the cast bar when the GAINED event happens so that we can display the channel when the cast ends
        end
    end

    -- Special handling for werewolf transform and transform back
    if abilityId == 39033 or abilityId == 39477 then
        local skillType, skillIndex, abilityIndex, morphChoice, rankIndex = GetSpecificSkillAbilityKeysByAbilityId(32455)
        name, icon = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
        if abilityId == 39477 then
            name = zo_strformat("<<1>> <<2>>", Abilities.Skill_Remove, name)
        end
    end

    if duration > 0 and not g_casting then
        -- If action result is BEGIN and not channeled then start, otherwise only use GAINED
        if (not forceChanneled and (((result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_BEGIN_CHANNEL) and not channeled) or (result == ACTION_RESULT_EFFECT_GAINED and (Castbar.CastDurationFix[abilityId] or channeled)) or (result == ACTION_RESULT_EFFECT_GAINED_DURATION and (Castbar.CastDurationFix[abilityId] or channeled)))) or (forceChanneled and result == ACTION_RESULT_BEGIN) then
            local currentTime = GetGameTimeMilliseconds()
            local endTime = currentTime + duration
            local remain = endTime - currentTime

            castbar.remain = endTime
            castbar.starts = currentTime
            castbar.ends = endTime
            castbar.icon:SetTexture(icon)
            castbar.id = abilityId

            if channeled then
                castbar.type = 2 -- CHANNEL
                castbar.bar.bar:SetValue(1)
            else
                castbar.type = 1 -- CAST
                castbar.bar.bar:SetValue(0)
            end
            if CombatInfo.SV.CastBarLabel then
                castbar.bar.name:SetText(name)
                castbar.bar.name:SetHidden(false)
            end
            if CombatInfo.SV.CastBarTimer then
                castbar.bar.timer:SetText(string_format("%.1f", remain / 1000))
                castbar.bar.timer:SetHidden(false)
            end

            castbar:SetHidden(false)
            g_casting = true
            eventManager:RegisterForUpdate(moduleName .. "CastBar", 20, CombatInfo.OnUpdateCastbar)
        end
    end

    -- Fix to lower the duration of the next cast of Profane Symbol quest ability for Scion of the Blood Matron (Vampire)
    if abilityId == 39507 then
        zo_callLater(function ()
            Castbar.CastDurationFix[39507] = 19500
        end, 5000)
    end
end

--[[
function CombatInfo.OnCombatEventSpecialFilters(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    CombatInfo.StopCastBar()
end
]]
--

function CombatInfo.OnCombatEventBar(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    -- If the source/target isn't the player then bail out now.
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER and targetType ~= COMBAT_UNIT_TYPE_PLAYER then
        return
    end

    if sourceType == COMBAT_UNIT_TYPE_PLAYER and targetType == COMBAT_UNIT_TYPE_PLAYER then
        g_toggledSlotsPlayer[abilityId] = true
    end

    -- Special handling for Crystallized Shield + Morphs
    if abilityId == 86135 or abilityId == 86139 or abilityId == 86143 then
        -- Make sure this event occured on the player only. If we hit another Warden's shield we don't want to change stack count.
        if result == ACTION_RESULT_DAMAGE_SHIELDED and targetType == COMBAT_UNIT_TYPE_PLAYER then
            if g_toggledSlotsFront[abilityId] or g_toggledSlotsBack[abilityId] then
                -- Reduce stack by one
                if g_toggledSlotsStack[abilityId] then
                    g_toggledSlotsStack[abilityId] = g_toggledSlotsStack[abilityId] - 1
                end
                if g_toggledSlotsFront[abilityId] then
                    local slotNum = g_toggledSlotsFront[abilityId]
                    if g_uiCustomToggle[slotNum] then
                        if g_toggledSlotsStack[abilityId] and g_toggledSlotsStack[abilityId] > 0 then
                            g_uiCustomToggle[slotNum].stack:SetText(g_toggledSlotsStack[abilityId])
                        else
                            g_uiCustomToggle[slotNum].stack:SetText("")
                        end
                    end
                end
                if g_toggledSlotsBack[abilityId] then
                    local slotNum = g_toggledSlotsBack[abilityId]
                    if g_uiCustomToggle[slotNum] then
                        if g_toggledSlotsStack[abilityId] and g_toggledSlotsStack[abilityId] > 0 then
                            g_uiCustomToggle[slotNum].stack:SetText(g_toggledSlotsStack[abilityId])
                        else
                            g_uiCustomToggle[slotNum].stack:SetText("")
                        end
                    end
                end
            end
        end
    end

    if result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_EFFECT_GAINED or result == ACTION_RESULT_EFFECT_GAINED_DURATION then
        local currentTime = GetGameTimeMilliseconds()
        if g_toggledSlotsFront[abilityId] or g_toggledSlotsBack[abilityId] then
            if CombatInfo.SV.ShowToggled then
                local duration = GetUpdatedAbilityDuration(abilityId)
                local endTime = currentTime + duration
                g_toggledSlotsRemain[abilityId] = endTime
                -- Handling for Crystallized Shield + Morphs
                if abilityId == 86135 or abilityId == 86139 or abilityId == 86143 then
                    g_toggledSlotsStack[abilityId] = 3
                end
                -- Handling for Trap Beast
                if abilityId == 35750 or abilityId == 40382 or abilityId == 40372 then
                    g_toggledSlotsStack[abilityId] = 1
                end
                -- Toggle highlight on
                if g_toggledSlotsFront[abilityId] then
                    local slotNum = g_toggledSlotsFront[abilityId]
                    CombatInfo.ShowSlot(slotNum, abilityId, currentTime, false)
                end
                if g_toggledSlotsBack[abilityId] then
                    local slotNum = g_toggledSlotsBack[abilityId]
                    CombatInfo.ShowSlot(slotNum, abilityId, currentTime, false)
                end
            end
        end
    elseif result == ACTION_RESULT_EFFECT_FADED then
        -- Ignore fading event if override is true
        if g_barNoRemove[abilityId] then
            if Effects.BarHighlightCheckOnFade[abilityId] then
                CombatInfo.BarHighlightSwap(abilityId)
            end
            return
        end

        if g_toggledSlotsRemain[abilityId] then
            if g_toggledSlotsFront[abilityId] and g_uiCustomToggle[g_toggledSlotsFront[abilityId]] then
                local slotNum = g_toggledSlotsFront[abilityId]
                CombatInfo.HideSlot(slotNum, abilityId)
            end
            if g_toggledSlotsBack[abilityId] and g_uiCustomToggle[g_toggledSlotsBack[abilityId]] then
                local slotNum = g_toggledSlotsBack[abilityId]
                CombatInfo.HideSlot(slotNum, abilityId)
            end
            g_toggledSlotsRemain[abilityId] = nil
            g_toggledSlotsStack[abilityId] = nil
        end
        if Effects.BarHighlightCheckOnFade[abilityId] and targetType == COMBAT_UNIT_TYPE_PLAYER then
            CombatInfo.BarHighlightSwap(abilityId)
        end
    end
end

function CombatInfo.OnSlotUpdated(eventCode, slotNum)
    -- Update ultimate label
    if slotNum == 8 then
        CombatInfo.UpdateUltimateLabel()
    end
end

local function removeSlotFromTable(table, slotNum)
    for abilityId, slot in pairs(table) do
        if slot == slotNum then
            table[abilityId] = nil
        end
    end
end

function CombatInfo.BarSlotUpdate(slotNum, wasfullUpdate, onlyProc)
    if not slotNum or not BACKBAR_INDEX_OFFSET then
        return
    end

    if slotNum < BACKBAR_INDEX_OFFSET then
        if CombatInfo.SV.ShowToggledUltimate then
            if slotNum < BAR_INDEX_START or slotNum > BAR_INDEX_END then
                return
            end
        else
            if slotNum < BAR_INDEX_START or slotNum > (BAR_INDEX_END - 1) then
                return
            end
        end
    end

    removeSlotFromTable(g_triggeredSlotsFront, slotNum)
    removeSlotFromTable(g_triggeredSlotsBack, slotNum)

    if g_uiProcAnimation[slotNum] and g_uiProcAnimation[slotNum]:IsPlaying() then
        g_uiProcAnimation[slotNum]:Stop()
    end

    if onlyProc == false then
        removeSlotFromTable(g_toggledSlotsFront, slotNum)
        removeSlotFromTable(g_toggledSlotsBack, slotNum)

        if g_uiCustomToggle[slotNum] then
            g_uiCustomToggle[slotNum]:SetHidden(true)
        end
    end

    if slotNum < BACKBAR_INDEX_OFFSET and not IsSlotUsed(slotNum, g_hotbarCategory) then
        return
    end

    local ability_id = LUIE.GetSlotTrueBoundId(slotNum, g_hotbarCategory)
    if slotNum > BACKBAR_INDEX_OFFSET then
        local hotbarCategory = g_hotbarCategory == HOTBAR_CATEGORY_BACKUP and HOTBAR_CATEGORY_PRIMARY or HOTBAR_CATEGORY_BACKUP
        ability_id = LUIE.GetSlotTrueBoundId(slotNum - BACKBAR_INDEX_OFFSET, hotbarCategory)

        -- Check backbar weapon type
        local weaponSlot = g_hotbarCategory == HOTBAR_CATEGORY_BACKUP and 4 or 20
        local weaponType = GetItemWeaponType(BAG_WORN, weaponSlot)

        -- Fix tracking for Staff Backbar
        if weaponType == WEAPONTYPE_FIRE_STAFF or weaponType == WEAPONTYPE_FROST_STAFF or weaponType == WEAPONTYPE_LIGHTNING_STAFF then
            if Effects.BarHighlightDestroFix[ability_id] and Effects.BarHighlightDestroFix[ability_id][weaponType] then
                ability_id = Effects.BarHighlightDestroFix[ability_id][weaponType]
            end
        end
    end

    -- Added this back for now but some abilities might still need updates in the override tables
    local showFakeAura = (Effects.BarHighlightOverride[ability_id] and Effects.BarHighlightOverride[ability_id].showFakeAura)

    if Effects.BarHighlightOverride[ability_id] then
        if Effects.BarHighlightOverride[ability_id].hide then
            return
        end
        if Effects.BarHighlightOverride[ability_id].newId then
            ability_id = Effects.BarHighlightOverride[ability_id].newId
        end
    end

    local cachedName = ZO_CachedStrFormat(SI_ABILITY_NAME, GetAbilityName(ability_id))
    local abilityName = Effects.EffectOverride[ability_id] and Effects.EffectOverride[ability_id].name or cachedName
    local duration = GetUpdatedAbilityDuration(ability_id) or 0

    local currentTime = GetGameTimeMilliseconds()

    local triggeredSlots = slotNum > BACKBAR_INDEX_OFFSET and g_triggeredSlotsBack or g_triggeredSlotsFront
    local proc = Effects.HasAbilityProc[abilityName]

    if proc then
        triggeredSlots[proc] = slotNum
        if g_triggeredSlotsRemain[proc] then
            if CombatInfo.SV.ShowTriggered then
                CombatInfo.PlayProcAnimations(slotNum)
                if CombatInfo.SV.BarShowLabel then
                    if not g_uiProcAnimation[slotNum] then
                        return
                    end
                    local remain = g_triggeredSlotsRemain[proc] - currentTime
                    g_uiProcAnimation[slotNum].procLoopTexture.label:SetText(SetBarRemainLabel(remain, ability_id))
                end
            end
        end
    end

    local toggledSlots = slotNum > BACKBAR_INDEX_OFFSET and g_toggledSlotsBack or g_toggledSlotsFront

    if onlyProc == false then
        if duration > 0 or Effects.AddNoDurationBarHighlight[ability_id] or Effects.IsGrimFocus[ability_id] or Effects.IsBloodFrenzy[ability_id] or Effects.MajorMinor[ability_id] then
            toggledSlots[ability_id] = slotNum
            if g_toggledSlotsRemain[ability_id] then
                if CombatInfo.SV.ShowToggled then
                    local slotNumST = toggledSlots[ability_id]
                    local desaturate
                    local math = slotNumST > BACKBAR_INDEX_OFFSET and slotNumST - BACKBAR_INDEX_OFFSET or nil
                    if math then
                        if g_uiCustomToggle[math] then
                            desaturate = false
                            if g_uiCustomToggle[math]:IsHidden() then
                                CombatInfo.BackbarHideSlot(slotNumST)
                                desaturate = true
                            end
                        end
                    end
                    CombatInfo.ShowSlot(slotNumST, ability_id, currentTime, desaturate)
                end
            end
        end
    end
end

function CombatInfo.UpdateUltimateLabel()
    -- Get the currently slotted ultimate cost
    local bar = g_hotbarCategory
    g_ultimateCost = GetSlotAbilityCost(g_ultimateSlot, COMBAT_MECHANIC_FLAGS_ULTIMATE, bar) or 0

    -- Update ultimate label
    CombatInfo.OnPowerUpdatePlayer(EVENT_POWER_UPDATE, "player", nil, COMBAT_MECHANIC_FLAGS_ULTIMATE, g_ultimateCurrent, 0, 0)
end

function CombatInfo.InventoryItemUsed()
    g_potionUsed = true
    zo_callLater(function ()
        g_potionUsed = false
    end, 200)
end

function CombatInfo.OnActiveHotbarUpdate(eventCode, didActiveHotbarChange, shouldUpdateAbilityAssignments, activeHotbarCategory)
    if didActiveHotbarChange == true or shouldUpdateAbilityAssignments == true then
        for _, physicalSlot in pairs(g_backbarButtons) do
            if physicalSlot.hotbarSwapAnimation then
                physicalSlot.noUpdates = true
                physicalSlot.hotbarSwapAnimation:PlayFromStart()
            end
        end
    else
        g_activeWeaponSwapInProgress = false
    end
end

function CombatInfo.OnSlotsFullUpdate(eventCode)
    -- Don't update bars if this full update event was from using an inventory item
    if g_potionUsed == true then
        return
    end

    -- Handle ultimate label first
    CombatInfo.UpdateUltimateLabel()

    -- Update action bar skills
    for i = BAR_INDEX_START, BAR_INDEX_END do
        CombatInfo.BarSlotUpdate(i, true, false)
    end

    for i = (BAR_INDEX_START + BACKBAR_INDEX_OFFSET), (BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET) do
        local button = g_backbarButtons[i]
        CombatInfo.SetupBackBarIcons(button)
        CombatInfo.BarSlotUpdate(i, true, false)
    end
end

function CombatInfo.PlayProcAnimations(slotNum)
    if not g_uiProcAnimation[slotNum] then
        local color = uiQuickSlot.color -- default color in case none is found
        -- Don't make a highlight frame for the backbar ultimate slot since it is not created
        if slotNum == (BAR_INDEX_END + BACKBAR_INDEX_OFFSET) then
            return
        end
        -- Otherwise make a highlight frame
        local actionButton
        if slotNum < BACKBAR_INDEX_OFFSET then
            actionButton = ZO_ActionBar_GetButton(slotNum)
        else
            actionButton = g_backbarButtons[slotNum]
        end
        local procLoopTexture = windowManager:CreateControl("$(parent)Loop_LUIE", actionButton.slot, CT_TEXTURE)
        procLoopTexture:SetAnchor(TOPLEFT, actionButton.slot:GetNamedChild("FlipCard"))
        procLoopTexture:SetAnchor(BOTTOMRIGHT, actionButton.slot:GetNamedChild("FlipCard"))
        procLoopTexture:SetTexture("/esoui/art/actionbar/abilityhighlight_mage_med.dds")
        procLoopTexture:SetBlendMode(TEX_BLEND_MODE_ADD)
        procLoopTexture:SetDrawLayer(DL_TEXT)
        procLoopTexture:SetHidden(true)

        local label = UI:Label(procLoopTexture, nil, nil, nil, g_barFont, nil, false)
        label:SetAnchor(TOPLEFT, actionButton.slot)
        label:SetAnchor(BOTTOMRIGHT, actionButton.slot, nil, 0, -CombatInfo.SV.BarLabelPosition)
        label:SetDrawLayer(DL_CONTROLS)
        label:SetDrawLayer(DL_OVERLAY)
        label:SetDrawTier(DT_HIGH)
        label:SetColor(unpack(CombatInfo.SV.RemainingTextColoured and color or { 1, 1, 1, 1 }))
        label:SetHidden(false)
        procLoopTexture.label = label

        local procLoopTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("UltimateReadyLoop", procLoopTexture)
        procLoopTimeline.procLoopTexture = procLoopTexture

        procLoopTimeline.onPlay = function (self)
            self.procLoopTexture:SetHidden(false)
        end
        procLoopTimeline.onStop = function (self)
            self.procLoopTexture:SetHidden(true)
        end

        procLoopTimeline:SetHandler("OnPlay", procLoopTimeline.onPlay)
        procLoopTimeline:SetHandler("OnStop", procLoopTimeline.onStop)

        g_uiProcAnimation[slotNum] = procLoopTimeline
    end
    if g_uiProcAnimation[slotNum] then
        if not g_uiProcAnimation[slotNum]:IsPlaying() then
            g_uiProcAnimation[slotNum]:PlayFromStart()
        end
    end
end

function CombatInfo.OnDeath(eventCode, unitTag, isDead)
    -- And toggle buttons
    if unitTag == "player" then
        for slotNum = BAR_INDEX_START, BAR_INDEX_END do
            if g_uiCustomToggle[slotNum] then
                g_uiCustomToggle[slotNum]:SetHidden(true)
                --[[if slotNum == 8 and CombatInfo.SV.UltimatePctEnabled and IsSlotUsed(g_ultimateSlot) then
                    uiUltimate.LabelPct:SetHidden(false)
                end]]
                --
            end
        end
        for slotNum = BAR_INDEX_START + BACKBAR_INDEX_OFFSET, BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET do
            if g_uiCustomToggle[slotNum] then
                g_uiCustomToggle[slotNum]:SetHidden(true)
            end
        end
    end
end

-- Displays custom toggle texture
function CombatInfo.ShowCustomToggle(slotNum)
    if not g_uiCustomToggle[slotNum] then
        local color = uiQuickSlot.color -- default color in case none is found
        -- Don't make a highlight frame for the backbar ultimate slot since it is not created
        if slotNum == (BAR_INDEX_END + BACKBAR_INDEX_OFFSET) then
            return
        end
        -- Otherwise make a highlight frame
        local actionButton
        if slotNum < BACKBAR_INDEX_OFFSET then
            actionButton = ZO_ActionBar_GetButton(slotNum)
        else
            actionButton = g_backbarButtons[slotNum]
        end
        local name = "ActionButton" .. slotNum .. "Toggle_LUIE"
        local window = windowManager:GetControlByName(name, "") -- Check to see if this frame already exists, don't create it if it does.
        if window == nil then
            local toggleFrame = windowManager:CreateControl("$(parent)Toggle_LUIE", actionButton.slot, CT_TEXTURE)
            -- toggleFrame.back = UI:Texture(toggleFrame, nil, nil, "/esoui/art/actionbar/actionslot_toggledon.dds")
            toggleFrame:SetAnchor(TOPLEFT, actionButton.slot:GetNamedChild("FlipCard"))
            toggleFrame:SetAnchor(BOTTOMRIGHT, actionButton.slot:GetNamedChild("FlipCard"))
            toggleFrame:SetTexture("/esoui/art/actionbar/actionslot_toggledon.dds")
            toggleFrame:SetBlendMode(TEX_BLEND_MODE_ADD)
            toggleFrame:SetDrawLayer(DL_BACKGROUND)
            toggleFrame:SetDrawLevel(DL_BACKGROUND)
            toggleFrame:SetDrawTier(DT_HIGH)
            toggleFrame:SetColor(0.5, 1, 0.5, 1)
            toggleFrame:SetHidden(false)

            toggleFrame.label = UI:Label(toggleFrame, nil, nil, nil, g_barFont, nil, false)
            toggleFrame.label:SetAnchor(TOPLEFT, actionButton.slot)
            toggleFrame.label:SetAnchor(BOTTOMRIGHT, actionButton.slot, nil, 0, -CombatInfo.SV.BarLabelPosition)
            toggleFrame.label:SetDrawLayer(DL_CONTROLS)
            toggleFrame.label:SetDrawLevel(DL_CONTROLS)
            toggleFrame.label:SetDrawTier(DT_HIGH)
            toggleFrame.label:SetColor(unpack(CombatInfo.SV.RemainingTextColoured and color or { 1, 1, 1, 1 }))
            toggleFrame.label:SetHidden(false)

            toggleFrame.stack = UI:Label(toggleFrame, nil, nil, nil, g_barFont, nil, false)
            toggleFrame.stack:SetAnchor(CENTER, actionButton.slot, BOTTOMLEFT)
            toggleFrame.stack:SetAnchor(CENTER, actionButton.slot, TOPRIGHT, -12, 14)
            -- toggleFrame.stack:SetAnchor(TOPLEFT, actionButton.slot)
            -- toggleFrame.stack:SetAnchor(BOTTOMRIGHT, actionButton.slot, nil, 22, -22)

            toggleFrame.stack:SetDrawLayer(DL_CONTROLS)
            toggleFrame.stack:SetDrawLevel(DL_CONTROLS)
            toggleFrame.stack:SetDrawTier(DT_HIGH)
            toggleFrame.stack:SetColor(unpack(CombatInfo.SV.RemainingTextColoured and color or { 1, 1, 1, 1 }))
            toggleFrame.stack:SetHidden(false)

            g_uiCustomToggle[slotNum] = toggleFrame
        end
    end
    if g_uiCustomToggle[slotNum] then
        g_uiCustomToggle[slotNum]:SetHidden(false)
    end
end

function CombatInfo.OnPowerUpdatePlayer(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    if unitTag ~= "player" then
        return
    end
    if powerType ~= COMBAT_MECHANIC_FLAGS_ULTIMATE then
        return
    end

    -- flag if ultimate is full - we"ll need it for ultimate generation texture
    uiUltimate.NotFull = (powerValue < powerMax)
    -- Calculate the percentage to activation old one and current
    local pct = (g_ultimateCost > 0) and zo_floor((powerValue / g_ultimateCost) * 100) or 0
    -- Set max percentage label to 100%.
    if pct > 100 then
        pct = 100
    end
    -- Update the tooltip only when the slot is used and percentage is enabled
    if IsSlotUsed(g_ultimateSlot, g_hotbarCategory) then
        if CombatInfo.SV.UltimateLabelEnabled or CombatInfo.SV.UltimatePctEnabled then
            -- Set % value
            if CombatInfo.SV.UltimatePctEnabled then
                uiUltimate.LabelPct:SetText(pct .. "%")
            end
            -- Set label value
            if CombatInfo.SV.UltimateLabelEnabled then
                uiUltimate.LabelVal:SetText(powerValue .. "/" .. g_ultimateCost)
            end
            -- Pct label: show always when less then 100% and possibly if UltimateHideFull is false
            if pct < 100 then
                -- Check Ultimate Percent Setting & if slot is used then check if the slot is currently showing a toggle
                local setHiddenPct = not CombatInfo.SV.UltimatePctEnabled
                if CombatInfo.SV.ShowToggledUltimate and g_uiCustomToggle[8] and not g_uiCustomToggle[8]:IsHidden() then
                    setHiddenPct = true
                end
                uiUltimate.LabelPct:SetHidden(setHiddenPct)
                -- Update Label Color
                if CombatInfo.SV.UltimateLabelEnabled then
                    for i = #uiUltimate.pctColors, 1, -1 do
                        if pct < uiUltimate.pctColors[i].pct then
                            uiUltimate.LabelVal:SetColor(unpack(uiUltimate.pctColors[i].color))
                            break
                        end
                    end
                end
            else
                -- Check Ultimate Percent Setting & if slot is used then check if the slot is currently showing a toggle
                local setHiddenPct = not CombatInfo.SV.UltimatePctEnabled
                if (CombatInfo.SV.ShowToggledUltimate and g_uiCustomToggle[8] and not g_uiCustomToggle[8]:IsHidden()) or CombatInfo.SV.UltimateHideFull then
                    setHiddenPct = true
                end
                uiUltimate.LabelPct:SetHidden(setHiddenPct)
                -- Update Label Color
                if CombatInfo.SV.UltimateLabelEnabled then
                    uiUltimate.LabelVal:SetColor(unpack(uiUltimate.color))
                end
            end
            -- Set label hidden or showing
            local setHiddenLabel = not CombatInfo.SV.UltimateLabelEnabled
            uiUltimate.LabelVal:SetHidden(setHiddenLabel)
        end
    else
        uiUltimate.LabelPct:SetHidden(true)
        uiUltimate.LabelVal:SetHidden(true)
    end
    -- Update stored value
    g_ultimateCurrent = powerValue
end

function CombatInfo.OnInventorySlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    if stackCountChange >= 0 then
        CombatInfo.UpdateUltimateLabel()
    end
end
