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
local StatChangeModule = LUIE_UnitAttributeVisualizerModuleBase:New()

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
    -- Build a list of UI controls to hold this statType on different UnitFrames lists
    local statControls = {}

    if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag][powerType] and UnitFrames.CustomFrames[unitTag][powerType].stat and UnitFrames.CustomFrames[unitTag][powerType].stat[statType] then
        table.insert(statControls, UnitFrames.CustomFrames[unitTag][powerType].stat[statType])
    end
    if UnitFrames.AvaCustFrames[unitTag] and UnitFrames.AvaCustFrames[unitTag][powerType] and UnitFrames.AvaCustFrames[unitTag][powerType].stat and UnitFrames.AvaCustFrames[unitTag][powerType].stat[statType] then
        table.insert(statControls, UnitFrames.AvaCustFrames[unitTag][powerType].stat[statType])
    end

    -- If we have a control, proceed next
    if #statControls > 0 then
        local value = 0

        -- Get all attribute visualizer effects for this unit in one call
        local results = { GetAllUnitAttributeVisualizerEffectInfo(unitTag) }

        -- Process results in groups of 6 (visualType, statType, attributeType, powerType, value, maxValue)
        for i = 1, #results, 6 do
            local visualType = results[i]
            local retStatType = results[i + 1]
            local retAttributeType = results[i + 2]
            local retPowerType = results[i + 3]
            local retValue = results[i + 4]

            -- Filter for matching stat/attribute/power combination
            if retStatType == statType and retAttributeType == attributeType and retPowerType == powerType then
                if visualType == ATTRIBUTE_VISUAL_INCREASED_STAT or visualType == ATTRIBUTE_VISUAL_DECREASED_STAT then
                    value = value + retValue
                end
            end
        end

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
            if control.inc then
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

UnitFrames.VisualizerModules.StatChangeModule = StatChangeModule

return StatChangeModule
