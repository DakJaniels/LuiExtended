-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local Data = LuiData.Data
local Effects = Data.Effects

local ChatOutput = LUIE.ChatOutput

-- -----------------------------------------------------------------------------
-- ESO API Locals.
-- -----------------------------------------------------------------------------

local GetString = GetString
local zo_strformat = zo_strformat

--- @type table<integer, string>
LUIE.buffTypes =
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

function LUIE.API_Hooks()
    local zos_RequestFriend = RequestFriend
    -- Hook for request friend so menu option also displays invite message
    -- Menu is true if this request is sent from the Player to Player interaction menu
    --- @param charOrDisplayName string
    --- @param message string?
    --- @param menu boolean?
    RequestFriend = function (charOrDisplayName, message, menu)
        zos_RequestFriend(charOrDisplayName, message)
        if not menu then
            message = zo_strformat(GetString(LUIE_STRING_SLASHCMDS_FRIEND_INVITE_MSG), charOrDisplayName)
            ChatOutput:Print(message, true)
            if LUIE.ChatAnnouncements.SV.Social.FriendIgnoreAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, message)
            end
        end
    end

    local zos_AddIgnore = AddIgnore
    -- Hook for request ignore to handle error message if account name is already ignored
    --- @param charOrDisplayName string
    AddIgnore = function (charOrDisplayName)
        zos_AddIgnore(charOrDisplayName)

        if IsIgnored(charOrDisplayName) then -- Only lists account names, unfortunately
            ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_IGNORE_FAILED_ALREADYIGNORE), true)
            if LUIE.ChatAnnouncements.SV.Social.FriendIgnoreAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_IGNORE_FAILED_ALREADYIGNORE)))
            end
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
            return
        end
    end

    -- If true then override -
    if LUIE.SV.CustomIcons then
        --
        -- Apply protected function hooks (see ProtectedHooks.lua)
        LUIE.ApplyProtectedHooks()

        local zos_GetSkillAbilityInfo = GetSkillAbilityInfo
        --- Hook for Icon/Name changes.
        --- @param skillType SkillType
        --- @param skillIndex luaindex
        --- @param abilityIndex luaindex
        --- @return string name
        --- @return textureName texture
        --- @return luaindex earnedRank
        --- @return boolean passive
        --- @return boolean ultimate
        --- @return boolean purchased
        --- @return luaindex|nil progressionIndex
        --- @return integer rank
        GetSkillAbilityInfo = function (skillType, skillIndex, abilityIndex)
            local name, texture, earnedRank, passive, ultimate, purchased, progressionIndex, rankIndex = zos_GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
            local abilityId = GetSkillAbilityId(skillType, skillIndex, abilityIndex, true)
            if Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].icon then
                texture = Effects.EffectOverride[abilityId].icon
            end
            if Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].name then
                name = Effects.EffectOverride[abilityId].name
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
            if Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].icon then
                texture = Effects.EffectOverride[abilityId].icon
            end
            if Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].name then
                name = Effects.EffectOverride[abilityId].name
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
        --- @return boolean canClickOff
        --- @return boolean castByPlayer
        GetUnitBuffInfo = function (unitTag, buffIndex)
            local buffName, startTime, endTime, buffSlot, stackCount, iconFile, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = zos_GetUnitBuffInfo(unitTag, buffIndex)
            local override = Effects.EffectOverride[abilityId]
            if override then
                if override.name then
                    buffName = override.name
                end
                if override.icon then
                    iconFile = override.icon
                end
            end
            return buffName, startTime, endTime, buffSlot, stackCount, iconFile, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer
        end

        local zos_GetKillingAttackerInfo = GetKillingAttackerInfo               -- Add a source to attacks that don't normally show one (mostly for environmental effects).
        local zos_GetKillingAttackInfo = GetKillingAttackInfo                   -- Change Source Name, Pet Name, or toggle damage that is sourced from the Player on/off.
        local zos_DoesKillingAttackHaveAttacker = DoesKillingAttackHaveAttacker -- Change Icon or Name (additional support for Zone based changes, and source attacker/pet changes).

        --- Override function for DoesKillingAttackHaveAttacker.
        --- @param index luaindex
        --- @return boolean hasAttacker
        DoesKillingAttackHaveAttacker = function (index)
            local hasAttacker = zos_DoesKillingAttackHaveAttacker(index)
            local attackName, attackDamage, attackIcon, wasKillingBlow, castTimeAgoMS, durationMS, numAttackHits, abilityId = zos_GetKillingAttackInfo(index)
            if Effects.EffectSourceOverride[abilityId] then
                if Effects.EffectSourceOverride[abilityId].addSource then
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
        --- @return boolean isPlayer
        --- @return boolean isBoss
        --- @return Alliance alliance
        --- @return string minionName
        --- @return string attackerDisplayName
        GetKillingAttackerInfo = function (index)
            local attackerRawName, attackerChampionPoints, attackerLevel, attackerAvARank, isPlayer, isBoss, alliance, minionName, attackerDisplayName = zos_GetKillingAttackerInfo(index)
            local attackName, attackDamage, attackIcon, wasKillingBlow, castTimeAgoMS, durationMS, numAttackHits, abilityId = zos_GetKillingAttackInfo(index)
            if Effects.EffectSourceOverride[abilityId] then
                if Effects.EffectSourceOverride[abilityId].source then
                    attackerRawName = Effects.EffectSourceOverride[abilityId].source
                end
                if Effects.EffectSourceOverride[abilityId].pet then
                    minionName = Effects.EffectSourceOverride[abilityId].pet
                end
                if Effects.EffectSourceOverride[abilityId].removePlayer then
                    isPlayer = false
                end
                if Effects.ZoneDataOverride[abilityId] then
                    local index1 = GetZoneId(GetCurrentMapZoneIndex())
                    local zoneName = GetPlayerLocationName()
                    if Effects.ZoneDataOverride[abilityId][index1] then
                        if Effects.ZoneDataOverride[abilityId][index1].source then
                            attackerRawName = Effects.ZoneDataOverride[abilityId][index1].source
                        end
                    end
                    if Effects.ZoneDataOverride[abilityId][zoneName] then
                        if Effects.ZoneDataOverride[abilityId][zoneName].source then
                            attackerRawName = Effects.ZoneDataOverride[abilityId][zoneName].source
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
        --- @return boolean|nil wasKillingBlow
        --- @return integer|nil castTimeAgoMS
        --- @return integer|nil durationMS
        --- @return integer|nil numAttackHits
        --- @return integer|nil abilityId
        --- @return textureName|nil abilityFxIcon
        GetKillingAttackInfo = function (index)
            local attackerRawName, attackerChampionPoints, attackerLevel, attackerAvARank, isPlayer, isBoss, alliance, minionName, attackerDisplayName = zos_GetKillingAttackerInfo(index)
            local attackName, attackDamage, attackIcon, wasKillingBlow, castTimeAgoMS, durationMS, numAttackHits, abilityId, abilityFxIcon = zos_GetKillingAttackInfo(index)

            -- Check if there is an effect override for the abilityId
            if Effects.EffectOverride[abilityId] then
                attackName = Effects.EffectOverride[abilityId].name or attackName
                attackIcon = Effects.EffectOverride[abilityId].icon or attackIcon
            end

            -- Check if there is a zone data override for the abilityId
            if Effects.ZoneDataOverride[abilityId] then
                local index2 = GetZoneId(GetCurrentMapZoneIndex())
                local zoneName = GetPlayerLocationName()

                -- Check if there is a zone data override for the current zone index
                if Effects.ZoneDataOverride[abilityId][index2] then
                    if Effects.ZoneDataOverride[abilityId][index2].icon then
                        attackIcon = Effects.ZoneDataOverride[abilityId][index2].icon
                    end
                    if Effects.ZoneDataOverride[abilityId][index2].name then
                        attackName = Effects.ZoneDataOverride[abilityId][index2].name
                    end
                    if Effects.ZoneDataOverride[abilityId][index2].hide then
                        return nil, nil, nil, nil, nil, nil, nil, nil, nil
                    end
                end

                -- Check if there is a zone data override for the current zone name
                if Effects.ZoneDataOverride[abilityId][zoneName] then
                    if Effects.ZoneDataOverride[abilityId][zoneName].icon then
                        attackIcon = Effects.ZoneDataOverride[abilityId][zoneName].icon
                    end
                    if Effects.ZoneDataOverride[abilityId][zoneName].name then
                        attackName = Effects.ZoneDataOverride[abilityId][zoneName].name
                    end
                    if Effects.ZoneDataOverride[abilityId][zoneName].hide then
                        return nil, nil, nil, nil, nil, nil, nil, nil, nil
                    end
                end
            end

            -- Check if there is a map data override for the abilityId
            if Effects.MapDataOverride[abilityId] then
                local mapName = GetMapName()

                -- Check if there is a map data override for the current map name
                if Effects.MapDataOverride[abilityId][mapName] then
                    if Effects.MapDataOverride[abilityId][mapName].icon then
                        attackIcon = Effects.MapDataOverride[abilityId][mapName].icon
                    end
                    if Effects.MapDataOverride[abilityId][mapName].name then
                        attackName = Effects.MapDataOverride[abilityId][mapName].name
                    end
                    if Effects.MapDataOverride[abilityId][mapName].hide then
                        return nil, nil, nil, nil, nil, nil, nil, nil, nil
                    end
                end
            end

            -- Check if there is an effect override by name for the abilityId
            if Effects.EffectOverrideByName[abilityId] then
                local unitName = zo_strformat("<<C:1>>", attackerRawName)
                local petName = zo_strformat("<<C:1>>", minionName)

                -- Check if there is an effect override by name for the attacker unit name
                if Effects.EffectOverrideByName[abilityId][unitName] then
                    if Effects.EffectOverrideByName[abilityId][unitName].hide then
                        return nil, nil, nil, nil, nil, nil, nil, nil, nil
                    end
                    attackName = Effects.EffectOverrideByName[abilityId][unitName].name or attackName
                    attackIcon = Effects.EffectOverrideByName[abilityId][unitName].icon or attackIcon
                end

                -- Check if there is an effect override by name for the minion name
                if Effects.EffectOverrideByName[abilityId][petName] then
                    if Effects.EffectOverrideByName[abilityId][petName].hide then
                        return nil, nil, nil, nil, nil, nil, nil, nil, nil
                    end
                    attackName = Effects.EffectOverrideByName[abilityId][petName].name or attackName
                    attackIcon = Effects.EffectOverrideByName[abilityId][petName].icon or attackIcon
                end
            end

            -- Check if the attack name is "Fall Damage" and there is an effect override for abilityId 10950
            if attackName == GetString(LUIE_STRING_SKILL_FALL_DAMAGE) then
                if Effects.EffectOverride[10950] then
                    attackIcon = Effects.EffectOverride[10950].icon
                end
            end

            return attackName, attackDamage, attackIcon, wasKillingBlow, castTimeAgoMS, durationMS, numAttackHits, abilityId, abilityFxIcon
        end

        LUIE.GetAbilityIcon = GetAbilityIcon -- Used only for PTS testing
        local zos_GetAbilityIcon = GetAbilityIcon
        --- Hook support for Custom Ability Icons (Helps normalize with other addons)
        --- @param abilityId integer
        --- @return textureName icon
        GetAbilityIcon = function (abilityId)
            local icon = zos_GetAbilityIcon(abilityId)
            if Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].icon then
                icon = Effects.EffectOverride[abilityId].icon
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
            local overrideCasterUnitTag = casterUnitTag or "player"
            local abilityName = zos_GetAbilityName(abilityId, overrideCasterUnitTag)
            if Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].name then
                abilityName = Effects.EffectOverride[abilityId].name
            end
            return abilityName
        end

        LUIE.GetArtificialEffectInfo = GetArtificialEffectInfo -- Used only for PTS testing
        local zos_GetArtificialEffectInfo = GetArtificialEffectInfo
        --- Hook support for ArtificialEffectId's
        --- @param artificialEffectId integer
        --- @return string displayName
        --- @return textureName icon
        --- @return BuffEffectType effectType
        --- @return integer sortOrder
        --- @return number timeStartedS
        --- @return number timeEndingS
        GetArtificialEffectInfo = function (artificialEffectId)
            local displayName, iconFile, effectType, sortOrder, timeStarted, timeEnding = zos_GetArtificialEffectInfo(artificialEffectId)
            if Effects.ArtificialEffectOverride[artificialEffectId] and Effects.ArtificialEffectOverride[artificialEffectId].name then
                displayName = Effects.ArtificialEffectOverride[artificialEffectId].name
            end
            return displayName, iconFile, effectType, sortOrder, timeStarted, timeEnding
        end

        local zos_GetArtificialEffectTooltipText = GetArtificialEffectTooltipText
        LUIE.zos_GetArtificialEffectTooltipText = zos_GetArtificialEffectTooltipText
        --- Hook support to pull custom tooltips for ArtificialEffectId's
        --- @param artificialEffectId integer
        --- @return string tooltipText
        GetArtificialEffectTooltipText = function (artificialEffectId)
            local ov = Effects.ArtificialEffectOverride[artificialEffectId]
            if ov and ov.tooltip and LUIE.FormatArtificialEffectTooltip then
                return LUIE.FormatArtificialEffectTooltip(artificialEffectId)
            end
            return zos_GetArtificialEffectTooltipText(artificialEffectId)
        end
    end
end
