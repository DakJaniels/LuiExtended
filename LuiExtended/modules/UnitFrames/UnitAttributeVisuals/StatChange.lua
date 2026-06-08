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

--- Module for handling increased/decreased stat visuals (armor debuffs, etc.)
--- @class LUIE_StatChangeModule : LUIE_UnitAttributeVisualizerModuleBase
local StatChangeModule = LUIE_UnitAttributeVisualizerModuleBase:Subclass()

function StatChangeModule:IsRelevant(unitAttributeVisual, statType, attributeType, powerType)
    return unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT or unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_STAT
end

function StatChangeModule:OnUnitChanged(unitTag)
    if not DoesUnitExist(unitTag) then
        return
    end

    -- Reinitialize stat change visuals for the new unit
    -- LUIE only tracks ARMOR_RATING and POWER stats, so we only need to initialize those
    local statsToCheck =
    {
        { stat = STAT_ARMOR_RATING, attr = ATTRIBUTE_HEALTH, power = COMBAT_MECHANIC_FLAGS_HEALTH },
        { stat = STAT_POWER,        attr = ATTRIBUTE_HEALTH, power = COMBAT_MECHANIC_FLAGS_HEALTH },
    }

    for _, statInfo in ipairs(statsToCheck) do
        -- Mark sequence IDs for both increase and decrease
        self:GetInitialValueAndMarkMostRecent(ATTRIBUTE_VISUAL_INCREASED_STAT, statInfo.stat, statInfo.attr, statInfo.power, unitTag)
        self:GetInitialValueAndMarkMostRecent(ATTRIBUTE_VISUAL_DECREASED_STAT, statInfo.stat, statInfo.attr, statInfo.power, unitTag)

        -- Update the stat overlay (will show/hide based on current effect state)
        self:UpdateStat(unitTag, statInfo.stat, statInfo.attr, statInfo.power)
    end
end

-- -----------------------------------------------------------------------------
-- Internal Implementation
-- -----------------------------------------------------------------------------

--- Updates stat change visuals (armor debuffs, etc.) for given unit
--- @param unitTag string
--- @param statType DerivedStats
--- @param attributeType Attributes
--- @param powerType CombatMechanicFlags
function StatChangeModule:UpdateStat(unitTag, statType, attributeType, powerType)
    local statControls = {}

    self:ForEachUnitFrameTable(unitTag, function (frameTable)
        if frameTable[powerType] and frameTable[powerType].stat and frameTable[powerType].stat[statType] then
            table.insert(statControls, frameTable[powerType].stat[statType])
        end
    end)

    if #statControls > 0 then
        local value = UnitFrames.GetAttributeVisualEffectValue(unitTag, ATTRIBUTE_VISUAL_INCREASED_STAT, statType, attributeType, powerType)
            + UnitFrames.GetAttributeVisualEffectValue(unitTag, ATTRIBUTE_VISUAL_DECREASED_STAT, statType, attributeType, powerType)

        for _, control in pairs(statControls) do
            -- Hide proper controls if they exist
            if control.dec then
                local shouldHide = value >= 0
                control.dec:SetHidden(shouldHide)
                -- Also unhide the textures inside the control
                if control.dec.smallTex then
                    control.dec.smallTex:SetHidden(shouldHide)
                end
                if control.dec.normalTex then
                    control.dec.normalTex:SetHidden(shouldHide)
                end
            end
            if control.inc and statType == STAT_POWER then
                local incValue = UnitFrames.GetAttributeVisualEffectValue(unitTag, ATTRIBUTE_VISUAL_INCREASED_STAT, statType, attributeType, powerType)
                local shouldHide = incValue <= 0
                control.inc:SetHidden(shouldHide)
                if control.inc.timeline then
                    if shouldHide then
                        control.inc.timeline:Stop()
                    elseif not control.inc.timeline:IsPlaying() then
                        control.inc.timeline:PlayFromStart()
                    end
                end
            elseif control.inc then
                control.inc:SetHidden(value <= 0)
            end
        end
    end
end

-- -----------------------------------------------------------------------------
-- Event Handlers
-- -----------------------------------------------------------------------------

function StatChangeModule:OnVisualizationAdded(unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
    self:UpdateStat(unitTag, statType, attributeType, powerType)
end

function StatChangeModule:OnVisualizationRemoved(unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
    self:UpdateStat(unitTag, statType, attributeType, powerType)
end

function StatChangeModule:OnVisualizationUpdated(unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue, sequenceId)
    self:UpdateStat(unitTag, statType, attributeType, powerType)
end

LUIE_StatChangeModule = StatChangeModule
UnitFrames.VisualizerModuleClasses.StatChangeModule = StatChangeModule
UnitFrames.VisualizerModules.StatChangeModule = StatChangeModule

return StatChangeModule
