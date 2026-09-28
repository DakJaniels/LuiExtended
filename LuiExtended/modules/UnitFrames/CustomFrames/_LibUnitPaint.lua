-- -----------------------------------------------------------------------------
-- LuiExtended - Custom frames paint from LibUnitFramework elements.
-- -----------------------------------------------------------------------------

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

local LIB_UNIT_ELEMENT_NAMES = {
    "Health",
    "Power",
    "Name",
    "AttributeVisual",
    "Class",
    "Level",
    "ChampionPoints",
    "Role",
    "Death",
    "Online",
    "Leader",
    "SupportRange",
    "Reaction",
    "UnitType",
    "Race",
    "Group",
}

local LIB_UNIT_CATEGORIES = {
    player = true,
    target = true,
    companion = true,
    smallGroup = true,
    raid = true,
    boss = true,
}

local SMOOTH_BAR_MS = 250

local function FormatPowerNumber(value)
    return tostring(LUIE.AbbreviateNumber(value, UnitFrames.SV.ShortenNumbers or false, true))
end

local function GetVisualRecordValue(attributeVisualElement, visualType, statType, attributeType, powerType)
    local visualsByStat = attributeVisualElement.visuals and attributeVisualElement.visuals[visualType]
    local visualsByAttribute = visualsByStat and visualsByStat[statType]
    local visualsByPower = visualsByAttribute and visualsByAttribute[attributeType]
    local record = visualsByPower and visualsByPower[powerType]
    if record and record.isActive and record.value then
        return record.value
    end
    return 0
end

local function GetActiveVisualValue(attributeVisualElement, visualType, powerType)
    if not attributeVisualElement or not attributeVisualElement.visuals then
        return 0
    end
    local visualsByStat = attributeVisualElement.visuals[visualType]
    if not visualsByStat then
        return 0
    end
    local totalValue = 0
    for _, visualsByAttribute in pairs(visualsByStat) do
        for _, visualsByPower in pairs(visualsByAttribute) do
            local record = visualsByPower[powerType]
            if record and record.isActive and record.value then
                totalValue = totalValue + record.value
            end
        end
    end
    return totalValue
end

local function DisplayRegen(regenControl, isShown)
    if regenControl == nil then
        return
    end
    regenControl:SetHidden(not isShown)
    if isShown then
        if regenControl.animation and regenControl.animation:IsPlaying() then
            return
        end
        if regenControl.timeline then
            regenControl.timeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
            regenControl.timeline:PlayFromStart()
        end
    elseif regenControl.timeline then
        regenControl.timeline:SetPlaybackLoopsRemaining(0)
    end
end

function LUIE_CustomFrameData_Base:UsesLibUnitFramework()
    return LIB_UNIT_CATEGORIES[self.frameCategory] == true
end

function LUIE_CustomFrameData_Base:UnbindLibUnit()
    local unit = self.libUnit
    local callback = self.libUnitCallback
    if unit and callback then
        for elementIndex = 1, #LIB_UNIT_ELEMENT_NAMES do
            local element = unit:GetElement(LIB_UNIT_ELEMENT_NAMES[elementIndex])
            if element then
                element:UnregisterCallback(LUF.CALLBACK_UPDATED, callback)
            end
        end
        unit:Disable()
    end
    self.libUnit = nil
    self.libUnitTag = nil
    self.libUnitCallback = nil
    self.libUnitHasShownPower = nil
end

function LUIE_CustomFrameData_Base:BindLibUnit(unitTag)
    if not self:UsesLibUnitFramework() or not unitTag or unitTag == "" then
        return
    end
    if self.libUnit and self.libUnitTag == unitTag then
        self.libUnit:RefreshEnabledElements()
        return
    end

    self:UnbindLibUnit()

    local unit = LUF:GetUnit(unitTag) or LUF:CreateUnit(unitTag)
    local frame = self

    local function OnElementUpdated(element)
        local elementName = element.elementName
        if elementName == "Health" or elementName == "Power" or elementName == "AttributeVisual" then
            frame:ApplyLibUnitResources()
        else
            frame:UpdateStaticControls()
        end
        if frame.unitTag == "reticleover" and (elementName == "Reaction" or elementName == "UnitType" or elementName == "Health" or elementName == "Death") then
            frame:ApplyLibUnitTargetChrome()
        end
    end

    for elementIndex = 1, #LIB_UNIT_ELEMENT_NAMES do
        local element = unit:RegisterElement(LIB_UNIT_ELEMENT_NAMES[elementIndex])
        if element then
            element:RegisterCallback(LUF.CALLBACK_UPDATED, OnElementUpdated)
        end
    end

    self.libUnit = unit
    self.libUnitTag = unitTag
    self.libUnitCallback = OnElementUpdated
    self.unitTag = unitTag
    unit:Enable()
