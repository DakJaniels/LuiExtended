--- @diagnostic disable: duplicate-set-field
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

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

        local function ApplyStatsRowCooldown(data, startTime, endTime)
            local duration = endTime - startTime
            if duration > 0 then
                local timeLeft = (endTime * 1000.0) - GetFrameTimeMilliseconds()
                data:SetCooldown(timeLeft, duration * 1000.0)
            end
        end

        local function GamepadEntryFromStatsRow(row)
            local data = ZO_GamepadEntryData:New(zo_strformat(SI_ABILITY_TOOLTIP_NAME, row.displayName), row.displayIcon)
            data.displayMode = GAMEPAD_STATS_DISPLAY_MODE.EFFECTS
            data.canClickOff = false
            data.isArtificial = row.isArtificial
            data.narrationText = GetActiveEffectNarration
            data.startTime = row.startTime
            data.endTime = row.endTime
            data.effectType = row.effectType

            if row.isArtificial then
                data.artificialEffectId = row.artificialEffectId
                data.tooltipTitle = row.displayName
                data.sortOrder = row.sortOrder
                ApplyStatsRowCooldown(data, row.startTime, row.endTime)
            else
                data.buffIndex = row.buffIndex
                data.buffSlot = row.buffSlot
                data.abilityId = row.abilityId
                data.isSyntheticFromScb = row.isSyntheticFromScb
                data.scbTooltipText = row.tooltipText
                if row.stackCount and row.stackCount > 1 then
                    data.stackCount = row.stackCount
                end
                ApplyStatsRowCooldown(data, row.startTime, row.endTime)
            end

            return data
        end

        for _, row in ipairs(LUIE.BuildStatsActiveEffectRows()) do
            self:AddActiveEffectData(GamepadEntryFromStatsRow(row))
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
        elseif selectedData.isSyntheticFromScb then
            abilityId = selectedData.abilityId
            buffType = selectedData.effectType or BUFF_EFFECT_TYPE_BUFF
            contentTitle = selectedData:GetDisplayName()
            contentStartTime = selectedData.startTime
            contentEndTime = selectedData.endTime
            contentDescription = selectedData.scbTooltipText or ""
        else
            contentTitle, contentStartTime, contentEndTime, buffSlot, _, _, _, buffType, _, _, abilityId = GetUnitBuffInfo("player", selectedData.buffIndex)

            contentDescription = LUIE.GetStatsActiveEffectTooltipText(abilityId, buffSlot, contentStartTime, contentEndTime)
            if (contentDescription == "" or contentDescription == nil) and buffSlot then
                contentDescription = GetAbilityEffectDescription(buffSlot)
            end
        end

        -- Add Ability ID / Buff Type Lines
        if LUIE.SpellCastBuffs.SV.TooltipAbilityId or LUIE.SpellCastBuffs.SV.TooltipBuffType then
            -- Add Ability ID Line
            if LUIE.SpellCastBuffs.SV.TooltipAbilityId then
                local labelAbilityId = abilityId or "None"
                if labelAbilityId == "Fake" then
                    selectedData.isArtificial = true
                end
                if selectedData.isArtificial then
                    labelAbilityId = LUIE.FormatStatsActiveEffectAbilityIdLabel(abilityId, true)
                end
                contentDescription = contentDescription .. "\n\nAbility ID: " .. labelAbilityId
            end

            -- Add Buff Type Line
            if LUIE.SpellCastBuffs.SV.TooltipBuffType then
                local buffTypeLookupId = selectedData.isArtificial and nil or abilityId
                buffType = LUIE.GetStatsActiveEffectTooltipBuffType(buffTypeLookupId, buffType)
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
