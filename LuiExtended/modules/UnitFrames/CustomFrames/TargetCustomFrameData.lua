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

function LUIE.CustomFramesBuildTarget()
    if UnitFrames.SV.CustomFramesTarget then
        -- Get references to XML-created controls
        local targetTlw = CreateLUIETopLevel("LUIE_CustomTargetFrame", "LUIE_UF_TargetFrame_Template")
        targetTlw.customPositionAttr = "CustomFramesTargetFramePos"
        targetTlw.preview = targetTlw:GetNamedChild("_Preview")
        targetTlw.previewLabel = targetTlw.preview:GetNamedChild("_Label")
        local target = targetTlw:GetNamedChild("_Target")
        local topInfo = target:GetNamedChild("_TopInfo")
        local botInfo = target:GetNamedChild("_BotInfo")
        local buffAnchor = target:GetNamedChild("_BuffAnchor")
        local thb = target:GetNamedChild("_Health")
        local tli = topInfo:GetNamedChild("_LevelIcon")
        local ari = botInfo:GetNamedChild("_AvaRankIcon")

        local buffs, debuffs
        if UnitFrames.SV.PlayerFrameOptions == 1 then
            buffs = targetTlw:GetNamedChild("_Buffs")
            debuffs = targetTlw:GetNamedChild("_Debuffs")
        else
            buffs = targetTlw:GetNamedChild("_Debuffs")
            debuffs = targetTlw:GetNamedChild("_Buffs")
        end

        UnitFrames.CustomFrames["reticleover"] =
        {
            ["unitTag"] = "reticleover",
            ["tlw"] = targetTlw,
            ["control"] = target,
            ["canHide"] = true,
            [COMBAT_MECHANIC_FLAGS_HEALTH] =
            {
                ["backdrop"] = thb,
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
            ["levelIcon"] = tli,
            ["veterancyRankIcon"] = topInfo:GetNamedChild("_VeterancyRankIcon"),
            ["overlandDifficultyIcon"] = topInfo:GetNamedChild("_OverlandDifficultyIcon"),
            ["level"] = topInfo:GetNamedChild("_Level"),
            ["classIcon"] = topInfo:GetNamedChild("_ClassIcon"),
            ["className"] = topInfo:GetNamedChild("_ClassName"),
            ["friendIcon"] = topInfo:GetNamedChild("_FriendIcon"),
            ["star1"] = topInfo:GetNamedChild("_Star1"),
            ["star2"] = topInfo:GetNamedChild("_Star2"),
            ["star3"] = topInfo:GetNamedChild("_Star3"),
            ["botInfo"] = botInfo,
            ["buffAnchor"] = buffAnchor,
            ["title"] = botInfo:GetNamedChild("_Title"),
            ["avaRankIcon"] = ari,
            ["avaRank"] = botInfo:GetNamedChild("_AvaRank"),
            ["dead"] = thb:GetNamedChild("_Dead"),
            ["skull"] = target:GetNamedChild("_Skull"),
            ["buffs"] = buffs,
            ["debuffs"] = debuffs,
        }
        UnitFrames.CustomFrames["reticleover"].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
        UnitFrames.CustomFrames["reticleover"].className:SetDrawLayer(DL_BACKGROUND)
        UnitFrames.CustomFramesManager:CreateFrame("reticleover", UnitFrames.CustomFrames["reticleover"], "target", LUIE_CustomFrameVisualizers.SetupTargetFrame)
    end
end

-- Helper to create the Ava Player Target Frame


function LUIE_TargetCustomFrameData:BuildStaticData()
    LUIE.CustomFramesBuildTarget()
end