end

local function ApplyStatusValue(statusBar, value, maximum, smooth, forceInit)
    if not statusBar then
        return
    end
    if smooth then
        ZO_StatusBar_SmoothTransition(statusBar, value, maximum, forceInit, nil, SMOOTH_BAR_MS)
    else
        statusBar:SetMinMax(0, maximum)
        statusBar:SetValue(value)
    end
end

local function ApplyRegenForPower(powerEntry, attributeVisualElement, powerType, increasedStat, decreasedStat, attributeType)
    local increasedValue = GetVisualRecordValue(attributeVisualElement, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, increasedStat, attributeType, powerType)
    local decreasedValue = GetVisualRecordValue(attributeVisualElement, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, decreasedStat, attributeType, powerType)
    if increasedValue < 0 then
        increasedValue = 1
    end
    if decreasedValue > 0 then
        decreasedValue = -1
    end
    local regenValue = increasedValue + decreasedValue
    DisplayRegen(powerEntry.regen1, regenValue > 0)
    DisplayRegen(powerEntry.regen2, regenValue > 0)
    DisplayRegen(powerEntry.degen1, regenValue < 0)
    DisplayRegen(powerEntry.degen2, regenValue < 0)
end

local function ApplyStatChange(healthEntry, attributeVisualElement)
    if not healthEntry.stat then
        return
    end
    local statRows = {
        { statType = STAT_ARMOR_RATING, attributeType = ATTRIBUTE_HEALTH },
        { statType = STAT_POWER, attributeType = ATTRIBUTE_HEALTH },
    }
    for rowIndex = 1, #statRows do
        local statType = statRows[rowIndex].statType
        local attributeType = statRows[rowIndex].attributeType
        local control = healthEntry.stat[statType]
        if control then
            local increasedValue = GetVisualRecordValue(attributeVisualElement, ATTRIBUTE_VISUAL_INCREASED_STAT, statType, attributeType, COMBAT_MECHANIC_FLAGS_HEALTH)
            local decreasedValue = GetVisualRecordValue(attributeVisualElement, ATTRIBUTE_VISUAL_DECREASED_STAT, statType, attributeType, COMBAT_MECHANIC_FLAGS_HEALTH)
            local combinedValue = increasedValue + decreasedValue
            if control.dec then
                local hideDecreased = combinedValue >= 0
                control.dec:SetHidden(hideDecreased)
                if control.dec.smallTex then
                    control.dec.smallTex:SetHidden(hideDecreased)
                end
                if control.dec.normalTex then
                    control.dec.normalTex:SetHidden(hideDecreased)
                end
            end
            if control.inc and statType == STAT_POWER then
                local hideIncreased = increasedValue <= 0
                control.inc:SetHidden(hideIncreased)
                if control.inc.timeline then
                    if hideIncreased then
                        control.inc.timeline:Stop()
                    elseif not control.inc.timeline:IsPlaying() then
                        control.inc.timeline:PlayFromStart()
                    end
                end
            elseif control.inc then
                control.inc:SetHidden(combinedValue <= 0)
            end
        end
    end
end

