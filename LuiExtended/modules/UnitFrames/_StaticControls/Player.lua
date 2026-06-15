-- -----------------------------------------------------------------------------
--  LuiExtended - Player custom frame static controls
-- -----------------------------------------------------------------------------

--- @class LUIE_CustomFrameObject
local FrameObject = LUIE_CustomFrameObject

function FrameObject:UpdatePlayerFrameStaticControls()
    FrameObject.UpdateStaticControlClassIcon(self)
    FrameObject.UpdateStaticControlFriendIcon(self)
    FrameObject.UpdateTopInfoOverlandIcon(self)
    FrameObject.UpdateStaticControlNameLabel(self, "player")
    FrameObject.UpdateStaticControlLevelRow(self)
    FrameObject.LayoutTopInfoPlayer(self)
    FrameObject.UpdateStaticControlTitleAndAva(self)
    FrameObject.UpdateStaticControlDeadAndGroupAlpha(self)
end
