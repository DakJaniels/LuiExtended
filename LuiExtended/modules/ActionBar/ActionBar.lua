--- @diagnostic disable: duplicate-doc-field
-- -----------------------------------------------------------------------------
--  LuiExtended — ActionBar implementation (namespace: Namespace.lua)
--  Distributed under The MIT License (MIT) (see LICENSE file)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.ActionBar
local ActionBar = LUIE.ActionBar

local LuiData = LuiData
local Data = LuiData.Data
local Effects = Data.Effects
local Abilities = Data.Abilities
local Castbar = Data.CastBarTable
local OtherAddonCompatability = LUIE.OtherAddonCompatability

local pairs = pairs
local printToChat = LUIE.PrintToChat
local GetSlotTrueBoundId = LUIE.GetSlotTrueBoundId
local GetAbilityDuration = GetAbilityDuration
local zo_strformat = zo_strformat
local string_format = string.format

local eventManager = GetEventManager()
local sceneManager = SCENE_MANAGER
local windowManager = GetWindowManager()
local animationManager = GetAnimationManager()
local chatSystem = ZO_GetChatSystem()

local moduleName = ActionBar.ModuleName

local BAR_INDEX_START = ActionBar.BAR_INDEX_START
local BAR_INDEX_END = ActionBar.BAR_INDEX_END
local BACKBAR_INDEX_END = ActionBar.BACKBAR_INDEX_END
local BACKBAR_INDEX_OFFSET = ActionBar.BACKBAR_INDEX_OFFSET
local OAKENSOUL_RING_ITEM_ID = ActionBar.OAKENSOUL_RING_ITEM_ID
local DROP_CALLOUT_VALIDITY_BY_ACTION_TYPE = ActionBar.DROP_CALLOUT_VALIDITY_BY_ACTION_TYPE
local CooldownMethod = ActionBar.CooldownMethod

local uiQuickSlot = ActionBar.uiQuickSlot
local uiUltimate = ActionBar.uiUltimate
local uiCompanionUltimate = ActionBar.uiCompanionUltimate
local GAMEPAD_CONSTANTS = ActionBar.GAMEPAD_CONSTANTS
local KEYBOARD_CONSTANTS = ActionBar.KEYBOARD_CONSTANTS
local isStackCounter = ActionBar.isStackCounter
local isStackBaseAbility = ActionBar.isStackBaseAbility
local PROC_SOUND_THRESHOLDS = ActionBar.PROC_SOUND_THRESHOLDS
local ACTION_BUTTON_BORDERS = ActionBar.ACTION_BUTTON_BORDERS
local BOUNCE_DURATION_MS = ActionBar.BOUNCE_DURATION_MS

local isFancyActionBarEnabled = OtherAddonCompatability.isFancyActionBarPlusEnabled or LUIE.IsItEnabled("FancyActionBar\43") or LUIE.IsItEnabled("FancyActionBar")
local CastBar = ActionBar.CastBar
local Backbar = ActionBar.Backbar
local g_ultimateCost = 0     -- Cost of ultimate Ability in Slot
local g_ultimateCurrent = 0  -- Current ultimate value
local g_ultimateSlot = ActionBar.ULTIMATE_SLOT_INDEX
local g_uiProcAnimation = {} -- Animation for bar slots
--- @type table<number, any>
local g_uiCustomToggle = {}  -- Toggle slots for bar Slots (value: control or true placeholder)
--- Returns the custom toggle control for slotNum, or nil if missing or still a placeholder.
function ActionBar.GetCustomToggleControl(slotNum)
    local toggleEntry = g_uiCustomToggle[slotNum]
    return (toggleEntry and toggleEntry ~= true) and toggleEntry or nil
end

local GetCustomToggleControl = ActionBar.GetCustomToggleControl

local g_hotbarCategory = GetActiveHotbarCategory()

function ActionBar.GetHotbarCategory()
    return g_hotbarCategory
end

function ActionBar.SetHotbarCategory(category)
    g_hotbarCategory = category
end

local g_actionBarActiveWeaponPair = GetHeldWeaponPair()

function ActionBar.GetHeldWeaponPair()
    return g_actionBarActiveWeaponPair
end

--- @param activeHotbarCategory HotBarCategory
--- @return HotBarCategory
local function GetInactiveHotbarCategory(activeHotbarCategory)
    if activeHotbarCategory == HOTBAR_CATEGORY_PRIMARY then
        return HOTBAR_CATEGORY_BACKUP
    end
    if activeHotbarCategory == HOTBAR_CATEGORY_BACKUP then
        return HOTBAR_CATEGORY_PRIMARY
    end
    if g_actionBarActiveWeaponPair == ACTIVE_WEAPON_PAIR_BACKUP then
        return HOTBAR_CATEGORY_PRIMARY
    end
    return HOTBAR_CATEGORY_BACKUP
end

--- @param remain integer
--- @return string
local function FormatDurationSeconds(remain)
    return string_format((ActionBar.SV.BarMillis and ((remain < ActionBar.SV.BarMillisThreshold * 1000) or ActionBar.SV.BarMillisAboveTen)) and "%.1f" or "%.1d", remain / 1000)
end