local function ApplyPossession(healthEntry, isActive)
    local overlay = healthEntry.possessionOverlay
    if not overlay then
        return
    end
    local halo = healthEntry.possessionHalo
    local glowLeft = healthEntry.possessionGlowLeft
    local glowRight = healthEntry.possessionGlowRight
    local glowCenter = healthEntry.possessionGlowCenter
    if isActive then
        overlay:SetHidden(false)
        if halo and halo.timeline then
            halo:SetHidden(false)
            if not halo.timeline:IsPlaying() then
                halo.timeline:PlayFromStart()
            end
        end
        if glowLeft and glowRight and glowCenter and not healthEntry.glowFadeAnimation then
            local glowFadeAnimation, glowFadeTimeline = CreateSimpleAnimation(ANIMATION_ALPHA, glowLeft)
            glowFadeAnimation:SetAlphaValues(0, 1)
            glowFadeAnimation:SetDuration(125)
            local fadeGlowRight = glowFadeTimeline:InsertAnimation(ANIMATION_ALPHA, glowRight, 0)
            fadeGlowRight:SetAlphaValues(0, 1)
            fadeGlowRight:SetDuration(125)
            local fadeGlowCenter = glowFadeTimeline:InsertAnimation(ANIMATION_ALPHA, glowCenter, 0)
            fadeGlowCenter:SetAlphaValues(0, 1)
            fadeGlowCenter:SetDuration(125)
            healthEntry.glowFadeAnimation = glowFadeTimeline
            glowLeft:SetHidden(false)
            glowRight:SetHidden(false)
            glowCenter:SetHidden(false)
        end
        if healthEntry.glowFadeAnimation and not healthEntry.glowFadeAnimation:IsPlaying() then
            healthEntry.glowFadeAnimation:PlayForward()
        end
    else
        overlay:SetHidden(true)
        if halo and halo.timeline then
            halo.timeline:Stop()
            halo:SetHidden(true)
        end
        if healthEntry.glowFadeAnimation then
            healthEntry.glowFadeAnimation:PlayBackward()
        end
        if glowLeft then
            glowLeft:SetHidden(true)
        end
        if glowRight then
            glowRight:SetHidden(true)
        end
        if glowCenter then
            glowCenter:SetHidden(true)
        end
    end
end

local function ApplyNoHealing(healthEntry, isActive, powerValue, powerEffectiveMax, smooth, forceInit)
    local overlay = healthEntry.noHealingOverlay
    if not overlay then
        return
    end
    local stripe = healthEntry.noHealingStripe
    local fadeAnimation = healthEntry.noHealingFadeAnimation
    if isActive then
        overlay:SetHidden(false)
        if stripe then
            stripe:SetHidden(false)
        end
        if fadeAnimation and not fadeAnimation:IsPlaying() then
            fadeAnimation:PlayForward()
        end
        ApplyStatusValue(overlay, powerValue, powerEffectiveMax, smooth, forceInit)
        ApplyStatusValue(stripe, powerValue, powerEffectiveMax, smooth, forceInit)
    elseif fadeAnimation then
        fadeAnimation:PlayBackward()
    else
        overlay:SetValue(0)
        overlay:SetHidden(true)
        if stripe then
            stripe:SetValue(0)
            stripe:SetHidden(true)
        end
    end
end

