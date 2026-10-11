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
    -- Expanded template: class/role icon hidden state changed above; re-chain the top row anchors (no-op for Compact).
    UnitFrames.ApplyRaidExpandedMemberLayout(self)
end

return FrameObject
