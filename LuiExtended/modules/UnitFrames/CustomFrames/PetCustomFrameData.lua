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

function LUIE.CustomFramesBuildPet()
    if UnitFrames.SV.CustomFramesPet then
        -- Get references to XML-created controls
        local pet = CreateLUIETopLevel("LUIE_CustomPetFrame", "LUIE_UF_PetFrame_Template")
        CreateMemberRangeFromVirtual(pet, pet:GetName() .. "_PetGroup", "LUIE_UF_PetGroupMember_Template", 1, 7)
        ApplyStackedMemberAnchors(pet, "PetGroup", 7)
        pet.customPositionAttr = "CustomFramesPetFramePos"
        pet.preview = pet:GetNamedChild("_Preview")
        pet.previewLabel = pet.preview:GetNamedChild("_Label")

        for i = 1, 7 do
            local unitTag = "PetGroup" .. i
            local control = pet:GetNamedChild("_" .. unitTag)
            local shb = control:GetNamedChild("_Health")
            local combatGlow = CreateCombatGlowBorder(shb)

            UnitFrames.CustomFrames[unitTag] =
            {
                ["tlw"] = pet,
                ["control"] = control,
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
            UnitFrames.CustomFrames[unitTag].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].label.format = "Current (Percentage%)"
            UnitFrames.CustomFramesManager:CreateFrame(unitTag, UnitFrames.CustomFrames[unitTag], "pet", LUIE_CustomFrameVisualizers.SetupPetFrame)
        end
    end
end

function LUIE_PetCustomFrameData:BuildStaticData()
    LUIE.CustomFramesBuildPet()
end
