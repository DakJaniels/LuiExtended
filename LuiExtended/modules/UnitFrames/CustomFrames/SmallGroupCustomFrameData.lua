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

function LUIE.CustomFramesBuildSmallGroup()
    if UnitFrames.SV.CustomFramesGroup then
        -- Get references to XML-created controls
        local group = CreateLUIETopLevel("LUIE_CustomSmallGroupFrame", "LUIE_UF_SmallGroupFrame_Template")
        CreateMemberRangeFromVirtual(group, group:GetName() .. "_SmallGroup", "LUIE_UF_SmallGroupMember_Template", 1, 4)
        ApplyStackedMemberAnchors(group, "SmallGroup", 4)
        group.customPositionAttr = "CustomFramesGroupFramePos"
        group.preview = group:GetNamedChild("_Preview")
        group.previewLabel = group.preview:GetNamedChild("_Label")

        for i = 1, 4 do
            local unitTag = "SmallGroup" .. i
            local control = group:GetNamedChild("_" .. unitTag)
            local topInfo = control:GetNamedChild("_TopInfo")
            local ghb = control:GetNamedChild("_Health")
            local gli = topInfo:GetNamedChild("_LevelIcon")

            -- Get container for LibGroupBroadcast integrations (positioned to right of health bar)
            local libGroupContainer = control:GetNamedChild("_LibGroupContainer")
            if not libGroupContainer then
                if LUIE.IsDevDebugEnabled() then
                    LUIE:Log("Error", "[LUIE] CreateSmallGroupFrames: Failed to get _LibGroupContainer for " .. unitTag)
                end
            end

            -- Create combat glow animation
            local combatGlow = CreateCombatGlowBorder(ghb)

            UnitFrames.CustomFrames[unitTag] =
            {
                ["tlw"] = group,
                ["control"] = control,
                [COMBAT_MECHANIC_FLAGS_HEALTH] =
                {
                    ["backdrop"] = ghb,
                    ["labelOne"] = ghb:GetNamedChild("_LabelOne"),
                    ["labelTwo"] = ghb:GetNamedChild("_LabelTwo"),
                    ["trauma"] = ghb:GetNamedChild("_Trauma"),
                    ["bar"] = ghb:GetNamedChild("_Bar"),
                    ["shield"] = ghb:GetNamedChild("_Shield"),
                    ["noHealingOverlay"] = ghb:GetNamedChild("_NoHealingOverlay"),
                    ["noHealingStripe"] = ghb:GetNamedChild("_NoHealingStripe"),
                    ["possessionOverlay"] = ghb:GetNamedChild("_PossessionOverlay"),
                    ["combatGlow"] = combatGlow,
                },
                ["topInfo"] = topInfo,
                ["name"] = topInfo:GetNamedChild("_Name"),
                ["levelIcon"] = gli,
                ["veterancyRankIcon"] = topInfo:GetNamedChild("_VeterancyRankIcon"),
                ["overlandDifficultyIcon"] = topInfo:GetNamedChild("_OverlandDifficultyIcon"),
                ["level"] = topInfo:GetNamedChild("_Level"),
                ["classIcon"] = topInfo:GetNamedChild("_ClassIcon"),
                ["friendIcon"] = topInfo:GetNamedChild("_FriendIcon"),
                ["roleIcon"] = ghb:GetNamedChild("_RoleIcon"),
                ["dead"] = ghb:GetNamedChild("_Dead"),
                ["leader"] = topInfo:GetNamedChild("_Leader"),
                ["libGroupContainer"] = libGroupContainer,
                ["resourceMagicka"] =
                {
                    ["backdrop"] = control:GetNamedChild("_ResourceMagicka"),
                    ["bar"] = control:GetNamedChild("_ResourceMagicka"):GetNamedChild("_Bar"),
                },
                ["resourceStamina"] =
                {
                    ["backdrop"] = control:GetNamedChild("_ResourceStamina"),
                    ["bar"] = control:GetNamedChild("_ResourceStamina"):GetNamedChild("_Bar"),
                },
            }

            UnitFrames.CustomFrames[unitTag].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
            control.defaultUnitTag = GetGroupUnitTagByIndex(i)
            control:SetMouseEnabled(true)
            control:SetHandler("OnMouseUp", UnitFrames.GroupFrames_OnMouseUp)
            topInfo.defaultUnitTag = GetGroupUnitTagByIndex(i)
            topInfo:SetMouseEnabled(true)
            topInfo:SetHandler("OnMouseUp", UnitFrames.GroupFrames_OnMouseUp)

            local realUnitTag = GetGroupUnitTagByIndex(i)
            if realUnitTag then
                UnitFrames.CustomFrames[unitTag].visualizerUnitTag = realUnitTag
                UnitFrames.CustomFrames[realUnitTag] = UnitFrames.CustomFrames[unitTag]
            end
            UnitFrames.CustomFramesManager:CreateFrame(unitTag, UnitFrames.CustomFrames[unitTag], "smallGroup", LUIE_CustomFrameVisualizers.SetupGroupFrame)
        end
    end
end

-- Helper to create the Raid Group Frames


function LUIE_SmallGroupCustomFrameData:BuildStaticData()
    LUIE.CustomFramesBuildSmallGroup()
end
