-- -----------------------------------------------------------------------------
--  LuiExtended - Small group custom frame static controls
-- -----------------------------------------------------------------------------

--- @class LUIE_CustomFrameObject
local FrameObject = LUIE_CustomFrameObject

function FrameObject:UpdateGroupFrameStaticControls()
    FrameObject.UpdateStaticControlRoleIcon(self)
    FrameObject.UpdateStaticControlClassIcon(self)
    if self.friendIcon then
        self.friendIcon:SetHidden(true)
    end
    if FrameObject.HasCustomTopInfoFrameCategory(self) then
        FrameObject.UpdateTopInfoOverlandIcon(self)
        FrameObject.UpdateStaticControlNameLabel(self, "group")
        FrameObject.UpdateStaticControlLevelRow(self)
        FrameObject.LayoutTopInfoSmallGroup(self)
    end
    FrameObject.UpdateStaticControlDeadAndGroupAlpha(self)
end
