-- -----------------------------------------------------------------------------
--  LuiExtended - Small group custom frame static controls
-- -----------------------------------------------------------------------------

--- @class LUIE_CustomFrameObject
local FrameObject = LUIE_CustomFrameObject

function FrameObject:UpdateGroupFrameStaticControls()
    FrameObject.UpdateStaticControlRoleIcon(self)
    FrameObject.UpdateStaticControlClassIcon(self)
    if self.name ~= nil then
        FrameObject.UpdateStaticControlNameLabel(self, "group")
    end
    FrameObject.UpdateStaticControlLevelRow(self)
    FrameObject.UpdateStaticControlDeadAndGroupAlpha(self)
end
