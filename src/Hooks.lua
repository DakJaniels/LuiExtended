-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local type, pairs, ipairs = type, pairs, ipairs
local zo_strformat = zo_strformat
local printToChat = LUIE.PrintToChat
local table_insert = table.insert
local table_sort = table.sort
local ANIMATION_MANAGER = GetAnimationManager()

local FORCE_SUPPRESS_COOLDOWN_SOUND = true
local HIDE_COUNT = 0
local overrideActiveRank = nil
local overrideCasterUnitTag = "player"

--- @type table<integer, string>
local buffTypes =
{
    [LUIE_BUFF_TYPE_BUFF] = GetString(LUIE_STRING_BUFF_TYPE_BUFF),
    [LUIE_BUFF_TYPE_DEBUFF] = GetString(LUIE_STRING_BUFF_TYPE_DEBUFF),
    [LUIE_BUFF_TYPE_UB_BUFF] = GetString(LUIE_STRING_BUFF_TYPE_UB_BUFF),
    [LUIE_BUFF_TYPE_UB_DEBUFF] = GetString(LUIE_STRING_BUFF_TYPE_UB_DEBUFF),
    [LUIE_BUFF_TYPE_GROUND_BUFF_TRACKER] = GetString(LUIE_STRING_BUFF_TYPE_GROUND_BUFF_TRACKER),
    [LUIE_BUFF_TYPE_GROUND_DEBUFF_TRACKER] = GetString(LUIE_STRING_BUFF_TYPE_GROUND_DEBUFF_TRACKER),
    [LUIE_BUFF_TYPE_GROUND_AOE_BUFF] = GetString(LUIE_STRING_BUFF_TYPE_GROUND_AOE_BUFF),
    [LUIE_BUFF_TYPE_GROUND_AOE_DEBUFF] = GetString(LUIE_STRING_BUFF_TYPE_GROUND_AOE_DEBUFF),
    [LUIE_BUFF_TYPE_ENVIRONMENT_BUFF] = GetString(LUIE_STRING_BUFF_TYPE_ENVIRONMENT_BUFF),
    [LUIE_BUFF_TYPE_ENVIRONMENT_DEBUFF] = GetString(LUIE_STRING_BUFF_TYPE_ENVIRONMENT_DEBUFF),
    [LUIE_BUFF_TYPE_NONE] = GetString(LUIE_STRING_BUFF_TYPE_NONE),
}

