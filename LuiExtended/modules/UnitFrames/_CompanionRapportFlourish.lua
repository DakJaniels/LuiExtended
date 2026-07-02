--- @diagnostic disable: undefined-field, missing-fields
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) UnitFrames
--- @field companionRapportFlourish LUIE_CompanionRapportFlourish|nil
local UnitFrames = LUIE.UnitFrames
if not UnitFrames then
    return
end

local eventManager = GetEventManager()
local EVENT_HANDLER = UnitFrames.moduleName .. "CompanionRapportFlourish"

local FLOURISH_DURATION_MS = 2800
local FLOURISH_RISE_PX = 28
local FLOURISH_FADE_DELAY_MS = 750
local FLOURISH_FADE_DURATION_MS = 2050
local RAPPORT_GRADIENT_START = ZO_ColorDef:New("722323") -- Red
local RAPPORT_GRADIENT_END = ZO_ColorDef:New("009966")   -- Green

--- @param label LabelControl
--- @return AnimationTimeline
local function CreateRapportFlourishTimeline(label)
    local timeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("LUIE_CompanionRapportFlourishAnimation", label)
    local translateAnimation = timeline:GetAnimation(1) ---@type AnimationObjectTranslate
    translateAnimation:SetTranslateOffsets(0, 0, 0, -FLOURISH_RISE_PX)
    translateAnimation:SetDuration(FLOURISH_DURATION_MS)

    local alphaAnimation = timeline:GetAnimation(2)
    alphaAnimation:SetAlphaValues(1, 0)
    alphaAnimation:SetOffsetInParent(FLOURISH_FADE_DELAY_MS)
    alphaAnimation:SetDuration(FLOURISH_FADE_DURATION_MS)

    timeline:SetHandler("OnStop", function ()
        label:SetHidden(true)
        label:SetAlpha(1)
    end)

    return timeline
end

--- @class LUIE_CompanionRapportFlourish : ZO_InitializingObject
--- @field label LabelControl|nil
--- @field timeline AnimationTimeline|nil
LUIE_CompanionRapportFlourish = ZO_InitializingObject:Subclass()

--- @param frameData table
function LUIE_CompanionRapportFlourish:BindControls(frameData)
    if frameData.rapportFlourish then
        return
    end

    local label = frameData.control:GetNamedChild("_RapportFlourish")
    local appearance = UnitFrames.GetCustomFrameAppearance("companion")
    label:SetFont(LUIE.Font.Resolve(appearance.fontFace, zo_max(14, appearance.fontSize or 14), appearance.fontStyle))
    label:SetDrawTier(DT_HIGH)
    label:SetHidden(true)

    self.label = label
    self.timeline = CreateRapportFlourishTimeline(label)
    frameData.rapportFlourish = true
end

function LUIE_CompanionRapportFlourish:StopFlourish()
    if not self.timeline then
        return
    end
    self.timeline:Stop()
    self.timeline:SetProgress(0)
end

--- @param delta integer
function LUIE_CompanionRapportFlourish:PlayFlourish(delta)
    self.timeline:Stop()
    self.timeline:SetProgress(0)

    local color = delta > 0 and RAPPORT_GRADIENT_END or RAPPORT_GRADIENT_START
    self.label:SetText(delta > 0 and string.format("+%d", delta) or string.format("-%d", -delta))
    self.label:SetColor(color:UnpackRGBA())
    self.label:SetAlpha(1)
    self.label:SetHidden(false)
    self.timeline:PlayFromStart()
end

--- @param companionId integer
--- @param previousRapport integer
--- @param currentRapport integer
--- @param adjustmentAmountType CompanionRapportAdjustmentAmount
function LUIE_CompanionRapportFlourish:OnCompanionRapportUpdate(companionId, previousRapport, currentRapport, adjustmentAmountType)
    if currentRapport == previousRapport then
        return
    end

    if not self.label
    or not UnitFrames.SV.CustomFramesCompanion
    or not UnitFrames.SV.CompanionRapportFlourish.enabled
    or companionId ~= GetActiveCompanionDefId() then
        return
    end

    local companionFrame = UnitFrames.CustomFrames["companion"]
    if not companionFrame or companionFrame.control:IsHidden() then
        return
    end

    self:PlayFlourish(currentRapport - previousRapport)
end

function LUIE_CompanionRapportFlourish:Initialize()
    eventManager:RegisterForEvent(EVENT_HANDLER, EVENT_COMPANION_RAPPORT_UPDATE, function (eventId, ...)
        self:OnCompanionRapportUpdate(...)
    end)
end
