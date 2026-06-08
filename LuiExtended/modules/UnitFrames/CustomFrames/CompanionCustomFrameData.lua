-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames
--- @type LUIE.CustomFramesShared
local Shared = LUIE.CustomFramesShared
local CreateLUIETopLevel = Shared.CreateLUIETopLevel
local ApplyStackedMemberAnchors = Shared.ApplyStackedMemberAnchors
local CreateMemberRangeFromVirtual = Shared.CreateMemberRangeFromVirtual
local CreateCombatGlowBorder = Shared.CreateCombatGlowBorder

function LUIE.CustomFramesBuildCompanion()
    if UnitFrames.SV.CustomFramesCompanion then
        -- Get references to XML-created controls
        local companionTlw = CreateLUIETopLevel("LUIE_CustomCompanionFrame", "LUIE_UF_CompanionFrame_Template")
        companionTlw.customPositionAttr = "CustomFramesCompanionFramePos"
        companionTlw.preview = companionTlw:GetNamedChild("_Preview")
        companionTlw.previewLabel = companionTlw.preview:GetNamedChild("_Label") --- @type LabelControl

        local companion = companionTlw:GetNamedChild("_Companion")
        local shb = companion:GetNamedChild("_Health")
        local combatGlow = CreateCombatGlowBorder(shb)

        UnitFrames.CustomFrames["companion"] =
        {
            ["unitTag"] = "companion",
            ["tlw"] = companionTlw,
            ["control"] = companion,
            [COMBAT_MECHANIC_FLAGS_HEALTH] =
            {
                ["backdrop"] = shb,
                ["label"] = shb:GetNamedChild("_Label"),
                ["trauma"] = shb:GetNamedChild("_Trauma"),
                ["bar"] = shb:GetNamedChild("_Bar"),
                ["shield"] = shb:GetNamedChild("_Shield"),
                ["noHealingOverlay"] = shb:GetNamedChild("_NoHealingOverlay"),
                ["noHealingStripe"] = shb:GetNamedChild("_NoHealingStripe"),
                ["possessionOverlay"] = shb:GetNamedChild("_PossessionOverlay"),
                ["combatGlow"] = combatGlow,
            },
            ["dead"] = shb:GetNamedChild("_Dead"),
            ["name"] = shb:GetNamedChild("_Name"),
        }
        UnitFrames.CustomFrames["companion"].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
        UnitFrames.CustomFrames["companion"][COMBAT_MECHANIC_FLAGS_HEALTH].label.format = "Current (Percentage%)"

        if UnitFrames.companionAbilityTrack then
            UnitFrames.companionAbilityTrack:CreateControls(UnitFrames.CustomFrames["companion"])
        end
        if UnitFrames.companionRapportFlourish then
            UnitFrames.companionRapportFlourish:BindControls(UnitFrames.CustomFrames["companion"])
        end
        UnitFrames.CustomFramesManager:CreateFrame("companion", UnitFrames.CustomFrames["companion"], "companion", LUIE_CustomFrameVisualizers.SetupCompanionFrame)
    end
end

-- Helper to create the Bosses Frames


function LUIE_CompanionCustomFrameData:BuildStaticData()
    LUIE.CustomFramesBuildCompanion()
end
