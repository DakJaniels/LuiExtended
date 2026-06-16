--- @diagnostic disable: missing-global-doc, duplicate-set-field
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

function LUIE.HookKeyboardStats()
    -- Hook STATS Screen Buffs & Debuffs — vanilla visibility; LUIE tooltips/icons on stats panel only.

    -- Define comparator function for sorting effects rows
    local function EffectsRowComparator(left, right)
        local leftIsArtificial, rightIsArtificial = left.isArtificial, right.isArtificial
        if leftIsArtificial ~= rightIsArtificial then
            -- Artificial before real
            return leftIsArtificial
        else
            if leftIsArtificial then
                -- Both artificial, use def defined sort order
                return left.sortOrder < right.sortOrder
            else
                -- Both real, use time
                return left.time.endTime < right.time.endTime
            end
        end
    end

    local function MapStatsRowToEffectsRow(row, effectsRowPool)
        local effectsRow = effectsRowPool:AcquireObject()
        effectsRow.name:SetText(zo_strformat(SI_ABILITY_TOOLTIP_NAME, row.displayName))
        effectsRow.icon:SetTexture(row.displayIcon)
        effectsRow.effectType = row.effectType or BUFF_EFFECT_TYPE_BUFF

        if row.stackCount and row.stackCount > 1 then
            effectsRow.stackCount:SetText(row.stackCount)
        else
            effectsRow.stackCount:SetText("")
        end

        local duration = (row.startTime or 0) - (row.endTime or 0)
        effectsRow.time:SetHidden(duration == 0)
        effectsRow.time.endTime = row.endTime or 0
        effectsRow.tooltipTitle = zo_strformat(SI_ABILITY_TOOLTIP_NAME, row.displayName)

        if row.isArtificial then
            effectsRow.sortOrder = row.sortOrder
            effectsRow.isArtificial = true
            effectsRow.isArtificialTooltip = true
            effectsRow.effectId = row.artificialEffectId
        else
            effectsRow.isArtificial = false
            effectsRow.isArtificialTooltip = false
            effectsRow.tooltipText = row.tooltipText or ""
            effectsRow.thirdLine = row.thirdLine
            effectsRow.buffSlot = row.buffSlot
            effectsRow.effectId = row.abilityId
        end

        return effectsRow
    end

    -- Position effects rows in the UI
    local function PositionEffectsRows(effectsRows)
        local prevRow
        for i, effectsRow in ipairs(effectsRows) do
            if prevRow then
                effectsRow:SetAnchor(TOPLEFT, prevRow, BOTTOMLEFT)
            else
                effectsRow:SetAnchor(TOPLEFT, nil, TOPLEFT, 5, 0)
            end
            effectsRow:SetHidden(false)
            prevRow = effectsRow
        end
    end

    function ZO_Stats:AddLongTermEffects(container, effectsRowPool)
        local function UpdateEffects()
            if not container:IsHidden() then
                effectsRowPool:ReleaseAllObjects()
                local effectsRows = {}

                for _, row in ipairs(LUIE.BuildStatsActiveEffectRows()) do
                    table.insert(effectsRows, MapStatsRowToEffectsRow(row, effectsRowPool))
                end

                table.sort(effectsRows, EffectsRowComparator)
                PositionEffectsRows(effectsRows)
            end
        end

        -- Register events
        local function OnEffectChanged(eventCode, changeType, buffSlot, buffName, unitTag)
            UpdateEffects()
            self:RefreshAllAttributes() -- Use the original method
        end

        local function HideMundusTooltips()
            for _, control in ipairs(self.mundusIconControls) do
                ZO_StatsMundusEntry_OnMouseExit(control)
            end
        end

        container:RegisterForEvent(EVENT_EFFECT_CHANGED, OnEffectChanged)
        container:AddFilterForEvent(EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
        container:RegisterForEvent(EVENT_EFFECTS_FULL_UPDATE, UpdateEffects)
        container:RegisterForEvent(EVENT_ARTIFICIAL_EFFECT_ADDED, UpdateEffects)
        container:RegisterForEvent(EVENT_ARTIFICIAL_EFFECT_REMOVED, UpdateEffects)
        container:SetHandler("OnEffectivelyShown", UpdateEffects)
        container:SetHandler("OnEffectivelyHidden", HideMundusTooltips)
    end

    -- Used to update Tooltips for Active Effects Window
    local function TooltipBottomLine(control, detailsLine)
        -- Add bottom divider and info if present:
        if LUIE.SpellCastBuffs.SV.TooltipAbilityId or LUIE.SpellCastBuffs.SV.TooltipBuffType then
            ZO_Tooltip_AddDivider(GameTooltip)
            GameTooltip:SetVerticalPadding(4)
            GameTooltip:AddLine("", "", ZO_NORMAL_TEXT:UnpackRGB())
            -- Add Ability ID Line
            if LUIE.SpellCastBuffs.SV.TooltipAbilityId then
                local labelAbilityId = control.effectId
                if labelAbilityId == nil or false then
                    labelAbilityId = "None"
                end
                if labelAbilityId == "Fake" then
                    control.artificial = true
                end
                if control.isArtificial then
                    -- ArtificialEffectId (live): 0 ESO Plus, 1 Battle Spirit, 2 LFG, 3 Battle Spirit Imperial City,
                    -- 4 Battleground Deserter, 5 Underdog Damage, 6 Underdog Healing, 7 Solo Queue XP, 8 Solo Queue AP.
                    labelAbilityId = LUIE.FormatStatsActiveEffectAbilityIdLabel(control.effectId, true)
                end
                GameTooltip:AddHeaderLine("Ability ID", "ZoFontWinT1", detailsLine, TOOLTIP_HEADER_SIDE_LEFT, ZO_NORMAL_TEXT:UnpackRGB())
                GameTooltip:AddHeaderLine(labelAbilityId, "ZoFontWinT1", detailsLine, TOOLTIP_HEADER_SIDE_RIGHT, 1, 1, 1)
                detailsLine = detailsLine + 1
            end

            -- Add Buff Type Line
            if LUIE.SpellCastBuffs.SV.TooltipBuffType then
                local buffTypeLookupId = control.isArtificial and nil or control.effectId
                local buffType = LUIE.GetStatsActiveEffectTooltipBuffType(buffTypeLookupId, control.effectType)
                GameTooltip:AddHeaderLine("Type", "ZoFontWinT1", detailsLine, TOOLTIP_HEADER_SIDE_LEFT, ZO_NORMAL_TEXT:UnpackRGB())
                GameTooltip:AddHeaderLine(LUIE.buffTypes[buffType], "ZoFontWinT1", detailsLine, TOOLTIP_HEADER_SIDE_RIGHT, 1, 1, 1)
                detailsLine = detailsLine + 1
            end
        end
    end

    -- Hook Tooltip Generation for STATS Screen Buffs & Debuffs
    function ZO_StatsActiveEffect_OnMouseEnter(control)
        InitializeTooltip(GameTooltip, control, RIGHT, -15, 0)

        local detailsLine
        local colorText = ZO_NORMAL_TEXT
        if control.thirdLine ~= "" and control.thirdLine ~= nil then
            colorText = control.effectType == BUFF_EFFECT_TYPE_DEBUFF and ZO_ERROR_COLOR or ZO_SUCCEEDED_TEXT
        end

        if control.isArtificialTooltip then
            local tooltipText = GetArtificialEffectTooltipText(control.effectId)
            GameTooltip:AddLine(control.tooltipTitle, "ZoFontHeader2", 1, 1, 1, nil)
            GameTooltip:SetVerticalPadding(1)
            ZO_Tooltip_AddDivider(GameTooltip)
            GameTooltip:SetVerticalPadding(5)
            GameTooltip:AddLine(tooltipText, "", colorText:UnpackRGBA())
            detailsLine = 5
        else
            detailsLine = 3
            GameTooltip:AddLine(control.tooltipTitle, "ZoFontHeader2", 1, 1, 1, nil)
            if control.tooltipText ~= "" and control.tooltipText ~= nil then
                GameTooltip:SetVerticalPadding(1)
                ZO_Tooltip_AddDivider(GameTooltip)
                GameTooltip:SetVerticalPadding(5)
                GameTooltip:AddLine(control.tooltipText, "", colorText:UnpackRGBA())
                detailsLine = 5
            end
            if control.thirdLine ~= "" and control.thirdLine ~= nil then
                if control.tooltipText == "" or control.tooltipText == nil then
                    GameTooltip:SetVerticalPadding(1)
                    ZO_Tooltip_AddDivider(GameTooltip)
                    GameTooltip:SetVerticalPadding(5)
                end
                detailsLine = 7
                GameTooltip:AddLine(control.thirdLine, "", ZO_NORMAL_TEXT:UnpackRGB())
            end
        end

        TooltipBottomLine(control, detailsLine)

        if not control.animation then
            control.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ShowOnMouseOverLabelAnimation", control:GetNamedChild("Highlight"))
        end
        control.animation:PlayForward()
    end

    -- Hook Skills Advisor (Keyboard) and use this variable to refresh the abilityData one time on initialization. We don't want to reload any more after that.
    function ZO_SkillsAdvisor_Suggestions_Keyboard:SetupAbilityEntry(control, skillProgressionData)
        local skillData = skillProgressionData:GetSkillData()
        local isPassive = skillData:IsPassive()

        control.skillProgressionData = skillProgressionData
        control.slot.skillProgressionData = skillProgressionData

        -- slot
        ZO_Skills_SetKeyboardAbilityButtonTextures(control.slot)
        local id = skillProgressionData:GetAbilityId()
        local icon = GetAbilityIcon(id)
        control.slotIcon:SetTexture(icon or skillProgressionData:GetIcon())
        control.slotLock:SetHidden(skillProgressionData:IsUnlocked())
        local morphControl = control:GetNamedChild("Morph")
        morphControl:SetHidden(isPassive or not skillProgressionData:IsMorph())

        -- name
        local detailedName
        if isPassive and skillData:GetNumRanks() > 1 then
            detailedName = skillProgressionData:GetFormattedNameWithRank()
        else
            detailedName = skillProgressionData:GetFormattedName()
        end
        detailedName = StringOnlyGSUB(detailedName, "With", "with")               -- Easiest way to fix the capitalization of the skill "Bond With Nature"
        detailedName = StringOnlyGSUB(detailedName, "Blessing Of", "Blessing of") -- Easiest way to fix the capitalization of the skill "Blessing of Restoration"
        control.nameLabel:SetText(detailedName)
        control.nameLabel:SetColor(PURCHASED_COLOR:UnpackRGBA())
    end
end