--- Forward declarations (OnAbilityUsed is defined above these helpers).
local forEachToggledBarSlot
local SetToggledStackLabels
local HideToggledSlots
local ShowToggledSlots
local DecrementBarHighlightCombatStack
local g_triggeredSlotsFront = {}           -- Triggered bar highlight slots
local g_triggeredSlotsBack = {}            -- Triggered bar highlight slots
--- @type table<number, number>
local g_triggeredSlotsRemain = {}          -- Table of remaining durations on proc abilities
local g_toggledSlotsBack = {}              -- Toggled bar highlight slots
local g_toggledSlotsFront = {}             -- Toggled bar highlight slots
--- @type table<number, number>
local g_toggledSlotsRemain = {}            -- Table of remaining durations on active abilities
--- @type table<number, number>
local g_toggledSlotsStack = {}             -- Table of stacks for active abilities
--- @type table<number, boolean>
local g_toggledSlotsPlayer = {}            -- Table of abilities that target the player (bar highlight doesn't fade on reticleover change)
local g_potionUsed = false                 -- Toggled on when a potion is used to prevent OnSlotsFullUpdate from updating timers.
--- @type {[integer]:boolean}
local g_barOverrideCI = {}                 -- Table for storing abilityId's from Effects.BarHighlightOverride that should show as an aura
--- @type {[integer]:boolean}
local g_barFakeAura = {}                   -- Table for storing abilityId's that only display a fakeaura
--- @type {[integer]:number}
local g_barDurationOverride = {}           -- Table for storing abilitiyId's that ignore ending event
--- @type {[integer]:boolean}
local g_barNoRemove = {}                   -- Table of abilities we don't remove from bar highlight
--- @type {[integer]:boolean}
local g_barCombatTrack = {}                -- Track ids registered via BarHighlightOverride.combatTrack
--- @type {[integer]:number}
local g_barCombatStackMax = {}             -- Max stacks (Effects.BarHighlightStack) for combatTrack highlights
--- @type {[integer]:integer}
local g_barConsumeStackOnCast = {}         -- Bound id -> track id (Effects.BarHighlightStackConsume)
--- @type {[integer]: "keep"|"clear"}
local g_barCombatStackZeroEffect = {}      -- Effects.BarHighlightStackZeroEffect for track buff ids
--- @type {[integer]: integer}
local g_barCombatEventRemap = {}           -- Slotted ability id -> combatTrack newId (from BarHighlightOverride)
--- @type {[integer]: boolean}
local g_barCombatTrackRemainOnSlotted = {} -- Track id: bar timer only from slotted-id combat / effect (not tick newId combat)
--- @type string[]
local g_barCombatEventNames = {}           -- EVENT_COMBAT_EVENT handler names (unregistered before rebuild)
--- @type {[integer]:number}
local g_protectAbilityRemoval = {}         -- AbilityId's set to a timestamp here to prevent removal of bar highlight when refreshing ground auras from causing the highlight to fade.
--- @type {[integer]:number}
local g_mineStacks = {}                    -- Individual AbilityId ground mine stack information
--- @type {[integer]:boolean}
local g_mineNoTurnOff = {}                 -- When this variable is true for an abilityId - don't remove the bar highlight for a mine (We we have reticleover target and the mine effect applies on the enemy)
local g_reticleHidden = false              -- Track if reticle is hidden to skip unnecessary processing
local g_barFont                            -- Font for Ability Highlight Label
local g_potionFont                         -- Font for Potion Timer Label
local g_ultimateFont                       -- Font for Ultimate Percentage Label
local g_companionUltimateFont              -- Font for companion ultimate percent label
local g_ProcSound                          -- Proc Sound
local g_boundArmamentsPlayed = {}          -- Specific variable to lockout Bound Armaments/Grim Focus from playing a proc sound at 5 stacks to only once per 5 seconds.
--- @type {[integer]:boolean}
local g_disableProcSound = {}              -- When we play a proc sound from a bar ability changing (like power lash) we put a 3 sec ICD on it so it doesn't spam when mousing on/off a target, etc
local g_actionBarDisplayAlpha              -- Last alpha applied to ZO_ActionBar1 (re-apply if UI resets it)
local g_activeWeaponSwapInProgress = false -- Toggled on when weapon swapping, TODO: maybe not needed
--- Always resolve at runtime; file-load snapshot of ZO_ActionBar1 can be wrong before UI exists.
local function GetActionBarControl()
    return ZO_ActionBar1
end
local ACTION_BAR = GetActionBarControl()
ActionBar.AttachPlatformWeaponSwap(ACTION_BAR)

local g_companionUltimateLabelsCreated = false

--- Matches ZOS `ShouldShowCompanionUltimateButton` (same condition as `Ingame/ActionBar/ActionBar.lua`): companion may not exist until summoned/active.
--- @return boolean
local function ShouldShowCompanionUltimateButton()
    return DoesUnitExist("companion") and HasActiveCompanion()
end

-- -----------------------------------------------------------------------------

--- @return LUIE_ACTIONBAR_GAMEPAD_CONSTANTS | LUIE_ACTIONBAR_KEYBOARD_CONSTANTS
local function GetPlatformConstants()
    return IsInGamepadPreferredMode() and GAMEPAD_CONSTANTS or KEYBOARD_CONSTANTS
end

--- ZOS `SetCompanionAnchors` KeybindBG + quickslot chain, plus FAB-style companion slot pin when the companion button exists (see ZOS `Ingame/ActionBar/ActionBar.lua`).
--- @param style LUIE_ACTIONBAR_GAMEPAD_CONSTANTS | LUIE_ACTIONBAR_KEYBOARD_CONSTANTS
--- @param weaponSwapControl table
local function ApplyCompanionAnchors(style, weaponSwapControl)
    local companionBtn = ZO_ActionBar_GetButton(ACTION_BAR_ULTIMATE_SLOT_INDEX + 1, HOTBAR_CATEGORY_COMPANION)
    local quickslotBtn = ZO_ActionBar_GetButton(nil, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    local keybindBG = ACTION_BAR:GetNamedChild("KeybindBG")
    if not quickslotBtn or not weaponSwapControl then
        return
    end
    local IS_ANCHORED_LEFT = true
    local scale = ACTION_BAR:GetScale()

    if ShouldShowCompanionUltimateButton() then
        if companionBtn then
            companionBtn:SetEnabled(true)
            companionBtn.slot:ClearAnchors()
            companionBtn.slot:SetAnchor(RIGHT, weaponSwapControl, LEFT, -style.quickslotOffsetXFromFirstSlot * scale)
            quickslotBtn:ApplyAnchor(companionBtn.slot, style.quickslotOffsetXFromCompanionUltimate, IS_ANCHORED_LEFT)
        else
            quickslotBtn:ApplyAnchor(weaponSwapControl, style.quickslotOffsetXFromFirstSlot, IS_ANCHORED_LEFT)
        end
        if keybindBG then
            keybindBG:SetDimensions(style.keybindBGWidth, style.keybindBGHeight)
            keybindBG:SetAnchor(BOTTOM, nil, nil, style.keybindBGAnchorOffsetX, 0)
        end
    else
        if companionBtn then
            companionBtn:SetEnabled(false)
        end
        quickslotBtn:ApplyAnchor(weaponSwapControl, style.quickslotOffsetXFromFirstSlot, IS_ANCHORED_LEFT)
        if keybindBG then
            keybindBG:SetDimensions(style.keybindBGWidthWithoutCompanion, style.keybindBGHeight)
            keybindBG:SetAnchor(BOTTOM, nil, nil, style.keybindBGAnchorOffsetXWithoutCompanion, 0)
        end
    end
end

local function RefreshCompanionQuickslotAnchors()
    if isFancyActionBarEnabled then
        return
    end
    local styleConstants = GetPlatformConstants()
    local weaponSwapControl = ACTION_BAR:GetNamedChild("WeaponSwap")
    if weaponSwapControl then
        ApplyCompanionAnchors(styleConstants, weaponSwapControl)
    end
end

ActionBar.RefreshCompanionQuickslotAnchors = RefreshCompanionQuickslotAnchors

-- -----------------------------------------------------------------------------

local slotsUpdated = {}

---
--- @param animation AnimationTimeline
--- @param button ActionButton
--- @param isBackBarSlot boolean
local function OnSwapAnimationHalfDone(animation, button, isBackBarSlot)
    for i = BAR_INDEX_START, BAR_INDEX_END do
        if not slotsUpdated[i] then
            local targetButton = Backbar.GetButton(i + BACKBAR_INDEX_OFFSET)
            ActionBar.BarSlotUpdate(i, false, false)
            ActionBar.BarSlotUpdate(i + BACKBAR_INDEX_OFFSET, false, false)
            -- Don't try to setup back bar ultimate
            if i < 8 then
                ActionBar.SetupBackBarIcons(targetButton, true)
            end
            if i == 8 then
                ActionBar.UpdateUltimateLabel()
            end
            slotsUpdated[i] = true
        end
    end
end

---
--- @param animation AnimationTimeline
--- @param button ActionButton
local function OnSwapAnimationDone(animation, button)
    button.noUpdates = false
    if button:GetSlot() == ACTION_BAR_ULTIMATE_SLOT_INDEX + 1 then
        g_activeWeaponSwapInProgress = false
    end
    slotsUpdated = {}
end

--- @param button ActionButton
local function SetupBounceAnimation(button)
    local mainTimeline = animationManager:CreateTimelineFromVirtual("ActionSlotBounceAnimation", button.flipCard)
    local iconTimeline = animationManager:CreateTimelineFromVirtual("ActionSlotBounceAnimation", button.icon)

    button.bounceAnimation = mainTimeline
    button.iconBounceAnimation = iconTimeline

    button.glowAnimation = ZO_AlphaAnimation:New(button.glow)
    button.glowAnimation:SetMinMaxAlpha(0, 1)

    button.needsAnimationParameterUpdate = true
end

---
--- @param button ActionButton
local function SetupSwapAnimation(button)
    button:SetupSwapAnimation(OnSwapAnimationHalfDone, OnSwapAnimationDone)
end

--- Bounce/swap animations for LUIE backbar ActionButtons.
function ActionBar.SetupBackbarButtonAnimations(button)
    SetupSwapAnimation(button)
    SetupBounceAnimation(button)
end

--- Backfill missing RGBA components on cast bar gradient saved colors (CombatInfo migration, LAM legacy).
--- @param savedGradientColor AB_Color|table|nil
--- @param defaultGradientColor AB_Color
--- @return AB_Color
local function BackfillCastBarGradientSavedColor(savedGradientColor, defaultGradientColor)
    if type(savedGradientColor) ~= "table" then
        return
        {
            defaultGradientColor[1],
            defaultGradientColor[2],
            defaultGradientColor[3],
            defaultGradientColor[4],
        }
    end
    if savedGradientColor[1] == nil and savedGradientColor.r ~= nil then
        local savedAlpha = savedGradientColor.a
        if savedAlpha == nil then
            savedAlpha = savedGradientColor.alpha
        end
        if savedAlpha == nil then
            savedAlpha = defaultGradientColor[4]
        end
        return { savedGradientColor.r, savedGradientColor.g, savedGradientColor.b, savedAlpha }
    end
    local function gradientComponentOrDefault(gradientComponentIndex)
        local savedComponentValue = savedGradientColor[gradientComponentIndex]
        if savedComponentValue == nil then
            return defaultGradientColor[gradientComponentIndex]
        end
        return savedComponentValue
    end
    return
    {
        gradientComponentOrDefault(1),
        gradientComponentOrDefault(2),
        gradientComponentOrDefault(3),
        gradientComponentOrDefault(4),
    }
end

-- Module initialization
--- Load saved vars, run migrations, create UI (quickslot/ultimate/backbar/castbar), register events.
--- @param enabled boolean
function ActionBar.Initialize(enabled)
    -- -----------------------------------------------------------------------------
    -- Load settings
    local isCharacterSpecific = LUIE.SV.CharacterSpecificSV
    if isCharacterSpecific then
        ActionBar.SV = ZO_SavedVars:New(LUIE.ModuleSavedVarNames.ActionBar, LUIE.SVVer, nil, ActionBar.Defaults, LUIE.SavedVarsProfile)
    else
        ActionBar.SV = ZO_SavedVars:NewAccountWide(LUIE.ModuleSavedVarNames.ActionBar, LUIE.SVVer, nil, ActionBar.Defaults, LUIE.SavedVarsProfile)
    end

    -- -----------------------------------------------------------------------------
    -- Migrate from CombatInfo module (one-time migration)
    if not LUIE.IsMigrationDone("actionbar_from_combatinfo") then
        local profile = LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile
        local displayName = GetDisplayName()
        local luiDisplayRoot = _G[LUIE.SVName][profile] and _G[LUIE.SVName][profile][displayName]
        local rawSavedVars
        if isCharacterSpecific then
            rawSavedVars = luiDisplayRoot and luiDisplayRoot[GetUnitName("player")]
        else
            rawSavedVars = luiDisplayRoot and luiDisplayRoot["$AccountWide"]
        end

        local combatInfoSavedVars
        if rawSavedVars and rawSavedVars.CombatInfo then
            combatInfoSavedVars = rawSavedVars.CombatInfo
        else
            combatInfoSavedVars = isCharacterSpecific and LUIE.GetRawModuleCharacterLeaf(LUIE.ModuleSavedVarNames.CombatInfo)
                or LUIE.GetRawModuleAccountWideLeaf(LUIE.ModuleSavedVarNames.CombatInfo)
        end

        if combatInfoSavedVars then
            -- List of fields that moved from CombatInfo to ActionBar
            local migrateFields =
            {
                "blacklist", "durationOverrides", "GlobalShowGCD", "GlobalPotion", "GlobalFlash",
                "GlobalDesat", "GlobalLabelColor", "GlobalMethod", "UltimateLabelEnabled",
                "UltimatePctEnabled", "UltimateHideFull", "UltimateGeneration", "UltimateLabelPosition",
                "UltimateFontFace", "UltimateFontStyle", "UltimateFontSize", "ShowTriggered",
                "ProcEnableSound", "ProcSoundName", "ShowToggled",
                "ShowToggledUltimate", "BarShowLabel", "BarLabelPosition", "BarFontFace",
                "BarFontStyle", "BarFontSize", "BarMillis", "BarMillisAboveTen", "BarMillisThreshold",
                "BarShowBack", "BarDarkUnused", "BarDesaturateUnused", "BarHideUnused",
                "PotionTimerShow", "PotionTimerLabelPosition", "PotionTimerFontFace",
                "PotionTimerFontStyle", "PotionTimerFontSize", "PotionTimerColor", "PotionTimerMillis",
                "CastBarEnable", "CastBarSizeW", "CastBarSizeH", "CastBarIconSize", "CastBarTexture",
                "CastBarLabel", "CastBarTimer", "CastBarFontFace", "CastBarFontStyle", "CastBarFontSize",
                "CastBarGradientC1", "CastBarGradientC2", "CastBarHeavy",
                "CastBarTimerFormat"
            }

            for _, field in ipairs(migrateFields) do
                if combatInfoSavedVars[field] ~= nil then
                    ActionBar.SV[field] = combatInfoSavedVars[field]
                    combatInfoSavedVars[field] = nil
                end
            end
        end

        LUIE.MarkMigrationDone("actionbar_from_combatinfo")
    end

    -- -----------------------------------------------------------------------------
    -- Backfill companion ultimate SV keys (FAB-aligned); must run before font style migration
    if not LUIE.IsMigrationDone("actionbar_companion_ultimate_v1") then
        local moduleDefaults = ActionBar.Defaults
        local companionKeys =
        {
            "CompanionUltimateLabelEnabled", "CompanionUltimatePctEnabled", "CompanionUltimateHideFull",
            "CompanionUltimateLabelPosition", "CompanionUltimateFontFace", "CompanionUltimateFontStyle",
            "CompanionUltimateFontSize", "CompanionUltimateColorDefault", "CompanionUltimateColor100",
            "CompanionUltimateColor80", "CompanionUltimateColor50",
        }
        for _, key in ipairs(companionKeys) do
            if ActionBar.SV[key] == nil then
                local defaultValue = moduleDefaults[key]
                if type(defaultValue) == "table" then
                    ActionBar.SV[key] = { defaultValue[1], defaultValue[2], defaultValue[3], defaultValue[4] }
                else
                    ActionBar.SV[key] = defaultValue
                end
            end
        end
        LUIE.MarkMigrationDone("actionbar_companion_ultimate_v1")
    end

    if not LUIE.IsMigrationDone("actionbar_castbar_weave_v1") then
        if ActionBar.SV.CastBarWeaveHelper == nil then
            ActionBar.SV.CastBarWeaveHelper = OtherAddonCompatability.isLibCombatEnabled
        end
        if ActionBar.SV.CastBarWeaveThresholdMs == nil then
            ActionBar.SV.CastBarWeaveThresholdMs = ActionBar.Defaults.CastBarWeaveThresholdMs
        end
        LUIE.MarkMigrationDone("actionbar_castbar_weave_v1")
    end

    -- -----------------------------------------------------------------------------
    -- Migrate font styles if needed
    -- Migrate font styles (string/display/nil -> valid 0-7); run once per account
    if not LUIE.IsMigrationDone("actionbar_fontstyles_v2") then
        ActionBar.SV.UltimateFontStyle = LUIE.MigrateFontStyle(ActionBar.SV.UltimateFontStyle)
        ActionBar.SV.BarFontStyle = LUIE.MigrateFontStyle(ActionBar.SV.BarFontStyle)
        ActionBar.SV.PotionTimerFontStyle = LUIE.MigrateFontStyle(ActionBar.SV.PotionTimerFontStyle)
        ActionBar.SV.CastBarFontStyle = LUIE.MigrateFontStyle(ActionBar.SV.CastBarFontStyle)
        ActionBar.SV.CompanionUltimateFontStyle = LUIE.MigrateFontStyle(ActionBar.SV.CompanionUltimateFontStyle)
        LUIE.MarkMigrationDone("actionbar_fontstyles_v2")
    end

    -- -----------------------------------------------------------------------------
    -- Migrate GlobalMethod if it's set to invalid value 3 (removed "Vertical" option)
    if not LUIE.IsMigrationDone("actionbar_globalmethod") then
        if ActionBar.SV.GlobalMethod == 3 then
            ActionBar.SV.GlobalMethod = 2 -- "Vertical Reveal"
        end
        LUIE.MarkMigrationDone("actionbar_globalmethod")
    end

    -- Cast bar gradients: CombatInfo / old saves may omit alpha (index 4)
    ActionBar.SV.CastBarGradientC1 = BackfillCastBarGradientSavedColor(
        ActionBar.SV.CastBarGradientC1, ActionBar.Defaults.CastBarGradientC1)
    ActionBar.SV.CastBarGradientC2 = BackfillCastBarGradientSavedColor(
        ActionBar.SV.CastBarGradientC2, ActionBar.Defaults.CastBarGradientC2)

    -- -----------------------------------------------------------------------------
    -- Disable module if setting not toggled on
    if not enabled then
        return
    end
    ActionBar.Enabled = true

    if ActionBar.SV.oocAlpha == nil then
        ActionBar.SV.oocAlpha = ActionBar.Defaults.oocAlpha
    end
    if ActionBar.SV.incAlpha == nil then
        ActionBar.SV.incAlpha = ActionBar.Defaults.incAlpha
    end

    -- -----------------------------------------------------------------------------
    ActionBar.ApplyFont()
    ActionBar.ApplyProcSound()

    -- -----------------------------------------------------------------------------
    -- Create Quickslot (Potion) Timer Label
    -- ZO_ActionBar_GetButton always returns the quickslot button when the category is HOTBAR_CATEGORY_QUICKSLOT_WHEEL, so there is no reason to pass in a slot
    local UNUSED = nil
    local quickslotButton = ZO_ActionBar_GetButton(UNUSED, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    local quickslotButtonButton = quickslotButton and quickslotButton.button

    local quickslotLabel = quickslotButtonButton:CreateControl("$(parent)Label", CT_LABEL)
    quickslotLabel:SetAnchor(CENTER, quickslotButtonButton, CENTER, 0, 0)
    quickslotLabel:SetFont(g_potionFont or "LUIE Default Font")
    quickslotLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    quickslotLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    quickslotLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    quickslotLabel:SetDrawLayer(DL_OVERLAY)
    quickslotLabel:SetDrawTier(DT_HIGH)
    quickslotLabel:SetHidden(true)
    uiQuickSlot.label = quickslotLabel

    if ActionBar.SV.PotionTimerColor then
        quickslotLabel:SetColor(unpack(uiQuickSlot.colour))
    else
        quickslotLabel:SetColor(1, 1, 1, 1)
    end
    ActionBar.ResetPotionTimerLabel() -- Set the label position

    -- Create Ultimate Overlay Labels
    local ActionButton8 = ZO_ActionBar_GetButton(ACTION_BAR_ULTIMATE_SLOT_INDEX + 1)
    local ActionButton8_button = ActionButton8 and ActionButton8.button
    -- Ultimate value label (numeric display above slot)
    local ultimateValueLabel = ActionButton8_button:CreateControl("$(parent)LabelVal", CT_LABEL)
    ultimateValueLabel:SetAnchor(BOTTOM, ActionButton8_button, TOP, 0, -3)
    ultimateValueLabel:SetFont("$(BOLD_FONT)|16|soft-shadow-thick")
    ultimateValueLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    ultimateValueLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    ultimateValueLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    ultimateValueLabel:SetHidden(true)
    uiUltimate.LabelVal = ultimateValueLabel

    -- Ultimate percentage label (overlay on slot)
    local ultimatePctLabel = ActionButton8_button:CreateControl("$(parent)LabelPct", CT_LABEL)
    ultimatePctLabel:SetFont(g_ultimateFont or "LUIE Default Font")
    ultimatePctLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    ultimatePctLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    ultimatePctLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    ultimatePctLabel:SetAnchor(TOPLEFT, ActionButton8_button)
    ultimatePctLabel:SetAnchor(BOTTOMRIGHT, ActionButton8_button, nil, 0, -ActionBar.SV.UltimateLabelPosition)
    ultimatePctLabel:SetColor(unpack(uiUltimate.colour))
    ultimatePctLabel:SetHidden(true)
    uiUltimate.LabelPct = ultimatePctLabel

    -- Ultimate ready burst texture
    local ultimateTexture = ActionButton8_button:CreateControl("$(parent)Texture", CT_TEXTURE)
    ultimateTexture:SetAnchor(CENTER, ActionButton8_button, CENTER, 0, 0)
    ultimateTexture:SetDimensions(160, 160)
    ultimateTexture:SetTexture("/esoui/art/crafting/white_burst.dds")
    ultimateTexture:SetDrawLayer(DL_BACKGROUND)
    ultimateTexture:SetBlendMode(TEX_BLEND_MODE_ADD)
    ultimateTexture:SetHidden(true)
    uiUltimate.Texture = ultimateTexture

    -- -----------------------------------------------------------------------------
    Backbar.CreateUI()
    Backbar.RegisterPlatformStyle()
    ActionBar.RegisterEvents()

    -- -----------------------------------------------------------------------------
    if ActionBar.SV.GlobalShowGCD then
        ActionBar.HookGCD()
    end

    -- -----------------------------------------------------------------------------
    CastBar.Initialize()
    LUIE.RefreshMoverOverlayFonts()

    ActionBar.ApplyDisplayAlpha()
end

-- -----------------------------------------------------------------------------
--- Called when active weapon pair changes; updates hotbar category and backbar.
--- @param activeWeaponPair ActiveWeaponPair
--- @param locked boolean
function ActionBar.OnActiveWeaponPairChanged(activeWeaponPair, locked)
    g_actionBarActiveWeaponPair = activeWeaponPair
    ActionBar.SetHotbarCategory(GetActiveHotbarCategory())
    g_activeWeaponSwapInProgress = true
    Backbar.UpdateButtonActionIds()
end

-- -----------------------------------------------------------------------------
-- Hook to update GCD support
--- Hooks ActionButton UpdateUsable/UpdateCooldown for global GCD display.
function ActionBar.HookGCD()
    ---
    --- @param self ActionButton
    --- @diagnostic disable-next-line: duplicate-set-field
    function ActionButton:UpdateUsable()
        local slotnum = self:GetSlot()
        local hotbarCategory = self.slot.slotNum == 1 and HOTBAR_CATEGORY_QUICKSLOT_WHEEL or g_hotbarCategory
        local isGamepad = IsInGamepadPreferredMode()
        local _, duration, _, _ = GetSlotCooldownInfo(slotnum, hotbarCategory)
        local isShowingCooldown = self.showingCooldown
        local isKeyboardUltimateSlot = not isGamepad and self.slot.slotNum == ACTION_BAR_ULTIMATE_SLOT_INDEX + 1
        local usable = false
        if not self.useFailure and not isShowingCooldown then
            usable = true
        elseif isKeyboardUltimateSlot and self.costFailureOnly and not isShowingCooldown then
            usable = true
            -- Fix to grey out potions
        elseif IsSlotItemConsumable(slotnum, hotbarCategory) and duration <= 1000 and not self.useFailure then
            usable = true
        end

        if usable ~= self.usable or isGamepad ~= self.isGamepad then
            self.usable = usable
            self.isGamepad = isGamepad
        end
        -- Have to move this out of conditional to fix desaturation from getting stuck on icons.
        local useDesaturation = (isShowingCooldown and ActionBar.SV.GlobalDesat)
        ZO_ActionSlot_SetUnusable(self.icon, not usable, useDesaturation)
    end

    -- Hook to update GCD support
    ---
    --- @param self ActionButton
    --- @param options table
    --- @diagnostic disable-next-line: duplicate-set-field
    function ActionButton:UpdateCooldown(options)
        local slotnum = self:GetSlot()
        local hotbarCategory = self.slot.slotNum == 1 and HOTBAR_CATEGORY_QUICKSLOT_WHEEL or g_hotbarCategory
        local remain, duration, global, globalSlotType = GetSlotCooldownInfo(slotnum, hotbarCategory)
        local isInCooldown = duration > 0
        local slotType = GetSlotType(slotnum, hotbarCategory)
        local showGlobalCooldownForCollectible = global and slotType == ACTION_TYPE_COLLECTIBLE and globalSlotType == ACTION_TYPE_COLLECTIBLE
        local showCooldown = isInCooldown and (ActionBar.SV.GlobalShowGCD or not global or showGlobalCooldownForCollectible)
        local updateChromaQuickslot = slotType ~= ACTION_TYPE_ABILITY and slotType ~= ACTION_TYPE_CRAFTED_ABILITY and ZO_RZCHROMA_EFFECTS
        local NO_LEADING_EDGE = false
        self.cooldown:SetHidden(not showCooldown)

        if showCooldown then
            -- For items with a long CD we need to be sure not to hide the countdown radial timer, so if the duration is the 1 sec GCD, then we don't turn off the cooldown animation.
            if not IsSlotItemConsumable(slotnum, hotbarCategory) or duration > 1000 or ActionBar.SV.GlobalPotion then
                self.cooldown:StartCooldown(remain, duration, CooldownMethod[ActionBar.SV.GlobalMethod], nil, NO_LEADING_EDGE)
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

                self.slot:SetHandler("OnUpdate", function ()
                    self:RefreshCooldown()
                end)
                if updateChromaQuickslot then
                    ZO_RZCHROMA_EFFECTS:RemoveKeybindActionEffect("ACTION_BUTTON_9")
                end
            end
        else
            if ActionBar.SV.GlobalFlash then
                if self.showingCooldown then
                    -- Stop flash from appearing on potion/ultimate if toggled off.
                    if not IsSlotItemConsumable(slotnum, hotbarCategory) or duration > 1000 or ActionBar.SV.GlobalPotion then
                        if self.cooldownCompleteAnim.animation == nil then
                            self.cooldownCompleteAnim.animation = CreateSimpleAnimation(ANIMATION_TEXTURE, self.cooldownCompleteAnim)
                        end
                        local cooldownFlashAnimation = self.cooldownCompleteAnim.animation
                        if cooldownFlashAnimation then
                            self.cooldownCompleteAnim:SetHidden(false)
                            self.cooldown:SetHidden(false)

                            cooldownFlashAnimation:SetImageData(16, 1)
                            cooldownFlashAnimation:SetFramerate(30)
                            cooldownFlashAnimation:GetTimeline():PlayFromStart()

                            if updateChromaQuickslot then
                                ZO_RZCHROMA_EFFECTS:AddKeybindActionEffect("ACTION_BUTTON_9")
                            end
                        end
                    end
                end
            end
            self.icon.percentComplete = 1
            self.slot:SetHandler("OnUpdate", nil)
            self.cooldown:ResetCooldown()
        end

        if showCooldown ~= self.showingCooldown then
            self:SetShowCooldown(showCooldown)
            self:UpdateActivationHighlight()

            if IsInGamepadPreferredMode() then
                self:SetCooldownPercentComplete(self.icon.percentComplete)
            end
        end

        if showCooldown or self.itemQtyFailure then
            self.icon:SetDesaturation(1)
        else
            self.icon:SetDesaturation(0)
        end

        local textColor
        if ActionBar.SV.GlobalLabelColor then
            textColor = showCooldown and INTERFACE_TEXT_COLOR_FAILED or INTERFACE_TEXT_COLOR_SELECTED
        else
            textColor = INTERFACE_TEXT_COLOR_SELECTED
        end
        self.buttonText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, textColor))

        self.isGlobalCooldown = global
        self:UpdateUsable()
    end
end

-- -----------------------------------------------------------------------------
-- Resolve ability rank for GetAbilityDuration/GetAbilityCastInfo (overrideRank).
-- Prefer GetAbilityProgressionRankFromAbilityId (correct for morphs, e.g. rank 4); fallback to progression chain then API 5th return.
---
--- @param abilityId integer
--- @return integer|nil rank 1-based rank, or nil to let API use default
local function GetAbilityRankForDuration(abilityId)
    local resolvedRank = GetAbilityProgressionRankFromAbilityId(abilityId)
    if resolvedRank == nil then
        local skillType, skillLineIndex, skillIndex, morphChoice, rankFromApi = GetSpecificSkillAbilityKeysByAbilityId(abilityId)
        resolvedRank = rankFromApi
        if skillType and skillLineIndex then
            local progressionId = GetProgressionSkillProgressionId(skillType, skillLineIndex, skillIndex)
            local morphSlot = (morphChoice == 0 and MORPH_SLOT_BASE) or (morphChoice == 1 and MORPH_SLOT_MORPH_1 or MORPH_SLOT_MORPH_2)
            if progressionId and morphSlot then
                local abilityIds = { GetProgressionSkillMorphSlotChainedAbilityIds(progressionId, morphSlot) }
                for rankIndex, chainAbilityId in ipairs(abilityIds) do
                    if chainAbilityId == abilityId then
                        resolvedRank = rankIndex
                        break
                    end
                end
            end
        end
    end

    return resolvedRank
end

-- -----------------------------------------------------------------------------
-- Helper function to get override ability duration.
---
--- @param abilityId integer
--- @return integer duration
local function GetUpdatedAbilityDuration(abilityId)
    local overrideCasterUnitTag = "player"
    local overrideActiveRank = GetAbilityRankForDuration(abilityId)
    local duration

    -- Prefer hardcoded override; otherwise use game API (ZOS tooltip order)
    duration = g_barDurationOverride[abilityId]
    if duration == nil then
        local isToggled = IsAbilityDurationToggled(abilityId, overrideCasterUnitTag)
        if isToggled then
            duration = 0 -- ZOS: toggles have no numeric duration
        else
            duration = GetAbilityDuration(abilityId, overrideActiveRank, overrideCasterUnitTag)
        end
    end

    -- If duration is 0, may be cast/channel — use cast time (ZOS: GetAbilityCastInfo 2nd return)
    if duration == 0 then
        local _, castTime = GetAbilityCastInfo(abilityId, overrideActiveRank, overrideCasterUnitTag)
        duration = castTime
    end

    return duration or 0
end

-- -----------------------------------------------------------------------------
-- Called on initialization and menu changes
-- Pull data from Effects.BarHighlightOverride Tables to filter the display of Bar Highlight abilities based off menu settings.
--- Rebuilds bar highlight override/fake-aura tables and (re)registers combat event filters.
function ActionBar.UpdateBarHighlightTables()
    for _, eventName in ipairs(g_barCombatEventNames) do
        eventManager:UnregisterForEvent(eventName, EVENT_COMBAT_EVENT)
    end
    g_barCombatEventNames = {}

    g_uiProcAnimation = {}
    g_uiCustomToggle = {}
    g_triggeredSlotsFront = {}
    g_triggeredSlotsBack = {}
    g_triggeredSlotsRemain = {}
    g_toggledSlotsFront = {}
    g_toggledSlotsBack = {}
    g_toggledSlotsRemain = {}
    g_toggledSlotsStack = {}
    g_toggledSlotsPlayer = {}
    g_barOverrideCI = {}
    g_barFakeAura = {}
    g_barDurationOverride = {}
    g_barNoRemove = {}
    g_barCombatTrack = {}
    g_barCombatStackMax = {}
    g_barConsumeStackOnCast = {}
    g_barCombatStackZeroEffect = {}
    g_barCombatEventRemap = {}
    g_barCombatTrackRemainOnSlotted = {}

    if ActionBar.SV.ShowTriggered or ActionBar.SV.ShowToggled then
        -- Grab any aura's from the list that have on EVENT_COMBAT_EVENT AURA support
        for abilityId, value in pairs(Effects.BarHighlightOverride) do
            if value.showFakeAura == true then
                if value.newId then
                    g_barOverrideCI[value.newId] = true
                    if value.duration then
                        g_barDurationOverride[value.newId] = value.duration
                    end
                    if value.noRemove then
                        g_barNoRemove[value.newId] = true
                    end
                    g_barFakeAura[value.newId] = true
                else
                    g_barOverrideCI[abilityId] = true
                    if value.duration then
                        g_barDurationOverride[abilityId] = value.duration
                    end
                    if value.noRemove then
                        g_barNoRemove[abilityId] = true
                    end
                    g_barFakeAura[abilityId] = true
                end
            elseif value.combatTrack == true then
                local combatTrackAbilityId = value.newId or abilityId
                g_barOverrideCI[combatTrackAbilityId] = true
                g_barCombatTrack[combatTrackAbilityId] = true
                if value.duration then
                    g_barDurationOverride[combatTrackAbilityId] = value.duration
                end
                if value.noRemove then
                    g_barNoRemove[combatTrackAbilityId] = true
                end
                -- Slotted id also fires combat (e.g. Engulfing 20930 BEGIN/GAIN DUR 4750); bar slot keys track id (32821).
                if value.newId and value.newId ~= abilityId then
                    g_barCombatEventRemap[abilityId] = combatTrackAbilityId
                    g_barOverrideCI[abilityId] = true
                end
                if value.combatTrackRemainOnSlotted and combatTrackAbilityId then
                    g_barCombatTrackRemainOnSlotted[combatTrackAbilityId] = true
                end
            else
                if value.noRemove then
                    if value.newId then
                        g_barNoRemove[value.newId] = true
                    else
                        g_barNoRemove[abilityId] = true
                    end
                end
            end
        end
        local counter = 0
        for ability_Id, _ in pairs(g_barOverrideCI) do
            counter = counter + 1
            local eventName = (moduleName .. "CombatEventBar" .. counter)
            ActionBar.RegisterBarCombatEvent(eventManager, g_barCombatEventNames, eventName,
                                             REGISTER_FILTER_ABILITY_ID, ability_Id, REGISTER_FILTER_IS_ERROR, false, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
        end
        for combatTrackAbilityId, maxStacks in pairs(Effects.BarHighlightStack) do
            if g_barOverrideCI[combatTrackAbilityId] then
                g_barCombatStackMax[combatTrackAbilityId] = maxStacks
            end
        end
        for slottedAbilityId, combatTrackAbilityId in pairs(Effects.BarHighlightStackConsume) do
            g_barConsumeStackOnCast[slottedAbilityId] = combatTrackAbilityId
        end
        for combatTrackAbilityId, mode in pairs(Effects.BarHighlightStackZeroEffect) do
            g_barCombatStackZeroEffect[combatTrackAbilityId] = mode
        end
        -- combatTrack buff fades often have no player source on FADE; target = player still clears bar highlight.
        for combatTrackAbilityId in pairs(g_barCombatTrack) do
            if g_barOverrideCI[combatTrackAbilityId] then
                counter = counter + 1
                local eventName = moduleName .. "CombatEventBarFade" .. combatTrackAbilityId
                ActionBar.RegisterBarCombatEvent(eventManager, g_barCombatEventNames, eventName,
                                                 REGISTER_FILTER_ABILITY_ID, combatTrackAbilityId, REGISTER_FILTER_IS_ERROR, false, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)
            end
        end
        for slottedId in pairs(g_barCombatEventRemap) do
            counter = counter + 1
            local eventName = moduleName .. "CombatEventBarFadeSlotted" .. slottedId
            ActionBar.RegisterBarCombatEvent(eventManager, g_barCombatEventNames, eventName,
                                             REGISTER_FILTER_ABILITY_ID, slottedId, REGISTER_FILTER_IS_ERROR, false, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)
        end
    end
end

-- -----------------------------------------------------------------------------
-- Clear and then (maybe) re-register event listeners for Combat/Power/Slot Updates
--- Registers update loop and all ActionBar event handlers (player activated, combat, power, slots, etc.).
function ActionBar.RegisterEvents()
    eventManager:UnregisterForUpdate(moduleName .. "OnUpdate")
    eventManager:UnregisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED)
    eventManager:UnregisterForEvent(moduleName .. "CombatState")

    eventManager:RegisterForUpdate(moduleName .. "OnUpdate", 100, ActionBar.OnUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED, function (eventId, initial)
        ActionBar.OnPlayerActivated()
    end)

    eventManager:RegisterForEvent(moduleName .. "CombatState", EVENT_PLAYER_COMBAT_STATE, function ()
        ActionBar.ApplyDisplayAlpha()
    end)

    eventManager:UnregisterForEvent(moduleName, EVENT_COMBAT_EVENT)
    eventManager:UnregisterForEvent(moduleName, EVENT_POWER_UPDATE)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOT_UPDATED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_ITEM_USED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOT_ABILITY_USED)
    eventManager:UnregisterForEvent(moduleName .. "OakensoulBackbar", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    eventManager:UnregisterForEvent(moduleName .. "CursorPickup", EVENT_CURSOR_PICKUP)
    eventManager:UnregisterForEvent(moduleName .. "CursorDropped", EVENT_CURSOR_DROPPED)
    eventManager:UnregisterForEvent(moduleName .. "SlotUsedStacks", EVENT_ACTION_SLOT_ABILITY_USED)
    eventManager:UnregisterForEvent(moduleName, EVENT_RETICLE_HIDDEN_UPDATE)
    eventManager:UnregisterForEvent(moduleName .. "CompanionPower", EVENT_POWER_UPDATE)
    eventManager:UnregisterForEvent(moduleName .. "UltCostChanged", EVENT_ULTIMATE_ABILITY_COST_CHANGED)
    eventManager:UnregisterForEvent(moduleName .. "CompanionZone", EVENT_ZONE_CHANGED)
    eventManager:UnregisterForEvent(moduleName .. "CompanionState", EVENT_ACTIVE_COMPANION_STATE_CHANGED)
    eventManager:UnregisterForEvent(moduleName .. "CompanionAnchorsWpn", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    if ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
        eventManager:RegisterForEvent(moduleName .. "CombatEvent1", EVENT_COMBAT_EVENT, function (_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
            ActionBar.OnCombatEvent(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
        end)
        eventManager:AddFilterForEvent(moduleName .. "CombatEvent1", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BLOCKED_DAMAGE)
        eventManager:RegisterForEvent(moduleName .. "PowerUpdate", EVENT_POWER_UPDATE, function (_, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
            ActionBar.OnPowerUpdatePlayer(unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
        end)
        eventManager:AddFilterForEvent(moduleName .. "PowerUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
        eventManager:RegisterForEvent(moduleName .. "InventoryUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function (_, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
            ActionBar.OnInventorySlotUpdate(bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
        end)
        eventManager:AddFilterForEvent(moduleName .. "InventoryUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT, REGISTER_FILTER_IS_NEW_ITEM, false)
    end
    if ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
        eventManager:RegisterForEvent(moduleName .. "CombatEvent2", EVENT_COMBAT_EVENT, function (_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
            ActionBar.OnCombatEvent(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
        end)
        eventManager:AddFilterForEvent(moduleName .. "CombatEvent2", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false)
    end
    CastBar.RegisterEvents()
    if ActionBar.SV.ShowToggled then
        eventManager:RegisterForEvent(moduleName .. "SlotUsedStacks", EVENT_ACTION_SLOT_ABILITY_USED, function (_, actionSlotIndex)
            ActionBar.OnAbilityUsed(actionSlotIndex)
        end)
    end
    if ActionBar.SV.ShowTriggered or ActionBar.SV.ShowToggled or ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, function (_, didActiveHotbarChange, shouldUpdateAbilityAssignments, activeHotbarCategory)
            ActionBar.OnActiveHotbarUpdate(didActiveHotbarChange, shouldUpdateAbilityAssignments, activeHotbarCategory)
        end)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, function (_)
            ActionBar.OnSlotsFullUpdate()
        end)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOT_UPDATED, function (_, actionSlotIndex)
            ActionBar.OnSlotUpdated(actionSlotIndex)
        end)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function (_, activeWeaponPair, locked)
            ActionBar.OnActiveWeaponPairChanged(activeWeaponPair, locked)
        end)
    end
    if ActionBar.SV.ShowTriggered or ActionBar.SV.ShowToggled then
        eventManager:RegisterForEvent(moduleName, EVENT_UNIT_DEATH_STATE_CHANGED, function (_, unitTag, isDead)
            ActionBar.OnDeath(unitTag, isDead)
        end)
        eventManager:RegisterForEvent(moduleName, EVENT_TARGET_CHANGED, function (_, unitTag)
            ActionBar.OnTargetChange(unitTag)
        end)
        eventManager:RegisterForEvent(moduleName, EVENT_RETICLE_TARGET_CHANGED, function (_)
            ActionBar.OnReticleTargetChanged()
        end)
        eventManager:RegisterForEvent(moduleName, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function (_, gamepadPreferred)
            ActionBar.BackbarSetupTemplate()
        end)

        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_ITEM_USED, function (_, itemSoundCategory)
            ActionBar.InventoryItemUsed()
        end)

        -- Setup bar highlight
        ActionBar.UpdateBarHighlightTables()
    end
    -- EVENT_EFFECT_CHANGED: bar highlights and vampire ultimate label (cast break is on CastBar)
    if ActionBar.SV.ShowTriggered or ActionBar.SV.ShowToggled or ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
        eventManager:RegisterForEvent(moduleName, EVENT_EFFECT_CHANGED, function (_, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType, passThrough, savedId)
            ActionBar.OnEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType, passThrough, savedId)
        end)
    end
    -- Register for ring slot changes - Oaken soul Ring (187658) equip/unequip toggles backbar visibility when BarShowBack
    Backbar.RegisterEvents()
    -- Drop callout handlers (mirrors ZOS: show valid/invalid slot highlight when dragging abilities)
    eventManager:RegisterForEvent(moduleName .. "CursorPickup", EVENT_CURSOR_PICKUP, function (_, cursorType, param1, param2, param3)
        if cursorType == MOUSE_CONTENT_ACTION and DROP_CALLOUT_VALIDITY_BY_ACTION_TYPE[param1] then
            Backbar.ShowAppropriateAbilityActionButtonDropCallouts(param1, param3)
        end
    end)
    eventManager:RegisterForEvent(moduleName .. "CursorDropped", EVENT_CURSOR_DROPPED, function (_, cursorType)
        if cursorType == MOUSE_CONTENT_ACTION then
            Backbar.HideAllAbilityActionButtonDropCallouts()
        end
    end)
    -- Display default UI ultimate text if the LUIE option is enabled.
    if ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
        if not ZO_IsConsoleOrGameCoreUI() then
            SetSetting(SETTING_TYPE_UI, UI_SETTING_ULTIMATE_NUMBER, 0)
        end
    end

    if ActionBar.SV.CompanionUltimateLabelEnabled or ActionBar.SV.CompanionUltimatePctEnabled then
        eventManager:RegisterForEvent(moduleName .. "CompanionPower", EVENT_POWER_UPDATE, function (_, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
            ActionBar.OnPowerUpdateCompanion(unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
        end)
        eventManager:AddFilterForEvent(moduleName .. "CompanionPower", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_ULTIMATE, REGISTER_FILTER_UNIT_TAG, "companion")
    end
    if ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled or ActionBar.SV.CompanionUltimateLabelEnabled or ActionBar.SV.CompanionUltimatePctEnabled then
        eventManager:RegisterForEvent(moduleName .. "UltCostChanged", EVENT_ULTIMATE_ABILITY_COST_CHANGED, function ()
            ActionBar.UpdateUltimateLabel()
            ActionBar.UpdateCompanionUltimateLabel()
        end)
    end

    eventManager:RegisterForEvent(moduleName .. "CompanionZone", EVENT_ZONE_CHANGED, function ()
        RefreshCompanionQuickslotAnchors()
    end)
    eventManager:RegisterForEvent(moduleName .. "CompanionState", EVENT_ACTIVE_COMPANION_STATE_CHANGED, function (_, newState, oldState)
        ActionBar.OnActiveCompanionStateChanged(newState)
    end)
    eventManager:RegisterForEvent(moduleName .. "CompanionAnchorsWpn", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function ()
        RefreshCompanionQuickslotAnchors()
    end)

    eventManager:RegisterForEvent(moduleName, EVENT_RETICLE_HIDDEN_UPDATE, function (_, hidden)
        ActionBar.OnReticleHiddenUpdate(hidden)
    end)
end

-- -----------------------------------------------------------------------------
--- Clears all entries from a custom list (e.g. blacklist); prints to chat.
--- @param list AB_CustomList
function ActionBar.ClearCustomList(list)
    local customListLabel = list == ActionBar.SV.blacklist and GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST) or ""
    for listKey, _ in pairs(list) do
        list[listKey] = nil
    end
    chatSystem:Maximize()
    chatSystem.primaryContainer:FadeIn()
    printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_CLEARED), customListLabel), true)
end

-- -----------------------------------------------------------------------------
-- List Handling (Add) for Prominent Auras & Blacklist
--- Adds an ability id or name to a custom list (e.g. blacklist); prints to chat.
--- @param list AB_CustomList
--- @param input any Ability id (number string) or name string
function ActionBar.AddToCustomList(list, input)
    local abilityId = tonumber(input)
    local customListLabel = list == ActionBar.SV.blacklist and GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST) or ""
    if abilityId and abilityId > 0 then
        local abilityDisplayName = zo_strformat("<<C:1>>", GetAbilityName(abilityId))
        if abilityDisplayName ~= nil and abilityDisplayName ~= "" then
            local abilityListIcon = zo_iconFormat(GetAbilityIcon(abilityId), 16, 16)
            list[abilityId] = true
            chatSystem:Maximize()
            chatSystem.primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_ID), abilityListIcon, abilityId, abilityDisplayName, customListLabel), true)
        else
            chatSystem:Maximize()
            chatSystem.primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_FAILED), input, customListLabel), true)
        end
    else
        if input ~= "" then
            list[input] = true
            chatSystem:Maximize()
            chatSystem.primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_NAME), input, customListLabel), true)
        end
    end
