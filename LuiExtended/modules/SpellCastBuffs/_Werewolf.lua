-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs

local eventManager = GetEventManager()

local moduleName = SpellCastBuffs.moduleName

-- Function to pull Werewolf Cast Bar / Buff Aura Icon based off the players morph choice
local function SetWerewolfIcon()
    local skillType, skillIndex, abilityIndex, morphChoice, rankIndex = GetSpecificSkillAbilityKeysByAbilityId(32455)
    local abilityInfo = { GetSkillAbilityInfo(skillType, skillIndex, abilityIndex) }
    SpellCastBuffs.werewolfName, SpellCastBuffs.werewolfIcon = abilityInfo[1], abilityInfo[2]
    SpellCastBuffs.werewolfId = GetSkillAbilityId(skillType, skillIndex, abilityIndex, false)
end

function SpellCastBuffs.DisplayWerewolfIcon()
    SetWerewolfIcon()
    local contextTarget = "player1"
    local context = SpellCastBuffs.DetermineContextSimple(contextTarget, SpellCastBuffs.werewolfId, SpellCastBuffs.werewolfName)
    local power = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_WEREWOLF)
    SpellCastBuffs.EffectsList[context]["Werewolf Indicator"] =
    {
        target = "player",
        type = 1,
        id = SpellCastBuffs.werewolfId,
        name = SpellCastBuffs.werewolfName,
        icon = SpellCastBuffs.werewolfIcon,
        dur = 0,
        starts = 1,
        ends = nil, -- ends=nil : last buff in sorting
        forced = "short",
        restart = true,
        iconNum = 0,
        werewolf = power / 1000,
    }
end

function SpellCastBuffs.HideWerewolfIcon()
    local contextTarget = "player1"
    local context = SpellCastBuffs.DetermineContextSimple(contextTarget, SpellCastBuffs.werewolfId, SpellCastBuffs.werewolfName)
    SpellCastBuffs.EffectsList[context]["Werewolf Indicator"] = nil
end

-- Get Werewolf State for Werewolf Buff Tracker
function SpellCastBuffs.WerewolfState(eventCode, werewolf, onActivation)
    if werewolf and not SpellCastBuffs.SV.HidePlayerBuffs then
        for i = 1, 6 do
            local skillLineData = SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(SKILL_TYPE_WORLD, i)
            local name, discovered, skillLineId = skillLineData:GetName(), skillLineData:IsAvailable(), skillLineData:GetId()
            if skillLineId == 50 and discovered then
                SpellCastBuffs.werewolfCounter = SpellCastBuffs.werewolfCounter + 1
                if SpellCastBuffs.werewolfCounter == 3 or onActivation then
                    SpellCastBuffs.DisplayWerewolfIcon()
                    eventManager:RegisterForEvent(moduleName, EVENT_POWER_UPDATE, SpellCastBuffs.OnPowerUpdate)
                    eventManager:AddFilterForEvent(moduleName, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_WEREWOLF, REGISTER_FILTER_UNIT_TAG, "player")
                    SpellCastBuffs.werewolfCounter = 0
                end
                return
            end
        end

        SpellCastBuffs.werewolfQuest = SpellCastBuffs.werewolfQuest + 1
        -- If we didn't return from the above statement this must be quest based werewolf transformation - so just display an unlimited duration passive as the counter.
        if SpellCastBuffs.werewolfQuest == 2 or onActivation then
            SpellCastBuffs.werewolfCounter = 0
        end
    else
        SpellCastBuffs.HideWerewolfIcon()
        eventManager:UnregisterForEvent(moduleName, EVENT_POWER_UPDATE)
        eventManager:UnregisterForUpdate(moduleName .. "WerewolfTicker")
        SpellCastBuffs.werewolfCounter = 0
        -- Delay resetting this value - as the quest werewolf transform event causes werewolf true, false, true in succession.
        zo_callLater(function ()
                         SpellCastBuffs.werewolfQuest = 0
                     end, 5000)
    end
end

-- EVENT_POWER_UPDATE handler for Werewolf Buff Tracker
function SpellCastBuffs.OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    if powerValue > 0 then
        SpellCastBuffs.DisplayWerewolfIcon()
    else
        SpellCastBuffs.HideWerewolfIcon()
    end

    -- Remove indicator if power reaches 0 - Needed for when the player is in WW form but dead/reincarnating
    if powerValue == 0 then
        SpellCastBuffs.HideWerewolfIcon()
        eventManager:UnregisterForEvent(moduleName, EVENT_POWER_UPDATE)
        eventManager:UnregisterForUpdate(moduleName .. "WerewolfTicker")
        SpellCastBuffs.werewolfCounter = 0
        -- Delay resetting this value - as the quest werewolf transform event causes werewolf true, false, true in succession.
        zo_callLater(function ()
                         SpellCastBuffs.werewolfQuest = 0
                     end, 5000)
    end
end