function LUIE.InitializeHooks()
    -- Hook Gamepad Skill Advisor for custom icon support
    -- Check if custom icons are enabled in settings
    -- if LUIE.SV.CustomIcons_Enabled then
    LUIE.InitializeHooksSkillAdvisor()

    local zos_GetSkillAbilityInfo = GetSkillAbilityInfo
    --- Hook for Icon/Name changes.
    --- @param skillType SkillType
    --- @param skillIndex luaindex
    --- @param abilityIndex luaindex
    --- @return string name
    --- @return textureName texture
    --- @return luaindex earnedRank
    --- @return bool passive
    --- @return bool ultimate
    --- @return bool purchased
    --- @return luaindex|nil progressionIndex
    --- @return integer rank
    GetSkillAbilityInfo = function (skillType, skillIndex, abilityIndex)
        local name, texture, earnedRank, passive, ultimate, purchased, progressionIndex, rankIndex = zos_GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
        local abilityId = GetSkillAbilityId(skillType, skillIndex, abilityIndex, true)
        if LUIE.Data.Effects.EffectOverride[abilityId] and LUIE.Data.Effects.EffectOverride[abilityId].icon then
            texture = LUIE.Data.Effects.EffectOverride[abilityId].icon
        end
        if LUIE.Data.Effects.EffectOverride[abilityId] and LUIE.Data.Effects.EffectOverride[abilityId].name then
            name = LUIE.Data.Effects.EffectOverride[abilityId].name
        end
        return name, texture, earnedRank, passive, ultimate, purchased, progressionIndex, rankIndex
    end

    local zos_GetSkillAbilityNextUpgradeInfo = GetSkillAbilityNextUpgradeInfo
    --- Hook for Icon/Name changes.
    --- @param skillType SkillType
    --- @param skillIndex luaindex
    --- @param abilityIndex luaindex
    --- @return string name
    --- @return textureName texture
    --- @return luaindex|nil earnedRank
    GetSkillAbilityNextUpgradeInfo = function (skillType, skillIndex, abilityIndex)
        local name, texture, earnedRank = zos_GetSkillAbilityNextUpgradeInfo(skillType, skillIndex, abilityIndex)
        local abilityId = GetSkillAbilityId(skillType, skillIndex, abilityIndex, true)
        if LUIE.Data.Effects.EffectOverride[abilityId] and LUIE.Data.Effects.EffectOverride[abilityId].icon then
            texture = LUIE.Data.Effects.EffectOverride[abilityId].icon
        end
        if LUIE.Data.Effects.EffectOverride[abilityId] and LUIE.Data.Effects.EffectOverride[abilityId].name then
            name = LUIE.Data.Effects.EffectOverride[abilityId].name
        end
        return name, texture, earnedRank
    end

    local zos_GetUnitBuffInfo = GetUnitBuffInfo
    --- Hook for Icon/Name changes.
    --- @param unitTag string
    --- @param buffIndex luaindex
    --- @return string buffName
    --- @return number timeStarted
    --- @return number timeEnding
    --- @return integer buffSlot
    --- @return integer stackCount
    --- @return textureName iconFilename
    --- @return string deprecatedBuffType
    --- @return BuffEffectType effectType
    --- @return AbilityType abilityType
    --- @return StatusEffectType statusEffectType
    --- @return integer abilityId
    --- @return bool canClickOff
    --- @return bool castByPlayer
    GetUnitBuffInfo = function (unitTag, buffIndex)
        local buffName, startTime, endTime, buffSlot, stackCount, iconFile, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = zos_GetUnitBuffInfo(unitTag, buffIndex)
        if LUIE.Data.Effects.EffectOverride[abilityId] and LUIE.Data.Effects.EffectOverride[abilityId].name then
            buffName = LUIE.Data.Effects.EffectOverride[abilityId].name
        end
        if LUIE.Data.Effects.EffectOverride[abilityId] and LUIE.Data.Effects.EffectOverride[abilityId].icon then
            iconFile = LUIE.Data.Effects.EffectOverride[abilityId].icon
        end
        return buffName, startTime, endTime, buffSlot, stackCount, iconFile, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer
    end

    local zos_GetKillingAttackerInfo = GetKillingAttackerInfo               -- Add a source to attacks that don't normally show one (mostly for environmental effects).
    local zos_GetKillingAttackInfo = GetKillingAttackInfo                   -- Change Source Name, Pet Name, or toggle damage that is sourced from the Player on/off.
    local zos_DoesKillingAttackHaveAttacker = DoesKillingAttackHaveAttacker -- Change Icon or Name (additional support for Zone based changes, and source attacker/pet changes).

    --- Override function for DoesKillingAttackHaveAttacker.
    --- @param index luaindex
    --- @return bool hasAttacker
    DoesKillingAttackHaveAttacker = function (index)
        local hasAttacker = zos_DoesKillingAttackHaveAttacker(index)
        local attackName, attackDamage, attackIcon, wasKillingBlow, castTimeAgoMS, durationMS, numAttackHits, abilityId = zos_GetKillingAttackInfo(index)
        if LUIE.Data.Effects.EffectSourceOverride[abilityId] then
            if LUIE.Data.Effects.EffectSourceOverride[abilityId].addSource then
                hasAttacker = true
            end
        end
        return hasAttacker
    end

    --- Override function for GetKillingAttackerInfo.
    --- @param index luaindex
    --- @return string attackerRawName
    --- @return integer attackerChampionPoints
    --- @return integer attackerLevel
    --- @return integer attackerAvARank
    --- @return bool isPlayer
    --- @return bool isBoss
    --- @return Alliance alliance
    --- @return string minionName
    --- @return string attackerDisplayName
    GetKillingAttackerInfo = function (index)
        local attackerRawName, attackerChampionPoints, attackerLevel, attackerAvARank, isPlayer, isBoss, alliance, minionName, attackerDisplayName = zos_GetKillingAttackerInfo(index)
        local attackName, attackDamage, attackIcon, wasKillingBlow, castTimeAgoMS, durationMS, numAttackHits, abilityId = zos_GetKillingAttackInfo(index)
        if LUIE.Data.Effects.EffectSourceOverride[abilityId] then
            if LUIE.Data.Effects.EffectSourceOverride[abilityId].source then
                attackerRawName = LUIE.Data.Effects.EffectSourceOverride[abilityId].source
            end
            if LUIE.Data.Effects.EffectSourceOverride[abilityId].pet then
                minionName = LUIE.Data.Effects.EffectSourceOverride[abilityId].pet
            end
            if LUIE.Data.Effects.EffectSourceOverride[abilityId].removePlayer then
                isPlayer = false
            end
            if LUIE.Data.Effects.ZoneDataOverride[abilityId] then
                local index1 = GetZoneId(GetCurrentMapZoneIndex())
                local zoneName = GetPlayerLocationName()
                if LUIE.Data.Effects.ZoneDataOverride[abilityId][index1] then
                    if LUIE.Data.Effects.ZoneDataOverride[abilityId][index1].source then
                        attackerRawName = LUIE.Data.Effects.ZoneDataOverride[abilityId][index1].source
                    end
                end
                if LUIE.Data.Effects.ZoneDataOverride[abilityId][zoneName] then
                    if LUIE.Data.Effects.ZoneDataOverride[abilityId][zoneName].source then
                        attackerRawName = LUIE.Data.Effects.ZoneDataOverride[abilityId][zoneName].source
                    end
                end
            end
        end
        return attackerRawName, attackerChampionPoints, attackerLevel, attackerAvARank, isPlayer, isBoss, alliance, minionName, attackerDisplayName
    end

    --- Override function for GetKillingAttackInfo.
    --- @param index luaindex
    --- @return string|nil attackName
    --- @return integer|nil attackDamage
    --- @return textureName|nil attackIcon
    --- @return bool|nil wasKillingBlow
    --- @return integer|nil castTimeAgoMS
    --- @return integer|nil durationMS
    --- @return integer|nil numAttackHits
    --- @return integer|nil abilityId
    --- @return textureName|nil abilityFxIcon
    GetKillingAttackInfo = function (index)
        local attackerRawName, attackerChampionPoints, attackerLevel, attackerAvARank, isPlayer, isBoss, alliance, minionName, attackerDisplayName = zos_GetKillingAttackerInfo(index)
        local attackName, attackDamage, attackIcon, wasKillingBlow, castTimeAgoMS, durationMS, numAttackHits, abilityId = zos_GetKillingAttackInfo(index)

        -- Check if there is an effect override for the abilityId
        if LUIE.Data.Effects.EffectOverride[abilityId] then
            attackName = LUIE.Data.Effects.EffectOverride[abilityId].name or attackName
            attackIcon = LUIE.Data.Effects.EffectOverride[abilityId].icon or attackIcon
        end

        -- Check if there is a zone data override for the abilityId
        if LUIE.Data.Effects.ZoneDataOverride[abilityId] then
            local index2 = GetZoneId(GetCurrentMapZoneIndex())
            local zoneName = GetPlayerLocationName()

            -- Check if there is a zone data override for the current zone index
            if LUIE.Data.Effects.ZoneDataOverride[abilityId][index2] then
                if LUIE.Data.Effects.ZoneDataOverride[abilityId][index2].icon then
                    attackIcon = LUIE.Data.Effects.ZoneDataOverride[abilityId][index2].icon
                end
                if LUIE.Data.Effects.ZoneDataOverride[abilityId][index2].name then
                    attackName = LUIE.Data.Effects.ZoneDataOverride[abilityId][index2].name
                end
                if LUIE.Data.Effects.ZoneDataOverride[abilityId][index2].hide then
                    return
                end
            end

            -- Check if there is a zone data override for the current zone name
            if LUIE.Data.Effects.ZoneDataOverride[abilityId][zoneName] then
                if LUIE.Data.Effects.ZoneDataOverride[abilityId][zoneName].icon then
                    attackIcon = LUIE.Data.Effects.ZoneDataOverride[abilityId][zoneName].icon
                end
                if LUIE.Data.Effects.ZoneDataOverride[abilityId][zoneName].name then
                    attackName = LUIE.Data.Effects.ZoneDataOverride[abilityId][zoneName].name
                end
                if LUIE.Data.Effects.ZoneDataOverride[abilityId][zoneName].hide then
                    return
                end
            end
        end

        -- Check if there is a map data override for the abilityId
        if LUIE.Data.Effects.MapDataOverride[abilityId] then
            local mapName = GetMapName()

            -- Check if there is a map data override for the current map name
            if LUIE.Data.Effects.MapDataOverride[abilityId][mapName] then
                if LUIE.Data.Effects.MapDataOverride[abilityId][mapName].icon then
                    attackIcon = LUIE.Data.Effects.MapDataOverride[abilityId][mapName].icon
                end
                if LUIE.Data.Effects.MapDataOverride[abilityId][mapName].name then
                    attackName = LUIE.Data.Effects.MapDataOverride[abilityId][mapName].name
                end
                if LUIE.Data.Effects.MapDataOverride[abilityId][mapName].hide then
                    return
                end
            end
        end

        -- Check if there is an effect override by name for the abilityId
        if LUIE.Data.Effects.EffectOverrideByName[abilityId] then
            local unitName = zo_strformat("<<C:1>>", attackerRawName)
            local petName = zo_strformat("<<C:1>>", minionName)

            -- Check if there is an effect override by name for the attacker unit name
            if LUIE.Data.Effects.EffectOverrideByName[abilityId][unitName] then
                if LUIE.Data.Effects.EffectOverrideByName[abilityId][unitName].hide then
                    return
                end
                attackName = LUIE.Data.Effects.EffectOverrideByName[abilityId][unitName].name or attackName
                attackIcon = LUIE.Data.Effects.EffectOverrideByName[abilityId][unitName].icon or attackIcon
            end

            -- Check if there is an effect override by name for the minion name
            if LUIE.Data.Effects.EffectOverrideByName[abilityId][petName] then
                if LUIE.Data.Effects.EffectOverrideByName[abilityId][petName].hide then
                    return
                end
                attackName = LUIE.Data.Effects.EffectOverrideByName[abilityId][petName].name or attackName
                attackIcon = LUIE.Data.Effects.EffectOverrideByName[abilityId][petName].icon or attackIcon
            end
        end

        -- Check if the attack name is "Fall Damage" and there is an effect override for abilityId 10950
        if attackName == GetString(LUIE_STRING_SKILL_FALL_DAMAGE) then
            if LUIE.Data.Effects.EffectOverride[10950] then
                attackIcon = LUIE.Data.Effects.EffectOverride[10950].icon
            end
        end

        return attackName, attackDamage, attackIcon, wasKillingBlow, castTimeAgoMS, durationMS, numAttackHits
    end

    LUIE.GetAbilityIcon = GetAbilityIcon -- Used only for PTS testing
    local zos_GetAbilityIcon = GetAbilityIcon
    --- Hook support for Custom Ability Icons (Helps normalize with other addons)
    --- @param abilityId integer
    --- @return textureName icon
    GetAbilityIcon = function (abilityId)
        local icon = zos_GetAbilityIcon(abilityId)
        if LUIE.Data.Effects.EffectOverride[abilityId] and LUIE.Data.Effects.EffectOverride[abilityId].icon then
            icon = LUIE.Data.Effects.EffectOverride[abilityId].icon
        end
        return icon
    end

    LUIE.GetAbilityName = GetAbilityName -- Used only for PTS testing
    local zos_GetAbilityName = GetAbilityName
    --- Hook support for Custom Ability Names (Helps normalize with other addons)
    --- @param abilityId integer
    --- @param casterUnitTag? string
    --- @return string abilityName
    GetAbilityName = function (abilityId, casterUnitTag)
        local abilityName = zos_GetAbilityName(abilityId)
        if LUIE.Data.Effects.EffectOverride[abilityId] and LUIE.Data.Effects.EffectOverride[abilityId].name then
            abilityName = LUIE.Data.Effects.EffectOverride[abilityId].name
        end
        return abilityName
    end

    LUIE.GetArtificialEffectInfo = GetArtificialEffectInfo -- Used only for PTS testing
    local zos_GetArtificialEffectInfo = GetArtificialEffectInfo
    --- Hook support for ArtificialffectId's
    --- @param artificialEffectId integer
    --- @return string displayName
    --- @return textureName icon
    --- @return BuffEffectType effectType
    --- @return integer sortOrder
    --- @return number timeStartedS
    --- @return number timeEndingS
    GetArtificialEffectInfo = function (artificialEffectId)
        local displayName, iconFile, effectType, sortOrder, timeStarted, timeEnding = zos_GetArtificialEffectInfo(artificialEffectId)
        if LUIE.Data.Effects.ArtificialEffectOverride[artificialEffectId] and LUIE.Data.Effects.ArtificialEffectOverride[artificialEffectId].icon then
            iconFile = LUIE.Data.Effects.ArtificialEffectOverride[artificialEffectId].icon
        end
        if LUIE.Data.Effects.ArtificialEffectOverride[artificialEffectId] and LUIE.Data.Effects.ArtificialEffectOverride[artificialEffectId].name then
            displayName = LUIE.Data.Effects.ArtificialEffectOverride[artificialEffectId].name
        end
        return displayName, iconFile, effectType, sortOrder, timeStarted, timeEnding
    end

    local zos_GetArtificialEffectTooltipText = GetArtificialEffectTooltipText
    --- Hook support to pull custom tooltips for ArtificialEffectId's
    --- @param artificialEffectId integer
    --- @return string tooltipText
    GetArtificialEffectTooltipText = function (artificialEffectId)
        local tooltip
        if LUIE.Data.Effects.ArtificialEffectOverride[artificialEffectId] and LUIE.Data.Effects.ArtificialEffectOverride[artificialEffectId].tooltip then
            tooltip = LUIE.Data.Effects.ArtificialEffectOverride[artificialEffectId].tooltip
            return tooltip
        else
            tooltip = zos_GetArtificialEffectTooltipText(artificialEffectId)
            return tooltip
        end
    end

    -- Hook synergy popup Icon/Name (to fix inconsistencies and add custom icons for some Quest/Encounter based Synergies)
    --- @diagnostic disable-next-line: duplicate-set-field
    ZO_Synergy.OnSynergyAbilityChanged = function (self)
        local hasSynergy, synergyName, iconFilename, prompt = GetCurrentSynergyInfo()

        if hasSynergy then
            -- Apply LUIE custom overrides if they exist
            if LUIE.Data.Effects.SynergyNameOverride[synergyName] then
                if LUIE.Data.Effects.SynergyNameOverride[synergyName].icon then
                    iconFilename = LUIE.Data.Effects.SynergyNameOverride[synergyName].icon
                end
                if LUIE.Data.Effects.SynergyNameOverride[synergyName].name then
                    synergyName = LUIE.Data.Effects.SynergyNameOverride[synergyName].name
                end
            end

            if self.lastSynergyName ~= synergyName then
                PlaySound(SOUNDS.ABILITY_SYNERGY_READY)

                if prompt == "" then
                    prompt = zo_strformat(SI_USE_SYNERGY, synergyName)
                end
                self.action:SetText(prompt)
                self.lastSynergyName = synergyName
            end

            self.icon:SetTexture(iconFilename)
            SHARED_INFORMATION_AREA:SetHidden(self, false)
        else
            SHARED_INFORMATION_AREA:SetHidden(self, true)
            self.lastSynergyName = nil
        end
    end

    -- Hook STATS Screen Buffs & Debuffs to hide buffs not needed, update icons, names, durations, and tooltips
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

    -- Helper function to determine if an effect should be shown
    local function ShouldShowEffect(abilityId)
        local override = LUIE.Data.Effects.EffectOverride[abilityId]
        if not override then
            return true
        end

        if override.hideReduce then
            return not LUIE.SpellCastBuffs.SV.HideReduce
        end
        return true
    end

    -- Helper function to generate tooltip text
    local function GetTooltipText(abilityId, buffSlot, timer, value2, value3)
        local tooltipText
        local override = LUIE.Data.Effects.EffectOverride[abilityId]

        -- Handle veteran difficulty tooltip
        if LUIE.ResolveVeteranDifficulty() and override and override.tooltipVeteran then
            tooltipText = zo_strformat(override.tooltipVeteran, timer, value2, value3)
        else
            tooltipText = (override and override.tooltip) and
                zo_strformat(override.tooltip, timer, value2, value3) or
                GetAbilityDescription(abilityId, overrideActiveRank, overrideCasterUnitTag)
        end

        -- Handle empty tooltip
        if tooltipText == "" or tooltipText == nil then
            local effectDesc = GetAbilityEffectDescription(buffSlot)
            if effectDesc ~= "" then
                tooltipText = effectDesc
            end
        end

        -- Handle default tooltip override
        if LUIE.Data.Effects.TooltipUseDefault[abilityId] then
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
            tooltipText = zo_strmatch(tooltipText, ".*%S")
        end

        -- Use default tooltip if custom tooltips are disabled
        if not LUIE.SpellCastBuffs.SV.TooltipCustom then
            tooltipText = GetAbilityEffectDescription(buffSlot)
            tooltipText = zo_strgsub(tooltipText, "\n$", "")
        end

        return tooltipText
    end

    -- Helper function to get third line text
    local function GetThirdLine(abilityId, timer)
        if LUIE.Data.Effects.EffectOverride[abilityId] and LUIE.Data.Effects.EffectOverride[abilityId].duration then
            timer = timer + LUIE.Data.Effects.EffectOverride[abilityId].duration
        end
        -- Additional third line logic can be added here if needed
        return nil
    end

    STATS.AddLongTermEffects = function (self, container, effectsRowPool)
        local function UpdateEffects()
            if not container:IsHidden() then
                effectsRowPool:ReleaseAllObjects()

                local effectsRows = {}

                -- Artificial effects
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
                        table_insert(effectsRows, effectsRow)
                    end
                end

                -- Track buffs for duplicate handling
                local trackBuffs = {}
                for i = 1, GetNumBuffs("player") do
                    local buffName, startTime, endTime, buffSlot, stackCount, iconFile, buffType, effectType, abilityType, statusEffectType, abilityId = GetUnitBuffInfo("player", i)
                    trackBuffs[i] =
                    {
                        buffName = buffName,
                        startTime = startTime,
                        endTime = endTime,
                        buffSlot = buffSlot,
                        stackCount = stackCount,
                        iconFile = iconFile,
                        buffType = buffType,
                        effectType = effectType,
                        abilityType = abilityType,
                        statusEffectType = statusEffectType,
                        abilityId = abilityId,
                    }
                end

                -- Handle duplicate abilities
                for i = 1, #trackBuffs do
                    local compareId = trackBuffs[i].abilityId
                    local compareTime = trackBuffs[i].endTime
                    if LUIE.Data.Effects.EffectOverride[compareId] and LUIE.Data.Effects.EffectOverride[compareId].noDuplicate then
                        for k, v in pairs(trackBuffs) do
                            if v.abilityId == compareId and v.endTime < compareTime then
                                v.markForRemove = true
                            end
                        end
                    end
                end

                -- Process buffs
                for i = 1, #trackBuffs do
                    local buff = trackBuffs[i]
                    if buff.buffSlot > 0 and buff.buffName ~= "" and
                    not (LUIE.Data.Effects.EffectOverride[buff.abilityId] and LUIE.Data.Effects.EffectOverride[buff.abilityId].hide) and
                    not buff.markForRemove then
                        -- Process tooltip values
                        local timer = buff.endTime - buff.startTime
                        local value2, value3 = 0, 0
                        local effectOverride = LUIE.Data.Effects.EffectOverride[buff.abilityId]

                        if effectOverride then
                            -- Handle value2
                            if effectOverride.tooltipValue2 then
                                value2 = effectOverride.tooltipValue2
                            elseif effectOverride.tooltipValue2Mod then
                                value2 = zo_floor(timer + effectOverride.tooltipValue2Mod + 0.5)
                            elseif effectOverride.tooltipValue2Id then
                                value2 = zo_floor((GetAbilityDuration(effectOverride.tooltipValue2Id, overrideActiveRank, overrideCasterUnitTag) or 0) + 0.5) / 1000
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

                            table_insert(effectsRows, effectsRow)
                        end
                    end
                end

                -- Sort and position rows
                table_sort(effectsRows, EffectsRowComparator)
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
        end

        -- Register events
        local function OnEffectChanged(eventCode, changeType, buffSlot, buffName, unitTag)
            UpdateEffects()
        end

        container:RegisterForEvent(EVENT_EFFECT_CHANGED, OnEffectChanged)
        container:AddFilterForEvent(EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
        container:RegisterForEvent(EVENT_EFFECTS_FULL_UPDATE, UpdateEffects)
        container:RegisterForEvent(EVENT_ARTIFICIAL_EFFECT_ADDED, UpdateEffects)
        container:RegisterForEvent(EVENT_ARTIFICIAL_EFFECT_REMOVED, UpdateEffects)
        container:SetHandler("OnEffectivelyShown", UpdateEffects)
    end

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
    }

    local function ArtificialEffectsRowComparator(left, right)
        return left.sortOrder < right.sortOrder
    end

    -- Hook GAMEPAD Stats List
    GAMEPAD_STATS.RefreshMainList = function (self)
        if self.currentTitleDropdown and self.currentTitleDropdown:IsDropdownVisible() then
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

        -- Character Info
        self.mainList:AddEntryWithHeader("ZO_GamepadMenuEntryTemplate", self.advancedStatsEntry)
        self.mainList:AddEntry("ZO_GamepadMenuEntryTemplate", self.characterEntry)

        -- Active Effects--
        self.numActiveEffects = 0

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

                table_insert(sortedArtificialEffectsTable, data)
            end
        end

        table_sort(sortedArtificialEffectsTable, ArtificialEffectsRowComparator)

        for i, data in ipairs(sortedArtificialEffectsTable) do
            self:AddActiveEffectData(data)
        end

        -- Real Effects
        local numBuffs = GetNumBuffs("player")
        local hasActiveEffects = numBuffs > 0
        if hasActiveEffects then
            for i = 1, numBuffs do
                local buffName, startTime, endTime, buffSlot, stackCount, iconFile, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff = GetUnitBuffInfo("player", i)

                if buffSlot > 0 and buffName ~= "" then
                    local data = ZO_GamepadEntryData:New(zo_strformat(SI_ABILITY_TOOLTIP_NAME, buffName), iconFile)
                    data.displayMode = GAMEPAD_STATS_DISPLAY_MODE.EFFECTS
                    data.buffIndex = i
                    data.buffSlot = buffSlot
                    data.canClickOff = canClickOff
                    data.isArtificial = false

                    local duration = endTime - startTime
                    if duration > 0 then
                        local timeLeft = (endTime * 1000.0) - GetFrameTimeMilliseconds()
                        data:SetCooldown(timeLeft, duration * 1000.0)
                    end

                    -- Hide effects if they are set to hide on the override.
                    if not LUIE.Data.Effects.EffectOverride[abilityId] or (LUIE.Data.Effects.EffectOverride[abilityId] and not LUIE.Data.Effects.EffectOverride[abilityId].hide) then
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

    -- Hook GAMEPAD Stats Refresh
    GAMEPAD_STATS.RefreshCharacterEffects = function (self)
        local selectedData = self.mainList:GetTargetData()

        local artificial, contentTitle, contentDescription, contentStartTime, contentEndTime, _

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
                if LUIE.Data.Effects.EffectOverride[abilityId] then
                    if LUIE.Data.Effects.EffectOverride[abilityId].tooltipValue2 then
                        value2 = LUIE.Data.Effects.EffectOverride[abilityId].tooltipValue2
                    elseif LUIE.Data.Effects.EffectOverride[abilityId].tooltipValue2Mod then
                        value2 = zo_floor(timer + LUIE.Data.Effects.EffectOverride[abilityId].tooltipValue2Mod + 0.5)
                    elseif LUIE.Data.Effects.EffectOverride[abilityId].tooltipValue2Id then
                        value2 = zo_floor((GetAbilityDuration(LUIE.Data.Effects.EffectOverride[abilityId].tooltipValue2Id, overrideActiveRank, overrideCasterUnitTag) or 0) + 0.5) / 1000
                    else
                        value2 = 0
                    end
                else
                    value2 = 0
                end
                if LUIE.Data.Effects.EffectOverride[abilityId] and LUIE.Data.Effects.EffectOverride[abilityId].tooltipValue3 then
                    value3 = LUIE.Data.Effects.EffectOverride[abilityId].tooltipValue3
                else
                    value3 = 0
                end
                timer = zo_floor((timer * 10) + 0.5) / 10

                local tooltipText
                if LUIE.ResolveVeteranDifficulty() == true and LUIE.Data.Effects.EffectOverride[abilityId] and LUIE.Data.Effects.EffectOverride[abilityId].tooltipVeteran then
                    tooltipText = zo_strformat(LUIE.Data.Effects.EffectOverride[abilityId].tooltipVeteran, timer, value2, value3)
                else
                    tooltipText = (LUIE.Data.Effects.EffectOverride[abilityId] and LUIE.Data.Effects.EffectOverride[abilityId].tooltip) and zo_strformat(LUIE.Data.Effects.EffectOverride[abilityId].tooltip, timer, value2, value3) or ""
                end

                -- Display Default Tooltip Description if no custom tooltip is present
                if tooltipText == "" or tooltipText == nil then
                    if GetAbilityEffectDescription(buffSlot) ~= "" then
                        tooltipText = GetAbilityEffectDescription(buffSlot)
                    end
                end

                -- Display Default Description if no internal effect description is present
                if tooltipText == "" or tooltipText == nil then
                    if GetAbilityDescription(abilityId, overrideActiveRank, overrideCasterUnitTag) ~= "" then
                        tooltipText = GetAbilityDescription(abilityId, overrideActiveRank, overrideCasterUnitTag)
                    end
                end

                -- Override custom tooltip with default tooltip if this ability is flagged to do so (scaling buffs like Mundus Stones)
                if LUIE.Data.Effects.TooltipUseDefault[abilityId] then
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
                    tooltipText = zo_strmatch(tooltipText, ".*%S")
                end
                local thirdLine
                local timer2 = (contentEndTime - contentStartTime)
                if LUIE.Data.Effects.EffectOverride[abilityId] and LUIE.Data.Effects.EffectOverride[abilityId].duration then
                    timer2 = timer2 + LUIE.Data.Effects.EffectOverride[abilityId].duration
                end
                --[[
                if LUIE.Data.Effects.TooltipNameOverride[contentTitle] then
                    thirdLine = zo_strformat(LUIE.Data.Effects.TooltipNameOverride[contentTitle], timer2)
                end
                if LUIE.Data.Effects.TooltipNameOverride[abilityId] then
                    thirdLine = zo_strformat(LUIE.Data.Effects.TooltipNameOverride[abilityId], timer2)
                end
                ]]
                --

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
                local labelAbilityId = abilityId or "None"
                if labelAbilityId == "Fake" then
                    artificial = true
                end
                if selectedData.isArtificial then
                    if abilityId == 0 then
                        -- ESO Plus
                        labelAbilityId = 63601
                    elseif abilityId == 1 or abilityId == 2 then
                        labelAbilityId = 999014
                    else
                        labelAbilityId = "Artificial"
                    end
                end
                contentDescription = contentDescription .. "\n\nAbility ID: " .. labelAbilityId
            end

            -- Add Buff Type Line
            if LUIE.SpellCastBuffs.SV.TooltipBuffType then
                buffType = buffType or LUIE_BUFF_TYPE_NONE
                if abilityId and LUIE.Data.Effects.EffectOverride[abilityId] and LUIE.Data.Effects.EffectOverride[abilityId].unbreakable then
                    buffType = buffType + 2
                end

                -- Setup tooltips for player aoe trackers
                if abilityId and LUIE.Data.Effects.EffectGroundDisplay[abilityId] then
                    buffType = buffType + 4
                end

                -- Setup tooltips for ground buff/debuff effects
                if abilityId and (LUIE.Data.Effects.AddGroundDamageAura[abilityId] or (LUIE.Data.Effects.EffectOverride[abilityId] and LUIE.Data.Effects.EffectOverride[abilityId].groundLabel)) then
                    buffType = buffType + 6
                end

                -- Setup tooltips for Fake Player Offline Auras
                if abilityId and LUIE.Data.Effects.FakePlayerOfflineAura[abilityId] then
                    if LUIE.Data.Effects.FakePlayerOfflineAura[abilityId].ground then
                        buffType = 6
                    else
                        buffType = 5
                    end
                end

                local endLine = buffTypes[buffType] --- @type string
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
        self:RefreshContentHeader(contentTitle)
    end

    -- Hook for request friend so menu option also displays invite message
    -- Menu is true if this request is sent from the Player to Player interaction menu
    local zos_RequestFriend = RequestFriend
    RequestFriend = function (option1, option2, menu)
        zos_RequestFriend(option1, option2)
        if not menu then
            local message = zo_strformat(GetString(LUIE_STRING_SLASHCMDS_FRIEND_INVITE_MSG), option1)
            printToChat(message, true)
            if LUIE.ChatAnnouncements.SV.Social.FriendIgnoreAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, message)
            end
        end
    end

    -- Hook for request ignore to handle error message if account name is already ignored
    local zos_AddIgnore = AddIgnore
    AddIgnore = function (option)
        zos_AddIgnore(option)

        if IsIgnored(option) then -- Only lists account names, unfortunately
            printToChat(GetString(LUIE_STRING_SLASHCMDS_IGNORE_FAILED_ALREADYIGNORE), true)
            if LUIE.ChatAnnouncements.SV.Social.FriendIgnoreAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, (GetString(LUIE_STRING_SLASHCMDS_IGNORE_FAILED_ALREADYIGNORE)))
            end
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
            return
        end
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
                    -- Map artificial effect IDs to our tracking IDs
                    if control.effectId == 0 then
                        -- ESO Plus
                        labelAbilityId = 63601
                    elseif control.effectId == 1 or control.effectId == 2 then
                        -- Battle Spirit (Cyrodiil)
                        labelAbilityId = 999014
                    elseif control.effectId == 3 then
                        -- Battleground Deserter
                        labelAbilityId = 999015
                    elseif control.effectId == 4 then
                        -- LFG Deserter
                        labelAbilityId = 999016
                    elseif control.effectId == 5 then
                        -- Battle Spirit (Imperial City)
                        labelAbilityId = 999018
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
                if effectId and LUIE.Data.Effects.EffectOverride[effectId] and LUIE.Data.Effects.EffectOverride[effectId].unbreakable then
                    buffType = buffType + 2
                end

                -- Setup tooltips for player aoe trackers
                if effectId and LUIE.Data.Effects.EffectGroundDisplay[effectId] then
                    buffType = buffType + 4
                end

                -- Setup tooltips for ground buff/debuff effects
                if effectId and (LUIE.Data.Effects.AddGroundDamageAura[effectId] or (LUIE.Data.Effects.EffectOverride[effectId] and LUIE.Data.Effects.EffectOverride[effectId].groundLabel)) then
                    buffType = buffType + 6
                end

                GameTooltip:AddHeaderLine("Type", "ZoFontWinT1", detailsLine, TOOLTIP_HEADER_SIDE_LEFT, ZO_NORMAL_TEXT:UnpackRGB())
                GameTooltip:AddHeaderLine(buffTypes[buffType], "ZoFontWinT1", detailsLine, TOOLTIP_HEADER_SIDE_RIGHT, 1, 1, 1)
                detailsLine = detailsLine + 1
            end
        end
    end

    -- Hook Tooltip Generation for STATS Screen Buffs & Debuffs
    ZO_StatsActiveEffect_OnMouseEnter = function (control)
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
    --- @diagnostic disable-next-line: duplicate-set-field
    ZO_SkillsAdvisor_Suggestions_Keyboard.SetupAbilityEntry = function (self, control, skillProgressionData)
        local skillData = skillProgressionData:GetSkillData()
        local isPassive = skillData:IsPassive()

        control.skillProgressionData = skillProgressionData
        control.slot.skillProgressionData = skillProgressionData

        -- slot
        ZO_Skills_SetKeyboardAbilityButtonTextures(control.slot)
        local id = skillProgressionData:GetAbilityId()
        control.slotIcon:SetTexture(GetAbilityIcon(id))
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
        detailedName = zo_strgsub(detailedName, "With", "with")               -- Easiest way to fix the capitalization of the skill "Bond With Nature"
        detailedName = zo_strgsub(detailedName, "Blessing Of", "Blessing of") -- Easiest way to fix the capitalization of the skill "Blessing of Restoration"
        control.nameLabel:SetText(detailedName)
        control.nameLabel:SetColor(PURCHASED_COLOR:UnpackRGBA())
    end

    -- Hook Action Slots
    local ACTION_BUTTON_BGS = { ability = "EsoUI/Art/ActionBar/abilityInset.dds", item = "EsoUI/Art/ActionBar/quickslotBG.dds" }
    local ACTION_BUTTON_BORDERS =
    {
        normal = "EsoUI/Art/ActionBar/abilityFrame64_up.dds",
        mouseDown = "EsoUI/Art/ActionBar/abilityFrame64_down.dds",
    }

    local function SetupActionSlot(slotObject, slotId)
        -- pass slotObject.button.hotbarCategory which will be nil or companion
        local slotIcon = GetSlotTexture(slotId, slotObject:GetHotbarCategory())

        -- Added function - Replace icons if needed
        local abilityId = LUIE.GetSlotTrueBoundId(slotId, slotObject:GetHotbarCategory())
        if LUIE.Data.Effects.BarIdOverride[abilityId] then
            slotIcon = LUIE.Data.Effects.BarIdOverride[abilityId]
        end

        slotObject:SetEnabled(true)
        local isGamepad = IsInGamepadPreferredMode()
        ZO_ActionSlot_SetupSlot(slotObject.icon, slotObject.button, slotIcon, isGamepad and "" or ACTION_BUTTON_BORDERS.normal, isGamepad and "" or ACTION_BUTTON_BORDERS.mouseDown, slotObject.cooldownIcon)
        slotObject:UpdateState()
    end

    local function SetupActionSlotWithBg(slotObject, slotId)
        SetupActionSlot(slotObject, slotId)
        slotObject.bg:SetTexture(ACTION_BUTTON_BGS.ability)
    end

    local function SetupAbilitySlot(slotObject, slotId)
        SetupActionSlotWithBg(slotObject, slotId)

        if slotId == ACTION_BAR_ULTIMATE_SLOT_INDEX + 1 then
            slotObject:RefreshUltimateNumberVisibility()
        else
            slotObject:ClearCount()
        end
    end

    local function SetupItemSlot(slotObject, slotId)
        SetupActionSlotWithBg(slotObject, slotId)
        slotObject:SetupCount()
    end

    local function SetupCollectibleActionSlot(slotObject, slotId)
        SetupActionSlotWithBg(slotObject, slotId)
        slotObject:ClearCount()
    end

    local function SetupQuestItemActionSlot(slotObject, slotId)
        SetupActionSlotWithBg(slotObject, slotId)
        slotObject:SetupCount()
    end

    local function SetupEmoteActionSlot(slotObject, slotId)
        SetupActionSlotWithBg(slotObject, slotId)
        slotObject:ClearCount()
    end

    local function SetupQuickChatActionSlot(slotObject, slotId)
        SetupActionSlotWithBg(slotObject, slotId)
        slotObject:ClearCount()
    end

    local function SetupEmptyActionSlot(slotObject, slotId)
        slotObject:Clear()
    end

    SetupSlotHandlers =
    {
        [ACTION_TYPE_ABILITY] = SetupAbilitySlot,
        [ACTION_TYPE_ITEM] = SetupItemSlot,
        [ACTION_TYPE_CRAFTED_ABILITY] = SetupAbilitySlot,
        [ACTION_TYPE_COLLECTIBLE] = SetupCollectibleActionSlot,
        [ACTION_TYPE_QUEST_ITEM] = SetupQuestItemActionSlot,
        [ACTION_TYPE_EMOTE] = SetupEmoteActionSlot,
        [ACTION_TYPE_QUICK_CHAT] = SetupQuickChatActionSlot,
        [ACTION_TYPE_NOTHING] = SetupEmptyActionSlot,
    }

    -- Hook to make Activation Highlight Effect play indefinitely instead of animation only once
    --- @diagnostic disable-next-line: duplicate-set-field
    ActionButton.UpdateActivationHighlight = function (self)
        local slotnum = self:GetSlot()
        local hotbarCategory = self.slot.slotNum == 1 and HOTBAR_CATEGORY_QUICKSLOT_WHEEL or self.button.hotbarCategory
        local slotType = GetSlotType(slotnum, hotbarCategory)
        local slotIsEmpty = (slotType == ACTION_TYPE_NOTHING)

        local abilityId = LUIE.GetSlotTrueBoundId(slotnum, hotbarCategory) -- Check AbilityId for if this should be a fake activation highlight

        local showHighlight = not slotIsEmpty and (ActionSlotHasActivationHighlight(slotnum, hotbarCategory) or LUIE.Data.Effects.IsAbilityActiveGlow[abilityId] == true) and not self.useFailure and not self.showingCooldown
        local isShowingHighlight = self.activationHighlight:IsHidden() == false

        if showHighlight ~= isShowingHighlight then
            self.activationHighlight:SetHidden(not showHighlight)

            if showHighlight then
                local _, _, activationAnimationTexture = GetSlotTexture(slotnum, hotbarCategory)
                self.activationHighlight:SetTexture(activationAnimationTexture)

                local anim = self.activationHighlight.animation
                if not anim then
                    anim = CreateSimpleAnimation(ANIMATION_TEXTURE, self.activationHighlight)
                    anim:SetImageData(64, 1)
                    anim:SetFramerate(30)
                    anim:GetTimeline():SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)

                    self.activationHighlight.animation = anim
                end

                anim:GetTimeline():PlayFromStart()
            else
                local anim = self.activationHighlight.animation
                if anim then
                    anim:GetTimeline():Stop()
                end
            end
        end
    end

    -- Hook to add AVA Guard Ability + Morphs into Toggle Highlights
    --- @diagnostic disable-next-line: duplicate-set-field
    ActionButton.UpdateState = function (self)
        local slotnum = self:GetSlot()
        local hotbarCategory = self.slot.slotNum == 1 and HOTBAR_CATEGORY_QUICKSLOT_WHEEL or self.button.hotbarCategory
        local slotType = GetSlotType(slotnum, hotbarCategory)
        local slotIsEmpty = (slotType == ACTION_TYPE_NOTHING)
        local abilityId = LUIE.GetSlotTrueBoundId(slotnum, hotbarCategory) -- Check AbilityId for if this should be a fake activation highlight

        self.button.actionId = LUIE.GetSlotTrueBoundId(slotnum, hotbarCategory)

        self:UpdateUseFailure()

        local hidden = true

        -- Add toggle highlight for abilites that need it (Guard + morphs)
        if IsSlotToggled(slotnum, hotbarCategory) == true or LUIE.Data.Effects.IsAbilityActiveHighlight[abilityId] then
            hidden = false
        end

        -- If LUIE Bar Highlight is enabled, hide certain "Toggle effects" (aka Blood Frenzy + morphs)
        if IsSlotToggled(slotnum, hotbarCategory) == true and LUIE.Data.Effects.RemoveAbilityActiveHighlight[abilityId] and LUIE.CombatInfo.SV.ShowToggled then
            hidden = true
        end

        self.status:SetHidden(hidden)

        self:UpdateActivationHighlight()
        self:UpdateCooldown(FORCE_SUPPRESS_COOLDOWN_SOUND)
    end

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
            countText = HIDE_COUNT,
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
    --- @diagnostic disable-next-line: duplicate-set-field
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
    --- @diagnostic disable-next-line: duplicate-set-field
    ZO_CampaignBonuses_Shared.BuildMasterList = function (self)
        self.masterList = {}

        for bonusType, info in ipairs(BONUS_SECTION_DATA) do
            local infoData = info.infoData
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
            local countText = scoreIndex
            --- @diagnostic disable-next-line: redundant-parameter
            local abilityId = info.abilityFunction(index, self.campaignId)
            local name = GetAbilityName(abilityId)
            local icon = (LUIE.Data.Effects.EffectOverride[abilityId] and LUIE.Data.Effects.EffectOverride[abilityId].passiveIcon) and LUIE.Data.Effects.EffectOverride[abilityId].passiveIcon or GetAbilityIcon(abilityId)                                                  -- Get Updated LUIE AbilityIcon here
            local description = (LUIE.Data.Effects.EffectOverride[abilityId] and LUIE.Data.Effects.EffectOverride[abilityId].tooltip) and LUIE.Data.Effects.EffectOverride[abilityId].tooltip or GetAbilityDescription(abilityId, overrideActiveRank, overrideCasterUnitTag) -- Get Updated LUIE Tooltip here

            if info.countText then
                if info.countText == HIDE_COUNT then
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

    -- Hook Gamepad Campaign Bonuses Tooltip
    CAMPAIGN_BONUSES_GAMEPAD.UpdateToolTip = function (self)
        GAMEPAD_TOOLTIPS:ClearLines(GAMEPAD_RIGHT_TOOLTIP)
        if self.abilityList:IsActive() then
            local targetData = self.abilityList:GetTargetData()
            if targetData and targetData.isHeader == false then
                -- Replace description
                if targetData.abilityId then
                    local abilityId = targetData.abilityId
                    if LUIE.Data.Effects.EffectOverride[abilityId] and LUIE.Data.Effects.EffectOverride[abilityId].tooltip then
                        targetData.description = LUIE.Data.Effects.EffectOverride[abilityId].tooltip
                    end
                end
                GAMEPAD_TOOLTIPS:LayoutAvABonus(GAMEPAD_RIGHT_TOOLTIP, targetData)
                self:SetTooltipHidden(false)
                return
            end
        end

        self:SetTooltipHidden(true)
    end

    -- Hook Campaign Bonuses Manager (we add abilityId, name, and the description to the control to carry over to the OnMouseEnter tooltip function)
    --- @diagnostic disable-next-line: duplicate-set-field
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
        -- Get Campaign ID
        local campaignId = GetCurrentCampaignId()
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
            local allHomeScrollsHeld, enemyScrollsHeld = GetAvAArtifactScore(campaignId, GetUnitAlliance("player"), OBJECTIVE_ARTIFACT_DEFENSIVE)
            return allHomeScrollsHeld, enemyScrollsHeld
        end

        -- Check Offensive Scroll Bonuses
        local function OffensiveScrolls(campaignId)
            local allHomeScrollsHeld, enemyScrollsHeld = GetAvAArtifactScore(campaignId, GetUnitAlliance("player"), OBJECTIVE_ARTIFACT_OFFENSIVE)
            return allHomeScrollsHeld, enemyScrollsHeld
        end

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
    --- @diagnostic disable-next-line: duplicate-set-field
    ZO_MapKeepUpgrade_Shared.RefreshLevels = function (self)
        self.levelsGridList:ClearGridList()

        for currentLevel = 0, GetKeepMaxUpgradeLevel(self.keepUpgradeObject:GetKeep()) do
            local numUpgrades = self.keepUpgradeObject:GetNumLevelUpgrades(currentLevel)
            if numUpgrades > 0 then
                local levelHeaderText = zo_strformat(SI_KEEP_UPGRADE_LEVEL_SECTION_HEADER, currentLevel)
                for i = 1, numUpgrades do
                    local name, description, icon, atPercent, isActive = self.keepUpgradeObject:GetLevelUpgradeInfo(currentLevel, i)

                    -- Override with custom icons here.
                    if LUIE.Data.Effects.KeepUpgradeOverride[name] then
                        icon = LUIE.Data.Effects.KeepUpgradeOverride[name]
                    end
                    -- Override with custom faction icons here.
                    if LUIE.Data.Effects.KeepUpgradeAlliance[name] then
                        icon = LUIE.Data.Effects.KeepUpgradeAlliance[name][LUIE.PlayerFaction]
                    end
                    -- Special condition to display a unique icon for rank 2 of siege cap upgrade.
                    if name == LUIE.Data.Abilities.Keep_Upgrade_Wood_Siege_Cap and currentLevel == 2 then
                        icon = "LuiExtended/media/icons/keepupgrade/upgrade_wood_siege_cap_2.dds"
                    end
                    -- Update the tooltips.
                    if LUIE.Data.Effects.KeepUpgradeTooltip[name] then
                        description = LUIE.Data.Effects.KeepUpgradeTooltip[name]
                    end
                    -- Update the name (Note: We do this last since our other conditionals check by name).
                    if LUIE.Data.Effects.KeepUpgradeNameFix[name] then
                        name = LUIE.Data.Effects.KeepUpgradeNameFix[name]
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

    -- Variables for Skill Window Hook
    local INCREASE_BUTTON_TEXTURES =
    {
        PLUS =
        {
            normal = "EsoUI/Art/Progression/addPoints_up.dds",
            mouseDown = "EsoUI/Art/Progression/addPoints_down.dds",
            mouseover = "EsoUI/Art/Progression/addPoints_over.dds",
            disabled = "EsoUI/Art/Progression/addPoints_disabled.dds",
        },
        MORPH =
        {
            normal = "EsoUI/Art/Progression/morph_up.dds",
            mouseDown = "EsoUI/Art/Progression/morph_down.dds",
            mouseover = "EsoUI/Art/Progression/morph_over.dds",
            disabled = "EsoUI/Art/Progression/morph_disabled.dds",
        },
        REMORPH =
        {
            normal = "EsoUI/Art/Progression/remorph_up.dds",
            mouseDown = "EsoUI/Art/Progression/remorph_down.dds",
            mouseover = "EsoUI/Art/Progression/remorph_over.dds",
            disabled = "EsoUI/Art/Progression/remorph_disabled.dds",
        },
    }

    -- Local function for Skill Window Hook
    local function ApplyButtonTextures(button, textures)
        button:SetNormalTexture(textures.normal)
        button:SetPressedTexture(textures.mouseDown)
        button:SetMouseOverTexture(textures.mouseover)
        button:SetDisabledTexture(textures.disabled)
    end

    -- Hook Skills Window (Keyboard)
    function ZO_Skills_AbilityEntry_Setup(control, skillData)
        local skillPointAllocator = skillData:GetPointAllocator()
        local skillProgressionData = skillPointAllocator:GetProgressionData()

        local isPassive = skillData:IsPassive()
        local isActive = not isPassive
        local isPurchased = skillPointAllocator:IsPurchased()
        local isUnlocked = skillProgressionData:IsUnlocked()

        local lastSkillProgressionData = control.skillProgressionData
        control.skillProgressionData = skillProgressionData
        control.slot.skillProgressionData = skillProgressionData
        control.slot.skillData = skillData

        -- slot
        local id = skillProgressionData:GetAbilityId()
        control.slotIcon:SetTexture(GetAbilityIcon(id))
        ZO_Skills_SetKeyboardAbilityButtonTextures(control.slot)
        ZO_ActionSlot_SetUnusable(control.slotIcon, not isPurchased, false)
        control.slot:SetEnabled(isPurchased and isActive)
        control.slotLock:SetHidden(isUnlocked)

        local hasSlotStatusUpdated = skillData:HasUpdatedStatusByType(ZO_SKILL_DATA_NEW_STATE.MORPHABLE) or skillData:HasUpdatedStatusByType(ZO_SKILL_DATA_NEW_STATE.CRAFTED_ABILITY)
        control.slot.statusIcon:SetHidden(not hasSlotStatusUpdated)

        if skillProgressionData:IsActive() and skillProgressionData:GetNumSkillStyles() > 0 then
            local collectibleData = skillProgressionData:GetSelectedSkillStyleCollectibleData()
            if collectibleData then
                control.skillStyleControl.selectedStyleButton.icon:SetTexture(collectibleData:GetIcon())
            end
        end

        -- xp bar
        local showXPBar = skillProgressionData:HasRankData()
        if showXPBar then
            local currentRank = skillProgressionData:GetCurrentRank()
            local startXP, endXP = skillProgressionData:GetRankXPExtents(currentRank)
            local currentXP = skillProgressionData:GetCurrentXP()
            local dontWrap = lastSkillProgressionData ~= skillProgressionData

            control.xpBar:SetHidden(false)
            ZO_SkillInfoXPBar_SetValue(control.xpBar, currentRank, startXP, endXP, currentXP, dontWrap)
        else
            local NO_LEVEL = nil
            local START_XP = 0
            local END_XP = 1
            local NO_XP = 0
            local DONT_WRAP = true

            control.xpBar:SetHidden(true)
            ZO_SkillInfoXPBar_SetValue(control.xpBar, NO_LEVEL, START_XP, END_XP, NO_XP, DONT_WRAP)
        end

        -- name
        local detailedName = skillProgressionData:GetDetailedName()
        detailedName = zo_strgsub(detailedName, "With", "with")               -- Easiest way to fix the capitalization of the skill "Bond With Nature"
        detailedName = zo_strgsub(detailedName, "Blessing Of", "Blessing of") -- Easiest way to fix the capitalization of the skill "Blessing of Restoration"
        control.nameLabel:SetText(detailedName)
        local offsetY = showXPBar and -10 or 0
        control.nameLabel:SetAnchor(LEFT, control.slot, RIGHT, 10, offsetY)

        if isPurchased then
            control.nameLabel:SetColor(PURCHASED_COLOR:UnpackRGBA())
        else
            if isUnlocked then
                control.nameLabel:SetColor(UNPURCHASED_COLOR:UnpackRGBA())
            else
                control.nameLabel:SetColor(LOCKED_COLOR:UnpackRGBA())
            end
        end

        -- increase/decrease buttons
        local increaseButton = control.increaseButton
        local decreaseButton = control.decreaseButton
        local hideIncreaseButton = true
        local hideDecreaseButton = true
        local canPurchase = skillPointAllocator:CanPurchase()
        local canIncreaseRank = skillPointAllocator:CanIncreaseRank()
        local canMorph = skillPointAllocator:CanMorph()
        local skillPointAllocationMode = SKILLS_AND_ACTION_BAR_MANAGER:GetSkillPointAllocationMode()
        if skillPointAllocationMode == SKILL_POINT_ALLOCATION_MODE_PURCHASE_ONLY then
            local increaseTextures
            if canMorph then
                increaseTextures = INCREASE_BUTTON_TEXTURES.MORPH
            elseif canPurchase or canIncreaseRank then
                increaseTextures = INCREASE_BUTTON_TEXTURES.PLUS
            end

            if increaseTextures then
                ApplyButtonTextures(increaseButton, increaseTextures)
                if GetActionBarLockedReason() == ACTION_BAR_LOCKED_REASON_COMBAT then
                    increaseButton:SetState(BSTATE_DISABLED)
                else
                    increaseButton:SetState(BSTATE_NORMAL)
                end
                hideIncreaseButton = false
            end
        else
            local isFullRespec = skillPointAllocationMode == SKILL_POINT_ALLOCATION_MODE_FULL
            if skillData:CanPointAllocationsBeAltered(isFullRespec) then
                hideIncreaseButton = false
                hideDecreaseButton = false

                if isPassive or not isPurchased or not skillData:IsAtMorph() then
                    ApplyButtonTextures(increaseButton, INCREASE_BUTTON_TEXTURES.PLUS)
                else
                    if skillProgressionData:IsMorph() then
                        ApplyButtonTextures(increaseButton, INCREASE_BUTTON_TEXTURES.REMORPH)
                    else
                        ApplyButtonTextures(increaseButton, INCREASE_BUTTON_TEXTURES.MORPH)
                    end
                end

                if canMorph or canPurchase or canIncreaseRank then
                    increaseButton:SetState(BSTATE_NORMAL)
                else
                    increaseButton:SetState(BSTATE_DISABLED)
                end

                if skillPointAllocator:CanSell() or skillPointAllocator:CanDecreaseRank() or skillPointAllocator:CanUnmorph() then
                    decreaseButton:SetState(BSTATE_NORMAL)
                else
                    decreaseButton:SetState(BSTATE_DISABLED)
                end
            end
        end

        increaseButton:SetHidden(hideIncreaseButton)
        decreaseButton:SetHidden(hideDecreaseButton)

        -- Don't show skill style functionality if in respec mode (decrease button showing)
        local skillStyleControl = control.skillStyleControl
        if hideDecreaseButton then
            skillStyleControl:ClearAnchors()
            if hideIncreaseButton then
                skillStyleControl:SetAnchor(RIGHT, control.slot, LEFT, -12)
            else
                skillStyleControl:SetAnchor(RIGHT, increaseButton, LEFT)
            end

            if isActive and skillProgressionData:GetNumSkillStyles() ~= 0 then
                skillStyleControl:SetHidden(false)
                if skillProgressionData:IsSkillStyleSelected() then
                    skillStyleControl.defaultStyleButton:SetHidden(true)
                    skillStyleControl.selectedStyleButton:SetHidden(false)
                else
                    skillStyleControl.defaultStyleButton:SetHidden(false)
                    skillStyleControl.selectedStyleButton:SetHidden(true)
                end
                skillStyleControl.statusIcon:SetHidden(not skillData:HasUpdatedStatusByType(ZO_SKILL_DATA_NEW_STATE.STYLE_COLLECTIBLE))
            else
                skillStyleControl:SetHidden(true)
            end
        else
            skillStyleControl:SetHidden(true)
        end
    end

    -- Overwrite default Skill Confirm Learn Menu for Skills with Custom Icons (Keyboard)
    local function InitializeKeyboardConfirmDialog()
        local confirmDialogControl = ZO_SkillsConfirmDialog
        confirmDialogControl.abilityName = confirmDialogControl:GetNamedChild("AbilityName")
        confirmDialogControl.ability = confirmDialogControl:GetNamedChild("Ability")
        confirmDialogControl.ability.icon = confirmDialogControl.ability:GetNamedChild("Icon")
        local advisementLabel = confirmDialogControl:GetNamedChild("Advisement")
        advisementLabel:SetText(GetString(SI_SKILLS_ADVISOR_PURCHASE_ADVISED))
        advisementLabel:SetColor(ZO_SKILLS_ADVISOR_ADVISED_COLOR:UnpackRGBA())
        confirmDialogControl.advisementLabel = advisementLabel

        local function SetupPurchaseAbilityConfirmDialog(dialog, skillProgressionData)
            if skillProgressionData:GetSkillData():GetPointAllocator():CanPurchase() then
                local dialogAbility = dialog.ability
                local id = skillProgressionData:GetAbilityId()
                dialog.abilityName:SetText(zo_strformat("<<C:1>>", GetAbilityName(id)))

                dialogAbility.skillProgressionData = skillProgressionData
                dialogAbility.icon:SetTexture(GetAbilityIcon(id))
                ZO_Skills_SetKeyboardAbilityButtonTextures(dialogAbility)

                local hideAdvisement = ZO_SKILLS_ADVISOR_SINGLETON:IsAdvancedModeSelected() or not skillProgressionData:IsAdvised()
                dialog.advisementLabel:SetHidden(hideAdvisement)
            end
        end

        ZO_Dialogs_RegisterCustomDialog("PURCHASE_ABILITY_CONFIRM",
            {
                customControl = confirmDialogControl,
                setup = SetupPurchaseAbilityConfirmDialog,
                title =
                {
                    text = SI_SKILLS_CONFIRM_PURCHASE_ABILITY,
                },
                buttons =
                {
                    [1] =
                    {
                        control = confirmDialogControl:GetNamedChild("Confirm"),
                        text = SI_SKILLS_UNLOCK_CONFIRM,
                        callback = function (dialog)
                            local skillProgressionData = dialog.data
                            local skillPointAllocator = skillProgressionData:GetSkillData():GetPointAllocator()
                            skillPointAllocator:Purchase()
                        end,
                    },

                    [2] =
                    {
                        control = confirmDialogControl:GetNamedChild("Cancel"),
                        text = SI_CANCEL,
                    },
                },
            })
    end

    -- Overwrite default Upgrade menu for Skills with Custom Icons (Keyboard)
    local function InitializeKeyboardUpgradeDialog()
        local upgradeDialogControl = ZO_SkillsUpgradeDialog
        upgradeDialogControl.desc = upgradeDialogControl:GetNamedChild("Description")

        upgradeDialogControl.baseAbility = upgradeDialogControl:GetNamedChild("BaseAbility")
        upgradeDialogControl.baseAbility.icon = upgradeDialogControl.baseAbility:GetNamedChild("Icon")

        upgradeDialogControl.upgradeAbility = upgradeDialogControl:GetNamedChild("UpgradeAbility")
        upgradeDialogControl.upgradeAbility.icon = upgradeDialogControl.upgradeAbility:GetNamedChild("Icon")

        local advisementLabel = upgradeDialogControl:GetNamedChild("Advisement")
        advisementLabel:SetText(GetString(SI_SKILLS_ADVISOR_PURCHASE_ADVISED))
        advisementLabel:SetColor(ZO_SKILLS_ADVISOR_ADVISED_COLOR:UnpackRGBA())

        local function SetupUpgradeAbilityDialog(dialog, skillData)
            -- Only passives upgrade
            assert(skillData:IsPassive())

            local skillPointAllocator = skillData:GetPointAllocator()
            if skillPointAllocator:CanIncreaseRank() then
                local rank = skillPointAllocator:GetSkillProgressionKey()
                local skillProgressionData = skillData:GetRankData(rank)
                local nextSkillProgressionData = skillData:GetRankData(rank + 1)

                local id = skillProgressionData:GetAbilityId()
                dialog.desc:SetText(zo_strformat(SI_SKILLS_UPGRADE_DESCRIPTION, GetAbilityName(id)))

                local baseAbility = dialog.baseAbility
                baseAbility.skillProgressionData = skillProgressionData
                baseAbility.icon:SetTexture(GetAbilityIcon(id))
                ZO_Skills_SetKeyboardAbilityButtonTextures(baseAbility)

                local upgradeAbility = dialog.upgradeAbility
                local idUpgrade = nextSkillProgressionData:GetAbilityId()
                upgradeAbility.skillProgressionData = nextSkillProgressionData
                upgradeAbility.icon:SetTexture(GetAbilityIcon(idUpgrade))
                ZO_Skills_SetKeyboardAbilityButtonTextures(upgradeAbility)

                local hideAdvisement = ZO_SKILLS_ADVISOR_SINGLETON:IsAdvancedModeSelected() or not skillData:IsAdvised()
                advisementLabel:SetHidden(hideAdvisement)
            end
        end

        ZO_Dialogs_RegisterCustomDialog("UPGRADE_ABILITY_CONFIRM",
            {
                customControl = upgradeDialogControl,
                setup = SetupUpgradeAbilityDialog,
                title =
                {
                    text = SI_SKILLS_UPGRADE_ABILITY,
                },
                buttons =
                {
                    [1] =
                    {
                        control = upgradeDialogControl:GetNamedChild("Confirm"),
                        text = SI_SKILLS_UPGRADE_CONFIRM,
                        callback = function (dialog)
                            local skillData = dialog.data
                            local skillPointAllocator = skillData:GetPointAllocator()
                            skillPointAllocator:IncreaseRank()
                        end,
                    },
                    [2] =
                    {
                        control = upgradeDialogControl:GetNamedChild("Cancel"),
                        text = SI_CANCEL,
                    },
                },
            })
    end

    InitializeKeyboardConfirmDialog()
    InitializeKeyboardUpgradeDialog()

    -- Function for Gamepad Skills Hook
    local function SetupAbilityIconFrame(control, isPassive, isActive, isAdvised)
        local iconTexture = control.icon

        local DOUBLE_FRAME_THICKNESS = 9
        local SINGLE_FRAME_THICKNESS = 5
        -- Circle Frame (Passive)
        local circleFrameTexture = control.circleFrame
        if circleFrameTexture then
            if isPassive then
                circleFrameTexture:SetHidden(false)
                local frameOffsetFromIcon
                if isAdvised then
                    frameOffsetFromIcon = DOUBLE_FRAME_THICKNESS
                    circleFrameTexture:SetTexture("EsoUI/Art/SkillsAdvisor/gamepad/gp_passiveDoubleFrame_64.dds")
                else
                    frameOffsetFromIcon = SINGLE_FRAME_THICKNESS
                    circleFrameTexture:SetTexture("EsoUI/Art/Miscellaneous/Gamepad/gp_passiveFrame_64.dds")
                end
                circleFrameTexture:ClearAnchors()
                circleFrameTexture:SetAnchor(TOPLEFT, iconTexture, TOPLEFT, -frameOffsetFromIcon, -frameOffsetFromIcon)
                circleFrameTexture:SetAnchor(BOTTOMRIGHT, iconTexture, BOTTOMRIGHT, frameOffsetFromIcon, frameOffsetFromIcon)
            else
                control.circleFrame:SetHidden(true)
            end
        end

        -- Edge Frame (Active)
        local SKILLS_ADVISOR_ACTIVE_DOUBLE_FRAME_WIDTH = 128
        local SKILLS_ADVISOR_ACTIVE_DOUBLE_FRAME_HEIGHT = 16
        local edgeFrameBackdrop = control.edgeFrame
        if isActive then
            edgeFrameBackdrop:SetHidden(false)
            local frameOffsetFromIcon
            if isAdvised then
                frameOffsetFromIcon = DOUBLE_FRAME_THICKNESS
                edgeFrameBackdrop:SetEdgeTexture("EsoUI/Art/SkillsAdvisor/gamepad/edgeDoubleframeGamepadBorder.dds", SKILLS_ADVISOR_ACTIVE_DOUBLE_FRAME_WIDTH, SKILLS_ADVISOR_ACTIVE_DOUBLE_FRAME_HEIGHT)
            else
                frameOffsetFromIcon = SINGLE_FRAME_THICKNESS
                edgeFrameBackdrop:SetEdgeTexture("EsoUI/Art/Miscellaneous/Gamepad/edgeframeGamepadBorder.dds", SKILLS_ADVISOR_ACTIVE_DOUBLE_FRAME_WIDTH, SKILLS_ADVISOR_ACTIVE_DOUBLE_FRAME_HEIGHT)
            end
            edgeFrameBackdrop:ClearAnchors()
            edgeFrameBackdrop:SetAnchor(TOPLEFT, iconTexture, TOPLEFT, -frameOffsetFromIcon, -frameOffsetFromIcon)
            edgeFrameBackdrop:SetAnchor(BOTTOMRIGHT, iconTexture, BOTTOMRIGHT, frameOffsetFromIcon, frameOffsetFromIcon)
        else
            edgeFrameBackdrop:SetHidden(true)
        end
    end

    local function SetBindingTextForSkill(keybindLabel, skillData, overrideSlotIndex, overrideHotbar)
        ZO_Keybindings_UnregisterLabelForBindingUpdate(keybindLabel)

        -- The spot where the keybind goes is occupied by the decrease button in the respec modes
        if SKILLS_AND_ACTION_BAR_MANAGER:GetSkillPointAllocationMode() == SKILL_POINT_ALLOCATION_MODE_PURCHASE_ONLY and skillData:IsActive() then
            local actionSlotIndex = overrideSlotIndex or skillData:GetSlotOnCurrentHotbar()
            if actionSlotIndex then
                local hotbarCategory = overrideHotbar or ACTION_BAR_ASSIGNMENT_MANAGER:GetCurrentHotbarCategory()
                local keyboardActionName, gamepadActionName = ACTION_BAR_ASSIGNMENT_MANAGER:GetKeyboardAndGamepadActionNameForSlot(actionSlotIndex, hotbarCategory)
                local HIDE_UNBOUND = false
                ZO_Keybindings_RegisterLabelForBindingUpdate(keybindLabel, keyboardActionName, HIDE_UNBOUND, gamepadActionName)

                local keybindWidth = 50 -- width assuming a single keybind
                if ACTION_BAR_ASSIGNMENT_MANAGER:IsUltimateSlot(actionSlotIndex) then
                    keybindWidth = 90   -- double keybind width (RB+LB)
                end

                keybindLabel:SetHidden(false)
                return keybindWidth
            end
        end

        keybindLabel:SetHidden(true)
        -- other controls depend on the keybind width for layout so let's reset its size too
        keybindLabel:SetText("")
        return 0
    end

    local function SetupIndicatorsForSkill(leftIndicator, rightIndicator, skillData, showIncrease, showDecrease, showNew)
        local indicatorRightWidth = 0

        -- If we don't have a left indicator then we aren't going to have a right indicator either, so exit the function
        if not leftIndicator then
            return indicatorRightWidth
        end
        local skillPointAllocator = skillData:GetPointAllocator()

        local increaseMultiIcon
        local decreaseMultiIcon
        if rightIndicator == nil then
            increaseMultiIcon = leftIndicator
            decreaseMultiIcon = leftIndicator
            leftIndicator:ClearIcons()
        elseif SKILLS_AND_ACTION_BAR_MANAGER:DoesSkillPointAllocationModeBatchSave() then
            increaseMultiIcon = rightIndicator
            decreaseMultiIcon = leftIndicator
            leftIndicator:ClearIcons()
            rightIndicator:ClearIcons()
        else
            increaseMultiIcon = leftIndicator
            decreaseMultiIcon = rightIndicator
            leftIndicator:ClearIcons()
            rightIndicator:ClearIcons()
        end

        -- Increase (Morph, Purchase, Increase Rank) Icon
        local increaseAction = ZO_SKILL_POINT_ACTION.NONE
        local isMorph = ZO_ActiveSkillProgressionData:IsMorph()
        if showIncrease then
            increaseAction = skillPointAllocator:GetIncreaseSkillAction()
        elseif isMorph then
            -- this is used more as an indicator that this skill has been morphed, than an indicator that you _should_ morph it
            increaseAction = ZO_SKILL_POINT_ACTION.MORPH
        end

        if increaseAction ~= ZO_SKILL_POINT_ACTION.NONE then
            increaseMultiIcon:AddIcon(ZO_Skills_GetGamepadSkillPointActionIcon(increaseAction))
        end

        -- Decrease (Unmorph, Sell, Decrease Rank)
        if showDecrease then
            local decreaseAction = skillPointAllocator:GetDecreaseSkillAction()
            if decreaseAction ~= ZO_SKILL_POINT_ACTION.NONE then
                decreaseMultiIcon:AddIcon(ZO_Skills_GetGamepadSkillPointActionIcon(decreaseAction))
            end

            -- Always carve out space for the decrease icon even if it isn't active so the name doesn't dance around as it appears and disappears
            indicatorRightWidth = 40
        end

        -- New Indicator
        if showNew then
            if skillData:HasUpdatedStatus() then
                leftIndicator:AddIcon("EsoUI/Art/Inventory/newItem_icon.dds")
            end
        end

        leftIndicator:Show()
        if rightIndicator then
            rightIndicator:Show()
        end

        return indicatorRightWidth
    end

    local SKILL_ENTRY_LABEL_WIDTH = 289

    -- Hook for Gamepad Skills Menu
    function ZO_GamepadSkillEntryTemplate_Setup(control, skillEntry, selected, activated, displayView)
        -- Some skill entries want to target a specific progression data (such as the morph dialog showing two specific morphs). Otherwise they use the skill progression that matches the current point spending.
        local skillData = skillEntry.skillData or skillEntry.skillProgressionData and skillEntry.skillProgressionData:GetSkillData() or skillEntry.craftedAbilityData and skillEntry.craftedAbilityData:GetSkillData()
        local skillProgressionData = skillEntry.skillProgressionData or skillData:GetPointAllocatorProgressionData()
        local skillPointAllocator = skillData:GetPointAllocator()
        local isUnlocked = skillProgressionData:IsUnlocked()
        local isActive = skillData:IsActive()
        local isNonCraftedActive = isActive and not skillData:IsCraftedAbility()
        local isMorph = isNonCraftedActive and skillProgressionData:IsMorph()
        local isPurchased = skillPointAllocator:IsPurchased()
        local isInSkillBuild = skillProgressionData:IsAdvised()

        -- Icon
        local iconTexture = control.icon
        iconTexture:SetTexture(GetAbilityIcon(skillProgressionData.abilityId))
        if displayView == ZO_SKILL_ABILITY_DISPLAY_INTERACTIVE then
            if isPurchased then
                iconTexture:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
            else
                iconTexture:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
            end
        end

        SetupAbilityIconFrame(control, skillData:IsPassive(), isActive, isInSkillBuild)

        -- Label Color
        if displayView == ZO_SKILL_ABILITY_DISPLAY_INTERACTIVE then
            if not skillEntry.isPreview and isPurchased then
                control.label:SetColor((selected and PURCHASED_COLOR or PURCHASED_UNSELECTED_COLOR):UnpackRGBA())
            end
        else
            control.label:SetColor(PURCHASED_COLOR:UnpackRGBA())
        end

        -- Lock Icon
        if control.lock then
            control.lock:SetHidden(isUnlocked)
        end

        local labelWidth = SKILL_ENTRY_LABEL_WIDTH

        local showIncrease = (displayView == ZO_SKILL_ABILITY_DISPLAY_INTERACTIVE)
        local showDecrease = SKILLS_AND_ACTION_BAR_MANAGER:DoesSkillPointAllocationModeAllowDecrease()
        local showNew = (displayView == ZO_SKILL_ABILITY_DISPLAY_INTERACTIVE)
        local indicatorWidth = SetupIndicatorsForSkill(control.leftIndicator, control.rightIndicator, skillData, showIncrease, showDecrease, showNew)
        labelWidth = labelWidth - indicatorWidth

        if displayView == ZO_SKILL_ABILITY_DISPLAY_INTERACTIVE then
            -- Current Binding Text
            if control.keybind then
                local keybindWidth = SetBindingTextForSkill(control.keybind, skillData)
                labelWidth = labelWidth - keybindWidth
            end
        end

        -- Size the label to allow space for the keybind and decrease icon
        control.label:SetWidth(labelWidth)
    end

    -- Hook for Gamepad Skills Preview
    function ZO_GamepadSkillEntryPreviewRow_Setup(control, skillData, overrideSlotIndex, overrideHotbar)
        local skillProgressionData = skillData:GetPointAllocatorProgressionData()
        local skillPointAllocator = skillData:GetPointAllocator()
        local isUnlocked = skillProgressionData:IsUnlocked()
        local isPurchased = overrideHotbar ~= nil or skillPointAllocator:IsPurchased()
        local isActive = skillData:IsActive()
        local isNonCraftedActive = isActive and not skillData:IsCraftedAbility()
        local isMorph = skillData:IsPlayerSkill() and isNonCraftedActive and skillProgressionData:IsMorph()

        -- Icon
        local iconTexture = control.icon
        iconTexture:SetTexture(skillProgressionData:GetIcon())
        if isPurchased then
            iconTexture:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
        else
            iconTexture:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
        end

        SetupAbilityIconFrame(control, skillData:IsPassive(), isActive, skillProgressionData:IsAdvised())

        -- Label
        control.label:SetText(skillProgressionData:GetDetailedGamepadName())
        local color = isPurchased and ZO_SELECTED_TEXT or ZO_DISABLED_TEXT
        control.label:SetColor(color:UnpackRGBA())

        -- Lock Icon
        control.lock:SetHidden(isUnlocked)

        -- Indicator
        local labelWidth = SKILL_ENTRY_LABEL_WIDTH
        local NO_RIGHT_INDICATOR = nil
        local SHOW_INCREASE = true
        local showDecrease = SKILLS_AND_ACTION_BAR_MANAGER:DoesSkillPointAllocationModeAllowDecrease()
        local SHOW_NEW = true
        local indicatorWidth = SetupIndicatorsForSkill(control.leftIndicator, NO_RIGHT_INDICATOR, skillData, SHOW_INCREASE, showDecrease, SHOW_NEW)
        labelWidth = labelWidth - indicatorWidth

        local keybindWidth = SetBindingTextForSkill(control.keybind, skillData, overrideSlotIndex, overrideHotbar)
        labelWidth = labelWidth - keybindWidth

        -- Size the label to allow space for the keybind and decrease icon
        control.label:SetWidth(labelWidth)
    end

    -- end
end
