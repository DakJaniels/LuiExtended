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

function LUIE.CustomFramesBuildBoss()
    if UnitFrames.SV.CustomFramesBosses then
        local bosses = CreateLUIETopLevel("LUIE_CustomBossFrame", "LUIE_UF_BossFrame_Template")
        CreateMemberRangeFromVirtual(bosses, bosses:GetName() .. "_boss", "LUIE_UF_BossMember_Template", BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END)
        ApplyStackedMemberAnchors(bosses, "boss", BOSS_RANK_ITERATION_END - BOSS_RANK_ITERATION_BEGIN + 1, BOSS_RANK_ITERATION_BEGIN)
        bosses.customPositionAttr = "CustomFramesBossesFramePos"
        bosses.preview = bosses:GetNamedChild("_Preview")
        bosses.previewLabel = bosses.preview:GetNamedChild("_Label")

        for i = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
            local unitTag = "boss" .. i
            local control = bosses:GetNamedChild("_" .. unitTag)
            local bhb = control:GetNamedChild("_Health")

            local thresholdContainer = bhb:GetNamedChild("_ThresholdContainer")

            UnitFrames.CustomFrames[unitTag] =
            {
                ["unitTag"] = unitTag,
                ["tlw"] = bosses,
                ["control"] = control,
                [COMBAT_MECHANIC_FLAGS_HEALTH] =
                {
                    ["backdrop"] = bhb,
                    ["label"] = bhb:GetNamedChild("_Label"),
                    ["trauma"] = bhb:GetNamedChild("_Trauma"),
                    ["bar"] = bhb:GetNamedChild("_Bar"),
                    ["invulnerable"] = bhb:GetNamedChild("_Invulnerable"),
                    ["invulnerableInlay"] = bhb:GetNamedChild("_InvulnerableInlay"),
                    ["shield"] = bhb:GetNamedChild("_Shield"),
                    ["noHealingOverlay"] = bhb:GetNamedChild("_NoHealingOverlay"),
                    ["noHealingStripe"] = bhb:GetNamedChild("_NoHealingStripe"),
                    ["possessionOverlay"] = bhb:GetNamedChild("_PossessionOverlay"),
                    ["thresholdContainer"] = thresholdContainer,
                    ["thresholdMarkers"] = {},
                    ["threshold"] = UnitFrames.targetThreshold,
                },
                ["dead"] = bhb:GetNamedChild("_Dead"),
                ["name"] = bhb:GetNamedChild("_Name"),
            }
            UnitFrames.CustomFrames[unitTag].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].label.format = "Percentage%"
            UnitFrames.CustomFramesManager:CreateFrame(unitTag, UnitFrames.CustomFrames[unitTag], "boss", LUIE_CustomFrameVisualizers.SetupBossFrame)
        end
    end
end

function LUIE_BossCustomFrameData:BuildStaticData()
    LUIE.CustomFramesBuildBoss()
end
