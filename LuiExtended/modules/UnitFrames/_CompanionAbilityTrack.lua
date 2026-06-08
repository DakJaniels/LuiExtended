--- @diagnostic disable: undefined-field, missing-fields
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) UnitFrames
--- @field companionAbilityTrack LUIE_CompanionAbilityTrack|nil
local UnitFrames = LUIE.UnitFrames
if not UnitFrames then
    return
end

local LuiData = LuiData
local Effects = LuiData.Data.Effects
--- @type CompanionAbilityTrack
local CompanionAbilityTrackData = Effects.CompanionAbilityTrack
local BUILTIN_INTERRUPT_ABILITY_ID = Effects.CompanionBuiltInInterruptAbilityId
local BUILTIN_INTERRUPT_SLOT_KEY = "builtin_interrupt"

local eventManager = GetEventManager()
local moduleName = UnitFrames.moduleName

local HOTBAR = HOTBAR_CATEGORY_COMPANION
-- Companion bar: five actives (FIRST..ULTIMATE-1) plus ultimate at ACTION_BAR_ULTIMATE_SLOT_INDEX + 1 (see ActionBar.lua).
local FIRST_SLOT = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1
local LAST_SLOT = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1

local ICON_SPACING = 2
local ROW_BELOW_GAP = 2
local UPDATE_INTERVAL_MS = 100
local UPDATE_NAME = moduleName .. "CompanionAbilityTrackTick"

--- @alias LUIE_CompanionAbilitySlotKind "hotbar" | "builtin"

--- @class LUIE_CompanionAbilitySlotOptions
--- @field kind LUIE_CompanionAbilitySlotKind
--- @field slotIndex integer|nil HOTBAR slot index when kind == "hotbar"
--- @field abilityId integer|nil Fixed ability id when kind == "builtin"

--- @class LUIE_CompanionAbilityTrackSettings
--- @field enabled boolean
--- @field iconSize integer
--- @field iconSpacing integer
--- @field showEffectTimer boolean
--- @field showStacks boolean
--- @field showBuiltinInterrupt boolean

--- @class LUIE_CompanionAbilityBuffSource
--- @field unitTag string
--- @field abilityId integer

-- -----------------------------------------------------------------------------
-- Settings and shared helpers
-- -----------------------------------------------------------------------------

--- @return LUIE_CompanionAbilityTrackSettings
local function GetCompanionAbilityTrackSettings()
    if not UnitFrames.SV.CompanionAbilityTrack then
        UnitFrames.SV.CompanionAbilityTrack = ZO_ShallowTableCopy(UnitFrames.Defaults.CompanionAbilityTrack)
    end
    return UnitFrames.SV.CompanionAbilityTrack
end

--- @param iconSize integer
--- @return string
local function GetSlotLabelFont(iconSize)
    local appearance = UnitFrames.GetCustomFrameAppearance("companion")
    local fontFace = UnitFrames.ResolveLuiMediaFontPath(appearance.fontFace)
    local fontStyle = appearance.fontStyle
    return LUIE.CreateFontString(fontFace, zo_max(12, iconSize - 6), fontStyle)
end

--- @param unitTag string
--- @param abilityId integer
--- @return integer|nil remainingMs
--- @return integer|nil stackCount
local function GetBuffRemainingMsAndStacks(unitTag, abilityId)
    if not unitTag or not DoesUnitExist(unitTag) then
        return nil, nil
    end

    for i = 1, GetNumBuffs(unitTag) do
        local _, timeStarted, timeEnding, _, stackCount, _, _, _, _, _, buffAbilityId = GetUnitBuffInfo(unitTag, i)
        if buffAbilityId == abilityId then
            local remainingS = timeEnding - GetFrameTimeSeconds()
            if remainingS > 0 then
                return zo_floor(remainingS * 1000 + 0.5), stackCount
            end
            return nil, stackCount
        end
    end
    return nil, nil
end