end

-- -----------------------------------------------------------------------------
-- List Handling (Remove) for Prominent Auras & Blacklist
--- Removes an ability id or name from a custom list (e.g. blacklist); prints to chat.
--- @param list AB_CustomList
--- @param input any Ability id (number string) or name string
function ActionBar.RemoveFromCustomList(list, input)
    local abilityId = tonumber(input)
    local customListLabel = list == ActionBar.SV.blacklist and GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST) or ""
    if abilityId and abilityId > 0 then
        local abilityDisplayName = zo_strformat("<<C:1>>", GetAbilityName(abilityId))
        local abilityListIcon = zo_iconFormat(GetAbilityIcon(abilityId), 16, 16)
        list[abilityId] = nil
        chatSystem:Maximize()
        chatSystem.primaryContainer:FadeIn()
        printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_REMOVED_ID), abilityListIcon, abilityId, abilityDisplayName, customListLabel), true)
    else
        if input ~= "" then
            list[input] = nil
            chatSystem:Maximize()
            chatSystem.primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_REMOVED_NAME), input, customListLabel), true)
        end
    end
end

-- -----------------------------------------------------------------------------
--- Set action bar and cast bar opacity from in-combat / out-of-combat saved values (0–100).
function ActionBar.ApplyDisplayAlpha()
    if not ActionBar.Enabled then
        g_actionBarDisplayAlpha = nil
        return
    end

    local oocAlpha = ActionBar.SV.oocAlpha or 100
    local incAlpha = ActionBar.SV.incAlpha or 100
    local alpha = 0.01 * (IsUnitInCombat("player") and incAlpha or oocAlpha)
    g_actionBarDisplayAlpha = alpha

    local actionBar = GetActionBarControl()
    if actionBar and actionBar.SetAlpha then
        actionBar:SetAlpha(alpha)
    end

    CastBar.ApplyDisplayAlpha(alpha)
