--- @diagnostic disable: duplicate-set-field
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local Data = LuiData.Data
local Effects = Data.Effects

LUIE.HookGamePadStats = function ()
    -- Hook GAMEPAD Stats List

    local GAMEPAD_STATS_DISPLAY_MODE =
    {
        CHARACTER = 1,
        ATTRIBUTES = 2,
        EFFECTS = 3,
        TITLE = 4,
        OUTFIT = 5,
        LEVEL_UP_REWARDS = 6,
        UPCOMING_LEVEL_UP_REWARDS = 7,
        ADVANCED_ATTRIBUTES = 8,
        MUNDUS = 9,
        GUILD = 10,
        DIFFICULTY = 11,
    }

    local function ArtificialEffectsRowComparator(left, right)
        return left.sortOrder < right.sortOrder
    end

    function ZO_GamepadStats:RefreshMainList()
        if self.currentDifficultyDropdown and self.currentDifficultyDropdown:IsDropdownVisible() then
            self.refreshMainListOnDropdownClose = true
            return
        end

        if self.currentTitleDropdown and self.currentTitleDropdown:IsDropdownVisible() then
            self.refreshMainListOnDropdownClose = true
            return
        end

        if self.currentGuildDropdown and self.currentGuildDropdown:IsDropdownVisible() then
            self.refreshMainListOnDropdownClose = true
            return
        end

        self.mainList:Clear()

        -- Level Up Reward
        if HasPendingLevelUpReward() then
            self.mainList:AddEntry("ZO_GamepadNewMenuEntryTemplate", self.claimRewardsEntry)
        elseif HasUpcomingLevelUpReward() then
            self.mainList:AddEntry("ZO_GamepadMenuEntryTemplate", self.upcomingRewardsEntry)
        end

        -- Difficulty
        self.mainList:AddEntryWithHeader("ZO_GamepadStatDifficultyRow", self.difficultyEntry)

        -- Title
        self.mainList:AddEntryWithHeader("ZO_GamepadStatTitleRow", self.titleEntry)

        -- Attributes
        for index, attributeEntry in ipairs(self.attributeEntries) do
            if index == 1 then
                self.mainList:AddEntryWithHeader("ZO_GamepadStatAttributeRow", attributeEntry)
            else
                self.mainList:AddEntry("ZO_GamepadStatAttributeRow", attributeEntry)
            end
        end

        -- Mundus Entries
        for key, attribute in pairs(self.attributeItems) do
            local NO_MUNDUS_EFFECT = false
            attribute:SetMundusEffect(NO_MUNDUS_EFFECT)
        end
        self.mundusEntries = {}
        self.mundusAdvancedStats = {}
        local activeMundusStoneBuffIndices = { GetUnitActiveMundusStoneBuffIndices("player") }
        local numActiveMundusStoneBuffs = #activeMundusStoneBuffIndices
        local numMundusSlots = GetNumAvailableMundusStoneSlots()
        local isPlayerAtMundusWarningLevel = GetUnitLevel("player") >= GetMundusWarningLevel()
        for slotIndex = 1, numMundusSlots do
            local mundusEntry = nil
            if numActiveMundusStoneBuffs >= slotIndex then
                local buffName, _, _, buffSlot, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", activeMundusStoneBuffIndices[slotIndex])
                local mundusStoneIndex = GetAbilityMundusStoneType(abilityId)
                mundusEntry = ZO_GamepadEntryData:New(zo_strformat(SI_STATS_MUNDUS_FORMATTER, buffName), ZO_STAT_MUNDUS_ICONS[mundusStoneIndex])
                mundusEntry.data =
                {
                    name = buffName,
                    description = GetAbilityEffectDescription(buffSlot),
                    mundusBuffIndex = activeMundusStoneBuffIndices[slotIndex],
                    slotIndex = slotIndex,
                    statEffects = {},
                }
                local numStatsForAbility = GetAbilityNumDerivedStats(abilityId)
                for statIndex = 1, numStatsForAbility do
                    local statType, effectValue = GetAbilityDerivedStatAndEffectByIndex(abilityId, statIndex)
                    local attributeItem = self:GetAttributeItem(statType)
                    if attributeItem then
                        local HAS_MUNDUS_EFFECT = true
                        attributeItem:SetMundusEffect(HAS_MUNDUS_EFFECT, buffName, effectValue, mundusEntry.data.mundusBuffIndex)
                    end
                    local statEffect =
                    {
                        statType = statType,
                        effect = effectValue,
                    }
                    table.insert(mundusEntry.data.statEffects, statEffect)
                end
                self.mundusAdvancedStats[slotIndex] = {}
                local numAdvancedStatsForAbility = GetAbilityNumAdvancedStats(abilityId)
                for advancedStatIndex = 1, numAdvancedStatsForAbility do
                    local statType, statFormat, effectValue = GetAbilityAdvancedStatAndEffectByIndex(abilityId, advancedStatIndex)
                    local statEffect =
                    {
                        statType = statType,
                        format = statFormat,
                        value = effectValue,
                    }
                    table.insert(self.mundusAdvancedStats[slotIndex], statEffect)
                end
            elseif numMundusSlots >= slotIndex then
                mundusEntry = ZO_GamepadEntryData:New(GetString("SI_MUNDUSSTONE", MUNDUS_STONE_INVALID), ZO_STAT_MUNDUS_ICONS[MUNDUS_STONE_INVALID])
                mundusEntry.data =
                {
                    name = GetString(SI_STATS_MUNDUS_NONE_TOOLTIP_TITLE),
                    description = GetString(SI_STATS_MUNDUS_NONE_TOOLTIP_DESCRIPTION),
                }
                if isPlayerAtMundusWarningLevel then
                    mundusEntry:SetNameColors(ZO_ERROR_COLOR, ZO_ERROR_COLOR)
                    mundusEntry:SetIconTint(ZO_ERROR_COLOR, ZO_ERROR_COLOR)
                else
                    local USE_DEFAULT_COLORS = nil
                    mundusEntry:SetNameColors(USE_DEFAULT_COLORS, USE_DEFAULT_COLORS)
                    mundusEntry:SetIconTint(USE_DEFAULT_COLORS, USE_DEFAULT_COLORS)
                end
            end
            if mundusEntry then
                mundusEntry.displayMode = GAMEPAD_STATS_DISPLAY_MODE.MUNDUS
                if slotIndex == 1 then
                    mundusEntry:SetHeader(GetString(SI_STATS_MUNDUS_TITLE))
                    self.mainList:AddEntryWithHeader("ZO_GamepadMenuEntryTemplate", mundusEntry)
                else
                    self.mainList:AddEntry("ZO_GamepadMenuEntryTemplate", mundusEntry)
                end
            end
        end

        -- Character Info
        self.mainList:AddEntryWithHeader("ZO_GamepadMenuEntryTemplate", self.advancedStatsEntry)
        self.mainList:AddEntry("ZO_GamepadMenuEntryTemplate", self.characterEntry)

        -- Guild (tabard)
        self.mainList:AddEntryWithHeader("ZO_GamepadStatGuildRow", self.guildEntry)

        -- Active Effects--
        self.numActiveEffects = 0

        local function GetActiveEffectNarration(entryData, entryControl)
            local narrations = {}

            -- Generate the standard parametric list entry narration
            ZO_AppendNarration(narrations, ZO_GetSharedGamepadEntryDefaultNarrationText(entryData, entryControl))

            -- Right panel header
            ZO_AppendNarration(narrations, ZO_GamepadGenericHeader_GetNarrationText(self.contentHeader, self.contentHeaderData))

            -- Right panel description
            ZO_AppendNarration(narrations, SCREEN_NARRATION_MANAGER:CreateNarratableObject(self.effectDescNarrationText))

            return narrations
        end

        -- Artificial effects
        local sortedArtificialEffectsTable = {}
        for effectId in ZO_GetNextActiveArtificialEffectIdIter do
            -- Skip ESO Plus buff (effectId == 0)
            if effectId ~= 0 then
                local displayName, iconFile, effectType, sortOrder, startTime, endTime = GetArtificialEffectInfo(effectId)

                local data = ZO_GamepadEntryData:New(zo_strformat(SI_ABILITY_TOOLTIP_NAME, displayName), iconFile)
                data.displayMode = GAMEPAD_STATS_DISPLAY_MODE.EFFECTS
                data.canClickOff = false
                data.artificialEffectId = effectId
                data.tooltipTitle = displayName
                data.sortOrder = sortOrder
                data.isArtificial = true

                local duration = endTime - startTime
                if duration > 0 then
                    local timeLeft = (endTime * 1000.0) - GetFrameTimeMilliseconds()
                    data:SetCooldown(timeLeft, duration * 1000.0)
                end

                data.narrationText = GetActiveEffectNarration

                table.insert(sortedArtificialEffectsTable, data)
            end
        end

        table.sort(sortedArtificialEffectsTable, ArtificialEffectsRowComparator)

        for i, data in ipairs(sortedArtificialEffectsTable) do
            self:AddActiveEffectData(data)
        end

        -- Real Effects
        local numBuffs = GetNumBuffs("player")
        local hasActiveEffects = numBuffs > 0
        if hasActiveEffects then
            for i = 1, numBuffs do
                local buffName, startTime, endTime, buffSlot, stackCount, iconFile, deprecatedBuffType, effectType, abilityType, statusEffectType, abilityId, canClickOff = GetUnitBuffInfo("player", i)

                if buffSlot > 0 and buffName ~= "" then
                    local data = ZO_GamepadEntryData:New(zo_strformat(SI_ABILITY_TOOLTIP_NAME, buffName), iconFile)
                    data.displayMode = GAMEPAD_STATS_DISPLAY_MODE.EFFECTS
                    data.buffIndex = i
                    data.buffSlot = buffSlot
                    data.canClickOff = canClickOff
                    data.isArtificial = false

                    if stackCount > 1 then
                        data.stackCount = stackCount
                    end

                    local duration = endTime - startTime
                    if duration > 0 then
                        local timeLeft = (endTime * 1000.0) - GetFrameTimeMilliseconds()
                        data:SetCooldown(timeLeft, duration * 1000.0)
                    end

                    data.narrationText = GetActiveEffectNarration

                    -- Hide effects if they are set to hide on the override.
                    if not Effects.EffectOverride[abilityId] or (Effects.EffectOverride[abilityId] and not Effects.EffectOverride[abilityId].hide) then
                        self:AddActiveEffectData(data)
                    end
                end
            end
        end

        if self.numActiveEffects == 0 then
            local data = ZO_GamepadEntryData:New(GetString(SI_STAT_GAMEPAD_EFFECTS_NONE_ACTIVE))
            data.displayMode = GAMEPAD_STATS_DISPLAY_MODE.EFFECTS
            data:SetHeader(GetString(SI_STATS_ACTIVE_EFFECTS))

            self.mainList:AddEntryWithHeader("ZO_GamepadEffectAttributeRow", data)
        end

        self.mainList:Commit()

        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
    end

    function ZO_GamepadStats:AddActiveEffectData(data)
        if self.numActiveEffects == 0 then
            data:SetHeader(GetString(SI_STATS_ACTIVE_EFFECTS))
            self.mainList:AddEntryWithHeader("ZO_GamepadEffectAttributeRow", data)
        else
            self.mainList:AddEntry("ZO_GamepadEffectAttributeRow", data)
        end
        self.numActiveEffects = self.numActiveEffects + 1
    end

    -- Hook GAMEPAD Stats Refresh
    function ZO_GamepadStats:RefreshCharacterEffects()
        local selectedData = self.mainList:GetTargetData()

        local contentTitle, contentDescription, contentStartTime, contentEndTime, _

        local buffSlot, abilityId, buffType
        if selectedData.isArtificial then
            abilityId = selectedData.artificialEffectId
            buffType = BUFF_EFFECT_TYPE_BUFF
            contentTitle, _, _, _, contentStartTime, contentEndTime = GetArtificialEffectInfo(selectedData.artificialEffectId)
            contentDescription = GetArtificialEffectTooltipText(selectedData.artificialEffectId)
        else
            contentTitle, contentStartTime, contentEndTime, buffSlot, _, _, _, buffType, _, _, abilityId = GetUnitBuffInfo("player", selectedData.buffIndex)

            if DoesAbilityExist(abilityId) then
                contentDescription = GetAbilityEffectDescription(buffSlot)

                local timer = contentEndTime - contentStartTime
                local value2
                local value3
                if Effects.EffectOverride[abilityId] then
                    if Effects.EffectOverride[abilityId].tooltipValue2 then
                        value2 = Effects.EffectOverride[abilityId].tooltipValue2
                    elseif Effects.EffectOverride[abilityId].tooltipValue2Mod then
                        value2 = zo_floor(timer + Effects.EffectOverride[abilityId].tooltipValue2Mod + 0.5)
                    elseif Effects.EffectOverride[abilityId].tooltipValue2Id then
                        value2 = zo_floor((GetAbilityDuration(Effects.EffectOverride[abilityId].tooltipValue2Id) or 0) + 0.5) / 1000
                    else
                        value2 = 0
                    end
                else
                    value2 = 0
                end
                if Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].tooltipValue3 then
                    value3 = Effects.EffectOverride[abilityId].tooltipValue3
                else
                    value3 = 0
                end
                timer = zo_floor((timer * 10) + 0.5) / 10

                local tooltipText
                if LUIE.ResolveVeteranDifficulty() == true and Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].tooltipVeteran then
                    tooltipText = zo_strformat(Effects.EffectOverride[abilityId].tooltipVeteran, timer, value2, value3)
                else
                    tooltipText = (Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].tooltip) and zo_strformat(Effects.EffectOverride[abilityId].tooltip, timer, value2, value3) or ""
                end

                -- Display Default Tooltip Description if no custom tooltip is present
                if tooltipText == "" or tooltipText == nil then
                    if GetAbilityEffectDescription(buffSlot) ~= "" then
                        tooltipText = GetAbilityEffectDescription(buffSlot)
                    end
                end

                -- Display Default Description if no internal effect description is present
                if tooltipText == "" or tooltipText == nil then
                    if GetAbilityDescription(abilityId) ~= "" then
                        tooltipText = GetAbilityDescription(abilityId)
                    end
                end

                -- Override custom tooltip with default tooltip if this ability is flagged to do so (scaling buffs like Mundus Stones)
                if Effects.TooltipUseDefault[abilityId] then
                    if GetAbilityEffectDescription(buffSlot) ~= "" then
                        tooltipText = GetAbilityEffectDescription(buffSlot)
                        tooltipText = LUIE.UpdateMundusTooltipSyntax(abilityId, tooltipText)
                    end
                end

                -- Set the Tooltip to be default if custom tooltips aren't enabled
                if not LUIE.SpellCastBuffs.SV.TooltipCustom then
                    tooltipText = GetAbilityEffectDescription(buffSlot)
                end

                if tooltipText ~= "" then
                    tooltipText = string.match(tooltipText, ".*%S")
                end
                local thirdLine
                local timer2 = (contentEndTime - contentStartTime)
                if Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].duration then
                    timer2 = timer2 + Effects.EffectOverride[abilityId].duration
                end

                contentDescription = tooltipText
                if thirdLine ~= "" and thirdLine ~= nil then
                    contentDescription = thirdLine
                end
            end
        end

        -- Add Ability ID / Buff Type Lines
        if LUIE.SpellCastBuffs.SV.TooltipAbilityId or LUIE.SpellCastBuffs.SV.TooltipBuffType then
            -- Add Ability ID Line
            if LUIE.SpellCastBuffs.SV.TooltipAbilityId then
                local labelAbilityId
                labelAbilityId = abilityId or "None"
                if labelAbilityId == "Fake" then
                    selectedData.isArtificial = true
                end
                if selectedData.isArtificial then
                    -- ArtificialEffectId (live): 0 ESO Plus, 1 Battle Spirit, 2 LFG, 3 Battle Spirit Imperial City,
                    -- 4 Battleground Deserter, 5–8 Underdog / Solo Queue bonuses.
                    if abilityId == 0 then
                        labelAbilityId = 63601
                    elseif abilityId == 1 or abilityId == 3 then
                        labelAbilityId = 999014
                    elseif abilityId == 2 then
                        labelAbilityId = "2 (LFG)"
                    elseif abilityId == 4 then
                        labelAbilityId = "4 (BG Deserter)"
                    elseif abilityId >= 5 and abilityId <= 8 then
                        labelAbilityId = abilityId
                    else
                        labelAbilityId = "Artificial"
                    end
                end
                contentDescription = contentDescription .. "\n\nAbility ID: " .. labelAbilityId
            end

            -- Add Buff Type Line
            if LUIE.SpellCastBuffs.SV.TooltipBuffType then
                buffType = buffType or LUIE_BUFF_TYPE_NONE
                if abilityId and Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].unbreakable then
                    buffType = buffType + 2
                end

                -- Setup tooltips for player aoe trackers
                if abilityId and Effects.EffectGroundDisplay[abilityId] then
                    buffType = buffType + 4
                end

                -- Setup tooltips for ground buff/debuff effects
                if abilityId and (Effects.AddGroundDamageAura[abilityId] or (Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].groundLabel)) then
                    buffType = buffType + 6
                end

                -- Setup tooltips for Fake Player Offline Auras
                if abilityId and Effects.FakePlayerOfflineAura[abilityId] then
                    if Effects.FakePlayerOfflineAura[abilityId].ground then
                        buffType = 6
                    else
                        buffType = 5
                    end
                end

                local endLine = LUIE.buffTypes[buffType] --- @type string
                contentDescription = contentDescription .. "\nType: " .. endLine
            end
        end

        local contentDuration = contentEndTime - contentStartTime
        if contentDuration > 0 then
            local function OnTimerUpdate()
                local timeLeft = contentEndTime - (GetFrameTimeMilliseconds() / 1000.0)

                local timeLeftText = ZO_FormatTime(timeLeft, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR)

                self:RefreshContentHeader(contentTitle, GetString(SI_STAT_GAMEPAD_TIME_REMAINING), timeLeftText)
            end

            self.effectDesc:SetHandler("OnUpdate", OnTimerUpdate)
        else
            self.effectDesc:SetHandler("OnUpdate", nil)
        end

        self.effectDesc:SetText(contentDescription)
        self.effectDescNarrationText = contentDescription
        self:RefreshContentHeader(contentTitle)
    end
end
