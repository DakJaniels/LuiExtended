-- -----------------------------------------------------------------------------
--  LuiExtended - Raid custom frame static controls (compact name on health bar)
-- -----------------------------------------------------------------------------

--- @class LUIE_CustomFrameObject
local FrameObject = LUIE_CustomFrameObject

function FrameObject:UpdateRaidFrameStaticControls()
    FrameObject.UpdateStaticControlRoleIcon(self)
    FrameObject.UpdateStaticControlClassIcon(self)
    if self.name ~= nil then
        FrameObject.UpdateStaticControlNameLabel(self, "raid")
    end
    FrameObject.UpdateStaticControlDeadAndGroupAlpha(self)
end
