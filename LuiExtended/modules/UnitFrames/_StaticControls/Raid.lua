-- -----------------------------------------------------------------------------
--  LuiExtended - Raid custom frame static controls (compact name on health bar)
-- -----------------------------------------------------------------------------

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

--- @class LUIE_CustomFrameObject
local FrameObject = LUIE_CustomFrameObject

function FrameObject:UpdateRaidFrameStaticControls()
    FrameObject.UpdateStaticControlRoleIcon(self)
    FrameObject.UpdateStaticControlClassIcon(self)
    if self.name ~= nil then
        FrameObject.UpdateStaticControlNameLabel(self, "raid")
    end
    FrameObject.UpdateStaticControlDeadAndGroupAlpha(self)
    -- Expanded template: class/role/custom icon hidden state changed above; re-chain the top row anchors.
    -- Compact: shift the name past a visible custom portrait without changing the class/role inset.
    if self.raidTemplate == UnitFrames.RAID_FRAME_TEMPLATE_EXPANDED then
        UnitFrames.ApplyRaidExpandedMemberLayout(self)
    else
        UnitFrames.LayoutCompactRaidCustomIcon(self)
    end
end

return FrameObject
