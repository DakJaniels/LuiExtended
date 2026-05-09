--- @diagnostic disable: missing-global-doc, duplicate-set-field
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local Data = LuiData.Data
local Effects = Data.Effects

function LUIE.HookKeyboardMap()
    -- Hook campaign screen to fix icons
    local function GetFormattedBonusString(data)
        if data and data.stringId then
            if data.value then
                return zo_strformat(SI_CAMPAIGN_BONUSES_INFO_FORMATTER, GetString(data.stringId), ZO_SELECTED_TEXT:Colorize(data.value))
            else
                return GetString(data.stringId)
            end
        end
        return ""
    end

    local function GetHomeKeepBonusData(campaignId)
        local data = {}
        local allHomeKeepsHeld = GetAvAKeepScore(campaignId, GetUnitAlliance("player"))
        if allHomeKeepsHeld then
            data.stringId = SI_CAMPAIGN_BONUSES_HOME_KEEP_PASS_INFO
        else
            data.stringId = SI_CAMPAIGN_BONUSES_HOME_KEEP_FAIL_INFO
        end
        return data
    end

    local function GetHomeKeepBonusScore(campaignId)
        local allHomeKeepsHeld = GetAvAKeepScore(campaignId, GetUnitAlliance("player"))
        return allHomeKeepsHeld and 1 or 0
    end

    local function GetKeepBonusData(campaignId)
        local _, enemyKeepsHeld = GetAvAKeepScore(campaignId, GetUnitAlliance("player"))
        local data =
        {
            stringId = SI_CAMPAIGN_BONUSES_ENEMY_KEEP_INFO,
            value = enemyKeepsHeld,
        }
        return data
    end

    local function GetKeepBonusScore(campaignId)
        local allHomeKeepsHeld, enemyKeepsHeld = GetAvAKeepScore(campaignId, GetUnitAlliance("player"))
        return allHomeKeepsHeld and enemyKeepsHeld or 0
    end

    local function GetEdgeKeepBonusScore(campaignId)
        return select(5, GetAvAKeepScore(campaignId, GetUnitAlliance("player")))
    end

    local function GetEdgeKeepBonusData(campaignId)
        local data =
        {
            stringId = SI_CAMPAIGN_BONUSES_EDGE_KEEP_INFO,
            value = GetEdgeKeepBonusScore(campaignId),
        }
        return data
    end

    local function GetDefensiveBonusData(campaignId)
        local _, enemyScrollsHeld = GetAvAArtifactScore(campaignId, GetUnitAlliance("player"), OBJECTIVE_ARTIFACT_DEFENSIVE)
        local data =
        {
            stringId = SI_CAMPAIGN_BONUSES_ENEMY_SCROLL_INFO,
            value = enemyScrollsHeld,
        }
        return data
    end

    local function GetDefensiveBonusCount()
        return GetNumArtifactScoreBonuses(GetUnitAlliance("player"), OBJECTIVE_ARTIFACT_DEFENSIVE)
    end

    local function GetDefensiveBonusAbilityId(index)
        return GetArtifactScoreBonusAbilityId(GetUnitAlliance("player"), OBJECTIVE_ARTIFACT_DEFENSIVE, index)
    end

    local function GetDefensiveBonusScore(campaignId)
        local allHomeScrollsHeld, enemyScrollsHeld = GetAvAArtifactScore(campaignId, GetUnitAlliance("player"), OBJECTIVE_ARTIFACT_DEFENSIVE)
        return allHomeScrollsHeld and enemyScrollsHeld or 0
    end

    local function GetOffensiveBonusData(campaignId)
        local _, enemyScrollsHeld = GetAvAArtifactScore(campaignId, GetUnitAlliance("player"), OBJECTIVE_ARTIFACT_OFFENSIVE)
        local data =
        {
            stringId = SI_CAMPAIGN_BONUSES_ENEMY_SCROLL_INFO,
            value = enemyScrollsHeld,
        }
        return data
    end

    local function GetOffensiveBonusCount()
        return GetNumArtifactScoreBonuses(GetUnitAlliance("player"), OBJECTIVE_ARTIFACT_OFFENSIVE)
    end

    local function GetOffensiveBonusAbilityId(index)
        return GetArtifactScoreBonusAbilityId(GetUnitAlliance("player"), OBJECTIVE_ARTIFACT_OFFENSIVE, index)
    end

    local function GetOffensiveBonusScore(campaignId)
        local allHomeScrollsHeld, enemyScrollsHeld = GetAvAArtifactScore(campaignId, GetUnitAlliance("player"), OBJECTIVE_ARTIFACT_OFFENSIVE)
        return allHomeScrollsHeld and enemyScrollsHeld or 0
    end

    local function GetEmperorBonusData(campaignId)
        local data = {}
        if DoesCampaignHaveEmperor(campaignId) then
            local alliance = GetCampaignEmperorInfo(campaignId)
            if alliance == GetUnitAlliance("player") then
                data.stringId = SI_CAMPAIGN_BONUSES_EMPEROR_PASS_INFO
            else
                data.stringId = SI_CAMPAIGN_BONUSES_EMPEROR_FAIL_INFO
            end
        else
            data.stringId = SI_CAMPAIGN_BONUSES_EMPEROR_NONE_INFO
        end
        return data
    end

    local function GetEmperorBonusAbilityId(index, campaignId)
        local emperorBonusRank = ZO_CampaignBonuses_GetEmperorBonusRank(campaignId)
        return GetEmperorAllianceBonusAbilityId(emperorBonusRank)
    end

    local function GetEmperorBonusScore(campaignId)
        if DoesCampaignHaveEmperor(campaignId) then
            local alliance = GetCampaignEmperorInfo(campaignId)
            if alliance == GetUnitAlliance("player") then
                return 1
            end
        end

        return 0
    end

    local BONUS_SECTION_DATA =
    {
        [ZO_CAMPAIGN_BONUS_TYPE_HOME_KEEPS] =
        {
            typeIcon = "EsoUI/Art/Campaign/campaignBonus_keepIcon.dds",
            typeIconGamepad = "EsoUI/Art/Campaign/Gamepad/gp_bonusIcon_keeps.dds",
            headerText = GetString(SI_CAMPAIGN_BONUSES_HOME_KEEP_HEADER),
            infoData = GetHomeKeepBonusData,
            count = 1,
            countText = GetString(SI_CAMPAIGN_BONUSES_HOME_KEEP_ALL),
            abilityFunction = GetKeepScoreBonusAbilityId,
            scoreFunction = GetHomeKeepBonusScore,
        },
        [ZO_CAMPAIGN_BONUS_TYPE_EMPEROR] =
        {
            typeIcon = "EsoUI/Art/Campaign/campaignBonus_emperorshipIcon.dds",
            typeIconGamepad = "EsoUI/Art/Campaign/Gamepad/gp_bonusIcon_emperor.dds",
            headerText = GetString(SI_CAMPAIGN_BONUSES_EMPERORSHIP_HEADER),
            infoData = GetEmperorBonusData,
            count = 1,
            countText = 0,
            abilityFunction = GetEmperorBonusAbilityId,
            scoreFunction = GetEmperorBonusScore,
        },
        [ZO_CAMPAIGN_BONUS_TYPE_ENEMY_KEEPS] =
        {
            typeIcon = "EsoUI/Art/Campaign/campaignBonus_keepIcon.dds",
            typeIconGamepad = "EsoUI/Art/Campaign/Gamepad/gp_bonusIcon_keeps.dds",
            headerText = GetString(SI_CAMPAIGN_BONUSES_ENEMY_KEEP_HEADER),
            infoData = GetKeepBonusData,
            detailsText = GetString(SI_CAMPAIGN_BONUSES_KEEP_REQUIRE_HOME_KEEP),
            count = GetNumKeepScoreBonuses,
            startIndex = 2,
            abilityFunction = GetKeepScoreBonusAbilityId,
            scoreFunction = GetKeepBonusScore,
        },
        [ZO_CAMPAIGN_BONUS_TYPE_DEFENSIVE_SCROLLS] =
        {
            typeIcon = "EsoUI/Art/Campaign/campaignBonus_scrollIcon.dds",
            typeIconGamepad = "EsoUI/Art/Campaign/Gamepad/gp_bonusIcon_scrolls.dds",
            headerText = GetString(SI_CAMPAIGN_BONUSES_DEFENSIVE_SCROLL_HEADER),
            infoData = GetDefensiveBonusData,
            detailsText = GetString(SI_CAMPAIGN_BONUSES_KEEP_REQUIRE_HOME_SCROLLS),
            count = GetDefensiveBonusCount,
            abilityFunction = GetDefensiveBonusAbilityId,
            scoreFunction = GetDefensiveBonusScore,
        },
        [ZO_CAMPAIGN_BONUS_TYPE_OFFENSIVE_SCROLLS] =
        {
            typeIcon = "EsoUI/Art/Campaign/campaignBonus_scrollIcon.dds",
            typeIconGamepad = "EsoUI/Art/Campaign/Gamepad/gp_bonusIcon_scrolls.dds",
            headerText = GetString(SI_CAMPAIGN_BONUSES_OFFENSIVE_SCROLL_HEADER),
            infoData = GetOffensiveBonusData,
            detailsText = GetString(SI_CAMPAIGN_BONUSES_KEEP_REQUIRE_HOME_SCROLLS),
            count = GetOffensiveBonusCount,
            abilityFunction = GetOffensiveBonusAbilityId,
            scoreFunction = GetOffensiveBonusScore,
        },
        [ZO_CAMPAIGN_BONUS_TYPE_EDGE_KEEPS] =
        {
            typeIcon = "EsoUI/Art/Campaign/campaignBonus_keepIcon.dds",
            typeIconGamepad = "EsoUI/Art/Campaign/Gamepad/gp_bonusIcon_keeps.dds",
            headerText = GetString(SI_CAMPAIGN_BONUSES_EDGE_KEEP_HEADER),
            infoData = GetEdgeKeepBonusData,
            count = GetNumEdgeKeepBonuses,
            abilityFunction = GetEdgeKeepBonusAbilityId,
            scoreFunction = GetEdgeKeepBonusScore,
        },
    }

    -- Hook Campaign Bonuses Data Table
    ZO_CampaignBonuses_Shared.CreateDataTable = function (self)
        self:BuildMasterList()

        self.dataTable = {}
        local nextItemIsHeader = false
        local headerName = nil
        for i = 1, #self.masterList do
            local data = self.masterList[i]
            if data.isHeader then
                nextItemIsHeader = true
                headerName = data.headerString
            else
                self.dataTable[i] = ZO_GamepadEntryData:New(data.name, data.icon)

                if nextItemIsHeader then
                    self.dataTable[i]:SetHeader(headerName)
                end

                self.dataTable[i].index = data.index
                self.dataTable[i].abilityId = data.abilityId -- Add AbilityId here for LUIE functions
                self.dataTable[i].typeIcon = data.typeIcon
                self.dataTable[i].countText = data.countText
                self.dataTable[i].name = data.name -- Add AbilityName here for LUIE functions
                self.dataTable[i].active = data.active
                self.dataTable[i].bonusType = data.bonusType
                self.dataTable[i].description = data.description

                nextItemIsHeader = false
            end
        end
    end

    -- Hook Campaign Bonuses Build Master List
    ZO_CampaignBonuses_Shared.BuildMasterList = function (self)
        self.masterList = {}

        for bonusType, info in ipairs(BONUS_SECTION_DATA) do
            local infoData
            infoData = info.infoData
            if type(info.infoData) == "function" then
                infoData = info.infoData(self.campaignId)
            end

            local infoText = ""
            if infoData then
                infoText = GetFormattedBonusString(infoData)
            end

            local detailsText = info.detailsText
            if type(info.detailsText) == "function" then
                detailsText = info.detailsText(self.campaignId)
            end

            local headerData =
            {
                isHeader = true,
                headerString = info.headerText,
                infoString = infoText,
                detailsString = detailsText or "",
                bonusType = bonusType,
            }

            self.masterList[#self.masterList + 1] = headerData

            local startIndex = info.startIndex or 1
            local score = info.scoreFunction(self.campaignId)
            local index = score and score ~= 0 and score + startIndex - 1 or startIndex
            -- Code only supports 10 bonuses even though the player's alliance could have acquired up to 12 keeps
            -- so cap the keep index to the max count allowed by the bonus data info
            local count = type(info.count) == "function" and info.count(self.campaignId) or info.count
            index = zo_min(index, count)
            local scoreIndex = index - startIndex + 1
            local countText
            countText = scoreIndex
            --- @diagnostic disable-next-line: redundant-parameter
            local abilityId = info.abilityFunction(index, self.campaignId)
            local name = GetAbilityName(abilityId)
            local icon = (Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].passiveIcon) and Effects.EffectOverride[abilityId].passiveIcon or GetAbilityIcon(abilityId)       -- Get Updated LUIE AbilityIcon here
            local description = (Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].tooltip) and Effects.EffectOverride[abilityId].tooltip or GetAbilityDescription(abilityId) -- Get Updated LUIE Tooltip here

            if info.countText then
                if info.countText == 0 then
                    countText = nil
                else
                    countText = info.countText
                end
            end

            local data =
            {
                index = index,
                isHeader = false,
                typeIcon = info.typeIcon,
                typeIconGamepad = info.typeIconGamepad,
                countText = countText,
                name = zo_strformat(SI_CAMPAIGN_BONUSES_ENTRY_ROW_FORMATTER, name),
                icon = icon,
                active = score and score >= scoreIndex,
                bonusType = bonusType,
                description = description,
                infoData = infoData,
                detailsText = detailsText or "",
            }

            self.masterList[#self.masterList + 1] = data
        end

        return self.masterList
    end



    -- Hook Campaign Bonuses Manager (we add abilityId, name, and the description to the control to carry over to the OnMouseEnter tooltip function)
    function ZO_CampaignBonusesManager:SetupBonusesEntry(control, data)
        ZO_SortFilterList.SetupRow(self, control, data)

        control.typeIcon = control:GetNamedChild("TypeIcon")
        control.count = control:GetNamedChild("Count")
        control.ability = control:GetNamedChild("Ability")
        control.icon = control.ability:GetNamedChild("Icon")
        control.nameLabel = control:GetNamedChild("Name")
        control.ability.index = data.index
        control.ability.bonusType = data.bonusType
        control.ability.abilityId = data.abilityId     -- Add AbilityId here to carry over to OnMouseEnter tooltip function
        control.ability.name = data.name               -- Add AbilityName here to carry over to OnMouseEnter tooltip function
        control.ability.description = data.description -- Add Tooltip here to carry over to OnMouseEnter tooltip function

        control.ability:SetEnabled(data.active)
        ZO_ActionSlot_SetUnusable(control.icon, not data.active)

        control.typeIcon:SetTexture(data.typeIcon)
        if data.countText then
            control.count:SetText(zo_strformat(SI_CAMPAIGN_SCORING_HOLDING, data.countText))
            control.count:SetHidden(false)
        else
            control.count:SetHidden(true)
        end
        control.nameLabel:SetText(data.name)
        control.icon:SetTexture(data.icon)
    end

    -- Generates extra lines for the Tooltips to show if the criteria for activating the passive is met (matches base functionality)
    local function KeepTooltipExtra(bonusType, tooltip)
        -- Local fields
        local r1, b1, g1
        local r2, b2, g2
        local tooltipLine2
        local tooltipLine3
        local showLine3

        -- Set text color
        local function SetAVATooltipColor(criteriaMet)
            local color = criteriaMet and ZO_SUCCEEDED_TEXT or ZO_ERROR_COLOR
            local r, g, b = color:UnpackRGB()
            return r, g, b
        end

        -- Check Defensive Scroll Bonuses
        local function DefensiveScrolls(campaignId)
            campaignId = campaignId or GetCurrentCampaignId()
            local allHomeScrollsHeld, enemyScrollsHeld = GetAvAArtifactScore(campaignId, GetUnitAlliance("player"), OBJECTIVE_ARTIFACT_DEFENSIVE)
            return allHomeScrollsHeld, enemyScrollsHeld
        end

        -- Check Offensive Scroll Bonuses
        local function OffensiveScrolls(campaignId)
            campaignId = campaignId or GetCurrentCampaignId()
            local allHomeScrollsHeld, enemyScrollsHeld = GetAvAArtifactScore(campaignId, GetUnitAlliance("player"), OBJECTIVE_ARTIFACT_OFFENSIVE)
            return allHomeScrollsHeld, enemyScrollsHeld
        end

        local campaignId = GetCurrentCampaignId()
        -- Conditional handling
        if bonusType == ZO_CAMPAIGN_BONUS_TYPE_DEFENSIVE_SCROLLS then
            tooltipLine2 = GetString(SI_CAMPAIGN_BONUSES_TOOLTIP_REQUIRES_DEFENSIVE_SCROLL)
            tooltipLine3 = GetString(SI_CAMPAIGN_BONUSES_TOOLTIP_REQUIRES_ALL_HOME_SCROLLS)
            local allHomeScrollsHeld, enemyScrollsHeld = DefensiveScrolls(campaignId)
            r1, b1, g1 = SetAVATooltipColor(enemyScrollsHeld > 0)
            r2, b2, g2 = SetAVATooltipColor(allHomeScrollsHeld)
            showLine3 = true
        elseif bonusType == ZO_CAMPAIGN_BONUS_TYPE_OFFENSIVE_SCROLLS then
            tooltipLine2 = GetString(SI_CAMPAIGN_BONUSES_TOOLTIP_REQUIRES_OFFENSIVE_SCROLL)
            tooltipLine3 = GetString(SI_CAMPAIGN_BONUSES_TOOLTIP_REQUIRES_ALL_HOME_SCROLLS)
            local allHomeScrollsHeld, enemyScrollsHeld = OffensiveScrolls(campaignId)
            r1, b1, g1 = SetAVATooltipColor(enemyScrollsHeld > 0)
            r2, b2, g2 = SetAVATooltipColor(allHomeScrollsHeld)
            showLine3 = true
        elseif bonusType == ZO_CAMPAIGN_BONUS_TYPE_EMPEROR then
            tooltipLine2 = GetString(SI_CAMPAIGN_BONUSES_TOOLTIP_REQUIRES_EMPEROR_ALLIANCE)
            local isEmperor = GetEmperorBonusScore(campaignId)
            r1, b1, g1 = SetAVATooltipColor(isEmperor == 1)
        elseif bonusType == ZO_CAMPAIGN_BONUS_TYPE_EDGE_KEEPS then
            tooltipLine2 = GetString(SI_CAMPAIGN_BONUSES_TOOLTIP_REQUIRES_NUM_EDGE_KEEPS)
            local edgeKeepBonus = GetEdgeKeepBonusScore(campaignId)
            r1, b1, g1 = SetAVATooltipColor(edgeKeepBonus > 0)
        else
            tooltipLine2 = GetString(SI_CAMPAIGN_BONUSES_TOOLTIP_REQUIRES_ALL_HOME_KEEPS)
            local allHomeKeepsHeld = GetHomeKeepBonusScore(campaignId)
            r1, b1, g1 = SetAVATooltipColor(allHomeKeepsHeld > 0)
        end

        -- Display Tooltip
        tooltip:AddLine(tooltipLine2, "", r1, b1, g1, nil, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER)
        if showLine3 then
            tooltip:AddLine(tooltipLine3, "", r2, b2, g2, nil, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER)
        end
    end

    -- Hook Campaign Bonuses Tooltip
    function ZO_CampaignBonuses_AbilitySlot_OnMouseEnter(control)
        local abilityId = control.abilityId
        local name = control.name
        local description = control.description
        -- Create a Tooltip matching the default Campaign Bonuses Tooltip
        InitializeTooltip(SkillTooltip, control, TOPLEFT, 5, -5, TOPRIGHT)
        SkillTooltip:SetVerticalPadding(16)
        SkillTooltip:AddLine(name, "ZoFontHeader3", 1, 1, 1, nil, MODIFY_TEXT_TYPE_UPPERCASE, TEXT_ALIGN_CENTER)
        SkillTooltip:SetVerticalPadding(0)
        ZO_Tooltip_AddDivider(SkillTooltip)
        SkillTooltip:SetVerticalPadding(8)
        local r, b, g = ZO_NORMAL_TEXT:UnpackRGB()
        SkillTooltip:AddLine(description, "", r, b, g, nil, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER)
        -- Setup extra tooltip information
        KeepTooltipExtra(control.bonusType, SkillTooltip)
    end

    -- Hook AVA Keep Upgrade
    ZO_MapKeepUpgrade_Shared.RefreshLevels = function (self)
        self.levelsGridList:ClearGridList()

        for currentLevel = 0, GetKeepMaxUpgradeLevel(self.keepUpgradeObject:GetKeep()) do
            local numUpgrades = self.keepUpgradeObject:GetNumLevelUpgrades(currentLevel)
            if numUpgrades > 0 then
                local levelHeaderText = zo_strformat(SI_KEEP_UPGRADE_LEVEL_SECTION_HEADER, currentLevel)
                for i = 1, numUpgrades do
                    local name, description, icon, atPercent, isActive = self.keepUpgradeObject:GetLevelUpgradeInfo(currentLevel, i)

                    -- Override with custom icons here.
                    if Effects.KeepUpgradeOverride[name] then
                        icon = Effects.KeepUpgradeOverride[name]
                    end
                    -- Override with custom faction icons here.
                    if Effects.KeepUpgradeAlliance[name] then
                        icon = Effects.KeepUpgradeAlliance[name][LUIE.PlayerFaction]
                    end
                    -- Special condition to display a unique icon for rank 2 of siege cap upgrade.
                    if name == LuiData.Data.Abilities.Keep_Upgrade_Wood_Siege_Cap and currentLevel == 2 then
                        icon = LUIE_MEDIA_ICONS_KEEPUPGRADE_UPGRADE_WOOD_SIEGE_CAP_2_DDS
                    end
                    -- Update the tooltips.
                    if Effects.KeepUpgrade_Tooltip[name] then
                        description = Effects.KeepUpgrade_Tooltip[name]
                    end
                    -- Update the name (Note: We do this last since our other conditionals check by name).
                    if Effects.KeepUpgradeNameFix[name] then
                        name = Effects.KeepUpgradeNameFix[name]
                    end

                    local data =
                    {
                        index = i,
                        gridHeaderName = levelHeaderText,
                        level = currentLevel,
                        name = name,
                        description = description,
                        icon = icon,
                        atPercent = atPercent,
                        isActive = isActive,
                    }

                    self.levelsGridList:AddEntry(ZO_GridSquareEntryData_Shared:New(data))
                end
            end
        end

        self.levelsGridList:CommitGridList()
    end

    -- Hook Keep Upgrade Tooltip (Keyboard)
    WORLD_MAP_KEEP_UPGRADE.Button_OnMouseEnter = function (self, control)
        InitializeTooltip(KeepUpgradeTooltip, control, TOPLEFT, 5, 0)

        local data = control.dataEntry.data:GetDataSource()

        -- Create a custom Tooltip matching the format of the default Keep Upgrade Tooltips
        local level = zo_strformat("<<1>> <<2>>", GetString(SI_ITEM_FORMAT_STR_LEVEL), data.level)
        local name = zo_strformat("<<1>>", data.name)
        local description = data.description

        KeepUpgradeTooltip:SetVerticalPadding(16)
        KeepUpgradeTooltip:AddLine(name, "ZoFontHeader3", 1, 1, 1, nil, MODIFY_TEXT_TYPE_UPPERCASE, TEXT_ALIGN_CENTER)
        KeepUpgradeTooltip:SetVerticalPadding(0)
        ZO_Tooltip_AddDivider(KeepUpgradeTooltip)
        KeepUpgradeTooltip:SetVerticalPadding(7)
        KeepUpgradeTooltip:AddLine(level, "ZoFontWinT1", 1, 1, 1, nil, MODIFY_TEXT_TYPE_UPPERCASE, TEXT_ALIGN_CENTER, false, 344)
        KeepUpgradeTooltip:SetVerticalPadding(0)
        local r, b, g = ZO_NORMAL_TEXT:UnpackRGB()
        KeepUpgradeTooltip:AddLine(description, "", r, b, g, nil, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER)
        KeepUpgradeTooltip:SetVerticalPadding(0)
    end
end
