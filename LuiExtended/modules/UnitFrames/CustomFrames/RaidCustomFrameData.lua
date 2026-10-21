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

local RAID_MEMBER_TEMPLATE_COMPACT = "LUIE_UF_RaidGroupMember_Template"
local RAID_MEMBER_TEMPLATE_EXPANDED = "LUIE_UF_RaidGroupMemberExpanded_Template"

--- Compact template: name/icons/status share the health bar; LibGroup container and resource bars are siblings of _Health.
--- @param control Control
--- @param rhb Control
--- @return table frameFields
local function CollectCompactRaidMemberControls(control, rhb)
    local magBackdrop = control:GetNamedChild("_ResourceMagicka")
    local stamBackdrop = control:GetNamedChild("_ResourceStamina")
    return
    {
        ["label"] = rhb:GetNamedChild("_Label"),
        ["name"] = rhb:GetNamedChild("_Name"),
        ["roleIcon"] = rhb:GetNamedChild("_RoleIcon"),
        ["classIcon"] = rhb:GetNamedChild("_ClassIcon"),
        ["dead"] = rhb:GetNamedChild("_Dead"),
        ["leader"] = rhb:GetNamedChild("_Leader"),
        ["libGroupContainer"] = control:GetNamedChild("_LibGroupContainer"),
        ["magBackdrop"] = magBackdrop,
        ["stamBackdrop"] = stamBackdrop,
    }
end

--- Expanded template (see RaidFrames.xml): _Frame is the padded container, _TopRow / _BottomRow sit on it and
--- _Health is the health band between them. Row children are named $(grandparent)_* so they resolve from the
--- member control; the health text (_Label / _Dead) stays on the health band like the compact template.
--- @param control Control
--- @param rhb Control
--- @return table frameFields
local function CollectExpandedRaidMemberControls(control, rhb)
    local topRow = control:GetNamedChild("_TopRow")
    local bottomRow = control:GetNamedChild("_BottomRow")
    return
    {
        ["label"] = rhb:GetNamedChild("_Label"),
        ["name"] = control:GetNamedChild("_Name"),
        ["roleIcon"] = control:GetNamedChild("_RoleIcon"),
        ["classIcon"] = control:GetNamedChild("_ClassIcon"),
        ["dead"] = rhb:GetNamedChild("_Dead"),
        ["leader"] = control:GetNamedChild("_Leader"),
        ["libGroupContainer"] = control:GetNamedChild("_LibGroupContainer"),
        ["magBackdrop"] = control:GetNamedChild("_ResourceMagicka"),
        ["stamBackdrop"] = control:GetNamedChild("_ResourceStamina"),
        ["frameBackdrop"] = control:GetNamedChild("_Frame"),
        ["topRow"] = topRow,
        ["bottomRow"] = bottomRow,
        ["resourceContainer"] = bottomRow:GetNamedChild("_ResourceContainer"),
        ["statsBorder"] = bottomRow:GetNamedChild("_StatsBorder"),
        ["statsLabel"] = control:GetNamedChild("_StatsLabel"),
    }
end

function LUIE.CustomFramesBuildRaidGroup()
    if UnitFrames.SV.CustomFramesRaid then
        local useExpandedTemplate = UnitFrames.IsRaidExpandedTemplate()
        local memberTemplateName = useExpandedTemplate and RAID_MEMBER_TEMPLATE_EXPANDED or RAID_MEMBER_TEMPLATE_COMPACT

        -- Get references to XML-created controls
        local raid = CreateLUIETopLevel("LUIE_CustomRaidGroupFrame", "LUIE_UF_RaidGroupFrame_Template")
        CreateMemberRangeFromVirtual(raid, raid:GetName() .. "_RaidGroup", memberTemplateName, 1, 12)
        ApplyStackedMemberAnchors(raid, "RaidGroup", 12)
        raid.customPositionAttr = "CustomFramesRaidFramePos"
        raid.preview = raid:GetNamedChild("_Preview")
        raid.previewLabel = raid.preview:GetNamedChild("_Label")

        for i = 1, 12 do
            local unitTag = "RaidGroup" .. i
            local control = raid:GetNamedChild("_" .. unitTag)
            local rhb = control:GetNamedChild("_Health")

            local memberControls
            if useExpandedTemplate then
                memberControls = CollectExpandedRaidMemberControls(control, rhb)
            else
                memberControls = CollectCompactRaidMemberControls(control, rhb)
            end

            -- Create combat glow animation (expanded: around the whole frame container, not just the health band)
            local combatGlow = CreateCombatGlowBorder(memberControls.frameBackdrop or rhb)

            UnitFrames.CustomFrames[unitTag] =
            {
                ["tlw"] = raid,
                ["control"] = control,
                [COMBAT_MECHANIC_FLAGS_HEALTH] =
                {
                    ["backdrop"] = rhb,
                    ["label"] = memberControls.label,
                    ["trauma"] = rhb:GetNamedChild("_Trauma"),
                    ["bar"] = rhb:GetNamedChild("_Bar"),
                    ["shield"] = rhb:GetNamedChild("_Shield"),
                    ["noHealingOverlay"] = rhb:GetNamedChild("_NoHealingOverlay"),
                    ["noHealingStripe"] = rhb:GetNamedChild("_NoHealingStripe"),
                    ["possessionOverlay"] = rhb:GetNamedChild("_PossessionOverlay"),
                    ["combatGlow"] = combatGlow,
                },
                ["name"] = memberControls.name,
                ["roleIcon"] = memberControls.roleIcon,
                ["classIcon"] = memberControls.classIcon,
                ["dead"] = memberControls.dead,
                ["leader"] = memberControls.leader,
                ["libGroupContainer"] = memberControls.libGroupContainer,
                ["resourceMagicka"] =
                {
                    ["backdrop"] = memberControls.magBackdrop,
                    ["bar"] = memberControls.magBackdrop:GetNamedChild("_Bar"),
                },
                ["resourceStamina"] =
                {
                    ["backdrop"] = memberControls.stamBackdrop,
                    ["bar"] = memberControls.stamBackdrop:GetNamedChild("_Bar"),
                },
            }

            if useExpandedTemplate then
                local frameData = UnitFrames.CustomFrames[unitTag]
                frameData.raidTemplate = UnitFrames.RAID_FRAME_TEMPLATE_EXPANDED
                frameData.frameBackdrop = memberControls.frameBackdrop
                frameData.topRow = memberControls.topRow
                frameData.bottomRow = memberControls.bottomRow
                frameData.resourceContainer = memberControls.resourceContainer
                frameData.statsBorder = memberControls.statsBorder
                frameData.statsLabel = memberControls.statsLabel
            end

            UnitFrames.CustomFrames[unitTag].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
            UnitFrames.CustomFrames[unitTag].name:SetMaxLineCount(1)

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
