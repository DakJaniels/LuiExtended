-- -----------------------------------------------------------------------------
--  LuiExtended - Target / AvA target custom frame static controls
-- -----------------------------------------------------------------------------

--- @class LUIE_CustomFrameObject
local FrameObject = LUIE_CustomFrameObject

function FrameObject:UpdateDefaultReticleoverStaticControls()
    FrameObject.UpdateStaticControlClassIcon(self)
    FrameObject.UpdateStaticControlFriendIcon(self)
    FrameObject.UpdateStaticControlDeadAndGroupAlpha(self)
end

function FrameObject:UpdateTargetFrameStaticControls()
    FrameObject.UpdateStaticControlDifficultyStars(self)
    FrameObject.UpdateStaticControlClassIcon(self)
    FrameObject.UpdateStaticControlClassName(self)
    FrameObject.UpdateStaticControlFriendIcon(self)
    FrameObject.UpdateStaticControlReticleNameWidth(self)
    FrameObject.UpdateTopInfoOverlandIcon(self)
    FrameObject.UpdateStaticControlNameLabel(self, "target")
    FrameObject.UpdateStaticControlLevelRow(self)
    local savedTitle = FrameObject.UpdateStaticControlTitleAndAva(self)
    if self.frameCategory == "avaTarget" then
        FrameObject.LayoutTopInfoAvaTarget(self)
    else
        FrameObject.LayoutTopInfoTarget(self)
    end
    FrameObject.UpdateStaticControlReticleBuffAnchors(self, savedTitle)
    FrameObject.UpdateStaticControlDeadAndGroupAlpha(self)
end