function LUIE_CustomFrameData_Base:ApplyLibUnitResources()
    local unit = self.libUnit
    if not unit then
        return
    end
    local healthElement = unit:GetElement("Health")
    local powerElement = unit:GetElement("Power")
    local attributeVisualElement = unit:GetElement("AttributeVisual")
    local nameElement = unit:GetElement("Name")
    local isPendingSummon = nameElement and nameElement.isPendingSummon and not nameElement.unitName
    local smooth = UnitFrames.SV.CustomSmoothBar
    local shieldValue = attributeVisualElement and GetActiveVisualValue(attributeVisualElement, ATTRIBUTE_VISUAL_POWER_SHIELDING, COMBAT_MECHANIC_FLAGS_HEALTH) or 0
    local traumaValue = attributeVisualElement and GetActiveVisualValue(attributeVisualElement, ATTRIBUTE_VISUAL_TRAUMA, COMBAT_MECHANIC_FLAGS_HEALTH) or 0
    local noHealingValue = attributeVisualElement and GetActiveVisualValue(attributeVisualElement, ATTRIBUTE_VISUAL_NO_HEALING, COMBAT_MECHANIC_FLAGS_HEALTH) or 0
    local unwaveringValue = attributeVisualElement and GetVisualRecordValue(attributeVisualElement, ATTRIBUTE_VISUAL_UNWAVERING_POWER, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH) or 0
    local possessionValue = attributeVisualElement and GetVisualRecordValue(attributeVisualElement, ATTRIBUTE_VISUAL_POSSESSION, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH) or 0

    local healthEntry = self[COMBAT_MECHANIC_FLAGS_HEALTH]
    if healthEntry and attributeVisualElement then
        ApplyStatChange(healthEntry, attributeVisualElement)
        ApplyPossession(healthEntry, possessionValue > 0)
    end

    for powerType, powerEntry in pairs(self) do
        if type(powerType) == "number" and type(powerEntry) == "table" and powerEntry.bar then
            local powerValue, powerMax, powerEffectiveMax
            if powerType == COMBAT_MECHANIC_FLAGS_HEALTH and healthElement then
                powerValue = healthElement.powerValue
                powerMax = healthElement.powerMax
                powerEffectiveMax = healthElement.powerEffectiveMax
            elseif powerElement and powerElement.pools then
                local pool = powerElement.pools[powerType]
                if pool then
                    powerValue = pool.powerValue
                    powerMax = pool.powerMax
                    powerEffectiveMax = pool.powerEffectiveMax
                end
            end

            local hideBar = isPendingSummon or not powerEffectiveMax or powerEffectiveMax <= 0 or powerValue == nil
            if hideBar then
                powerEntry.bar:SetHidden(true)
                if powerEntry.shield then
                    powerEntry.shield:SetValue(0)
                    powerEntry.shield:SetHidden(true)
                end
                if powerEntry.trauma then
                    powerEntry.trauma:SetValue(0)
                    powerEntry.trauma:SetHidden(true)
                end
            else
                local isGuard = self.unitTag == "reticleover" and powerType == COMBAT_MECHANIC_FLAGS_HEALTH and IsUnitInvulnerableGuard("reticleover")
                local isCritter = self.unitTag == "reticleover" and powerType == COMBAT_MECHANIC_FLAGS_HEALTH and powerEffectiveMax <= 9
                local drawnValue = powerValue
                if powerType == COMBAT_MECHANIC_FLAGS_HEALTH and traumaValue > 0 then
                    drawnValue = powerValue - traumaValue
                    if drawnValue < 0 then
                        drawnValue = 0
                    end
                end
                self.libUnitHasShownPower = self.libUnitHasShownPower or {}
                local forceInit = not self.libUnitHasShownPower[powerType]
                self.libUnitHasShownPower[powerType] = true
                local percent = zo_floor(100 * powerValue / powerEffectiveMax)
                local shieldText = (powerType == COMBAT_MECHANIC_FLAGS_HEALTH and shieldValue > 0) and shieldValue or nil
                local traumaText = (powerType == COMBAT_MECHANIC_FLAGS_HEALTH and traumaValue > 0) and traumaValue or nil

                for _, labelName in pairs({ "label", "labelOne", "labelTwo" }) do
                    local label = powerEntry[labelName]
                    if label then
                        if (isGuard or isCritter) and labelName == "labelOne" then
                            label:SetText(isGuard and " - Invulnerable - " or " - Critter - ")
                            label:SetHidden(false)
                        elseif (isGuard or isCritter) and labelName == "labelTwo" then
                            label:SetText("")
                            label:SetHidden(true)
                        else
                            local formatString = tostring(label.format or UnitFrames.SV.Format)
                            local labelText = LUF:FormatPowerLabel(formatString, powerValue, powerEffectiveMax, shieldText, traumaText, FormatPowerNumber)
                            label:SetText(labelText)
                            if (labelName == "labelOne" or labelName == "labelTwo") and self.unitTag == "reticleover" and powerValue == 0 then
                                label:SetHidden(true)
                            end
                        end
                        local isUnwavering = powerType == COMBAT_MECHANIC_FLAGS_HEALTH and unwaveringValue == 1 and powerValue > 0
                        if isUnwavering or isGuard then
                            label:SetColor(unpack(powerEntry.color or { 1, 1, 1, 1 }))
                        else
                            local isLow = percent < (powerEntry.threshold or UnitFrames.defaultThreshold)
                            label:SetColor(unpack(isLow and { 1, 0.25, 0.38, 1 } or powerEntry.color or { 1, 1, 1, 1 }))
                        end
                    end
                end

                local showInvulnerable = powerEntry.invulnerable and ((unwaveringValue == 1 and powerValue > 0) or isGuard)
                if showInvulnerable then
                    powerEntry.invulnerable:SetHidden(false)
                    powerEntry.bar:SetHidden(true)
                    ApplyStatusValue(powerEntry.invulnerable, powerValue, powerEffectiveMax, false, true)
                    if powerEntry.invulnerableInlay then
                        powerEntry.invulnerableInlay:SetHidden(false)
                        ApplyStatusValue(powerEntry.invulnerableInlay, powerValue, powerEffectiveMax, false, true)
                    end
                else
                    if powerEntry.invulnerable then
                        powerEntry.invulnerable:SetHidden(true)
                    end
                    if powerEntry.invulnerableInlay then
                        powerEntry.invulnerableInlay:SetHidden(true)
                    end
                    if not (isCritter or isGuard) then
                        powerEntry.bar:SetHidden(false)
                        local dodgePrediction = UnitFrames.dodgePrediction
                        if self.unitTag == "player" and powerType == COMBAT_MECHANIC_FLAGS_STAMINA and dodgePrediction and dodgePrediction:ShouldUseSmoothBar() then
                            dodgePrediction:SmoothTransition(powerEntry.bar, drawnValue, powerEffectiveMax, forceInit)
                        else
                            if dodgePrediction and self.unitTag == "player" and powerType == COMBAT_MECHANIC_FLAGS_STAMINA then
                                dodgePrediction:StopSmoothAnimation(powerEntry.bar)
                            end
                            ApplyStatusValue(powerEntry.bar, drawnValue, powerEffectiveMax, smooth, forceInit)
                        end
                    end
                end

                if powerType == COMBAT_MECHANIC_FLAGS_HEALTH then
                    if powerEntry.shield then
                        if shieldValue > 0 then
                            powerEntry.shield:SetHidden(false)
                            if powerEntry.shieldbackdrop then
                                powerEntry.shieldbackdrop:SetHidden(false)
                            end
                            ApplyStatusValue(powerEntry.shield, shieldValue, powerEffectiveMax, smooth, false)
                        else
                            powerEntry.shield:SetValue(0)
                            powerEntry.shield:SetHidden(true)
                            if powerEntry.shieldbackdrop then
                                powerEntry.shieldbackdrop:SetHidden(true)
                            end
                        end
                    end
                    if powerEntry.trauma then
                        if traumaValue > 0 then
                            powerEntry.trauma:SetHidden(false)
                            ApplyStatusValue(powerEntry.trauma, powerValue, powerEffectiveMax, smooth, forceInit)
                        else
                            powerEntry.trauma:SetValue(0)
                            powerEntry.trauma:SetHidden(true)
                        end
                    end
                    ApplyNoHealing(powerEntry, noHealingValue > 0, powerValue, powerEffectiveMax, smooth, forceInit)
                end
            end
        end
    end

    if attributeVisualElement then
        local regenRows = {
            { powerType = COMBAT_MECHANIC_FLAGS_HEALTH, statType = STAT_HEALTH_REGEN_COMBAT, attributeType = ATTRIBUTE_HEALTH },
            { powerType = COMBAT_MECHANIC_FLAGS_MAGICKA, statType = STAT_MAGICKA_REGEN_COMBAT, attributeType = ATTRIBUTE_MAGICKA },
            { powerType = COMBAT_MECHANIC_FLAGS_STAMINA, statType = STAT_STAMINA_REGEN_COMBAT, attributeType = ATTRIBUTE_STAMINA },
        }
        for rowIndex = 1, #regenRows do
            local regenRow = regenRows[rowIndex]
            local powerEntry = self[regenRow.powerType]
            if type(powerEntry) == "table" then
                ApplyRegenForPower(powerEntry, attributeVisualElement, regenRow.powerType, regenRow.statType, regenRow.statType, regenRow.attributeType)
            end
        end
    end

    if self.unitTag == "player" and healthElement and powerElement then
        local function MarkStatFull(powerType, powerValue, powerEffectiveMax)
            if powerValue ~= nil and powerEffectiveMax ~= nil then
                UnitFrames.statFull[powerType] = (powerValue == powerEffectiveMax)
            end
        end
        MarkStatFull(COMBAT_MECHANIC_FLAGS_HEALTH, healthElement.powerValue, healthElement.powerEffectiveMax)
        local magickaPool = powerElement.pools and powerElement.pools[COMBAT_MECHANIC_FLAGS_MAGICKA]
        local staminaPool = powerElement.pools and powerElement.pools[COMBAT_MECHANIC_FLAGS_STAMINA]
        local mountPool = powerElement.pools and powerElement.pools[COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA]
        if magickaPool then
            MarkStatFull(COMBAT_MECHANIC_FLAGS_MAGICKA, magickaPool.powerValue, magickaPool.powerEffectiveMax)
        end
        if staminaPool then
            MarkStatFull(COMBAT_MECHANIC_FLAGS_STAMINA, staminaPool.powerValue, staminaPool.powerEffectiveMax)
            local dodgePrediction = UnitFrames.dodgePrediction
            if dodgePrediction and not dodgePrediction:ShouldUseSmoothBar() then
                dodgePrediction:Refresh(true)
            end
        end
        if mountPool then
            MarkStatFull(COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA, mountPool.powerValue, mountPool.powerEffectiveMax)
        end
        UnitFrames.CustomFramesApplyInCombat()
    end

    if self.unitTag == "reticleover" then
        self:ApplyLibUnitTargetChrome()
    end

    if healthElement and self.unitTag and string.sub(self.unitTag, 1, 4) == "boss" then
        UnitFrames.UpdateBossThresholds()
    end

    if healthElement and self.unitTag and ZO_Group_IsGroupUnitTag(self.unitTag) and UnitFrames.RefreshCombatGlowForUnit then
        UnitFrames.RefreshCombatGlowForUnit(self.unitTag)
    end