--- @param entry CompanionAbilityTrackEntry
--- @return LUIE_CompanionAbilityBuffSource[]
local function BuildTrackBuffSourcesFromEntry(entry)
    --- @type LUIE_CompanionAbilityBuffSource[]
    local sources = {}
    if entry.trackId then
        sources[#sources + 1] = { unitTag = entry.unitTag or "companion", abilityId = entry.trackId }
    end
    if entry.extraTrackIds then
        local unitTag = entry.unitTag or "companion"
        for _, extraId in ipairs(entry.extraTrackIds) do
            sources[#sources + 1] = { unitTag = unitTag, abilityId = extraId }
        end
    end
    if entry.alternateTrackId then
        sources[#sources + 1] = { unitTag = entry.alternateUnitTag or "reticleover", abilityId = entry.alternateTrackId }
    end
    if entry.alternateTrackIds then
        local unitTag = entry.alternateUnitTag or "reticleover"
        for _, altId in ipairs(entry.alternateTrackIds) do
            sources[#sources + 1] = { unitTag = unitTag, abilityId = altId }
        end
    end
    return sources
end

--- @param container object
--- @return boolean
local function ValidateSlotControls(container)
    if not container then
        return false
    end
    if BUILTIN_INTERRUPT_ABILITY_ID and not container:GetNamedChild("_SlotBuiltinInterrupt") then
        return false
    end
    for slotIndex = FIRST_SLOT, LAST_SLOT do
        if not container:GetNamedChild("_Slot" .. tostring(slotIndex)) then
            return false
        end
    end
    return true
end

--- @param container object
--- @param slotIndex integer
--- @return object|nil
local function GetHotbarSlotBackdrop(container, slotIndex)
    if not container then
        return nil
    end
    return container:GetNamedChild("_Slot" .. tostring(slotIndex))
end

-- -----------------------------------------------------------------------------
-- LUIE_CompanionAbilitySlot
-- -----------------------------------------------------------------------------

--- @class LUIE_CompanionAbilitySlot : ZO_Object
--- @field backdrop object
--- @field icon object|nil
--- @field effectCooldown object|nil
--- @field durationLabel object|nil
--- @field stackLabel object|nil
--- @field options LUIE_CompanionAbilitySlotOptions
--- @field slottedId integer|nil
--- @field actionSlotIndex integer|nil
LUIE_CompanionAbilitySlot = ZO_Object:Subclass()

--- @param backdrop object|nil
--- @param options LUIE_CompanionAbilitySlotOptions
--- @return LUIE_CompanionAbilitySlot|nil
function LUIE_CompanionAbilitySlot:New(backdrop, options)
    if not backdrop or not options then
        return nil
    end
    local slot = ZO_Object.New(self)
    slot.backdrop = backdrop
    slot.icon = backdrop:GetNamedChild("_Icon")
    slot.effectCooldown = backdrop:GetNamedChild("_EffectCooldown")
    slot.durationLabel = backdrop:GetNamedChild("_Duration")
    slot.stackLabel = backdrop:GetNamedChild("_Stack")
    slot.options = options
    slot.slottedId = nil
    slot.actionSlotIndex = options.kind == "hotbar" and options.slotIndex or nil
    slot:InitializeDisplay()
    slot:SetupTooltip()
    return slot
end

function LUIE_CompanionAbilitySlot:InitializeDisplay()
    local labelFont = GetSlotLabelFont(24)
    if self.durationLabel then
        self.durationLabel:SetDrawTier(DT_HIGH)
        self.durationLabel:SetFont(labelFont)
        self.durationLabel:SetHidden(true)
    end
    if self.stackLabel then
        self.stackLabel:SetDrawTier(DT_HIGH)
        self.stackLabel:SetFont(labelFont)
    end
    if self.effectCooldown then
        self.effectCooldown:SetHidden(true)
    end
    self.backdrop:SetMouseEnabled(true)
end

--- @param iconSize integer
function LUIE_CompanionAbilitySlot:ApplyDimensions(iconSize)
    self.backdrop:SetDimensions(iconSize, iconSize)
    if self.icon then
        self.icon:SetDimensions(iconSize - 2, iconSize - 2)
    end
end

--- @param iconSize integer
function LUIE_CompanionAbilitySlot:ApplyLabelFonts(iconSize)
    local labelFont = GetSlotLabelFont(iconSize)
    if self.durationLabel then
        self.durationLabel:SetFont(labelFont)
    end
    if self.stackLabel then
        self.stackLabel:SetFont(labelFont)
    end
end

function LUIE_CompanionAbilitySlot:SetupTooltip()
    local slot = self
    if self.options.kind == "hotbar" then
        self.backdrop:SetHandler("OnMouseEnter", function (control)
            if IsInGamepadPreferredMode() then
                return
            end
            local idx = slot.actionSlotIndex
            if not idx or GetSlotType(idx, HOTBAR) == ACTION_TYPE_NOTHING then
                return
            end
            InitializeTooltip(AbilityTooltip, control, BOTTOM, 0, -4, TOP)
            AbilityTooltip:SetAction(idx, HOTBAR)
        end)
    elseif self.options.kind == "builtin" and self.options.abilityId then
        local abilityId = self.options.abilityId
        self.backdrop:SetHandler("OnMouseEnter", function (control)
            if IsInGamepadPreferredMode() then
                return
            end
            InitializeTooltip(AbilityTooltip, control, BOTTOM, 0, -4, TOP)
            AbilityTooltip:SetAbilityId(abilityId)
        end)
    end
    self.backdrop:SetHandler("OnMouseExit", function ()
        ClearTooltip(AbilityTooltip)
    end)
end

--- @param settings LUIE_CompanionAbilityTrackSettings
--- @param effectRemainingMs integer|nil
--- @param stacks integer|nil
--- @param maxStacks integer|nil
function LUIE_CompanionAbilitySlot:ApplyEffectVisual(settings, effectRemainingMs, stacks, maxStacks)
    if self.effectCooldown then
        if settings.showEffectTimer and effectRemainingMs and effectRemainingMs > 0 then
            self.effectCooldown:SetHidden(false)
            self.effectCooldown:StartCooldown(effectRemainingMs, effectRemainingMs, CD_TYPE_VERTICAL, CD_TIME_TYPE_TIME_REMAINING, false)
            if self.icon then
                self.icon:SetColor(1, 1, 1, 1)
            end
        else
            self.effectCooldown:ResetCooldown()
            self.effectCooldown:SetHidden(true)
            if self.icon then
                if effectRemainingMs and effectRemainingMs > 0 then
                    self.icon:SetColor(1, 1, 1, 1)
                else
                    self.icon:SetColor(0.85, 0.85, 0.85, 1)
                end
            end
        end
    end

    if self.durationLabel then
        if settings.showEffectTimer and effectRemainingMs and effectRemainingMs > 0 then
            local labelSeconds = zo_ceil(effectRemainingMs / 1000)
            if labelSeconds > 0 then
                self.durationLabel:SetText(tostring(labelSeconds))
                self.durationLabel:SetHidden(false)
            else
                self.durationLabel:SetText("")
                self.durationLabel:SetHidden(true)
            end
        else
            self.durationLabel:SetText("")
            self.durationLabel:SetHidden(true)
        end
    end

    if self.stackLabel then
        if settings.showStacks and stacks and stacks > 0 then
            if maxStacks and maxStacks > 0 then
                self.stackLabel:SetText(string.format("%d/%d", stacks, maxStacks))
            else
                self.stackLabel:SetText(tostring(stacks))
            end
            self.stackLabel:SetHidden(false)
        else
            self.stackLabel:SetHidden(true)
        end
    end
end

--- @param track LUIE_CompanionAbilityTrack
--- @param settings LUIE_CompanionAbilityTrackSettings
--- @param rowVisible boolean
function LUIE_CompanionAbilitySlot:Update(track, settings, rowVisible)
    if not rowVisible or not settings then
        self.backdrop:SetHidden(true)
        return
    end

    if self.options.kind == "builtin" then
        self:UpdateBuiltin(track, settings)
    else
        self:UpdateHotbar(track, settings)
    end
end

--- @param track LUIE_CompanionAbilityTrack
--- @param settings LUIE_CompanionAbilityTrackSettings
function LUIE_CompanionAbilitySlot:UpdateBuiltin(track, settings)
    if not BUILTIN_INTERRUPT_ABILITY_ID or settings.showBuiltinInterrupt == false then
        self.backdrop:SetHidden(true)
        return
    end

    local slottedId = BUILTIN_INTERRUPT_ABILITY_ID
    local entry = CompanionAbilityTrackData[slottedId]
    if not entry or not entry.builtInInterrupt then
        self.backdrop:SetHidden(true)
        return
    end

    self.backdrop:SetHidden(false)
    self.slottedId = slottedId
    self.actionSlotIndex = nil

    local icon = GetAbilityIcon(slottedId)
    if self.icon then
        if icon and icon ~= "" then
            self.icon:SetTexture(icon)
            self.icon:SetColor(1, 1, 1, 1)
        else
            self.icon:SetTexture(ZO_NO_TEXTURE_FILE)
        end
    end

    local effectRemainingMs, stacks = track:ResolveEffectRemaining(slottedId, entry)
    self:ApplyEffectVisual(settings, effectRemainingMs, stacks, entry.maxStacks)
end

--- @param track LUIE_CompanionAbilityTrack
--- @param settings LUIE_CompanionAbilityTrackSettings
function LUIE_CompanionAbilitySlot:UpdateHotbar(track, settings)
    local slotIndex = self.options.slotIndex
    if not slotIndex then
        self.backdrop:SetHidden(true)
        return
    end

    self.backdrop:SetHidden(false)
    self.actionSlotIndex = slotIndex

    if IsActionSlotLocked(slotIndex, HOTBAR) then
        if self.icon then
            self.icon:SetTexture("EsoUI/Art/actionbar/quickslotBG.dds")
            self.icon:SetColor(0.4, 0.4, 0.4, 0.8)
        end
        self:ApplyEffectVisual(settings, nil, nil, nil)
        return
    end

    if GetSlotType(slotIndex, HOTBAR) == ACTION_TYPE_NOTHING or not IsSlotUsed(slotIndex, HOTBAR) then
        if self.icon then
            self.icon:SetTexture(ZO_NO_TEXTURE_FILE)
        end
        self:ApplyEffectVisual(settings, nil, nil, nil)
        return
    end

    local slottedId = LUIE.GetSlotTrueBoundId(slotIndex, HOTBAR)
    if slottedId and slottedId > 0 then
        self.slottedId = slottedId
        if self.icon then
            local icon = GetAbilityIcon(slottedId)
            if icon and icon ~= "" then
                self.icon:SetTexture(icon)
            else
                self.icon:SetTexture(GetSlotTexture(slotIndex, HOTBAR))
            end
        end
    else
        self.slottedId = nil
        if self.icon then
            self.icon:SetTexture(GetSlotTexture(slotIndex, HOTBAR))
        end
    end

    local entry = slottedId and CompanionAbilityTrackData[slottedId]
    local effectRemainingMs, stacks
    if entry and slottedId then
        effectRemainingMs, stacks = track:ResolveEffectRemaining(slottedId, entry)
    end

    self:ApplyEffectVisual(settings, effectRemainingMs, stacks, entry and entry.maxStacks)
end

-- -----------------------------------------------------------------------------
-- LUIE_CompanionAbilityRow
-- -----------------------------------------------------------------------------

--- @class LUIE_CompanionAbilityRow : ZO_Object
--- @field container object
--- @field slots table<integer|string, LUIE_CompanionAbilitySlot>
--- @field interruptSlotKey string
LUIE_CompanionAbilityRow = ZO_Object:Subclass()

--- @param container object
--- @return LUIE_CompanionAbilityRow
function LUIE_CompanionAbilityRow:New(container)
    local row = ZO_Object.New(self)
    row.container = container
    row.slots = {}
    row.interruptSlotKey = BUILTIN_INTERRUPT_SLOT_KEY
    return row
end

--- @return table|nil
--- @return object|nil healthBackdrop
function LUIE_CompanionAbilityRow:GetCompanionFrame()
    local frame = UnitFrames.CustomFrames["companion"]
    if not frame then
        return nil, nil
    end
    local health = frame[COMBAT_MECHANIC_FLAGS_HEALTH]
    return frame, health and health.backdrop
end

--- @return boolean
function LUIE_CompanionAbilityRow:IsFeatureEnabled()
    local settings = GetCompanionAbilityTrackSettings()
    return UnitFrames.Enabled
        and UnitFrames.SV.CustomFramesCompanion
        and settings.enabled
end

--- @return boolean
function LUIE_CompanionAbilityRow:ShouldShow()
    return self:IsFeatureEnabled()
        and DoesUnitExist("companion")
        and HasActiveCompanion()
end

--- @param settings LUIE_CompanionAbilityTrackSettings
--- @return integer
function LUIE_CompanionAbilityRow:GetRowIconCount(settings)
    local count = LAST_SLOT - FIRST_SLOT + 1
    if settings.showBuiltinInterrupt ~= false and BUILTIN_INTERRUPT_ABILITY_ID then
        count = count + 1
    end
    return count
end

--- @param settings LUIE_CompanionAbilityTrackSettings
function LUIE_CompanionAbilityRow:ApplyLayout(settings)
    if not settings or not self.container then
        return
    end

    local iconSize = settings.iconSize or 24
    local spacing = settings.iconSpacing or ICON_SPACING
    local iconCount = self:GetRowIconCount(settings)
    local rowWidth = (iconSize * iconCount) + (spacing * zo_max(0, iconCount - 1))
    self.container:SetDimensions(rowWidth, iconSize)

    local frame, healthBackdrop = self:GetCompanionFrame()
    if not healthBackdrop then
        return
    end

    local anchorBelow = healthBackdrop
    if frame and frame[COMBAT_MECHANIC_FLAGS_HEALTH] and frame[COMBAT_MECHANIC_FLAGS_HEALTH].shieldbackdrop then
        anchorBelow = frame[COMBAT_MECHANIC_FLAGS_HEALTH].shieldbackdrop
    end

    self.container:ClearAnchors()
    self.container:SetAnchor(TOPLEFT, anchorBelow, BOTTOMLEFT, 0, ROW_BELOW_GAP)

    local prevBackdrop
    local interruptSlot = self.slots[self.interruptSlotKey]
    if interruptSlot and settings.showBuiltinInterrupt ~= false then
        interruptSlot:ApplyDimensions(iconSize)
        interruptSlot:ApplyLabelFonts(iconSize)
        interruptSlot.backdrop:ClearAnchors()
        interruptSlot.backdrop:SetAnchor(TOPLEFT, self.container, TOPLEFT, 0, 0)
        prevBackdrop = interruptSlot.backdrop
    elseif interruptSlot then
        interruptSlot.backdrop:SetHidden(true)
    end

    for slotIndex = FIRST_SLOT, LAST_SLOT do
        local slot = self.slots[slotIndex]
        if slot then
            slot:ApplyDimensions(iconSize)
            slot:ApplyLabelFonts(iconSize)
            slot.backdrop:ClearAnchors()
            if prevBackdrop then
                slot.backdrop:SetAnchor(LEFT, prevBackdrop, RIGHT, spacing, 0)
            else
                slot.backdrop:SetAnchor(TOPLEFT, self.container, TOPLEFT, 0, 0)
            end
            prevBackdrop = slot.backdrop
        end
    end
end

--- @param track LUIE_CompanionAbilityTrack
--- @param settings LUIE_CompanionAbilityTrackSettings|nil
function LUIE_CompanionAbilityRow:RefreshAll(track, settings)
    settings = settings or GetCompanionAbilityTrackSettings()

    if not self:IsFeatureEnabled() then
        self.container:SetHidden(true)
        return
    end

    if not self:ShouldShow() then
        self.container:SetHidden(true)
        return
    end

    self.container:SetHidden(false)
    local rowVisible = true

    local interruptSlot = self.slots[self.interruptSlotKey]
    if interruptSlot then
        interruptSlot:Update(track, settings, rowVisible)
    end

    for slotIndex = FIRST_SLOT, LAST_SLOT do
        local slot = self.slots[slotIndex]
        if slot then
            slot:Update(track, settings, rowVisible)
        end
    end
end

--- @param track LUIE_CompanionAbilityTrack
--- @param slotIndex integer
function LUIE_CompanionAbilityRow:RefreshHotbarSlot(track, slotIndex)
    local settings = GetCompanionAbilityTrackSettings()
    local slot = self.slots[slotIndex]
    if not slot then
        return
    end
    local rowVisible = self:ShouldShow()
    if not self:IsFeatureEnabled() or not rowVisible then
        slot.backdrop:SetHidden(true)
        return
    end
    slot:Update(track, settings, rowVisible)
end

--- @param track LUIE_CompanionAbilityTrack
--- @param slottedId integer
function LUIE_CompanionAbilityRow:RefreshSlottedAbility(track, slottedId)
    if slottedId == BUILTIN_INTERRUPT_ABILITY_ID then
        local interruptSlot = self.slots[self.interruptSlotKey]
        if interruptSlot then
            interruptSlot:Update(track, GetCompanionAbilityTrackSettings(), self:ShouldShow())
        end
    end
    for slotIndex = FIRST_SLOT, LAST_SLOT do
        local boundId = LUIE.GetSlotTrueBoundId(slotIndex, HOTBAR)
        if boundId == slottedId then
            self:RefreshHotbarSlot(track, slotIndex)
        end
    end
end

-- -----------------------------------------------------------------------------
-- LUIE_CompanionAbilityTrack
-- -----------------------------------------------------------------------------

--- @class LUIE_CompanionAbilityTrack : ZO_Object
--- @field row LUIE_CompanionAbilityRow|nil
--- @field trackIdToSlotted table<integer, integer>
--- @field slottedIds table<integer, boolean>
--- @field groundTrackToSlotted table<integer, integer>
--- @field combatTrackEndMs table<integer, integer>
--- @field slottedIdsWithAlternateTrack table<integer, boolean>
--- @field eventsRegistered boolean
--- @field updateTickRegistered boolean
LUIE_CompanionAbilityTrack = ZO_Object:Subclass()

--- @return LUIE_CompanionAbilityTrack
function LUIE_CompanionAbilityTrack:New()
    local track = ZO_Object.New(self)
    track.row = nil
    track.trackIdToSlotted = {}
    track.slottedIds = {}
    track.groundTrackToSlotted = {}
    track.combatTrackEndMs = {}
    track.slottedIdsWithAlternateTrack = {}
    track.eventsRegistered = false
    track.updateTickRegistered = false
    return track
end

--- @param hotbarCategory integer
--- @param actionSlotIndex integer
--- @return boolean
local function IsCompanionBarSlot(hotbarCategory, actionSlotIndex)
    return hotbarCategory == HOTBAR
        and actionSlotIndex >= FIRST_SLOT
        and actionSlotIndex <= LAST_SLOT
end

function LUIE_CompanionAbilityTrack:BuildLookupTables()
    ZO_ClearTable(self.slottedIds)
    ZO_ClearTable(self.trackIdToSlotted)
    ZO_ClearTable(self.groundTrackToSlotted)
    ZO_ClearTable(self.slottedIdsWithAlternateTrack)

    for slottedId, entry in pairs(CompanionAbilityTrackData) do
        if entry.alternateTrackId or entry.alternateTrackIds then
            self.slottedIdsWithAlternateTrack[slottedId] = true
        end
        self.slottedIds[slottedId] = true
        if entry.trackId then
            self.trackIdToSlotted[entry.trackId] = slottedId
        end
        if entry.alternateTrackId then
            self.trackIdToSlotted[entry.alternateTrackId] = slottedId
        end
        if entry.alternateTrackIds then
            for _, altId in ipairs(entry.alternateTrackIds) do
                self.trackIdToSlotted[altId] = slottedId
            end
        end
        if entry.groundTrackId then
            self.groundTrackToSlotted[entry.groundTrackId] = slottedId
            self.trackIdToSlotted[entry.groundTrackId] = slottedId
        end
        if entry.groundTrackIds then
            for _, groundId in ipairs(entry.groundTrackIds) do
                self.groundTrackToSlotted[groundId] = slottedId
                self.trackIdToSlotted[groundId] = slottedId
            end
        end
        if entry.extraTrackIds then
            for _, extraId in ipairs(entry.extraTrackIds) do
                self.trackIdToSlotted[extraId] = slottedId
            end
        end
    end
end

--- @param bestRemaining integer|nil
--- @param bestStacks integer|nil
--- @param unitTag string
--- @param abilityId integer
--- @return integer|nil
--- @return integer|nil
local function ConsiderBuffForEffect(bestRemaining, bestStacks, unitTag, abilityId)
    local remaining, stacks = GetBuffRemainingMsAndStacks(unitTag, abilityId)
    if remaining and (not bestRemaining or remaining > bestRemaining) then
        bestRemaining = remaining
        bestStacks = stacks
    elseif stacks and stacks > 0 and not bestRemaining then
        bestStacks = stacks
    end
    return bestRemaining, bestStacks
end

--- @param slottedId integer
--- @param entry CompanionAbilityTrackEntry
--- @return integer|nil effectRemainingMs
--- @return integer|nil stacks
function LUIE_CompanionAbilityTrack:ResolveEffectRemaining(slottedId, entry)
    local bestRemaining
    local bestStacks

    for _, source in ipairs(BuildTrackBuffSourcesFromEntry(entry)) do
        bestRemaining, bestStacks = ConsiderBuffForEffect(bestRemaining, bestStacks, source.unitTag, source.abilityId)
    end

    local trackEnd = self.combatTrackEndMs[slottedId]
    if trackEnd then
        local trackRemaining = trackEnd - GetGameTimeMilliseconds()
        if trackRemaining > 0 then
            if not bestRemaining or trackRemaining > bestRemaining then
                bestRemaining = trackRemaining
            end
        else
            self.combatTrackEndMs[slottedId] = nil
        end
    end

    return bestRemaining, bestStacks
end

--- @param slottedId integer
--- @param trackAbilityId integer
--- @param hitValue integer
function LUIE_CompanionAbilityTrack:StartCombatTrackTimer(slottedId, trackAbilityId, hitValue)
    local durationMs = hitValue
    if not durationMs or durationMs < 500 then
        durationMs = GetAbilityDuration(trackAbilityId)
    end
    if durationMs and durationMs > 0 then
        self.combatTrackEndMs[slottedId] = GetGameTimeMilliseconds() + durationMs
    end
end

--- @param frameData table
function LUIE_CompanionAbilityTrack:BindSlotControls(frameData)
    local companionControl = frameData.control
    local container = companionControl and companionControl:GetNamedChild("_CompanionAbilities")
    if not container or not ValidateSlotControls(container) then
        return
    end

    if not self.row then
        self.row = LUIE_CompanionAbilityRow:New(container)
    end

    container:SetDrawLayer(DL_CONTROLS)
    container:SetDrawTier(DT_MEDIUM)

    local settings = GetCompanionAbilityTrackSettings()
    local iconSize = settings.iconSize or 24

    if BUILTIN_INTERRUPT_ABILITY_ID then
        local interruptBackdrop = container:GetNamedChild("_SlotBuiltinInterrupt")
        if interruptBackdrop and not self.row.slots[BUILTIN_INTERRUPT_SLOT_KEY] then
            self.row.slots[BUILTIN_INTERRUPT_SLOT_KEY] = LUIE_CompanionAbilitySlot:New(interruptBackdrop,
                                                                                       {
                                                                                           kind = "builtin",
                                                                                           abilityId = BUILTIN_INTERRUPT_ABILITY_ID,
                                                                                       })
            local interruptSlot = self.row.slots[BUILTIN_INTERRUPT_SLOT_KEY]
            if interruptSlot then
                interruptSlot:ApplyLabelFonts(iconSize)
            end
        end
    end

    for slotIndex = FIRST_SLOT, LAST_SLOT do
        if not self.row.slots[slotIndex] then
            local backdrop = GetHotbarSlotBackdrop(container, slotIndex)
            self.row.slots[slotIndex] = LUIE_CompanionAbilitySlot:New(backdrop,
                                                                      {
                                                                          kind = "hotbar",
                                                                          slotIndex = slotIndex,
                                                                      })
            local slot = self.row.slots[slotIndex]
            if slot then
                slot:ApplyLabelFonts(iconSize)
            end
        end
    end

    frameData.companionAbilities =
    {
        container = container,
        row = self.row,
    }
end

--- @param frameData table
function LUIE_CompanionAbilityTrack:CreateControls(frameData)
    if not frameData or frameData.companionAbilities then
        return
    end
    self:BindSlotControls(frameData)
    self:ApplyLayout()
end

function LUIE_CompanionAbilityTrack:RefreshAll()
    if not self.row then
        return
    end
    self.row:RefreshAll(self, GetCompanionAbilityTrackSettings())
end

--- @param slotIndex integer
function LUIE_CompanionAbilityTrack:RefreshSlot(slotIndex)
    if not self.row then
        return
    end
    self.row:RefreshHotbarSlot(self, slotIndex)
end

--- @param slottedId integer
function LUIE_CompanionAbilityTrack:RefreshSlottedAbility(slottedId)
    if not self.row then
        return
    end
    self.row:RefreshSlottedAbility(self, slottedId)
end

function LUIE_CompanionAbilityTrack:ApplyLayout()
    if not self.row then
        return
    end
    local settings = GetCompanionAbilityTrackSettings()
    self.row:ApplyLayout(settings)
    self:RefreshAll()
end

--- @return integer
function LUIE_CompanionAbilityTrack:GetCompanionFrameExtraHeight()
    if not self.row or not self.row:IsFeatureEnabled() then
        return 0
    end
    local settings = GetCompanionAbilityTrackSettings()
    local iconSize = settings.iconSize or 24
    return iconSize + ROW_BELOW_GAP
end

function LUIE_CompanionAbilityTrack:RegisterUpdateTick()
    if self.updateTickRegistered then
        return
    end
    local track = self
    eventManager:RegisterForUpdate(UPDATE_NAME, UPDATE_INTERVAL_MS, function ()
        if not track.row or not track.row:IsFeatureEnabled() or not track.row:ShouldShow() then
            return
        end
        track:RefreshAll()
    end)
    self.updateTickRegistered = true
end

--- @param hotbarCategory integer
--- @param actionSlotIndex integer
function LUIE_CompanionAbilityTrack:OnCompanionHotbarSlotUpdated(hotbarCategory, actionSlotIndex)
    if not IsCompanionBarSlot(hotbarCategory, actionSlotIndex) then
        return
    end
    self:RefreshSlot(actionSlotIndex)
end

--- @param hotbarCategory integer
--- @param actionSlotIndex integer
function LUIE_CompanionAbilityTrack:OnActionSlotEffectUpdate(hotbarCategory, actionSlotIndex)
    if not IsCompanionBarSlot(hotbarCategory, actionSlotIndex) then
        return
    end
    local slottedId = LUIE.GetSlotTrueBoundId(actionSlotIndex, HOTBAR)
    if slottedId and slottedId > 0 then
        self:RefreshSlottedAbility(slottedId)
    else
        self:RefreshSlot(actionSlotIndex)
    end
end

--- @param unitTag string
--- @param abilityId integer
function LUIE_CompanionAbilityTrack:OnEffectChanged(unitTag, abilityId)
    local slottedId = self.trackIdToSlotted[abilityId]
    if not slottedId then
        return
    end
    self:RefreshSlottedAbility(slottedId)
end

function LUIE_CompanionAbilityTrack:OnReticleTargetChanged()
    for slottedId in pairs(self.slottedIdsWithAlternateTrack) do
        self:RefreshSlottedAbility(slottedId)
    end
end

--- @param newState CompanionState
--- @param oldState CompanionState
function LUIE_CompanionAbilityTrack:OnActiveCompanionStateChanged(newState, oldState)
    if newState ~= COMPANION_STATE_ACTIVE then
        ZO_ClearTable(self.combatTrackEndMs)
    end
    self:RefreshAll()
end

--- @param summonResult CompanionSummonResult
function LUIE_CompanionAbilityTrack:OnCompanionSummonResult(summonResult)
    if summonResult == COMPANION_SUMMON_RESULT_SUMMON_REQUESTED
        or summonResult == COMPANION_SUMMON_RESULT_SUMMON_AUTO_REQUESTED
        or summonResult == COMPANION_SUMMON_RESULT_ADDED_FOR_GROUP_PLAYER then
        self:RefreshAll()
    else
        ZO_ClearTable(self.combatTrackEndMs)
        self:RefreshAll()
    end
end

--- @param result ActionResult
--- @param abilityId integer
function LUIE_CompanionAbilityTrack:OnCombatEventEffectFaded(result, abilityId)
    if result ~= ACTION_RESULT_EFFECT_FADED then
        return
    end
    local slottedFromTrack = self.trackIdToSlotted[abilityId]
    if not slottedFromTrack then
        return
    end
    self.combatTrackEndMs[slottedFromTrack] = nil
    self:RefreshSlottedAbility(slottedFromTrack)
end

--- @param result ActionResult
--- @param hitValue integer
--- @param abilityId integer
function LUIE_CompanionAbilityTrack:OnCombatEventCompanion(result, hitValue, abilityId)
    local slottedFromTrack = self.trackIdToSlotted[abilityId]
    if not slottedFromTrack then
        return
    end
    if result == ACTION_RESULT_EFFECT_GAINED or result == ACTION_RESULT_EFFECT_GAINED_DURATION then
        self:StartCombatTrackTimer(slottedFromTrack, abilityId, hitValue)
        self:RefreshSlottedAbility(slottedFromTrack)
    elseif result == ACTION_RESULT_BEGIN and not self.slottedIds[abilityId] then
        self:StartCombatTrackTimer(slottedFromTrack, abilityId, hitValue)
        self:RefreshSlottedAbility(slottedFromTrack)
    end
end

function LUIE_CompanionAbilityTrack:RegisterEvents()
    if self.eventsRegistered then
        return
    end
    self.eventsRegistered = true

    local handler = moduleName .. "CompanionAbilityTrack"
    local track = self

    local function RegisterHotbarEvents()
        eventManager:RegisterForEvent(handler .. "HotbarSlot", EVENT_HOTBAR_SLOT_STATE_UPDATED, function (eventId, actionSlotIndex, hotbarCategory)
            track:OnCompanionHotbarSlotUpdated(hotbarCategory, actionSlotIndex)
        end)
        eventManager:RegisterForEvent(handler .. "SlotEffect", EVENT_ACTION_SLOT_EFFECT_UPDATE, function (eventId, hotbarCategory, actionSlotIndex)
            track:OnActionSlotEffectUpdate(hotbarCategory, actionSlotIndex)
        end)
        eventManager:RegisterForEvent(handler, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, function (eventId)
            track:RefreshAll()
        end)
        eventManager:RegisterForEvent(handler, EVENT_COMPANION_SKILLS_FULL_UPDATE, function (eventId, isInit)
            track:RefreshAll()
        end)
        eventManager:RegisterForEvent(handler, EVENT_ACTION_BAR_LOCKED_REASON_CHANGED, function (eventId)
            track:RefreshAll()
        end)
    end

    local function RegisterEffectEvents()
        local function OnEffectChangedEvent(eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
            track:OnEffectChanged(unitTag, abilityId)
        end
        local effectUnitTags = { "companion", "reticleover", "player" }
        for index, unitTag in ipairs(effectUnitTags) do
            local effectHandler = handler .. "Effect" .. tostring(index)
            eventManager:RegisterForEvent(effectHandler, EVENT_EFFECT_CHANGED, OnEffectChangedEvent)
            eventManager:AddFilterForEvent(effectHandler, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, unitTag)
        end
    end

    local function RegisterCombatEvents()
        eventManager:RegisterForEvent(handler .. "CombatFade", EVENT_COMBAT_EVENT, function (eventId, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
            if isError then
                return
            end
            track:OnCombatEventEffectFaded(result, abilityId)
        end)
        eventManager:AddFilterForEvent(handler .. "CombatFade", EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, false)

        eventManager:RegisterForEvent(handler .. "CombatCompanion", EVENT_COMBAT_EVENT, function (eventId, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
            if isError then
                return
            end
            track:OnCombatEventCompanion(result, hitValue, abilityId)
        end)
        eventManager:AddFilterForEvent(handler .. "CombatCompanion", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER_COMPANION, REGISTER_FILTER_IS_ERROR, false)
    end

    local function RegisterCompanionLifecycleEvents()
        eventManager:RegisterForEvent(handler, EVENT_ACTIVE_COMPANION_STATE_CHANGED, function (eventId, newState, oldState)
            track:OnActiveCompanionStateChanged(newState, oldState)
        end)
        eventManager:RegisterForEvent(handler, EVENT_COMPANION_ACTIVATED, function (eventId, companionId)
            track:RefreshAll()
        end)
        eventManager:RegisterForEvent(handler, EVENT_COMPANION_DEACTIVATED, function (eventId)
            ZO_ClearTable(track.combatTrackEndMs)
            track:RefreshAll()
        end)
        eventManager:RegisterForEvent(handler, EVENT_COMPANION_SUMMON_RESULT, function (eventId, summonResult, companionId)
            track:OnCompanionSummonResult(summonResult)
        end)
        eventManager:RegisterForEvent(handler, EVENT_RETICLE_TARGET_CHANGED, function (eventId)
            track:OnReticleTargetChanged()
        end)
    end

    RegisterHotbarEvents()
    RegisterEffectEvents()
    RegisterCombatEvents()
    RegisterCompanionLifecycleEvents()

    self:RegisterUpdateTick()
end

function LUIE_CompanionAbilityTrack:Initialize()
    self:BuildLookupTables()

    local frame = UnitFrames.CustomFrames["companion"]
    if frame then
        if not frame.companionAbilities then
            self:CreateControls(frame)
        elseif frame.companionAbilities.container and not self.row then
            self:BindSlotControls(frame)
            self:ApplyLayout()
        end
    end

    self:RegisterEvents()
    self:RefreshAll()
end
