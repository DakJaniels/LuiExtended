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

--- Module for handling Possession (mind control) visual effects
--- @class LUIE_PossessionModule : LUIE_UnitAttributeVisualizerModuleBase
local PossessionModule = LUIE_UnitAttributeVisualizerModuleBase:Subclass()

function PossessionModule:IsRelevant(unitAttributeVisual, statType, attributeType, powerType)
    return unitAttributeVisual == ATTRIBUTE_VISUAL_POSSESSION
end

function PossessionModule:OnUnitChanged(unitTag)
    if not DoesUnitExist(unitTag) then
        return
    end

    -- Reinitialize possession visual for the new unit
    local value = self:GetInitialValueAndMarkMostRecent(ATTRIBUTE_VISUAL_POSSESSION, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH, unitTag)
    self:UpdatePossession(unitTag, value)
end

-- -----------------------------------------------------------------------------
-- Internal Implementation
-- -----------------------------------------------------------------------------

--- Updates possession overlay for given unit
--- @param unitTag string
--- @param value number
function PossessionModule:UpdatePossession(unitTag, value)
    if UnitFrames.savedHealth[unitTag] == nil then
        return
    end

    local isActive = value > 0

    -- Helper to setup/stop possession animations
    local function updatePossessionOverlay(healthBar)
        if not healthBar or not healthBar.possessionOverlay then return end

        local overlay = healthBar.possessionOverlay
        local halo = healthBar.possessionHalo
        local glowLeft = healthBar.possessionGlowLeft
        local glowRight = healthBar.possessionGlowRight
        local glowCenter = healthBar.possessionGlowCenter

        if isActive then
            overlay:SetHidden(false)

            -- Show and play halo animation (pre-created in CustomFrames build)
            if halo and halo.timeline then
                halo:SetHidden(false)
                if not halo.timeline:IsPlaying() then
                    halo.timeline:PlayFromStart()
                end
            end

            -- Fade in glow overlays
            if glowLeft and glowRight and glowCenter and not healthBar.glowFadeAnimation then
                local glowFadeAnim, glowFadeTimeline = CreateSimpleAnimation(ANIMATION_ALPHA, glowLeft)
                glowFadeAnim:SetAlphaValues(0, 1)
                glowFadeAnim:SetDuration(125)

                local fadeGlowRight = glowFadeTimeline:InsertAnimation(ANIMATION_ALPHA, glowRight, 0)
                --- @cast fadeGlowRight AnimationObjectAlpha
                fadeGlowRight:SetAlphaValues(0, 1)
                fadeGlowRight:SetDuration(125)
                local fadeGlowCenter = glowFadeTimeline:InsertAnimation(ANIMATION_ALPHA, glowCenter, 0)
                --- @cast fadeGlowCenter AnimationObjectAlpha
                fadeGlowCenter:SetAlphaValues(0, 1)
                fadeGlowCenter:SetDuration(125)

                healthBar.glowFadeAnimation = glowFadeTimeline
                glowLeft:SetHidden(false)
                glowRight:SetHidden(false)
                glowCenter:SetHidden(false)
            end

            if healthBar.glowFadeAnimation and not healthBar.glowFadeAnimation:IsPlaying() then
                healthBar.glowFadeAnimation:PlayForward()
            end
        else
            overlay:SetHidden(true)

            -- Stop and hide halo animation
            if halo and halo.timeline then
                halo.timeline:Stop()
                halo:SetHidden(true)
            end

            -- Fade out glow overlays
            if healthBar.glowFadeAnimation then
                healthBar.glowFadeAnimation:PlayBackward()
            end
            if glowLeft then glowLeft:SetHidden(true) end
            if glowRight then glowRight:SetHidden(true) end
            if glowCenter then glowCenter:SetHidden(true) end
        end
    end

    self:ForEachPowerEntry(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, function (healthBar)
        updatePossessionOverlay(healthBar)
    end)
end

-- -----------------------------------------------------------------------------
-- Event Handlers
-- -----------------------------------------------------------------------------

function PossessionModule:OnVisualizationAdded(unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
    self:UpdatePossession(unitTag, value)
end

function PossessionModule:OnVisualizationRemoved(unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
    self:UpdatePossession(unitTag, 0)
end

function PossessionModule:OnVisualizationUpdated(unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue, sequenceId)
    self:UpdatePossession(unitTag, newValue)
end

LUIE_PossessionModule = PossessionModule
UnitFrames.VisualizerModuleClasses.PossessionModule = PossessionModule
UnitFrames.VisualizerModules.PossessionModule = PossessionModule

return PossessionModule
