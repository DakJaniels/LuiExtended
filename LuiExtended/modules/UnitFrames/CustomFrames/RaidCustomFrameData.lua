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

function LUIE.CustomFramesBuildRaidGroup()
    if UnitFrames.SV.CustomFramesRaid then
        -- Get references to XML-created controls
        local raid = CreateLUIETopLevel("LUIE_CustomRaidGroupFrame", "LUIE_UF_RaidGroupFrame_Template")
        CreateMemberRangeFromVirtual(raid, raid:GetName() .. "_RaidGroup", "LUIE_UF_RaidGroupMember_Template", 1, 12)
        ApplyStackedMemberAnchors(raid, "RaidGroup", 12)
        raid.customPositionAttr = "CustomFramesRaidFramePos"
        raid.preview = raid:GetNamedChild("_Preview")
        raid.previewLabel = raid.preview:GetNamedChild("_Label")

        for i = 1, 12 do
            local unitTag = "RaidGroup" .. i
            local control = raid:GetNamedChild("_" .. unitTag)
            local rhb = control:GetNamedChild("_Health")

            -- Create container for LibGroupBroadcast integrations (positioned to right of health bar)
            local libGroupContainer = control:GetNamedChild("_LibGroupContainer")

            -- Get resource bars from XML for LibGroupBroadcast integration
            local magBackdrop = control:GetNamedChild("_ResourceMagicka")
            local stamBackdrop = control:GetNamedChild("_ResourceStamina")

            -- Create combat glow animation
            local combatGlow = CreateCombatGlowBorder(rhb)

            UnitFrames.CustomFrames[unitTag] =
            {
                ["tlw"] = raid,
                ["control"] = control,
                [COMBAT_MECHANIC_FLAGS_HEALTH] =
                {
                    ["backdrop"] = rhb,
                    ["label"] = rhb:GetNamedChild("_Label"),
                    ["trauma"] = rhb:GetNamedChild("_Trauma"),
                    ["bar"] = rhb:GetNamedChild("_Bar"),
                    ["shield"] = rhb:GetNamedChild("_Shield"),
                    ["noHealingOverlay"] = rhb:GetNamedChild("_NoHealingOverlay"),
                    ["noHealingStripe"] = rhb:GetNamedChild("_NoHealingStripe"),
                    ["possessionOverlay"] = rhb:GetNamedChild("_PossessionOverlay"),
                    ["combatGlow"] = combatGlow,
                },
                ["name"] = rhb:GetNamedChild("_Name"),
                ["roleIcon"] = rhb:GetNamedChild("_RoleIcon"),
                ["classIcon"] = rhb:GetNamedChild("_ClassIcon"),
                ["dead"] = rhb:GetNamedChild("_Dead"),
                ["leader"] = rhb:GetNamedChild("_Leader"),
                ["libGroupContainer"] = libGroupContainer,
                ["resourceMagicka"] =
                {
                    ["backdrop"] = magBackdrop,
                    ["bar"] = magBackdrop:GetNamedChild("_Bar"),
                },
                ["resourceStamina"] =
                {
                    ["backdrop"] = stamBackdrop,
                    ["bar"] = stamBackdrop:GetNamedChild("_Bar"),
                },
            }
            UnitFrames.CustomFrames[unitTag].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)

            control.defaultUnitTag = GetGroupUnitTagByIndex(i)
            control:SetMouseEnabled(true)
            control:SetHandler("OnMouseUp", UnitFrames.GroupFrames_OnMouseUp)

            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].label.format = "Current (Percentage%)"

            local realUnitTag = GetGroupUnitTagByIndex(i)
            if realUnitTag then
                UnitFrames.CustomFrames[unitTag].visualizerUnitTag = realUnitTag
                UnitFrames.CustomFrames[realUnitTag] = UnitFrames.CustomFrames[unitTag]
            end
            UnitFrames.CustomFramesManager:CreateFrame(unitTag, UnitFrames.CustomFrames[unitTag], "raid", LUIE_CustomFrameVisualizers.SetupRaidFrame)
        end
    end
end

-- Helper to create the Pet Frames


function LUIE_RaidCustomFrameData:BuildStaticData()
    LUIE.CustomFramesBuildRaidGroup()
end
