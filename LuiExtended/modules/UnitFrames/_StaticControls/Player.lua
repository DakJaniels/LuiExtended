-- -----------------------------------------------------------------------------
--  LuiExtended - Player custom frame static controls
-- -----------------------------------------------------------------------------

--- @class LUIE_CustomFrameObject
local FrameObject = LUIE_CustomFrameObject

function FrameObject:UpdatePlayerFrameStaticControls()
    FrameObject.UpdateStaticControlClassIcon(self)
    FrameObject.UpdateStaticControlFriendIcon(self)
    if self.name ~= nil then
        FrameObject.UpdateStaticControlNameLabel(self, "player")
    end
    FrameObject.UpdateStaticControlLevelRow(self)
    FrameObject.UpdateStaticControlTitleAndAva(self)
    FrameObject.UpdateStaticControlDeadAndGroupAlpha(self)
end
