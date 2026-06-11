-- -----------------------------------------------------------------------------
--  LuiExtended - Target / AvA target custom frame static controls
-- -----------------------------------------------------------------------------

--- @class LUIE_CustomFrameObject
local FrameObject = LUIE_CustomFrameObject

function FrameObject:UpdateTargetFrameStaticControls()
    FrameObject.UpdateStaticControlDifficultyStars(self)
    FrameObject.UpdateStaticControlClassIcon(self)
    FrameObject.UpdateStaticControlClassName(self)
    FrameObject.UpdateStaticControlFriendIcon(self)
    FrameObject.UpdateStaticControlReticleNameWidth(self)
    if self.name ~= nil then
        FrameObject.UpdateStaticControlNameLabel(self, "target")
    end
    FrameObject.UpdateStaticControlLevelRow(self)
    local savedTitle = FrameObject.UpdateStaticControlTitleAndAva(self)
    FrameObject.UpdateStaticControlReticleBuffAnchors(self, savedTitle)
    FrameObject.UpdateStaticControlDeadAndGroupAlpha(self)
end
