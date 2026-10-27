-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
-- -----------------------------------------------------------------------------

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames
-- -----------------------------------------------------------------------------

--- Dedicated overlay for ATTRIBUTE_VISUAL_FORCE_ARMOR_SHRED.
--- The cracked decreased-armor control stays on ATTRIBUTE_VISUAL_DECREASED_STAT.
--- @class LUIE_ForceArmorShredModule : LUIE_UnitAttributeVisualizerModuleBase
local ForceArmorShredModule = LUIE_UnitAttributeVisualizerModuleBase:Subclass()

local ARMOR_STAT = STAT_ARMOR_RATING
local ARMOR_ATTRIBUTE = ATTRIBUTE_HEALTH
local ARMOR_POWER = COMBAT_MECHANIC_FLAGS_HEALTH

function ForceArmorShredModule:IsRelevant(unitAttributeVisual, statType, attributeType, powerType)
    return ATTRIBUTE_VISUAL_FORCE_ARMOR_SHRED ~= nil and unitAttributeVisual == ATTRIBUTE_VISUAL_FORCE_ARMOR_SHRED
end

function ForceArmorShredModule:OnUnitChanged(unitTag)
    if not DoesUnitExist(unitTag) or not ATTRIBUTE_VISUAL_FORCE_ARMOR_SHRED then
        return
    end

    self:GetInitialValueAndMarkMostRecent(ATTRIBUTE_VISUAL_FORCE_ARMOR_SHRED, ARMOR_STAT, ARMOR_ATTRIBUTE, ARMOR_POWER, unitTag)
    self:UpdateForceArmorShred(unitTag, ARMOR_STAT, ARMOR_ATTRIBUTE, ARMOR_POWER)
end

--- Shows the armor-rating glow when the force-shred value on the event tuple is non-zero.
--- @param unitTag string
--- @param statType DerivedStats
--- @param attributeType Attributes
--- @param powerType CombatMechanicFlags
function ForceArmorShredModule:UpdateForceArmorShred(unitTag, statType, attributeType, powerType)
    if not ATTRIBUTE_VISUAL_FORCE_ARMOR_SHRED then
        return
    end

    local forceValue = UnitFrames.GetAttributeVisualEffectValue(unitTag, ATTRIBUTE_VISUAL_FORCE_ARMOR_SHRED, statType, attributeType, powerType)
    local shouldHide = forceValue == 0

    self:ForEachUnitFrameTable(unitTag, function (frameTable)
        local healthEntry = frameTable[ARMOR_POWER]
        local armorStat = healthEntry and healthEntry.stat and healthEntry.stat[ARMOR_STAT]
        local shredControl = armorStat and armorStat.shred
        if shredControl then
            shredControl:SetHidden(shouldHide)
            if shredControl.smallTex then
                shredControl.smallTex:SetHidden(shouldHide)
            end
            if shredControl.normalTex then
                shredControl.normalTex:SetHidden(shouldHide)
            end
        end
    end)
end

function ForceArmorShredModule:OnVisualizationAdded(unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
    self:UpdateForceArmorShred(unitTag, statType, attributeType, powerType)
end

function ForceArmorShredModule:OnVisualizationRemoved(unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
    self:UpdateForceArmorShred(unitTag, statType, attributeType, powerType)
end

function ForceArmorShredModule:OnVisualizationUpdated(unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue, sequenceId)
    self:UpdateForceArmorShred(unitTag, statType, attributeType, powerType)
end

LUIE_ForceArmorShredModule = ForceArmorShredModule
UnitFrames.VisualizerModuleClasses.ForceArmorShredModule = ForceArmorShredModule
UnitFrames.VisualizerModules.ForceArmorShredModule = ForceArmorShredModule

return ForceArmorShredModule
