-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- SpellCastBuffs namespace
--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs

-- Used to clear existing .effectsList.unitTag and to request game API to fill it again
---
--- @param unitTag string
SpellCastBuffs.ReloadEffects = function (unitTag)
    -- Bail if this isn't reticleover or player
    if unitTag ~= "player" and unitTag ~= "reticleover" then
        return
    end

    -- Clear existing base containers
    for effectType = BUFF_EFFECT_TYPE_ITERATION_BEGIN, BUFF_EFFECT_TYPE_ITERATION_END do
        SpellCastBuffs.EffectsList[unitTag .. effectType] = {}
    end
    -- Clear prominent containers
    if unitTag == "player" then
        local context = { "promb_player", "promb_ground", "promd_player", "promd_ground" }
        for _, v in pairs(context) do
            SpellCastBuffs.EffectsList[v] = {}
        end
    else
        local context = { "promb_target", "promd_target" }
        for _, v in pairs(context) do
            SpellCastBuffs.EffectsList[v] = {}
        end
    end

    -- Stop doing anything else if we moused off a target
    if GetUnitName(unitTag) == "" then
        return
    end

    -- Bail out if the target is dead
    if IsUnitDead(unitTag) then
        return
    end

    -- Get unitName to pass to OnEffectChanged
    local unitName = GetRawUnitName(unitTag)
    -- Fill it again
    for i = 1, GetNumBuffs(unitTag) do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo(unitTag, i)
        -- Fudge this value to send to SpellCastBuffs.OnEffectChanged if this is a debuff
        if castByPlayer == true then
            --- @diagnostic disable-next-line: cast-local-type
            castByPlayer = COMBAT_UNIT_TYPE_PLAYER
        else
            --- @diagnostic disable-next-line: cast-local-type
            castByPlayer = COMBAT_UNIT_TYPE_OTHER
        end
        SpellCastBuffs.OnEffectChanged(0, EFFECT_RESULT_UPDATED, buffSlot, buffName, unitTag, timeStarted, timeEnding, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, unitName, 0, --[[unitId]] abilityId, castByPlayer)
    end
    -- Display Disguise State (note that this function handles filtering player/target buffs if hidden)
    SpellCastBuffs.DisguiseStateChanged(nil, unitTag, GetUnitDisguiseState(unitTag))
    -- Display Stealth State (note that this function handles filtering player/target buffs if hidden)
    SpellCastBuffs.StealthStateChanged(nil, unitTag, GetUnitStealthState(unitTag))

    -- Player Specific
    if unitTag == "player" and not SpellCastBuffs.SV.HidePlayerBuffs then
        -- Display Assistant/Non-Combat Pet/Mount Icon
        SpellCastBuffs.CollectibleBuff()
        SpellCastBuffs.MountStatus("", true)
        -- Display Disguise Icon (if disguised)
        if not SpellCastBuffs.SV.IgnoreDisguise then
            SpellCastBuffs.SetDisguiseItem()
        end
        -- Update Artificial Effects
        SpellCastBuffs.ArtificialEffectUpdate()
        -- Display Recall Cooldown
        if SpellCastBuffs.SV.ShowRecall and not SpellCastBuffs.SV.HidePlayerDebuffs then
            SpellCastBuffs.ShowRecallCooldown()
        end
        -- Reload werewolf effects
        if SpellCastBuffs.SV.ShowWerewolf and IsPlayerInWerewolfForm() then
            SpellCastBuffs.WerewolfState(nil, true, true)
        end
    end

    -- Target Specific
    if unitTag == "reticleover" and not SpellCastBuffs.SV.HideTargetBuffs then
        -- Handle FAKE DEBUFFS between targets
        SpellCastBuffs.RestoreSavedFakeEffects()
        -- Add Name Auras
        SpellCastBuffs.AddNameAura()
        -- Display Battle Spirit
        SpellCastBuffs.LoadBattleSpiritTarget()
    end
end
