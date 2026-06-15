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

function LUIE.CustomFramesBuildAvaTarget()
    if UnitFrames.SV.AvaCustFramesTarget then
        -- Get references to XML-created controls
        local targetTlw = CreateLUIETopLevel("LUIE_CustomAvaPlayerTargetFrame", "LUIE_UF_AvaPlayerTargetFrame_Template")
        targetTlw.customPositionAttr = "AvaCustFramesTargetFramePos"
        targetTlw.preview = targetTlw:GetNamedChild("_Preview")
        targetTlw.previewLabel = targetTlw.preview:GetNamedChild("_Label")
        local target = targetTlw:GetNamedChild("_Target")
        local topInfo = target:GetNamedChild("_TopInfo")
        local botInfo = target:GetNamedChild("_BotInfo")
        local buffAnchor = target:GetNamedChild("_BuffAnchor")
        local thb = target:GetNamedChild("_Health")
        local cn = botInfo:GetNamedChild("_ClassName")

        UnitFrames.CustomFrames["AvaPlayerTarget"] =
        {
            ["unitTag"] = "reticleover",
            ["tlw"] = targetTlw,
            ["control"] = target,
            ["canHide"] = true,
            [COMBAT_MECHANIC_FLAGS_HEALTH] =
            {
                ["backdrop"] = thb,
                ["label"] = thb:GetNamedChild("_Label"),
                ["labelOne"] = thb:GetNamedChild("_LabelOne"),
                ["labelTwo"] = thb:GetNamedChild("_LabelTwo"),
                ["trauma"] = thb:GetNamedChild("_Trauma"),
                ["bar"] = thb:GetNamedChild("_Bar"),
                ["invulnerable"] = thb:GetNamedChild("_Invulnerable"),
                ["invulnerableInlay"] = thb:GetNamedChild("_InvulnerableInlay"),
                ["shield"] = thb:GetNamedChild("_Shield"),
                ["noHealingOverlay"] = thb:GetNamedChild("_NoHealingOverlay"),
                ["noHealingStripe"] = thb:GetNamedChild("_NoHealingStripe"),
                ["possessionOverlay"] = thb:GetNamedChild("_PossessionOverlay"),
                ["threshold"] = UnitFrames.targetThreshold,
            },
            ["topInfo"] = topInfo,
            ["name"] = topInfo:GetNamedChild("_Name"),
            ["classIcon"] = topInfo:GetNamedChild("_ClassIcon"),
            ["levelIcon"] = topInfo:GetNamedChild("_LevelIcon"),
            ["veterancyRankIcon"] = topInfo:GetNamedChild("_VeterancyRankIcon"),
            ["overlandDifficultyIcon"] = topInfo:GetNamedChild("_OverlandDifficultyIcon"),
            ["level"] = topInfo:GetNamedChild("_Level"),
            ["avaRankIcon"] = topInfo:GetNamedChild("_AvaRankIcon"),
            ["botInfo"] = botInfo,
            ["buffAnchor"] = buffAnchor,
            ["className"] = cn,
            ["title"] = botInfo:GetNamedChild("_Title"),
            ["avaRank"] = botInfo:GetNamedChild("_AvaRank"),
            ["dead"] = thb:GetNamedChild("_Dead"),
        }

        UnitFrames.CustomFrames["AvaPlayerTarget"].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
        UnitFrames.CustomFrames["AvaPlayerTarget"][COMBAT_MECHANIC_FLAGS_HEALTH].label.format = "Percentage%"
        UnitFrames.CustomFrames["AvaPlayerTarget"][COMBAT_MECHANIC_FLAGS_HEALTH].labelOne.format = "Current + Shield"
        UnitFrames.CustomFrames["AvaPlayerTarget"][COMBAT_MECHANIC_FLAGS_HEALTH].labelTwo.format = "Max"

        UnitFrames.AvaCustFrames["reticleover"] = UnitFrames.CustomFrames["AvaPlayerTarget"]
        UnitFrames.CustomFramesManager:CreateFrame("AvaPlayerTarget", UnitFrames.CustomFrames["AvaPlayerTarget"], "avaTarget", LUIE_CustomFrameVisualizers.SetupAvaTargetFrame)
    end
end

-- Helper to create the Small Group Frames


function LUIE_AvaTargetCustomFrameData:BuildStaticData()
    LUIE.CustomFramesBuildAvaTarget()
end