end

function LUIE_CustomFrameData_Base:ApplyLibUnitTargetChrome()
    if self.unitTag ~= "reticleover" or not self.libUnit then
        return
    end
    local reactionElement = self.libUnit:GetElement("Reaction")
    local unitTypeElement = self.libUnit:GetElement("UnitType")
    local healthElement = self.libUnit:GetElement("Health")
    if not reactionElement then
        return
    end

    local reactionType = reactionElement.reaction
    local attackable = unitTypeElement and unitTypeElement.isAttackable
    local color
    if reactionType == UNIT_REACTION_HOSTILE then
        color = UnitFrames.SV.Target_FontColour_Hostile
    elseif reactionType == UNIT_REACTION_PLAYER_ALLY then
        color = UnitFrames.SV.Target_FontColour_FriendlyPlayer
    elseif attackable and reactionType ~= UNIT_REACTION_HOSTILE then
        color = UnitFrames.SV.Target_FontColour
    else
        color = (reactionType == UNIT_REACTION_FRIENDLY or reactionType == UNIT_REACTION_NPC_ALLY) and UnitFrames.SV.Target_FontColour_FriendlyNPC or UnitFrames.SV.Target_FontColour
    end

    local powerValue = healthElement and healthElement.powerValue or 0
    local powerEffectiveMax = healthElement and healthElement.powerEffectiveMax or 0
    local isCritter = powerEffectiveMax > 0 and powerEffectiveMax <= 9
    local isGuard = IsUnitInvulnerableGuard("reticleover")
    local healthEntry = self[COMBAT_MECHANIC_FLAGS_HEALTH]
    local threshold = healthEntry and healthEntry.threshold or 0
    local healthPercent = powerEffectiveMax > 0 and (100 * powerValue / powerEffectiveMax) or 0

    UnitFrames.reticleoverHostile = (reactionType == UNIT_REACTION_HOSTILE) and UnitFrames.SV.TargetEnableSkull
    if self.skull then
        self.skull:SetHidden(not UnitFrames.reticleoverHostile or powerValue == 0 or healthPercent > threshold)
    end
    if self.name and color then
        self.name:SetColor(color[1], color[2], color[3], 1)
    end
    if self.className and color then
        self.className:SetColor(color[1], color[2], color[3], 1)
    end
    if healthEntry and healthEntry.labelTwo then
        local deadHidden = not self.dead or self.dead:IsHidden()
        healthEntry.labelTwo:SetHidden(isCritter or isGuard or not deadHidden)
    end
end
