-- -----------------------------------------------------------------------------
--  LuiExtended - Boss, pet, companion, default extenders, uncategorized frames
-- -----------------------------------------------------------------------------

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

--- @class LUIE_CustomFrameObject
local FrameObject = LUIE_CustomFrameObject

function FrameObject:UpdateGenericFrameStaticControls()
    FrameObject.UpdateStaticControlRoleIcon(self)
    FrameObject.UpdateStaticControlDifficultyStars(self)
    FrameObject.UpdateStaticControlClassIcon(self)
    FrameObject.UpdateStaticControlClassName(self)
    FrameObject.UpdateStaticControlFriendIcon(self)
    FrameObject.UpdateStaticControlReticleNameWidth(self)
    if self.name ~= nil then
        FrameObject.UpdateStaticControlNameLabel(self, nil)
    end
    FrameObject.UpdateStaticControlLevelRow(self)
    local savedTitle = FrameObject.UpdateStaticControlTitleAndAva(self)
    FrameObject.UpdateStaticControlReticleBuffAnchors(self, savedTitle)
    FrameObject.UpdateStaticControlDeadAndGroupAlpha(self)
end

function FrameObject:UpdateStaticControls()
    FrameObject.ApplyStaticControlUnitFields(self)
    local frameCategory = self.frameCategory
    if frameCategory == "smallGroup" then
        FrameObject.UpdateGroupFrameStaticControls(self)
    elseif frameCategory == "player" then
        FrameObject.UpdatePlayerFrameStaticControls(self)
    elseif frameCategory == "target" or frameCategory == "avaTarget" then
        FrameObject.UpdateTargetFrameStaticControls(self)
    elseif frameCategory == "raid" then
        FrameObject.UpdateRaidFrameStaticControls(self)
    else
        local category = FrameObject.GetStaticControlDisplayCategory(self)
        if category == "target" and self.unitTag == "reticleover" then
            FrameObject.UpdateDefaultReticleoverStaticControls(self)
        elseif category == "group" then
            FrameObject.UpdateGroupFrameStaticControls(self)
        elseif category == "raid" then
            FrameObject.UpdateRaidFrameStaticControls(self)
        else
            FrameObject.UpdateGenericFrameStaticControls(self)
        end
    end
end

--- Entry for default extenders and call sites that hold a plain frame table.
--- @param unitFrame LUIE_CustomFrameObject|table|nil
function UnitFrames.UpdateStaticControls(unitFrame)
    if unitFrame == nil then
        return
    end
    FrameObject.UpdateStaticControls(unitFrame)
end