end

-- -----------------------------------------------------------------------------
-- Used to populate abilities icons after the user has logged on
--- Runs on EVENT_PLAYER_ACTIVATED: full slot update, ultimate label, backbar visibility, drop callouts.
function ActionBar.OnPlayerActivated()
    -- Manually trigger event to update stats
    g_hotbarCategory = GetActiveHotbarCategory()
    ActionBar.CreateCompanionUltimateLabels()
    RefreshCompanionQuickslotAnchors()
    ActionBar.OnSlotsFullUpdate()
    for i = (BAR_INDEX_START + BACKBAR_INDEX_OFFSET), (BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET) do
        -- Update Bar Slots on initial load (don't want to do it normally when we do a slot update)
        ActionBar.BarSlotUpdate(i, true, false)
    end
    ActionBar.OnPowerUpdatePlayer("player", nil, COMBAT_MECHANIC_FLAGS_ULTIMATE, GetUnitPower("player", COMBAT_MECHANIC_FLAGS_ULTIMATE))

    Backbar.HideAllAbilityActionButtonDropCallouts()
    Backbar.OnPlayerActivatedScan()

    ActionBar.ApplyDisplayAlpha()
end

-- -----------------------------------------------------------------------------
-- Hide duration label if the ability is Grim Focus or one of its morphs
--- @param remain integer
--- @param abilityId integer
--- @return string
local function SetBarRemainLabel(remain, abilityId)
    if Effects.IsGrimFocus[abilityId] or Effects.IsBloodFrenzy[abilityId]
    then
        return ""
    end

    return FormatDurationSeconds(remain)
end

-- -----------------------------------------------------------------------------
-- Updates all floating labels. Called every 100ms
---
--- @param currentTimeMS integer
function ActionBar.OnUpdate(currentTimeMS)
    if g_actionBarDisplayAlpha then
        local actionBar = GetActionBarControl()
        if actionBar and actionBar.GetAlpha and actionBar.SetAlpha then
            if zo_abs(actionBar:GetAlpha() - g_actionBarDisplayAlpha) > 0.001 then
                actionBar:SetAlpha(g_actionBarDisplayAlpha)
            end
        end
    end

    -- Procs
    for highlightAbilityId, effectEndTimeMs in pairs(g_triggeredSlotsRemain) do
        local remain = effectEndTimeMs - currentTimeMS
        local frontSlotNum = g_triggeredSlotsFront[highlightAbilityId]
        local backSlotNum = g_triggeredSlotsBack[highlightAbilityId]
        local frontAnim = frontSlotNum and g_uiProcAnimation[frontSlotNum]
        local backAnim = backSlotNum and g_uiProcAnimation[backSlotNum]
        -- If duration reaches 0 then remove effect
        if effectEndTimeMs < currentTimeMS then
            if frontAnim then
                frontAnim:Stop()
            end
            if backAnim then
                backAnim:Stop()
            end
            g_triggeredSlotsRemain[highlightAbilityId] = nil
        end
        -- Update Label (FRONT)(BACK)
        if ActionBar.SV.BarShowLabel and remain then
            if frontAnim then
                frontAnim.procLoopTexture.label:SetText(SetBarRemainLabel(remain, highlightAbilityId))
            end
            if backAnim then
                backAnim.procLoopTexture.label:SetText(SetBarRemainLabel(remain, highlightAbilityId))
            end
        end
    end
    -- Ability Highlight
    for highlightAbilityId, effectEndTimeMs in pairs(g_toggledSlotsRemain) do
        local remain = effectEndTimeMs - currentTimeMS
        local frontSlotNum = g_toggledSlotsFront[highlightAbilityId]
        local backSlotNum = g_toggledSlotsBack[highlightAbilityId]
        local frontToggle = frontSlotNum and g_uiCustomToggle[frontSlotNum]
        local backToggle = backSlotNum and g_uiCustomToggle[backSlotNum]
        -- Update Label (FRONT)
        if effectEndTimeMs < currentTimeMS then
            if frontToggle then
                ActionBar.HideSlot(frontSlotNum, highlightAbilityId)
            end
            if backToggle then
                ActionBar.HideSlot(backSlotNum, highlightAbilityId)
            end
            g_toggledSlotsRemain[highlightAbilityId] = nil
            g_toggledSlotsStack[highlightAbilityId] = nil
        end
        -- Update Label (BACK)
        if ActionBar.SV.BarShowLabel and remain then
            if frontToggle then
                frontToggle.label:SetText(SetBarRemainLabel(remain, highlightAbilityId))
            end
            if backToggle then
                backToggle.label:SetText(SetBarRemainLabel(remain, highlightAbilityId))
            end
        end
    end

    -- Quickslot cooldown
    if ActionBar.SV.PotionTimerShow then
        local slotIndex = GetCurrentQuickslot()
        local remain, duration, _ = GetSlotCooldownInfo(slotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
        local label = uiQuickSlot.label
        local timeColours = uiQuickSlot.timeColours
        if duration > 5000 then
            label:SetHidden(false)
            if not ActionBar.SV.PotionTimerColor then
                label:SetColor(1, 1, 1, 1)
            else
                local color = uiQuickSlot.colour
                local r, g, b, a = color[1], color[2], color[3], color[4]
                for i = #timeColours, 1, -1 do
                    if remain < timeColours[i].remain then
                        color = timeColours[i].colour
                        break
                    end
                end
                label:SetColor(r, g, b, a)
            end
            local text
            if remain > 86400000 then
                text = zo_floor(remain / 86400000) .. " d"
            elseif remain > 6000000 then
                text = zo_floor(remain / 3600000) .. "h"
            elseif remain > 600000 then
                text = zo_floor(remain / 60000) .. "m"
            elseif remain > 60000 then
                local minutesPart = zo_floor(remain / 60000)
                local secondsPart = remain / 1000 - 60 * minutesPart
                text = minutesPart .. ":" .. string_format("%.2d", secondsPart)
            else
                text = string_format(ActionBar.SV.PotionTimerMillis and "%.1f" or "%.1d", 0.001 * remain)
            end
            label:SetText(text)
        else
            label:SetHidden(true)
        end
    end

    -- Hide Ultimate generation texture if it is time to do so
    if ActionBar.SV.UltimateGeneration then
        if not uiUltimate.Texture:IsHidden() and uiUltimate.FadeTime < currentTimeMS then
            uiUltimate.Texture:SetHidden(true)
        end
    end
end

-- -----------------------------------------------------------------------------
--- @param actionSlotIndex number
function ActionBar.OnAbilityUsed(actionSlotIndex)
    -- combatTrack stack spenders (Effects.BarHighlightStackConsume)
    if ActionBar.SV.ShowToggled then
        local slottedAbilityId = GetSlotTrueBoundId(actionSlotIndex, g_hotbarCategory)
        local combatTrackAbilityId = g_barConsumeStackOnCast[slottedAbilityId]
        if combatTrackAbilityId and (g_toggledSlotsFront[combatTrackAbilityId] or g_toggledSlotsBack[combatTrackAbilityId]) and g_toggledSlotsRemain[combatTrackAbilityId] then
            DecrementBarHighlightCombatStack(combatTrackAbilityId)
        end
    end
end

-- -----------------------------------------------------------------------------
---
--- @param fontNameKey string
--- @param fontStyleKey string
--- @param fontSizeKey string
--- @param defaultFontStyle integer
--- @param defaultFontSize integer
--- @return string
local function buildModuleFontString(fontNameKey, fontStyleKey, fontSizeKey, defaultFontStyle, defaultFontSize)
    local fontName = LUIE.Fonts[ActionBar.SV[fontNameKey]]
    if not fontName or fontName == "" then
        LUIE:Log("Debug", GetString(LUIE_STRING_ERROR_FONT))
        fontName = "LUIE Default Font"
    end
    local fontStyle = ActionBar.SV[fontStyleKey] or defaultFontStyle
    local fontSize = (ActionBar.SV[fontSizeKey] and ActionBar.SV[fontSizeKey] > 0) and ActionBar.SV[fontSizeKey] or defaultFontSize
    return LUIE.CreateFontString(fontName, fontSize, fontStyle)
end

-- -----------------------------------------------------------------------------
-- Updates local variables with new font.
--- Applies SV font settings to bar, quickslot, ultimate, and castbar labels.
function ActionBar.ApplyFont()
    if not ActionBar.Enabled then
        return
    end

    g_barFont = buildModuleFontString("BarFontFace", "BarFontStyle", "BarFontSize", FONT_STYLE_OUTLINE, 17)
    for slotNum, _ in pairs(g_uiProcAnimation) do
        g_uiProcAnimation[slotNum].procLoopTexture.label:SetFont(g_barFont)
    end
    for slotNum, _ in pairs(g_uiCustomToggle) do
        if g_uiCustomToggle[slotNum] ~= true then
            g_uiCustomToggle[slotNum].label:SetFont(g_barFont)
            g_uiCustomToggle[slotNum].stack:SetFont(g_barFont)
        end
    end

    g_potionFont = buildModuleFontString("PotionTimerFontFace", "PotionTimerFontStyle", "PotionTimerFontSize", FONT_STYLE_OUTLINE, 17)
    if uiQuickSlot.label then
        uiQuickSlot.label:SetFont(g_potionFont)
    end

    g_ultimateFont = buildModuleFontString("UltimateFontFace", "UltimateFontStyle", "UltimateFontSize", FONT_STYLE_OUTLINE, 17)
    if uiUltimate.LabelPct then
        uiUltimate.LabelPct:SetFont(g_ultimateFont)
    end

    g_companionUltimateFont = buildModuleFontString("CompanionUltimateFontFace", "CompanionUltimateFontStyle", "CompanionUltimateFontSize", FONT_STYLE_OUTLINE, 17)
    if uiCompanionUltimate.LabelPct then
        uiCompanionUltimate.LabelPct:SetFont(g_companionUltimateFont)
    end

    CastBar.ApplyFont(buildModuleFontString("CastBarFontFace", "CastBarFontStyle", "CastBarFontSize", FONT_STYLE_SOFT_SHADOW_THIN, 16))
end

-- -----------------------------------------------------------------------------
-- Updates Proc Sound - called on initialization and menu changes
--- Sets proc sound from SV; optionally plays it if menu is provided.
--- @param previewMenuContext table? If set, plays the sound for preview.
function ActionBar.ApplyProcSound(previewMenuContext)
    local barProcSound = LUIE.Sounds[ActionBar.SV.ProcSoundName]
    if not barProcSound or barProcSound == "" then
        printToChat(GetString(LUIE_STRING_ERROR_SOUND), true)
        barProcSound = "DeathRecap_KillingBlowShown"
    end

    g_ProcSound = barProcSound

    if previewMenuContext then
        PlaySound(g_ProcSound)
    end
end

-- -----------------------------------------------------------------------------
-- Resets the ultimate labels on menu option change
--- Re-anchors ultimate percent label using SV UltimateLabelPosition.
function ActionBar.ResetUltimateLabel()
    uiUltimate.LabelPct:ClearAnchors()
    local ActionButton8 = ZO_ActionBar_GetButton(ACTION_BAR_ULTIMATE_SLOT_INDEX + 1)
    local ultimateActionButtonSlot = ActionButton8 and ActionButton8.slot
    uiUltimate.LabelPct:SetAnchor(TOPLEFT, ultimateActionButtonSlot)
    uiUltimate.LabelPct:SetAnchor(BOTTOMRIGHT, ultimateActionButtonSlot, nil, 0, -ActionBar.SV.UltimateLabelPosition)
end

-- -----------------------------------------------------------------------------
--- Creates companion ultimate overlay labels on first use (after CompanionUltimateButton exists).
function ActionBar.CreateCompanionUltimateLabels()
    if g_companionUltimateLabelsCreated then
        return
    end
    if not ActionBar.SV.CompanionUltimateLabelEnabled and not ActionBar.SV.CompanionUltimatePctEnabled then
        return
    end
    local companionBtn = ZO_ActionBar_GetButton(g_ultimateSlot, HOTBAR_CATEGORY_COMPANION)
    local companionButton = companionBtn and companionBtn.button
    if not companionButton then
        return
    end

    local ultimateValueLabel = companionButton:CreateControl("$(parent)LUIECompanionLabelVal", CT_LABEL)
    ultimateValueLabel:SetAnchor(BOTTOM, companionButton, TOP, 0, -3)
    ultimateValueLabel:SetFont("$(BOLD_FONT)|16|soft-shadow-thick")
    ultimateValueLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    ultimateValueLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
    ultimateValueLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    ultimateValueLabel:SetHidden(not ActionBar.SV.CompanionUltimateLabelEnabled)
    uiCompanionUltimate.LabelVal = ultimateValueLabel

    local ultimatePctLabel = companionButton:CreateControl("$(parent)LUIECompanionLabelPct", CT_LABEL)
    ultimatePctLabel:SetFont(g_companionUltimateFont or "LUIE Default Font")
    ultimatePctLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    ultimatePctLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    ultimatePctLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    ultimatePctLabel:SetAnchor(TOPLEFT, companionButton)
    ultimatePctLabel:SetAnchor(BOTTOMRIGHT, companionButton, nil, 0, -ActionBar.SV.CompanionUltimateLabelPosition)
    ultimatePctLabel:SetColor(unpack(ActionBar.SV.CompanionUltimateColorDefault))
    ultimatePctLabel:SetDrawLayer(DL_OVERLAY)
    ultimatePctLabel:SetDrawTier(DT_HIGH)
    ultimatePctLabel:SetHidden(not ActionBar.SV.CompanionUltimatePctEnabled)
    uiCompanionUltimate.LabelPct = ultimatePctLabel

    g_companionUltimateLabelsCreated = true
    ActionBar.ApplyFont()
    ActionBar.ResetCompanionUltimateLabel()
end

--- Re-anchors companion ultimate percent label using SV CompanionUltimateLabelPosition.
function ActionBar.ResetCompanionUltimateLabel()
    if not uiCompanionUltimate.LabelPct then
        return
    end
    uiCompanionUltimate.LabelPct:ClearAnchors()
    local companionBtn = ZO_ActionBar_GetButton(g_ultimateSlot, HOTBAR_CATEGORY_COMPANION)
    local companionSlot = companionBtn and companionBtn.slot
    if not companionSlot then
        return
    end
    uiCompanionUltimate.LabelPct:SetAnchor(TOPLEFT, companionSlot)
    uiCompanionUltimate.LabelPct:SetAnchor(BOTTOMRIGHT, companionSlot, nil, 0, -ActionBar.SV.CompanionUltimateLabelPosition)
end

--- Refreshes companion ultimate slot label (cost, percentage) from companion power and slot ability.
--- @param optionalCurrentPower number|nil Current ultimate value; if nil, read from API.
function ActionBar.UpdateCompanionUltimateLabel(optionalCurrentPower)
    if not ActionBar.SV.CompanionUltimateLabelEnabled and not ActionBar.SV.CompanionUltimatePctEnabled then
        if uiCompanionUltimate.LabelVal then
            uiCompanionUltimate.LabelVal:SetHidden(true)
        end
        if uiCompanionUltimate.LabelPct then
            uiCompanionUltimate.LabelPct:SetHidden(true)
        end
        return
    end
    ActionBar.CreateCompanionUltimateLabels()
    if not uiCompanionUltimate.LabelVal and not uiCompanionUltimate.LabelPct then
        return
    end
    local isCompanionActive = ShouldShowCompanionUltimateButton()
    if not isCompanionActive then
        if uiCompanionUltimate.LabelVal then
            uiCompanionUltimate.LabelVal:SetHidden(true)
        end
        if uiCompanionUltimate.LabelPct then
            uiCompanionUltimate.LabelPct:SetHidden(true)
        end
        return
    end

    local current = optionalCurrentPower
    if current == nil then
        current = GetUnitPower("companion", COMBAT_MECHANIC_FLAGS_ULTIMATE)
    end
    local maxCost = GetSlotAbilityCost(g_ultimateSlot, COMBAT_MECHANIC_FLAGS_ULTIMATE, HOTBAR_CATEGORY_COMPANION) or 0

    if maxCost <= 0 or not IsSlotUsed(g_ultimateSlot, HOTBAR_CATEGORY_COMPANION) then
        if uiCompanionUltimate.LabelVal then
            uiCompanionUltimate.LabelVal:SetHidden(true)
        end
        if uiCompanionUltimate.LabelPct then
            uiCompanionUltimate.LabelPct:SetHidden(true)
        end
        return
    end

    local ultimatePercent = zo_floor((current / maxCost) * 100)
    if ultimatePercent > 100 then
        ultimatePercent = 100
    end

    local settings = ActionBar.SV
    if uiCompanionUltimate.LabelVal and settings.CompanionUltimateLabelEnabled then
        uiCompanionUltimate.LabelVal:SetText(current .. "/" .. maxCost)
        local hideVal = settings.CompanionUltimateHideFull and current >= maxCost
        uiCompanionUltimate.LabelVal:SetHidden(hideVal)
    end

    if uiCompanionUltimate.LabelPct and settings.CompanionUltimatePctEnabled then
        local colourRow = settings.CompanionUltimateColor50
        if ultimatePercent >= 100 then
            colourRow = settings.CompanionUltimateColor100
        elseif ultimatePercent >= 80 then
            colourRow = settings.CompanionUltimateColor80
        end
        uiCompanionUltimate.LabelPct:SetColor(unpack(colourRow))
        uiCompanionUltimate.LabelPct:SetText(ultimatePercent .. "%")
        local hidePct = settings.CompanionUltimateHideFull and current >= maxCost
        uiCompanionUltimate.LabelPct:SetHidden(hidePct)
    end
end

--- Companion ultimate power path only (see `REGISTER_FILTER_UNIT_TAG` / `REGISTER_FILTER_POWER_TYPE` on CompanionPower).
--- @param _unitTag string Filtered to `"companion"`.
--- @param _powerIndex luaindex?
--- @param _powerType CombatMechanicFlags Filtered to ultimate.
--- @param powerValue integer
--- @param powerMax integer
--- @param _powerEffectiveMax integer
function ActionBar.OnPowerUpdateCompanion(_unitTag, _powerIndex, _powerType, powerValue, powerMax, _powerEffectiveMax)
    uiCompanionUltimate.NotFull = (powerValue < powerMax)
    ActionBar.UpdateCompanionUltimateLabel(powerValue)
end

--- @param newState CompanionState
function ActionBar.OnActiveCompanionStateChanged(newState)
    RefreshCompanionQuickslotAnchors()
    local active = newState == COMPANION_STATE_ACTIVE
    if active then
        if uiCompanionUltimate.LabelVal and ActionBar.SV.CompanionUltimateLabelEnabled then
            uiCompanionUltimate.LabelVal:SetHidden(false)
        end
        if uiCompanionUltimate.LabelPct and ActionBar.SV.CompanionUltimatePctEnabled then
            uiCompanionUltimate.LabelPct:SetHidden(false)
        end
        ActionBar.UpdateCompanionUltimateLabel()
    else
        if uiCompanionUltimate.LabelVal then
            uiCompanionUltimate.LabelVal:SetHidden(true)
        end
        if uiCompanionUltimate.LabelPct then
            uiCompanionUltimate.LabelPct:SetHidden(true)
        end
    end
end

-- -----------------------------------------------------------------------------
-- Resets bar labels on menu option change
--- Clears and re-anchors all bar highlight labels (proc + toggle) per SV BarLabelPosition.
function ActionBar.ResetBarLabel()
    for slotNum, _ in pairs(g_uiProcAnimation) do
        g_uiProcAnimation[slotNum].procLoopTexture.label:SetText("")
    end

    for slotNum, _ in pairs(g_uiCustomToggle) do
        if g_uiCustomToggle[slotNum] ~= true then
            g_uiCustomToggle[slotNum].label:SetText("")
        end
    end

    for i = BAR_INDEX_START, BAR_INDEX_END do
        -- Clear base action bars
        local actionButton = ZO_ActionBar_GetButton(i)
        local actionButtonSlot = actionButton and actionButton.slot
        local customToggleControl = GetCustomToggleControl(i)
        if customToggleControl then
            customToggleControl.label:ClearAnchors()
            customToggleControl.label:SetAnchor(TOPLEFT, actionButtonSlot)
            customToggleControl.label:SetAnchor(BOTTOMRIGHT, actionButtonSlot, nil, 0, -ActionBar.SV.BarLabelPosition)
        elseif g_uiProcAnimation[i] then
            g_uiProcAnimation[i].procLoopTexture.label:ClearAnchors()
            g_uiProcAnimation[i].procLoopTexture.label:SetAnchor(TOPLEFT, actionButtonSlot)
            g_uiProcAnimation[i].procLoopTexture.label:SetAnchor(BOTTOMRIGHT, actionButtonSlot, nil, 0, -ActionBar.SV.BarLabelPosition)
        end

        local backIndex = i + BACKBAR_INDEX_OFFSET
        local actionButtonBB = Backbar.GetButton(backIndex)
        local backbarCustomToggleControl = GetCustomToggleControl(backIndex)
        if backbarCustomToggleControl then
            backbarCustomToggleControl.label:ClearAnchors()
            backbarCustomToggleControl.label:SetAnchor(TOPLEFT, actionButtonBB.slot)
            backbarCustomToggleControl.label:SetAnchor(BOTTOMRIGHT, actionButtonBB.slot, nil, 0, -ActionBar.SV.BarLabelPosition)
        elseif g_uiProcAnimation[backIndex] then
            g_uiProcAnimation[backIndex].procLoopTexture.label:ClearAnchors()
            g_uiProcAnimation[backIndex].procLoopTexture.label:SetAnchor(TOPLEFT, actionButtonBB.slot)
            g_uiProcAnimation[backIndex].procLoopTexture.label:SetAnchor(BOTTOMRIGHT, actionButtonBB.slot, nil, 0, -ActionBar.SV.BarLabelPosition)
        end
    end
end

-- -----------------------------------------------------------------------------
-- Resets Potion Timer label - called on initialization and menu changes
--- Re-anchors quickslot timer label using SV PotionTimerLabelPosition.
function ActionBar.ResetPotionTimerLabel()
    local QSB = ACTION_BAR:GetNamedChild("QuickslotButtonButton")
    uiQuickSlot.label:ClearAnchors()
    uiQuickSlot.label:SetAnchor(TOPLEFT, QSB)
    uiQuickSlot.label:SetAnchor(BOTTOMRIGHT, QSB, nil, 0, -ActionBar.SV.PotionTimerLabelPosition)
end

-- -----------------------------------------------------------------------------
-- Runs on the EVENT_TARGET_CHANGE listener.
-- This handler fires every time the someone target changes.
-- This function is needed in case the player teleports via Way Shrine
--- Refreshes bar highlight on reticle target when player becomes the target (e.g. wayshrine).
--- @param unitTag string
function ActionBar.OnTargetChange(unitTag)
    if unitTag ~= "player" then
        return
    end
    ActionBar.OnReticleTargetChanged()
end

-- -----------------------------------------------------------------------------
-- Runs on the EVENT_RETICLE_HIDDEN_UPDATE listener.
-- This handler fires when the reticle visibility changes
--- Stores reticle hidden state for skipping bar highlight updates.
--- @param hidden boolean
function ActionBar.OnReticleHiddenUpdate(hidden)
    g_reticleHidden = hidden
end

-- -----------------------------------------------------------------------------
-- Runs on the EVENT_RETICLE_TARGET_CHANGED listener.
-- This handler fires every time the player's reticle target changes
--- Updates bar highlights when reticle target changes; hides/shows toggled slots and re-scans buffs.
function ActionBar.OnReticleTargetChanged()
    -- Skip processing if reticle is hidden
    if g_reticleHidden then
        return
    end

    local unitTag = "reticleover"

    for highlightAbilityId, _effectEndTimeMs in pairs(g_toggledSlotsRemain) do
        if ((g_toggledSlotsFront[highlightAbilityId] and g_uiCustomToggle[g_toggledSlotsFront[highlightAbilityId]]) or (g_toggledSlotsBack[highlightAbilityId] and g_uiCustomToggle[g_toggledSlotsBack[highlightAbilityId]])) and not (g_toggledSlotsPlayer[highlightAbilityId] or g_barNoRemove[highlightAbilityId]) then
            if g_toggledSlotsFront[highlightAbilityId] and g_uiCustomToggle[g_toggledSlotsFront[highlightAbilityId]] then
                local slotNum = g_toggledSlotsFront[highlightAbilityId]
                ActionBar.HideSlot(slotNum, highlightAbilityId)
            end
            if g_toggledSlotsBack[highlightAbilityId] and g_uiCustomToggle[g_toggledSlotsBack[highlightAbilityId]] then
                local slotNum = g_toggledSlotsBack[highlightAbilityId]
                ActionBar.HideSlot(slotNum, highlightAbilityId)
            end
            g_toggledSlotsRemain[highlightAbilityId] = nil
            g_toggledSlotsStack[highlightAbilityId] = nil
            if Effects.BarHighlightCheckOnFade[highlightAbilityId] then
                ActionBar.BarHighlightSwap(highlightAbilityId)
            end
        end
    end

    if DoesUnitExist("reticleover") then
        -- Fill it again
        for i = 1, GetNumBuffs(unitTag) do
            local unitName = GetRawUnitName(unitTag)
            local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer
            buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo(unitTag, i)
            -- Convert boolean to number value if cast by player
            if castByPlayer == true then
                castByPlayer = 1
            else
                castByPlayer = 5
            end
            if not IsUnitDead(unitTag) then
                ActionBar.OnEffectChanged(
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
                    0,
                    abilityId,
                    castByPlayer,
                    false,
                    nil)
            end
        end
    end
end

-- -----------------------------------------------------------------------------
---
-- When the primary tracked effect fades, iterate over unit buffs to see if another buff is present.
-- If found, send a dummy EFFECT_RESULT_GAINED event using that buff's duration/stack info but the original ability's id.
-- This allows bar highlights to "swap" to an alternative buff (e.g. Minor Maim from Grave Grasp vs Ghostly Embrace).
--
--- @param abilityId integer The original ability id (key into BarHighlightCheckOnFade).
--
-- Priority system: id1 > id2 > id3. First match wins. Each id may use a different unitTag via id2Tag/id3Tag.
-- castByPlayer must be true: when two instances of the same buff exist (one player-cast, one not), we only highlight our own.
--
-- Paths:
--   1. duration > 0: duration and durationMod are ability IDs. GetUpdatedAbilityDuration(id) returns ms; we use duration_ms - durationMod_ms for the synthetic aura.
--   2. id1/id2/id3: Scan buffs on unitTag (or id2Tag/id3Tag overrides), find first match, fire event.
function ActionBar.BarHighlightSwap(abilityId)
    local fadeCheckConfig = Effects.BarHighlightCheckOnFade[abilityId]
    if not fadeCheckConfig then return end

    local unitTag = fadeCheckConfig.unitTag
    if not DoesUnitExist(unitTag) then return end

    -- Path 1: Fake duration. duration and durationMod are ability IDs; GetUpdatedAbilityDuration returns ms. Result: duration_ms - durationMod_ms.
    local duration = fadeCheckConfig.duration or 0
    local durationMod = fadeCheckConfig.durationMod or 0
    if duration > 0 then
        local fakeDuration = GetUpdatedAbilityDuration(duration) - GetUpdatedAbilityDuration(durationMod)
        local timeStarted = GetGameTimeSeconds()
        local timeEnding = timeStarted + (fakeDuration / 1000)
        ActionBar.OnEffectChanged(EFFECT_RESULT_GAINED, nil, nil, unitTag, timeStarted, timeEnding, 0, nil, nil, 1, ABILITY_TYPE_BONUS, 0, nil, nil, abilityId, 1, true, nil)
        return
    end

    -- Path 2: Buff scan. Build priority-ordered checks: { id, tag } per fallback.
    -- id1 uses unitTag; id2 uses id2Tag if set, else unitTag; id3 uses id3Tag if set, else current tag.
    local checks = {}
    local fallbackAbilityId1 = fadeCheckConfig.id1 or 0
    local fallbackAbilityId2 = fadeCheckConfig.id2 or 0
    local fallbackAbilityId3 = fadeCheckConfig.id3 or 0
    if fallbackAbilityId1 ~= 0 then checks[#checks + 1] = { abilityId = fallbackAbilityId1, unitTag = unitTag } end
    if fallbackAbilityId2 ~= 0 then
        unitTag = fadeCheckConfig.id2Tag or unitTag
        checks[#checks + 1] = { abilityId = fallbackAbilityId2, unitTag = unitTag }
    end
    if fallbackAbilityId3 ~= 0 then
        unitTag = fadeCheckConfig.id3Tag or unitTag
        checks[#checks + 1] = { abilityId = fallbackAbilityId3, unitTag = unitTag }
    end

    for _, buffCheck in ipairs(checks) do
        for i = 1, GetNumBuffs(buffCheck.unitTag) do
            local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityIdNew, canClickOff, castByPlayer = GetUnitBuffInfo(buffCheck.unitTag, i)
            if buffCheck.abilityId == abilityIdNew and castByPlayer then
                ActionBar.OnEffectChanged(EFFECT_RESULT_GAINED, nil, nil, buffCheck.unitTag, timeStarted, timeEnding, stackCount, nil, buffType, effectType, abilityType, statusEffectType, nil, nil, abilityId, COMBAT_UNIT_TYPE_PLAYER, true, nil)
                return
            end
        end
    end
end

--- Iterate over front and back toggled slots for abilityId; call slotCallback(slotNum) for each valid slot.
forEachToggledBarSlot = function (abilityId, slotCallback)
    local frontSlotNum = g_toggledSlotsFront[abilityId]
    local backSlotNum = g_toggledSlotsBack[abilityId]
    if frontSlotNum and GetCustomToggleControl(frontSlotNum) then slotCallback(frontSlotNum) end
    if backSlotNum and GetCustomToggleControl(backSlotNum) then slotCallback(backSlotNum) end
end

--- Set stack label on all toggled slots for abilityId. textOrNil: number to display, or nil/0 for empty.
SetToggledStackLabels = function (abilityId, textOrNil)
    local stackLabelText = (textOrNil and textOrNil > 0) and tostring(textOrNil) or ""
    forEachToggledBarSlot(abilityId, function (slotNum)
        g_uiCustomToggle[slotNum].stack:SetText(stackLabelText)
    end)
end

--- Hide all toggled slots for abilityId.
HideToggledSlots = function (abilityId)
    forEachToggledBarSlot(abilityId, function (slotNum)
        ActionBar.HideSlot(slotNum, abilityId)
    end)
end

--- Show all toggled slots for abilityId.
ShowToggledSlots = function (abilityId, currentTime)
    if g_toggledSlotsFront[abilityId] then
        ActionBar.ShowSlot(g_toggledSlotsFront[abilityId], abilityId, currentTime, false)
    end
    if g_toggledSlotsBack[abilityId] then
        ActionBar.ShowSlot(g_toggledSlotsBack[abilityId], abilityId, currentTime, false)
    end
end

--- Decrement combatTrack stack buff (Effects.BarHighlightStackConsume) after slotted ability use.
DecrementBarHighlightCombatStack = function (combatTrackAbilityId)
    local stacks = g_toggledSlotsStack[combatTrackAbilityId]
    if not stacks or stacks <= 0 then
        return
    end
    stacks = stacks - 1
    g_toggledSlotsStack[combatTrackAbilityId] = stacks > 0 and stacks or nil

    local currentTimeMs = GetGameTimeMilliseconds()
    if not g_toggledSlotsStack[combatTrackAbilityId] then
        g_toggledSlotsRemain[combatTrackAbilityId] = nil
        HideToggledSlots(combatTrackAbilityId)
    else
        ShowToggledSlots(combatTrackAbilityId, currentTimeMs)
    end
    if ActionBar.SV.BarShowLabel and g_barCombatStackMax[combatTrackAbilityId] then
        SetToggledStackLabels(combatTrackAbilityId, g_toggledSlotsStack[combatTrackAbilityId])
    end
end

--- Play proc sound at stack thresholds. Used by Grim Focus and Bound Armaments.
local function PlayProcSoundAtStacks(abilityId, stackCount)
    local thresholds = PROC_SOUND_THRESHOLDS[abilityId]
    if not thresholds or not ActionBar.SV.ShowTriggered or not ActionBar.SV.ProcEnableSound then return end
    if not g_boundArmamentsPlayed[abilityId] then
        g_boundArmamentsPlayed[abilityId] = {}
    end
    local t1, t2 = thresholds[1], thresholds[2]
    if (stackCount == t1 or stackCount == t2) and not g_boundArmamentsPlayed[abilityId][stackCount] then
        PlaySound(g_ProcSound)
        PlaySound(g_ProcSound)
        g_boundArmamentsPlayed[abilityId][stackCount] = true
    end
    if stackCount < t1 then
        g_boundArmamentsPlayed[abilityId][t1] = false
        g_boundArmamentsPlayed[abilityId][t2] = false
    elseif stackCount < t2 and stackCount > t1 then
        g_boundArmamentsPlayed[abilityId][t2] = false
    end
end

--- Try BarHighlightSwap if abilityId has a CheckOnFade config.
local function TryBarHighlightSwap(abilityId)
    if Effects.BarHighlightCheckOnFade[abilityId] then
        ActionBar.BarHighlightSwap(abilityId)
    end
end

--- Handle ground effect FADED: mine stack decrement, stack labels, HideSlot when stacks reach 0, or non-mine fade.
local function OnGroundEffectFaded(abilityId)
    if abilityId == 32958 then return end -- Ignore Shifting Standard
    local currentTime = GetGameTimeMilliseconds()
    if g_protectAbilityRemoval[abilityId] and g_protectAbilityRemoval[abilityId] >= currentTime then return end

    if Effects.IsGroundMineAura[abilityId] or Effects.IsGroundMineStack[abilityId] then
        if not g_mineStacks[abilityId] then return end
        g_mineStacks[abilityId] = g_mineStacks[abilityId] - Effects.EffectGroundDisplay[abilityId].stackRemove

        if ActionBar.SV.BarShowLabel and not Effects.HideGroundMineStacks[abilityId] then
            SetToggledStackLabels(abilityId, g_mineStacks[abilityId] > 0 and g_mineStacks[abilityId] or nil)
        end

        if g_mineStacks[abilityId] == 0 and not g_mineNoTurnOff[abilityId] then
            if g_toggledSlotsRemain[abilityId] then HideToggledSlots(abilityId) end
            g_toggledSlotsRemain[abilityId] = nil
            g_toggledSlotsStack[abilityId] = nil
            TryBarHighlightSwap(abilityId)
        end
    else
        if g_barNoRemove[abilityId] then return end
        if g_toggledSlotsRemain[abilityId] then HideToggledSlots(abilityId) end
        g_toggledSlotsRemain[abilityId] = nil
        g_toggledSlotsStack[abilityId] = nil
    end
end

--- Handle ground effect GAINED: mine stack init, ShowSlot.
local function OnGroundEffectGained(abilityId, endTime, stackCount)
    if g_mineNoTurnOff[abilityId] then g_mineNoTurnOff[abilityId] = nil end
    local currentTime = GetGameTimeMilliseconds()
    g_protectAbilityRemoval[abilityId] = currentTime + 150

    if Effects.IsGroundMineAura[abilityId] then
        g_mineStacks[abilityId] = Effects.EffectGroundDisplay[abilityId].stackReset
    elseif Effects.IsGroundMineStack[abilityId] then
        g_mineStacks[abilityId] = g_mineStacks[abilityId] and (g_mineStacks[abilityId] + Effects.EffectGroundDisplay[abilityId].stackRemove) or 1
        if g_mineStacks[abilityId] > Effects.EffectGroundDisplay[abilityId].stackReset then
            g_mineStacks[abilityId] = Effects.EffectGroundDisplay[abilityId].stackReset
        end
    end

    if ActionBar.SV.ShowToggled and (g_toggledSlotsFront[abilityId] or g_toggledSlotsBack[abilityId]) then
        g_toggledSlotsPlayer[abilityId] = true
        g_toggledSlotsRemain[abilityId] = 1000 * endTime
        g_toggledSlotsStack[abilityId] = stackCount
        ShowToggledSlots(abilityId, currentTime)
    end
end

--- Handle non-ground effect FADED: Grim Focus stack clear, proc stop, toggle hide, BarHighlightSwap.
local function OnEffectFaded(abilityId)
    if isStackCounter[abilityId] then
        for stackBaseAbilityId in pairs(isStackBaseAbility) do
            g_toggledSlotsStack[stackBaseAbilityId] = nil
            if ActionBar.SV.ShowToggled and ActionBar.SV.BarShowLabel and (g_toggledSlotsFront[stackBaseAbilityId] or g_toggledSlotsBack[stackBaseAbilityId]) then
                SetToggledStackLabels(stackBaseAbilityId, nil)
            end
        end
    end

    if g_barNoRemove[abilityId] then
        TryBarHighlightSwap(abilityId)
        return
    end

    if g_triggeredSlotsRemain[abilityId] then
        if g_triggeredSlotsFront[abilityId] and g_uiProcAnimation[g_triggeredSlotsFront[abilityId]] then
            g_uiProcAnimation[g_triggeredSlotsFront[abilityId]]:Stop()
        end
        if g_triggeredSlotsBack[abilityId] and g_uiProcAnimation[g_triggeredSlotsBack[abilityId]] then
            g_uiProcAnimation[g_triggeredSlotsBack[abilityId]]:Stop()
        end
        g_triggeredSlotsRemain[abilityId] = nil
    end

    if g_toggledSlotsRemain[abilityId] then
        HideToggledSlots(abilityId)
        g_toggledSlotsRemain[abilityId] = nil
        if not isStackBaseAbility[abilityId] then g_toggledSlotsStack[abilityId] = nil end
    end

    TryBarHighlightSwap(abilityId)
end

--- Handle non-ground effect GAINED: proc sound, proc animation, ShowSlot, Grim Focus stack labels.
local function OnEffectGained(abilityId, unitTag, endTime, stackCount, changeType)
    PlayProcSoundAtStacks(abilityId, stackCount)

    if g_triggeredSlotsFront[abilityId] or g_triggeredSlotsBack[abilityId] then
        if ActionBar.SV.ShowTriggered then
            local currentTime = GetGameTimeMilliseconds()
            if ActionBar.SV.ProcEnableSound and unitTag == "player" and g_triggeredSlotsFront[abilityId] then
                if abilityId == 46327 and changeType == EFFECT_RESULT_GAINED then
                    PlaySound(g_ProcSound)
                    PlaySound(g_ProcSound)
                else
                    PlaySound(g_ProcSound)
                    PlaySound(g_ProcSound)
                end
            end
            g_triggeredSlotsRemain[abilityId] = 1000 * endTime
            local remain = g_triggeredSlotsRemain[abilityId] - currentTime
            if g_triggeredSlotsFront[abilityId] then
                ActionBar.PlayProcAnimations(g_triggeredSlotsFront[abilityId])
                if ActionBar.SV.BarShowLabel and g_uiProcAnimation[g_triggeredSlotsFront[abilityId]] then
                    g_uiProcAnimation[g_triggeredSlotsFront[abilityId]].procLoopTexture.label:SetText(FormatDurationSeconds(remain))
                end
            end
            if g_triggeredSlotsBack[abilityId] then
                ActionBar.PlayProcAnimations(g_triggeredSlotsBack[abilityId])
                if ActionBar.SV.BarShowLabel and g_uiProcAnimation[g_triggeredSlotsBack[abilityId]] then
                    g_uiProcAnimation[g_triggeredSlotsBack[abilityId]].procLoopTexture.label:SetText(FormatDurationSeconds(remain))
                end
            end
        end
    end

    if g_toggledSlotsFront[abilityId] or g_toggledSlotsBack[abilityId] then
        if ActionBar.SV.ShowToggled then
            local maxStack = g_barCombatStackMax[abilityId]
            if maxStack then
                if stackCount == 0 then
                    local zeroMode = g_barCombatStackZeroEffect[abilityId]
                    if zeroMode == "keep" and g_toggledSlotsRemain[abilityId] then
                        ShowToggledSlots(abilityId, GetGameTimeMilliseconds())
                    elseif zeroMode == "clear" then
                        HideToggledSlots(abilityId)
                        g_toggledSlotsRemain[abilityId] = nil
                        g_toggledSlotsStack[abilityId] = nil
                    end
                else
                    local currentTime = GetGameTimeMilliseconds()
                    g_toggledSlotsRemain[abilityId] = 1000 * endTime
                    if not isStackBaseAbility[abilityId] then
                        if stackCount and stackCount > 0 then
                            g_toggledSlotsStack[abilityId] = stackCount
                        elseif not g_toggledSlotsStack[abilityId] and g_toggledSlotsRemain[abilityId] then
                            g_toggledSlotsStack[abilityId] = maxStack
                        end
                    end
                    ShowToggledSlots(abilityId, currentTime)
                    if ActionBar.SV.BarShowLabel and g_toggledSlotsStack[abilityId] then
                        SetToggledStackLabels(abilityId, g_toggledSlotsStack[abilityId])
                    end
                end
            else
                local currentTime = GetGameTimeMilliseconds()
                local newRemain = 1000 * endTime
                if g_barCombatTrackRemainOnSlotted[abilityId] and g_toggledSlotsRemain[abilityId] and g_toggledSlotsRemain[abilityId] > currentTime then
                    if newRemain > g_toggledSlotsRemain[abilityId] then
                        g_toggledSlotsRemain[abilityId] = newRemain
                    end
                else
                    g_toggledSlotsRemain[abilityId] = newRemain
                end
                if not isStackBaseAbility[abilityId] then
                    if stackCount and stackCount > 0 then
                        g_toggledSlotsStack[abilityId] = stackCount
                    end
                end
                ShowToggledSlots(abilityId, currentTime)
            end
        end
    end

    if isStackCounter[abilityId] then
        for i = 1, GetNumBuffs(unitTag) do
            local baseId = select(11, GetUnitBuffInfo(unitTag, i))
            if isStackBaseAbility[baseId] then
                g_toggledSlotsStack[baseId] = stackCount
                if ActionBar.SV.ShowToggled and ActionBar.SV.BarShowLabel and (g_toggledSlotsFront[baseId] or g_toggledSlotsBack[baseId]) then
                    SetToggledStackLabels(baseId, g_toggledSlotsStack[baseId] and g_toggledSlotsStack[baseId] > 0 and g_toggledSlotsStack[baseId] or nil)
                end
            end
        end
    end
end

-- Extra returns here - passThrough & savedId
--- Handles EVENT_EFFECT_CHANGED: bar highlights, cast bar break, SETHOTBAR backbar hide, BarHighlightSwap, etc.
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
--- @param passThrough any
--- @param savedId integer
function ActionBar.OnEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType, passThrough, savedId)
    -- If we're displaying a fake bar highlight then bail out here (sometimes we need a fake aura that doesn't end to simulate effects that can be overwritten, such as Major/Minor buffs.
    -- Technically we don't want to stop the highlight of the original ability since we can only track one buff per slot and overwriting the buff with a longer duration buff shouldn't throw the player off by making the glow disappear earlier.
    if g_barFakeAura[abilityId] and not passThrough then
        return
    end
    -- Bail out if this effect wasn't cast by the player.
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then
        return
    end

    local combatTrackRemap = g_barCombatEventRemap[abilityId]
    if combatTrackRemap then
        abilityId = combatTrackRemap
    end

    -- Auto-hide back bar when abilityType is SETHOTBAR (e.g. Volendrung mythic forces weapon bar swap)
    if unitTag == "player" and abilityType == ABILITY_TYPE_SETHOTBAR then
        if Backbar.OnSetHotbarEffect(changeType) then
            return
        end
    end

    -- Update ultimate label on vampire stage change.
    if Effects.IsVamp[abilityId] and changeType == EFFECT_RESULT_GAINED then
        ActionBar.UpdateUltimateLabel()
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
        if Effects.LinkedGroundMine[abilityId] then abilityId = Effects.LinkedGroundMine[abilityId] end
        if changeType == EFFECT_RESULT_FADED then
            OnGroundEffectFaded(abilityId)
        else
            OnGroundEffectGained(abilityId, endTime, stackCount)
        end
        return
    end

    -- Hijack abilityId for extra bar highlights (skip if FancyActionBar active)
    if not isFancyActionBarEnabled and not passThrough then
        local extraId = Effects.BarHighlightExtraId[abilityId]
        if extraId then
            abilityId = extraId
            if Effects.IsGroundMineAura[abilityId] then
                g_toggledSlotsPlayer[abilityId] = nil
                if unitTag == "reticleover" then g_mineNoTurnOff[abilityId] = true end
            end
        end
    end

    if unitTag ~= "player" and unitTag ~= "reticleover" then return end

    if changeType == EFFECT_RESULT_FADED then
        OnEffectFaded(abilityId)
    else
        OnEffectGained(abilityId, unitTag, endTime, stackCount, changeType)
    end
end

-- -----------------------------------------------------------------------------
--- Hides the custom toggle control for a slot; updates backbar/saturation/ultimate pct as needed.
--- @param slotNum integer
--- @param abilityId integer
function ActionBar.HideSlot(slotNum, abilityId)
    local customToggleControl = GetCustomToggleControl(slotNum)
    if customToggleControl then
        customToggleControl:SetHidden(true)
    end
    if slotNum > BACKBAR_INDEX_OFFSET then
        if slotNum ~= BAR_INDEX_END + BACKBAR_INDEX_OFFSET then
            ActionBar.BackbarHideSlot(slotNum)
            ActionBar.ToggleBackbarSaturation(slotNum, ActionBar.SV.BarDarkUnused)
        end
    end
    if slotNum == g_ultimateSlot and ActionBar.SV.UltimatePctEnabled and IsSlotUsed(g_ultimateSlot, g_hotbarCategory) then
        uiUltimate.LabelPct:SetHidden(false)
    end
end

-- -----------------------------------------------------------------------------
--- Shows the custom toggle for a slot, updates backbar/saturation, and sets duration/stack labels.
--- @param slotNum integer
--- @param abilityId integer
--- @param currentTimeMS integer
--- @param desaturate boolean
function ActionBar.ShowSlot(slotNum, abilityId, currentTimeMS, desaturate)
    ActionBar.ShowCustomToggle(slotNum)
    if slotNum > BACKBAR_INDEX_OFFSET then
        if slotNum ~= BAR_INDEX_END + BACKBAR_INDEX_OFFSET then
            ActionBar.BackbarShowSlot(slotNum)
            ActionBar.ToggleBackbarSaturation(slotNum, desaturate)
        end
    end
    if slotNum == 8 and ActionBar.SV.UltimatePctEnabled then
        uiUltimate.LabelPct:SetHidden(true)
    end
    if ActionBar.SV.BarShowLabel then
        local customToggleControl = GetCustomToggleControl(slotNum)
        if not customToggleControl then
            return
        end
        local toggledEffectEndMs = g_toggledSlotsRemain[abilityId]
        local remain = toggledEffectEndMs and (toggledEffectEndMs - currentTimeMS) or 0
        customToggleControl.label:SetText(SetBarRemainLabel(remain, abilityId))
        if g_toggledSlotsStack[abilityId] and g_toggledSlotsStack[abilityId] > 0 then
            customToggleControl.stack:SetText(g_toggledSlotsStack[abilityId])
        elseif g_mineStacks[abilityId] and g_mineStacks[abilityId] > 0 then
            -- No stack for Time Freeze
            if not Effects.HideGroundMineStacks[abilityId] then
                customToggleControl.stack:SetText(g_mineStacks[abilityId])
            end
        else
            customToggleControl.stack:SetText("")
        end
    end
end

-- -----------------------------------------------------------------------------

local validDamageResults =
{
    [ACTION_RESULT_DAMAGE] = true,
    [ACTION_RESULT_CRITICAL_DAMAGE] = true,
    [ACTION_RESULT_PRECISE_DAMAGE] = true,
    [ACTION_RESULT_WRECKING_DAMAGE] = true,
    [ACTION_RESULT_DOT_TICK] = true,
    [ACTION_RESULT_DOT_TICK_CRITICAL] = true,
    [ACTION_RESULT_IMMUNE] = true,
    [ACTION_RESULT_REFLECTED] = true,
    [ACTION_RESULT_ABSORBED] = true,
    [ACTION_RESULT_PARRIED] = true,
    [ACTION_RESULT_DODGED] = true,
    [ACTION_RESULT_BLOCKED] = true,
    [ACTION_RESULT_BLOCKED_DAMAGE] = true,
    [ACTION_RESULT_RESIST] = true,
    [ACTION_RESULT_PARTIAL_RESIST] = true,
    [ACTION_RESULT_MISS] = true,
    [ACTION_RESULT_DEFENDED] = true,
    [ACTION_RESULT_INTERCEPTED] = true,
    [ACTION_RESULT_FALL_DAMAGE] = true,
    [ACTION_RESULT_DAMAGE_SHIELDED] = true,
}

local function isValidDamageResult(result)
    return validDamageResults[result]
end

--- - **EVENT_COMBAT_EVENT ** (ultimate generation, trap beast ground-mine handling)
function ActionBar.OnCombatEvent(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if ActionBar.SV.UltimateGeneration and uiUltimate.NotFull and ((result == ACTION_RESULT_BLOCKED_DAMAGE and targetType == COMBAT_UNIT_TYPE_PLAYER) or (Effects.IsWeaponAttack[abilityName] and sourceType == COMBAT_UNIT_TYPE_PLAYER and targetName ~= "")) then
        uiUltimate.Texture:SetHidden(false)
        uiUltimate.FadeTime = GetGameTimeMilliseconds() + 8000
    end

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
                        ActionBar.BarHighlightSwap(compareId)
                    end
                    return
                end
            end
        end
    end
end

--- Resolve bar-highlight timer length from combatTrack override data and combat hitValue (ms).
local function GetCombatTrackToggleDurationMs(combatAbilityId, result, hitValue)
    local combatTrackAbilityId = g_barCombatEventRemap[combatAbilityId] or combatAbilityId
    if not g_barCombatTrack[combatTrackAbilityId] then
        return nil
    end
    if  (result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_EFFECT_GAINED or result == ACTION_RESULT_EFFECT_GAINED_DURATION)
    and type(hitValue) == "number" and hitValue >= 500 then
        return hitValue
    end
    return g_barDurationOverride[combatTrackAbilityId]
end

--- @param barAbilityId integer Highlight / remain key (usually combatTrack newId)
--- @param combatAbilityId integer Raw abilityId from EVENT_COMBAT_EVENT
--- @param currentTimeMS integer
--- @param durationMs integer|nil
local function SetCombatTrackToggleRemain(barAbilityId, combatAbilityId, currentTimeMS, durationMs)
    if not durationMs or durationMs <= 0 then
        return
    end
    if g_barCombatTrackRemainOnSlotted[barAbilityId] and not g_barCombatEventRemap[combatAbilityId] then
        return
    end
    g_toggledSlotsRemain[barAbilityId] = currentTimeMS + durationMs
end

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
function ActionBar.OnCombatEventBar(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    -- If the source/target isn't the player then bail out now.
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER and targetType ~= COMBAT_UNIT_TYPE_PLAYER then
        return
    end

    local barAbilityId = g_barCombatEventRemap[abilityId] or abilityId

    if sourceType == COMBAT_UNIT_TYPE_PLAYER and targetType == COMBAT_UNIT_TYPE_PLAYER then
        g_toggledSlotsPlayer[barAbilityId] = true
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
                    local customToggleControl = GetCustomToggleControl(slotNum)
                    if customToggleControl then
                        if g_toggledSlotsStack[abilityId] and g_toggledSlotsStack[abilityId] > 0 then
                            customToggleControl.stack:SetText(g_toggledSlotsStack[abilityId])
                        else
                            customToggleControl.stack:SetText("")
                        end
                    end
                end
                if g_toggledSlotsBack[abilityId] then
                    local slotNum = g_toggledSlotsBack[abilityId]
                    local customToggleControl = GetCustomToggleControl(slotNum)
                    if customToggleControl then
                        if g_toggledSlotsStack[abilityId] and g_toggledSlotsStack[abilityId] > 0 then
                            customToggleControl.stack:SetText(g_toggledSlotsStack[abilityId])
                        else
                            customToggleControl.stack:SetText("")
                        end
                    end
                end
            end
        end
    end

    if result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_EFFECT_GAINED or result == ACTION_RESULT_EFFECT_GAINED_DURATION then
        local currentTimeMS = GetFrameTimeMilliseconds()
        if g_toggledSlotsFront[barAbilityId] or g_toggledSlotsBack[barAbilityId] then
            if ActionBar.SV.ShowToggled then
                local skipToggleShow = false
                local maxStack = g_barCombatStackMax[barAbilityId]
                if maxStack then
                    -- combatTrack stack buff: hitValue = stack count (EFFECT_GAINED) or duration ms (EFFECT_GAINED_DURATION).
                    if result == ACTION_RESULT_EFFECT_GAINED_DURATION and type(hitValue) == "number" and hitValue >= 500 then
                        g_toggledSlotsRemain[barAbilityId] = currentTimeMS + hitValue
                        if not g_toggledSlotsStack[barAbilityId] then
                            g_toggledSlotsStack[barAbilityId] = maxStack
                            if ActionBar.SV.BarShowLabel then
                                SetToggledStackLabels(barAbilityId, maxStack)
                            end
                        end
                    elseif result == ACTION_RESULT_EFFECT_GAINED and type(hitValue) == "number" and hitValue > 0 and hitValue <= maxStack then
                        g_toggledSlotsStack[barAbilityId] = hitValue
                        if ActionBar.SV.BarShowLabel then
                            SetToggledStackLabels(barAbilityId, hitValue)
                        end
                        if not g_toggledSlotsRemain[barAbilityId] then
                            local duration = g_barDurationOverride[barAbilityId] or GetUpdatedAbilityDuration(barAbilityId)
                            if duration > 0 then
                                g_toggledSlotsRemain[barAbilityId] = currentTimeMS + duration
                            end
                        end
                    end
                else
                    local durationMs = GetCombatTrackToggleDurationMs(abilityId, result, hitValue)
                    if not durationMs or durationMs <= 0 then
                        if result == ACTION_RESULT_EFFECT_GAINED_DURATION and type(hitValue) == "number" and hitValue >= 500 then
                            durationMs = hitValue
                        else
                            durationMs = GetUpdatedAbilityDuration(barAbilityId)
                        end
                    end
                    if durationMs and durationMs > 0 then
                        SetCombatTrackToggleRemain(barAbilityId, abilityId, currentTimeMS, durationMs)
                    end
                end
                -- Handling for Crystallized Shield + Morphs
                if barAbilityId == 86135 or barAbilityId == 86139 or barAbilityId == 86143 then
                    g_toggledSlotsStack[barAbilityId] = 3
                end
                -- Handling for Trap Beast
                if barAbilityId == 35750 or barAbilityId == 40382 or barAbilityId == 40372 then
                    g_toggledSlotsStack[barAbilityId] = 1
                end
                -- Toggle highlight on
                if not skipToggleShow then
                    if g_toggledSlotsFront[barAbilityId] then
                        local slotNum = g_toggledSlotsFront[barAbilityId]
                        ActionBar.ShowSlot(slotNum, barAbilityId, currentTimeMS, false)
                    end
                    if g_toggledSlotsBack[barAbilityId] then
                        local slotNum = g_toggledSlotsBack[barAbilityId]
                        ActionBar.ShowSlot(slotNum, barAbilityId, currentTimeMS, false)
                    end
                end
            end
        end
    elseif result == ACTION_RESULT_EFFECT_FADED then
        -- Ignore fading event if override is true
        if g_barNoRemove[barAbilityId] then
            if Effects.BarHighlightCheckOnFade[barAbilityId] then
                ActionBar.BarHighlightSwap(barAbilityId)
            end
            return
        end

        if g_toggledSlotsRemain[barAbilityId] then
            if g_toggledSlotsFront[barAbilityId] and g_uiCustomToggle[g_toggledSlotsFront[barAbilityId]] then
                local slotNum = g_toggledSlotsFront[barAbilityId]
                ActionBar.HideSlot(slotNum, barAbilityId)
            end
            if g_toggledSlotsBack[barAbilityId] and g_uiCustomToggle[g_toggledSlotsBack[barAbilityId]] then
                local slotNum = g_toggledSlotsBack[barAbilityId]
                ActionBar.HideSlot(slotNum, barAbilityId)
            end
            g_toggledSlotsRemain[barAbilityId] = nil
            g_toggledSlotsStack[barAbilityId] = nil
        end
        if Effects.BarHighlightCheckOnFade[barAbilityId] and targetType == COMBAT_UNIT_TYPE_PLAYER then
            ActionBar.BarHighlightSwap(barAbilityId)
        end
    end
end

--- @param actionSlotIndex luaindex
function ActionBar.OnSlotUpdated(actionSlotIndex)
    -- Update ultimate label
    if actionSlotIndex == 8 then
        ActionBar.UpdateUltimateLabel()
    end
    -- Update the slot if the bound id has a proc
    if actionSlotIndex >= BAR_INDEX_START and actionSlotIndex <= BAR_INDEX_END then
        local abilityId = GetSlotTrueBoundId(actionSlotIndex, g_hotbarCategory)
        if Effects.IsAbilityProc[abilityId] or Effects.BaseForAbilityProc[abilityId] then
            ActionBar.BarSlotUpdate(actionSlotIndex, false, true)
        end
    end
end

-- Handle slot update for action bars
---
--- @param slotNum integer
--- @param wasFullUpdate boolean
--- @param onlyProc boolean
function ActionBar.BarSlotUpdate(slotNum, wasFullUpdate, onlyProc)
    -- Look only for action bar slots
    if slotNum < BACKBAR_INDEX_OFFSET then
        if ActionBar.SV.ShowToggledUltimate then
            if slotNum < BAR_INDEX_START or slotNum > BAR_INDEX_END then
                return
            end
        else
            if slotNum < BAR_INDEX_START or slotNum > (BAR_INDEX_END - 1) then
                return
            end
        end
    end

    -- Remove saved triggered proc information
    for abilityId, slot in pairs(g_triggeredSlotsFront) do
        if (slot == slotNum) then
            g_triggeredSlotsFront[abilityId] = nil
        end
    end
    for abilityId, slot in pairs(g_triggeredSlotsBack) do
        if (slot == slotNum) then
            g_triggeredSlotsBack[abilityId] = nil
        end
    end

    -- Stop possible proc animation
    if g_uiProcAnimation[slotNum] and g_uiProcAnimation[slotNum]:IsPlaying() then
        -- g_uiProcAnimation[slotNum].procLoopTexture.label:SetText("")
        g_uiProcAnimation[slotNum]:Stop()
    end

    if onlyProc == false then
        -- Remove custom toggle information and custom highlight
        for abilityId, slot in pairs(g_toggledSlotsFront) do
            if (slot == slotNum) then
                g_toggledSlotsFront[abilityId] = nil
            end
        end
        for abilityId, slot in pairs(g_toggledSlotsBack) do
            if (slot == slotNum) then
                g_toggledSlotsBack[abilityId] = nil
            end
        end

        local customToggleControl = GetCustomToggleControl(slotNum)
        if customToggleControl then
            customToggleControl:SetHidden(true)
        end
    end

    local physicalSlotNum
    local hotbarCategory
    if slotNum > BACKBAR_INDEX_OFFSET then
        physicalSlotNum = slotNum - BACKBAR_INDEX_OFFSET
        hotbarCategory = g_hotbarCategory == HOTBAR_CATEGORY_BACKUP and HOTBAR_CATEGORY_PRIMARY or HOTBAR_CATEGORY_BACKUP
    else
        physicalSlotNum = slotNum
        hotbarCategory = g_hotbarCategory
    end

    -- Bail out if slot is not used and we're not referencing a fake backbar slot.
    if GetSlotType(physicalSlotNum, hotbarCategory) == ACTION_TYPE_NOTHING then
        return
    end

    local abilityId = GetSlotTrueBoundId(slotNum, g_hotbarCategory)
    if slotNum > BACKBAR_INDEX_OFFSET then
        local inactiveHotbarCategory = GetInactiveHotbarCategory(ActionBar.GetHotbarCategory())
        abilityId = GetSlotTrueBoundId(slotNum - BACKBAR_INDEX_OFFSET, inactiveHotbarCategory)

        local weaponSlot = inactiveHotbarCategory == HOTBAR_CATEGORY_BACKUP and EQUIP_SLOT_BACKUP_MAIN or EQUIP_SLOT_MAIN_HAND
        local weaponType = GetItemWeaponType(BAG_WORN, weaponSlot)

        if weaponType == WEAPONTYPE_FIRE_STAFF or weaponType == WEAPONTYPE_FROST_STAFF or weaponType == WEAPONTYPE_LIGHTNING_STAFF or weaponType == WEAPONTYPE_NONE then
            if Effects.BarHighlightDestroFix[abilityId] and Effects.BarHighlightDestroFix[abilityId][weaponType] then
                abilityId = Effects.BarHighlightDestroFix[abilityId][weaponType]
            end
        end
    end

    local showFakeAura = (Effects.BarHighlightOverride[abilityId] and Effects.BarHighlightOverride[abilityId].showFakeAura)

    if Effects.BarHighlightOverride[abilityId] then
        if Effects.BarHighlightOverride[abilityId].hide then
            return
        end
        if Effects.BarHighlightOverride[abilityId].newId then
            abilityId = Effects.BarHighlightOverride[abilityId].newId
        end
    end

    if showFakeAura and abilityId then
        if not g_barFakeAura[abilityId] then
            g_barFakeAura[abilityId] = true
            g_barOverrideCI[abilityId] = true

            local override = Effects.BarHighlightOverride[abilityId]
            if override and override.duration then
                g_barDurationOverride[abilityId] = override.duration
            end
        end
    end

    local abilityName = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].name or GetAbilityName(abilityId, "player") -- GetSlotName(slotNum)
    -- local _, _, channel = GetAbilityCastInfo(abilityId)
    local duration = GetUpdatedAbilityDuration(abilityId)
    local currentTime = GetGameTimeMilliseconds()

    local triggeredSlots
    if slotNum > BACKBAR_INDEX_OFFSET then
        triggeredSlots = g_triggeredSlotsBack
    else
        triggeredSlots = g_triggeredSlotsFront
    end

    -- Check if currently this ability is in proc state
    local procAbilityKey = Effects.HasAbilityProc[abilityName]
    if Effects.IsAbilityProc[GetSlotTrueBoundId(slotNum, g_hotbarCategory)] then
        if ActionBar.SV.ShowTriggered then
            ActionBar.PlayProcAnimations(slotNum)
            if ActionBar.SV.ProcEnableSound then
                if not wasFullUpdate and not g_disableProcSound[slotNum] then
                    PlaySound(g_ProcSound)
                    PlaySound(g_ProcSound)
                    -- Only play a proc sound every 3 seconds (matches Power Lash cd)
                    g_disableProcSound[slotNum] = true
                    zo_callLater(function ()
                                     g_disableProcSound[slotNum] = false
                                 end, 3000)
                end
            end
        end
    elseif procAbilityKey then
        triggeredSlots[procAbilityKey] = slotNum
        if g_triggeredSlotsRemain[procAbilityKey] then
            if ActionBar.SV.ShowTriggered then
                ActionBar.PlayProcAnimations(slotNum)
                if ActionBar.SV.BarShowLabel then
                    if not g_uiProcAnimation[slotNum] then return end
                    local remain = g_triggeredSlotsRemain[procAbilityKey] - currentTime
                    g_uiProcAnimation[slotNum].procLoopTexture.label:SetText(FormatDurationSeconds(remain))
                end
            end
        end
    end

    local toggledSlots
    if slotNum > BACKBAR_INDEX_OFFSET then
        toggledSlots = g_toggledSlotsBack
    else
        toggledSlots = g_toggledSlotsFront
    end

    -- Check for active duration to display highlight for abilities on bar swap
    if onlyProc == false and toggledSlots and abilityId then
        if duration > 0 or Effects.AddNoDurationBarHighlight[abilityId] or Effects.MajorMinor[abilityId] then
            toggledSlots[abilityId] = slotNum
            if g_toggledSlotsRemain[abilityId] then
                if ActionBar.SV.ShowToggled then
                    slotNum = toggledSlots[abilityId]
                    -- Check the other slot here to determine if we desaturate (in case effects are running in both slots)
                    local desaturate
                    local slotIndex = slotNum > BACKBAR_INDEX_OFFSET and slotNum - BACKBAR_INDEX_OFFSET or nil
                    if slotIndex then
                        local customToggleControl = GetCustomToggleControl(slotIndex)
                        if customToggleControl then
                            desaturate = false
                            if customToggleControl:IsHidden() then
                                ActionBar.BackbarHideSlot(slotNum)
                                desaturate = true
                            end
                        end
                    end
                    ActionBar.ShowSlot(slotNum, abilityId, currentTime, desaturate)
                end
            end
        end
    end
end

--- -----------------------------------------------------------------------------
--- Refreshes ultimate slot label (cost, percentage) from current power and slot ability.
function ActionBar.UpdateUltimateLabel()
    -- Get the currently slotted ultimate cost
    local ultimateHotbarCategory = g_hotbarCategory
    g_ultimateCost = GetSlotAbilityCost(g_ultimateSlot, COMBAT_MECHANIC_FLAGS_ULTIMATE, ultimateHotbarCategory) or 0

    -- Update ultimate label
    ActionBar.OnPowerUpdatePlayer("player", nil, COMBAT_MECHANIC_FLAGS_ULTIMATE, g_ultimateCurrent, 0, 0)
end

--- -----------------------------------------------------------------------------
--- Called when an inventory item is used; refreshes ultimate label.
function ActionBar.InventoryItemUsed()
    g_potionUsed = true
    zo_callLater(function ()
                     g_potionUsed = false
                 end, 200)
end

--- - **EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED **
---
-- -----------------------------------------------------------------------------
--- Handles EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED: updates hotbar category, backbar icons, ultimate.
--- @param didActiveHotbarChange boolean
--- @param shouldUpdateAbilityAssignments boolean
--- @param activeHotbarCategory HotBarCategory
function ActionBar.OnActiveHotbarUpdate(didActiveHotbarChange, shouldUpdateAbilityAssignments, activeHotbarCategory)
    if didActiveHotbarChange == true or shouldUpdateAbilityAssignments == true then
        for _, physicalSlot in pairs(Backbar.GetButtons()) do
            if physicalSlot.hotbarSwapAnimation then
                physicalSlot.noUpdates = true
                physicalSlot.hotbarSwapAnimation:PlayFromStart()
            end
        end
    else
        g_activeWeaponSwapInProgress = false
    end
end

--- - **EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED**
--- Full refresh of all bar slots (main + backbar), potion timer, and backbar visibility.
function ActionBar.OnSlotsFullUpdate()
    -- Don't update bars if this full update event was from using an inventory item
    if g_potionUsed == true then
        return
    end

    -- Handle ultimate label first
    ActionBar.UpdateUltimateLabel()
    ActionBar.UpdateCompanionUltimateLabel()
    RefreshCompanionQuickslotAnchors()

    -- Update action bar skills
    for i = BAR_INDEX_START, BAR_INDEX_END do
        ActionBar.BarSlotUpdate(i, true, false)
    end

    for i = (BAR_INDEX_START + BACKBAR_INDEX_OFFSET), (BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET) do
        local button = Backbar.GetButton(i)
        ActionBar.SetupBackBarIcons(button, nil)
        ActionBar.BarSlotUpdate(i, true, false)
    end
end

--- Play proc/ready animation for an action slot<br>
--- Creates animation controls on first call, then plays the timeline
--- @param slotNum integer The action slot index
function ActionBar.PlayProcAnimations(slotNum)
    -- Early return if animation exists and is playing
    local existingAnimation = g_uiProcAnimation[slotNum]
    if existingAnimation then
        if not existingAnimation:IsPlaying() then
            existingAnimation:PlayFromStart()
        end
        return
    end

    -- Don't create for backbar ultimate slot
    if slotNum == (BAR_INDEX_END + BACKBAR_INDEX_OFFSET) then
        return
    end

    -- Set placeholder immediately to prevent race condition
    g_uiProcAnimation[slotNum] = true

    -- Get action button
    local actionButton = slotNum < BACKBAR_INDEX_OFFSET
        and ZO_ActionBar_GetButton(slotNum)
        or Backbar.GetButton(slotNum)

    -- Create proc loop texture from virtual template
    local procLoopTexture = windowManager:CreateControlFromVirtual("$(parent)Loop_LUIE", actionButton.slot, "ZO_PendingLoop_Glow")
    procLoopTexture:SetAnchor(TOPLEFT, actionButton.slot:GetNamedChild("FlipCard"))
    procLoopTexture:SetAnchor(BOTTOMRIGHT, actionButton.slot:GetNamedChild("FlipCard"))
    procLoopTexture:SetDrawLayer(DL_TEXT)
    procLoopTexture:SetHidden(true)

    -- Create label control
    local label = procLoopTexture:CreateControl("$(parent)Label", CT_LABEL)
    label:SetFont(g_barFont or "LUIE Default Font")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    label:SetAnchor(TOPLEFT, actionButton.slot)
    label:SetAnchor(BOTTOMRIGHT, actionButton.slot, nil, 0, -ActionBar.SV.BarLabelPosition)
    label:SetDrawLayer(DL_OVERLAY)
    label:SetDrawTier(DT_HIGH)
    label:SetColor(1, 1, 1, 1)
    label:SetHidden(false)
    procLoopTexture.label = label

    -- Create timeline animation
    local procLoopTimeline = animationManager:CreateTimelineFromVirtual("UltimateReadyLoop", procLoopTexture)
    procLoopTimeline.procLoopTexture = procLoopTexture
    procLoopTimeline:SetHandler("OnPlay", function ()
        procLoopTexture:SetHidden(false)
    end)
    procLoopTimeline:SetHandler("OnStop", function ()
        procLoopTexture:SetHidden(true)
    end)

    -- Replace placeholder with actual timeline and start playing
    g_uiProcAnimation[slotNum] = procLoopTimeline
    procLoopTimeline:PlayFromStart()
end

--- - **EVENT_UNIT_DEATH_STATE_CHANGED **
---
--- @param unitTag string
--- @param isDead boolean
function ActionBar.OnDeath(unitTag, isDead)
    -- And toggle buttons
    if unitTag == "player" then
        for slotNum = BAR_INDEX_START, BAR_INDEX_END do
            local customToggleControl = GetCustomToggleControl(slotNum)
            if customToggleControl then
                customToggleControl:SetHidden(true)
                --[[if slotNum == 8 and ActionBar.SV.UltimatePctEnabled and IsSlotUsed(g_ultimateSlot) then
                    uiUltimate.LabelPct:SetHidden(false)
                end]]
                --
            end
        end
        for slotNum = BAR_INDEX_START + BACKBAR_INDEX_OFFSET, BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET do
            local customToggleControl = GetCustomToggleControl(slotNum)
            if customToggleControl then
                customToggleControl:SetHidden(true)
            end
        end
    end
end

--- Display custom toggle texture for an action slot<br>
--- Creates toggle controls on first call, then shows the cached control<br>
--- Uses placeholder pattern to prevent race condition during control creation
--- @param slotNum integer The action slot index
function ActionBar.ShowCustomToggle(slotNum)
    if isFancyActionBarEnabled then
        return
    end

    -- Early return if already exists and is a control (not placeholder)
    local existingToggle = g_uiCustomToggle[slotNum]
    if existingToggle and existingToggle ~= true then
        existingToggle:SetHidden(false)
        return
    end

    -- Don't create for backbar ultimate slot
    if slotNum == (BAR_INDEX_END + BACKBAR_INDEX_OFFSET) then
        return
    end

    -- If placeholder exists, skip (creation already in progress)
    if existingToggle == true then
        return
    end

    -- Set placeholder immediately to prevent race condition
    g_uiCustomToggle[slotNum] = true

    -- Get action button
    local actionButton = slotNum < BACKBAR_INDEX_OFFSET
        and ZO_ActionBar_GetButton(slotNum)
        or Backbar.GetButton(slotNum)

    -- Create toggle frame
    local toggleFrame = actionButton.slot:CreateControl("$(parent)Toggle_LUIE", CT_TEXTURE)
    toggleFrame:SetAnchor(TOPLEFT, actionButton.slot:GetNamedChild("FlipCard"))
    toggleFrame:SetAnchor(BOTTOMRIGHT, actionButton.slot:GetNamedChild("FlipCard"))
    toggleFrame:SetTexture("/esoui/art/actionbar/actionslot_toggledon.dds")
    toggleFrame:SetBlendMode(TEX_BLEND_MODE_ADD)
    toggleFrame:SetDrawLayer(DL_BACKGROUND)
    toggleFrame:SetDrawLevel(actionButton.slot:GetDrawLevel() + 1)
    toggleFrame:SetDrawTier(DT_HIGH)
    toggleFrame:SetColor(0.5, 1, 0.5, 1)

    -- Create label control
    local label = toggleFrame:CreateControl("$(parent)Label", CT_LABEL)
    label:SetFont(g_barFont or "LUIE Default Font")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    label:SetAnchor(TOPLEFT, actionButton.slot)
    label:SetAnchor(BOTTOMRIGHT, actionButton.slot, nil, 0, -ActionBar.SV.BarLabelPosition)
    label:SetDrawLayer(DL_CONTROLS)
    label:SetDrawLevel(toggleFrame:GetDrawLevel() + 1)
    label:SetDrawTier(DT_HIGH)
    label:SetColor(1, 1, 1, 1)
    label:SetHidden(false)
    toggleFrame.label = label

    -- Create stack label control
    local stack = toggleFrame:CreateControl("$(parent)Stack", CT_LABEL)
    stack:SetFont(g_barFont or "LUIE Default Font")
    stack:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    stack:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    stack:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    stack:SetAnchor(CENTER, actionButton.slot, BOTTOMLEFT)
    stack:SetAnchor(CENTER, actionButton.slot, TOPRIGHT, -12, 14)
    stack:SetDrawLayer(DL_CONTROLS)
    stack:SetDrawLevel(toggleFrame:GetDrawLevel() + 1)
    stack:SetDrawTier(DT_HIGH)
    stack:SetColor(1, 1, 1, 1)
    stack:SetHidden(false)
    toggleFrame.stack = stack

    -- Replace placeholder with actual frame and show it
    g_uiCustomToggle[slotNum] = toggleFrame
    toggleFrame:SetHidden(false)
end

--- - **EVENT_POWER_UPDATE **
---
--- @param unitTag string
--- @param powerIndex luaindex
--- @param powerType CombatMechanicFlags
--- @param powerValue integer
--- @param powerMax integer
--- @param powerEffectiveMax integer
function ActionBar.OnPowerUpdatePlayer(unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    if unitTag ~= "player" then
        return
    end
    if powerType ~= COMBAT_MECHANIC_FLAGS_ULTIMATE then
        return
    end

    -- flag if ultimate is full - we"ll need it for ultimate generation texture
    uiUltimate.NotFull = (powerValue < powerMax)
    -- Calculate the percentage to activation old one and current
    local ultimatePercent = (g_ultimateCost > 0) and zo_floor((powerValue / g_ultimateCost) * 100) or 0
    -- Set max percentage label to 100%.
    if ultimatePercent > 100 then
        ultimatePercent = 100
    end
    -- Update the tooltip only when the slot is used and percentage is enabled
    if IsSlotUsed(g_ultimateSlot, g_hotbarCategory) then
        if ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
            -- Set % value
            if ActionBar.SV.UltimatePctEnabled then
                uiUltimate.LabelPct:SetText(ultimatePercent .. "%")
            end
            -- Set label value
            if ActionBar.SV.UltimateLabelEnabled then
                uiUltimate.LabelVal:SetText(powerValue .. "/" .. g_ultimateCost)
            end
            -- Pct label: show always when less then 100% and possibly if UltimateHideFull is false
            if ultimatePercent < 100 then
                -- Check Ultimate Percent Setting & if slot is used then check if the slot is currently showing a toggle
                local setHiddenPct = not ActionBar.SV.UltimatePctEnabled
                local ultimateSlotToggle = GetCustomToggleControl(8)
                if ActionBar.SV.ShowToggledUltimate and ultimateSlotToggle and not ultimateSlotToggle:IsHidden() then
                    setHiddenPct = true
                end
                uiUltimate.LabelPct:SetHidden(setHiddenPct)
                -- Update Label Color
                if ActionBar.SV.UltimateLabelEnabled then
                    for i = #uiUltimate.pctColours, 1, -1 do
                        if ultimatePercent < uiUltimate.pctColours[i].pct then
                            local color = uiUltimate.pctColours[i].colour
                            local r, g, b, a = color[1], color[2], color[3], color[4]
                            uiUltimate.LabelVal:SetColor(r, g, b, a)
                            break
                        end
                    end
                end
            else
                -- Check Ultimate Percent Setting & if slot is used then check if the slot is currently showing a toggle
                local setHiddenPct = not ActionBar.SV.UltimatePctEnabled
                local ultimateSlotToggle = GetCustomToggleControl(8)
                if (ActionBar.SV.ShowToggledUltimate and ultimateSlotToggle and not ultimateSlotToggle:IsHidden()) or ActionBar.SV.UltimateHideFull then
                    setHiddenPct = true
                end
                uiUltimate.LabelPct:SetHidden(setHiddenPct)
                -- Update Label Color
                if ActionBar.SV.UltimateLabelEnabled then
                    local color = uiUltimate.colour
                    local r, g, b, a = color[1], color[2], color[3], color[4]
                    uiUltimate.LabelVal:SetColor(r, g, b, a)
                end
            end
            -- Set label hidden or showing
            local setHiddenLabel = not ActionBar.SV.UltimateLabelEnabled
            uiUltimate.LabelVal:SetHidden(setHiddenLabel)
        end
    else
        uiUltimate.LabelPct:SetHidden(true)
        uiUltimate.LabelVal:SetHidden(true)
    end
    -- Update stored value
    g_ultimateCurrent = powerValue
end

-- -----------------------------------------------------------------------------
--- - **EVENT_INVENTORY_SINGLE_SLOT_UPDATE **
---
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
function ActionBar.OnInventorySlotUpdate(bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
    if stackCountChange >= 0 then
        ActionBar.UpdateUltimateLabel()
    end
end
