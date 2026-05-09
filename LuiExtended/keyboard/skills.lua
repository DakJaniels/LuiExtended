--- @diagnostic disable: missing-global-doc, duplicate-set-field
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local Data = LuiData.Data
local Effects = Data.Effects

LUIE.HookKeyboardStats = function ()
    -- Hook STATS Screen Buffs & Debuffs to hide buffs not needed, update icons, names, durations, and tooltips


    -- Helper function to determine if an effect should be shown
    ---
    --- @param abilityId integer
    --- @return boolean
    local function ShouldShowEffect(abilityId)
        local override = Effects.EffectOverride[abilityId]
        if not override then
            return true
        end

        if override.hideReduce then
            return not LUIE.SpellCastBuffs.SV.HideReduce
        end
        return true
    end

    -- Helper function to generate tooltip text
    --- @param abilityId integer
    --- @param buffSlot integer
    --- @param timer integer
    --- @param value2 integer
    --- @param value3 integer
    --- @return string tooltipText
    local function GetTooltipText(abilityId, buffSlot, timer, value2, value3)
        local function GenTooltipText(tooltipText)
            local override = Effects.EffectOverride[abilityId]

            -- Handle veteran difficulty tooltip
            if LUIE.ResolveVeteranDifficulty() and override and override.tooltipVeteran then
                tooltipText = zo_strformat(override.tooltipVeteran, timer, value2, value3)
            else
                tooltipText = (override and override.tooltip) and
                    zo_strformat(override.tooltip, timer, value2, value3) or
                    GetAbilityDescription(abilityId)
            end

            -- Handle empty tooltip
            if tooltipText == "" or tooltipText == nil then
                local effectDesc = GetAbilityEffectDescription(buffSlot)
                if effectDesc ~= "" then
                    tooltipText = effectDesc
                end
            end

            -- Handle default tooltip override
            if Effects.TooltipUseDefault[abilityId] then
                local effectDesc = GetAbilityEffectDescription(buffSlot)
                if effectDesc ~= "" then
                    tooltipText = LUIE.UpdateMundusTooltipSyntax(abilityId, effectDesc)
                end
            end

            -- Handle dynamic tooltip
            if override and override.dynamicTooltip then
                tooltipText = LUIE.DynamicTooltip(abilityId) or tooltipText -- Fallback to original tooltipText if nil
            end

            -- Clean up tooltip text
            if tooltipText ~= "" then
                tooltipText = string.match(tooltipText, ".*%S")
            end

            -- Use default tooltip if custom tooltips are disabled
            if not LUIE.SpellCastBuffs.SV.TooltipCustom then
                tooltipText = GetAbilityEffectDescription(buffSlot)
                tooltipText = StringOnlyGSUB(tooltipText, "\n$", "")
            end
            return tooltipText
        end
        local tooltipText = GenTooltipText("")
        return tooltipText
    end

    -- Helper function to get third line text
    local function GetThirdLine(abilityId, timer)
        if Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].duration then
            timer = timer + Effects.EffectOverride[abilityId].duration
        end
        -- Additional third line logic can be added here if needed
        return nil
    end

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

    -- Process artificial effects
    local function ProcessArtificialEffects(effectsRows, effectsRowPool)
        for effectId in ZO_GetNextActiveArtificialEffectIdIter do
            -- Skip ESO Plus buff (effectId == 0)
            if effectId ~= 0 then
                local displayName, iconFile, effectType, sortOrder, startTime, endTime = GetArtificialEffectInfo(effectId)
                local effectsRow = effectsRowPool:AcquireObject()
                effectsRow.name:SetText(zo_strformat(SI_ABILITY_TOOLTIP_NAME, displayName))
                effectsRow.icon:SetTexture(iconFile)
                effectsRow.effectType = effectType
                local duration = startTime - endTime
                effectsRow.time:SetHidden(duration == 0)
                effectsRow.time.endTime = endTime
                effectsRow.sortOrder = sortOrder
                effectsRow.tooltipTitle = zo_strformat(SI_ABILITY_TOOLTIP_NAME, displayName)
                effectsRow.effectId = effectId
                effectsRow.isArtificial = true
                effectsRow.isArtificialTooltip = true

                -- Special handling for Battleground Deserter Penalty
                if effectId == 1 then
                    startTime = GetFrameTimeSeconds()
                    local cooldown = GetLFGCooldownTimeRemainingSeconds(LFG_COOLDOWN_BATTLEGROUND_DESERTED_QUEUE)
                    endTime = startTime + cooldown
                    duration = startTime - endTime
                    effectsRow.time:SetHidden(duration == 0)
                    effectsRow.time.endTime = endTime
                    effectsRow.isArtificial = false -- Sort with normal buffs
                end
                table.insert(effectsRows, effectsRow)
            end
        end
        return effectsRows
    end

    -- Collect player buffs data
    local function CollectPlayerBuffs()
        local trackBuffs = {}
        for i = 1, GetNumBuffs("player") do
            local buffName, startTime, endTime, buffSlot, stackCount, iconFile, deprecatedBuffType, effectType, abilityType, statusEffectType, abilityId = GetUnitBuffInfo("player", i)
            trackBuffs[i] =
            {
                buffName = buffName,
                startTime = startTime,
                endTime = endTime,
                buffSlot = buffSlot,
                stackCount = stackCount,
                iconFile = iconFile,
                deprecatedBuffType = deprecatedBuffType,
                effectType = effectType,
                abilityType = abilityType,
                statusEffectType = statusEffectType,
                abilityId = abilityId,
            }
        end
        return trackBuffs
    end

    -- Handle duplicate abilities
    local function HandleDuplicateBuffs(trackBuffs)
        for i = 1, #trackBuffs do
            local compareId = trackBuffs[i].abilityId
            local compareTime = trackBuffs[i].endTime
            if Effects.EffectOverride[compareId] and Effects.EffectOverride[compareId].noDuplicate then
                for k, v in pairs(trackBuffs) do
                    if v.abilityId == compareId and v.endTime < compareTime then
                        v.markForRemove = true
                    end
                end
            end
        end
        return trackBuffs
    end

    -- Process player buffs
    local function ProcessPlayerBuffs(effectsRows, effectsRowPool, trackBuffs)
        for i = 1, #trackBuffs do
            local buff = trackBuffs[i]
            if buff.buffSlot > 0 and buff.buffName ~= "" and
            not (Effects.EffectOverride[buff.abilityId] and Effects.EffectOverride[buff.abilityId].hide) and
            not buff.markForRemove then
                -- Process tooltip values
                local timer = buff.endTime - buff.startTime
                local value2, value3 = 0, 0
                local effectOverride = Effects.EffectOverride[buff.abilityId]

                if effectOverride then
                    -- Handle value2
                    if effectOverride.tooltipValue2 then
                        value2 = effectOverride.tooltipValue2
                    elseif effectOverride.tooltipValue2Mod then
                        value2 = zo_floor(timer + effectOverride.tooltipValue2Mod + 0.5)
                    elseif effectOverride.tooltipValue2Id then
                        value2 = zo_floor((GetAbilityDuration(effectOverride.tooltipValue2Id) or 0) + 0.5) / 1000
                    end
                    -- Handle value3
                    value3 = effectOverride.tooltipValue3 or 0
                end

                timer = zo_floor((timer * 10) + 0.5) / 10

                -- Generate tooltip text
                local tooltipText = GetTooltipText(buff.abilityId, buff.buffSlot, timer, value2, value3)

                -- Apply effect type override if needed
                if effectOverride and effectOverride.type then
                    buff.effectType = effectOverride.type
                end

                -- Create effects row if conditions are met
                if ShouldShowEffect(buff.abilityId) then
                    local effectsRow = effectsRowPool:AcquireObject()
                    effectsRow.name:SetText(zo_strformat(SI_ABILITY_TOOLTIP_NAME, buff.buffName))
                    effectsRow.icon:SetTexture(buff.iconFile)

                    -- Always set the stack count text - set to empty string if stack count is 1 or less
                    -- This ensures stack count is cleared when objects are reused from the pool
                    if buff.stackCount > 1 then
                        effectsRow.stackCount:SetText(buff.stackCount)
                    else
                        effectsRow.stackCount:SetText("")
                    end

                    effectsRow.tooltipTitle = zo_strformat(SI_ABILITY_TOOLTIP_NAME, buff.buffName)
                    effectsRow.tooltipText = tooltipText
                    effectsRow.thirdLine = GetThirdLine(buff.abilityId, buff.endTime - buff.startTime)

                    local duration = buff.startTime - buff.endTime
                    effectsRow.time:SetHidden(duration == 0)
                    effectsRow.time.endTime = buff.endTime
                    effectsRow.effectType = buff.effectType
                    effectsRow.buffSlot = buff.buffSlot
                    effectsRow.isArtificial = false
                    effectsRow.effectId = buff.abilityId

                    table.insert(effectsRows, effectsRow)
                end
            end
        end
        return effectsRows
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

                -- Process artificial effects
                effectsRows = ProcessArtificialEffects(effectsRows, effectsRowPool)

                -- Collect and process player buffs
                local trackBuffs = CollectPlayerBuffs()
                trackBuffs = HandleDuplicateBuffs(trackBuffs)
                effectsRows = ProcessPlayerBuffs(effectsRows, effectsRowPool, trackBuffs)

                -- Sort and position rows
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
                    if control.effectId == 0 then
                        labelAbilityId = 63601  -- ESO Plus (legacy debug label)
                    elseif control.effectId == 1 or control.effectId == 3 then
                        labelAbilityId = 999014 -- SpellCastBuffs fake id for Battle Spirit (+ IC)
                    elseif control.effectId == 2 then
                        labelAbilityId = "2 (LFG)"
                    elseif control.effectId == 4 then
                        labelAbilityId = "4 (BG Deserter)"
                    elseif control.effectId >= 5 and control.effectId <= 8 then
                        labelAbilityId = control.effectId
                    else
                        labelAbilityId = "Artificial"
                    end
                end
                GameTooltip:AddHeaderLine("Ability ID", "ZoFontWinT1", detailsLine, TOOLTIP_HEADER_SIDE_LEFT, ZO_NORMAL_TEXT:UnpackRGB())
                GameTooltip:AddHeaderLine(labelAbilityId, "ZoFontWinT1", detailsLine, TOOLTIP_HEADER_SIDE_RIGHT, 1, 1, 1)
                detailsLine = detailsLine + 1
            end

            -- Add Buff Type Line
            if LUIE.SpellCastBuffs.SV.TooltipBuffType then
                local buffType = control.effectType or LUIE_BUFF_TYPE_NONE
                local effectId = control.effectId
                if effectId and Effects.EffectOverride[effectId] and Effects.EffectOverride[effectId].unbreakable then
                    buffType = buffType + 2
                end

                -- Setup tooltips for player aoe trackers
                if effectId and Effects.EffectGroundDisplay[effectId] then
                    buffType = buffType + 4
                end

                -- Setup tooltips for ground buff/debuff effects
                if effectId and (Effects.AddGroundDamageAura[effectId] or (Effects.EffectOverride[effectId] and Effects.EffectOverride[effectId].groundLabel)) then
                    buffType = buffType + 6
                end

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
