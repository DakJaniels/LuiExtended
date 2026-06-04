-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local LuiData = LuiData
--- @type Data
local Data = LuiData.Data
--- @type Effects
local Effects = Data.Effects
local Abilities = Data.Abilities
local Tooltips = Data.Tooltips
local ChatOutput = LUIE.ChatOutput
local GetString = GetString
local zo_strformat = zo_strformat
local chatSystem = ZO_GetChatSystem()
local GetAbilityIcon = GetAbilityIcon
local GetAbilityName = GetAbilityName
local zo_iconFormat = zo_iconFormat
local tonumber = tonumber

-- SpellCastBuffs namespace
--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs


-- Bulk list add from menu buttons
function SpellCastBuffs.AddBulkToCustomList(list, table)
    if table ~= nil then
        for k, _ in pairs(table) do
            SpellCastBuffs.AddToCustomList(list, k)
        end
    end
end

function SpellCastBuffs.ClearCustomList(list)
    local listRef =
        list == SpellCastBuffs.SV.PromBuffTable and GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS) or
        list == SpellCastBuffs.SV.PromDebuffTable and GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS) or
        list == SpellCastBuffs.SV.PriorityBuffTable and GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_BUFFS) or
        list == SpellCastBuffs.SV.PriorityDebuffTable and GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_DEBUFFS) or
        list == SpellCastBuffs.SV.BlacklistTable and GetString(LUIE_STRING_CUSTOM_LIST_AURA_BLACKLIST)
    for k, _ in pairs(list) do
        list[k] = nil
    end
    chatSystem:Maximize()
    chatSystem.primaryContainer:FadeIn()
    ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_CLEARED), listRef), true)
    SpellCastBuffs.ReloadEffects("player")
end

-- List Handling (Add) for Prominent Auras & Blacklist
function SpellCastBuffs.AddToCustomList(list, input)
    local id = tonumber(input)
    local listRef =
        list == SpellCastBuffs.SV.PromBuffTable and GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS) or
        list == SpellCastBuffs.SV.PromDebuffTable and GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS) or
        list == SpellCastBuffs.SV.PriorityBuffTable and GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_BUFFS) or
        list == SpellCastBuffs.SV.PriorityDebuffTable and GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_DEBUFFS) or
        list == SpellCastBuffs.SV.BlacklistTable and GetString(LUIE_STRING_CUSTOM_LIST_AURA_BLACKLIST)
    if id and id > 0 then
        local name = zo_strformat("<<C:1>>", GetAbilityName(id))
        if name ~= nil and name ~= "" then
            local icon = zo_iconFormat(GetAbilityIcon(id), 16, 16)
            list[id] = true
            chatSystem:Maximize()
            chatSystem.primaryContainer:FadeIn()
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_ID), icon, id, name, listRef), true)
        else
            chatSystem:Maximize()
            chatSystem.primaryContainer:FadeIn()
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_FAILED), input, listRef), true)
        end
    else
        if input ~= "" then
            list[input] = true
            chatSystem:Maximize()
            chatSystem.primaryContainer:FadeIn()
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_NAME), input, listRef), true)
        end
    end
    SpellCastBuffs.ReloadEffects("player")
end

-- List Handling (Remove) for Prominent Auras & Blacklist
function SpellCastBuffs.RemoveFromCustomList(list, input)
    local id = tonumber(input)
    local listRef =
        list == SpellCastBuffs.SV.PromBuffTable and GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS) or
        list == SpellCastBuffs.SV.PromDebuffTable and GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS) or
        list == SpellCastBuffs.SV.PriorityBuffTable and GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_BUFFS) or
        list == SpellCastBuffs.SV.PriorityDebuffTable and GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_DEBUFFS) or
        list == SpellCastBuffs.SV.BlacklistTable and GetString(LUIE_STRING_CUSTOM_LIST_AURA_BLACKLIST)
    if id and id > 0 then
        local name = zo_strformat("<<C:1>>", GetAbilityName(id))
        local icon = zo_iconFormat(GetAbilityIcon(id), 16, 16)
        list[id] = nil
        chatSystem:Maximize()
        chatSystem.primaryContainer:FadeIn()
        ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_REMOVED_ID), icon, id, name, listRef), true)
    else
        if input ~= "" then
            list[input] = nil
            chatSystem:Maximize()
            chatSystem.primaryContainer:FadeIn()
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_REMOVED_NAME), input, listRef), true)
        end
    end
    SpellCastBuffs.ReloadEffects("player")
end

-- Helper to get current list and check if buff is in list
function SpellCastBuffs.GetCurrentList()
    if SpellCastBuffs.SV.ListMode == "whitelist" then
        return SpellCastBuffs.SV.WhitelistTable
    else
        return SpellCastBuffs.SV.BlacklistTable
    end
end

---
--- @param abilityId integer
--- @param abilityName string
--- @return table<integer|string> list
function SpellCastBuffs.IsBuffListed(abilityId, abilityName)
    local list = SpellCastBuffs.GetCurrentList()
    return list[abilityId] or list[abilityName]
end

-- Called from the menu and on initialize to build the table of hidden effects.
function SpellCastBuffs.UpdateContextHideList()
    SpellCastBuffs.hidePlayerEffects = {}
    SpellCastBuffs.hideTargetEffects = {}

    -- Hide Warden Crystallized Shield & morphs from effects on the player (we use fake buffs to track this so that the stack count can be displayed)
    SpellCastBuffs.hidePlayerEffects[86135] = true
    SpellCastBuffs.hidePlayerEffects[86139] = true
    SpellCastBuffs.hidePlayerEffects[86143] = true

    if SpellCastBuffs.SV.IgnoreMundusPlayer then
        for k, v in pairs(Effects.IsBoon) do
            SpellCastBuffs.hidePlayerEffects[k] = v
        end
    end
    if SpellCastBuffs.SV.IgnoreMundusTarget then
        for k, v in pairs(Effects.IsBoon) do
            SpellCastBuffs.hideTargetEffects[k] = v
        end
    end
    if SpellCastBuffs.SV.IgnoreVampPlayer then
        for k, v in pairs(Effects.IsVamp) do
            SpellCastBuffs.hidePlayerEffects[k] = v
        end
    end
    if SpellCastBuffs.SV.IgnoreVampTarget then
        for k, v in pairs(Effects.IsVamp) do
            SpellCastBuffs.hideTargetEffects[k] = v
        end
    end
    if SpellCastBuffs.SV.IgnoreLycanPlayer then
        for k, v in pairs(Effects.IsLycan) do
            SpellCastBuffs.hidePlayerEffects[k] = v
        end
    end
    if SpellCastBuffs.SV.IgnoreLycanTarget then
        for k, v in pairs(Effects.IsLycan) do
            SpellCastBuffs.hideTargetEffects[k] = v
        end
    end
    if SpellCastBuffs.SV.IgnoreDiseasePlayer then
        for k, v in pairs(Effects.IsVampLycanDisease) do
            SpellCastBuffs.hidePlayerEffects[k] = v
        end
    end
    if SpellCastBuffs.SV.IgnoreDiseaseTarget then
        for k, v in pairs(Effects.IsVampLycanDisease) do
            SpellCastBuffs.hideTargetEffects[k] = v
        end
    end
    if SpellCastBuffs.SV.IgnoreBitePlayer then
        for k, v in pairs(Effects.IsVampLycanBite) do
            SpellCastBuffs.hidePlayerEffects[k] = v
        end
    end
    if SpellCastBuffs.SV.IgnoreBiteTarget then
        for k, v in pairs(Effects.IsVampLycanBite) do
            SpellCastBuffs.hideTargetEffects[k] = v
        end
    end
    if SpellCastBuffs.SV.IgnoreCyrodiilPlayer then
        for k, v in pairs(Effects.IsCyrodiil) do
            SpellCastBuffs.hidePlayerEffects[k] = v
        end
    end
    if SpellCastBuffs.SV.IgnoreCyrodiilTarget then
        for k, v in pairs(Effects.IsCyrodiil) do
            SpellCastBuffs.hideTargetEffects[k] = v
        end
    end
    if SpellCastBuffs.SV.IgnoreEsoPlusPlayer then
        SpellCastBuffs.hidePlayerEffects[63601] = true
    end
    if SpellCastBuffs.SV.IgnoreEsoPlusTarget then
        SpellCastBuffs.hideTargetEffects[63601] = true
    end
    if SpellCastBuffs.SV.IgnoreSoulSummonsPlayer then
        for k, v in pairs(Effects.IsSoulSummons) do
            SpellCastBuffs.hidePlayerEffects[k] = v
        end
    end
    if SpellCastBuffs.SV.IgnoreSoulSummonsTarget then
        for k, v in pairs(Effects.IsSoulSummons) do
            SpellCastBuffs.hideTargetEffects[k] = v
        end
    end
    if SpellCastBuffs.SV.IgnoreFoodPlayer then
        for k, v in pairs(Effects.IsFoodBuff) do
            SpellCastBuffs.hidePlayerEffects[k] = v
        end
    end
    if SpellCastBuffs.SV.IgnoreFoodTarget then
        for k, v in pairs(Effects.IsFoodBuff) do
            SpellCastBuffs.hideTargetEffects[k] = v
        end
    end
    if SpellCastBuffs.SV.IgnoreExperiencePlayer then
        for k, v in pairs(Effects.IsExperienceBuff) do
            SpellCastBuffs.hidePlayerEffects[k] = v
        end
    end
    if SpellCastBuffs.SV.IgnoreExperienceTarget then
        for k, v in pairs(Effects.IsExperienceBuff) do
            SpellCastBuffs.hideTargetEffects[k] = v
        end
    end
    if SpellCastBuffs.SV.IgnoreAllianceXPPlayer then
        for k, v in pairs(Effects.IsAllianceXPBuff) do
            SpellCastBuffs.hidePlayerEffects[k] = v
        end
    end
    if SpellCastBuffs.SV.IgnoreAllianceXPTarget then
        for k, v in pairs(Effects.IsAllianceXPBuff) do
            SpellCastBuffs.hideTargetEffects[k] = v
        end
    end
    if not SpellCastBuffs.SV.ShowBlockPlayer then
        for k, v in pairs(Effects.IsBlock) do
            SpellCastBuffs.hidePlayerEffects[k] = v
        end
    end
    if not SpellCastBuffs.SV.ShowBlockTarget then
        for k, v in pairs(Effects.IsBlock) do
            SpellCastBuffs.hideTargetEffects[k] = v
        end
    end
end

-- Called from the menu and on initialize to build the table of effects we should show regardless of source (by id).
function SpellCastBuffs.UpdateDisplayOverrideIdList()
    -- Clear the list
    SpellCastBuffs.debuffDisplayOverrideId = {}

    -- Add effects from table if enabled
    if SpellCastBuffs.SV.ShowSharedEffects then
        for k, v in pairs(Effects.DebuffDisplayOverrideId) do
            SpellCastBuffs.debuffDisplayOverrideId[k] = v
        end
    end

    -- Always show NPC self applied debuffs
    for k, v in pairs(Effects.DebuffDisplayOverrideIdAlways) do
        SpellCastBuffs.debuffDisplayOverrideId[k] = v
    end

    -- Major/Minor
    if SpellCastBuffs.SV.ShowSharedMajorMinor then
        for k, v in pairs(Effects.DebuffDisplayOverrideMajorMinor) do
            SpellCastBuffs.debuffDisplayOverrideId[k] = v
        end
    end
end

-- Builds a lookup of every ability id that LuiData treats as the shared
-- "Off Balance" debuff. Any entry in Effects.EffectOverride that either uses
-- Tooltips.Generic_Off_Balance or normalizes to Abilities.Skill_Off_Balance
-- counts. The Immunity buff (and any explicit BUFF_EFFECT_TYPE_BUFF entry)
-- is excluded so ally-applied OB *debuffs* can promote to the prominent
-- target container without requiring a hand-maintained id list.
function SpellCastBuffs.BuildOffBalanceDebuffLookup()
    SpellCastBuffs.offBalanceDebuffById = {}
    local lookup = SpellCastBuffs.offBalanceDebuffById
    local obTooltip = Tooltips.Generic_Off_Balance
    local obName = Abilities.Skill_Off_Balance

    for id, data in pairs(Effects.EffectOverride) do
        if data.type ~= BUFF_EFFECT_TYPE_BUFF then
            if (obTooltip and data.tooltip == obTooltip) or (obName and data.name == obName) then
                lookup[id] = true
            end
        end
    end
end

-- -----------------------------------------------------------------------------
-- Effect instance uid (ZOS BuffDebuff-aligned storage keys)
-- Native rows use API buffSlot; synthetics use namespaced string uids.
-- -----------------------------------------------------------------------------

--- @param buffSlot integer|string
--- @return integer|string
function SpellCastBuffs.GetEffectUidNative(buffSlot)
    return buffSlot
end

--- @param abilityId integer
--- @return string
local function GetEffectUidFake(abilityId)
    return "fake:" .. tostring(abilityId)
end
SpellCastBuffs.GetEffectUidFake = GetEffectUidFake

--- @param unitName string
--- @param abilityId integer
--- @return string
function SpellCastBuffs.GetEffectUidNameAura(unitName, abilityId)
    return "name:" .. tostring(unitName) .. ":" .. tostring(abilityId)
end

--- @param listKey integer|string
--- @return boolean
function SpellCastBuffs.IsSyntheticEffectKey(listKey)
    if type(listKey) == "string" then
        return listKey:sub(1, 5) == "fake:"
            or listKey:sub(1, 5) == "name:"
            or listKey:find("^Name Specific Buff", 1, true) ~= nil
    end
    return false
end

--- @param unitTag string
--- @param abilityId integer
--- @return boolean
function SpellCastBuffs.UnitHasBuffAbilityId(unitTag, abilityId)
    if unitTag == nil or abilityId == nil then
        return false
    end
    for i = 1, GetNumBuffs(unitTag) do
        local _, _, _, _, _, _, _, _, _, _, buffAbilityId = GetUnitBuffInfo(unitTag, i)
        if buffAbilityId == abilityId then
            return true
        end
    end
    return false
end

--- @param context string
--- @param abilityId integer
--- @param keepUid integer|string|nil
function SpellCastBuffs.RemoveSyntheticEffectsForAbilityId(context, abilityId, keepUid)
    local effectsList = SpellCastBuffs.EffectsList[context]
    if not effectsList then
        return
    end
    local fakeUid = GetEffectUidFake(abilityId)
    for listKey, effect in pairs(effectsList) do
        if listKey ~= keepUid and effect.id == abilityId then
            if listKey == fakeUid or SpellCastBuffs.IsSyntheticEffectKey(listKey) then
                effectsList[listKey] = nil
            elseif type(listKey) == "number" and effect.buffSlot == nil then
                effectsList[listKey] = nil
            end
        end
    end
    SpellCastBuffs.MarkDisplayDirty()
end

--- @param context string
--- @param abilityId integer
--- @return table|nil
function SpellCastBuffs.GetFakeEffectEntry(context, abilityId)
    local effectsList = SpellCastBuffs.EffectsList[context]
    if not effectsList then
        return nil
    end
    local uid = GetEffectUidFake(abilityId)
    return effectsList[uid] or effectsList[abilityId]
end

--- @param context string
--- @param abilityId integer
--- @return boolean removed True if an effects-list row was cleared
function SpellCastBuffs.ClearFakeEffectEntry(context, abilityId)
    local effectsList = SpellCastBuffs.EffectsList[context]
    if not effectsList then
        return false
    end
    local uid = GetEffectUidFake(abilityId)
    local removed = effectsList[uid] ~= nil or effectsList[abilityId] ~= nil
    if not removed then
        return false
    end
    effectsList[uid] = nil
    effectsList[abilityId] = nil
    SpellCastBuffs.MarkDisplayDirty()
    return true
end

--- @param context string
--- @param abilityId integer
--- @param entry table
function SpellCastBuffs.SetFakeCombatEffect(context, abilityId, entry)
    local uid = GetEffectUidFake(abilityId)
    entry.uid = uid
    local effectsList = SpellCastBuffs.EffectsList[context]
    effectsList[uid] = entry
    effectsList[abilityId] = nil
    SpellCastBuffs.MarkDisplayDirty()
end

--- Remove other EffectsList rows that share the same UI container and ability id (e.g. ground + reticleover2 -> target debuffs).
--- @param keepContext string
--- @param abilityId integer
--- @param keepUid integer|string|nil
function SpellCastBuffs.RemoveDuplicateEffectsInSharedContainer(keepContext, abilityId, keepUid)
    local keepContainer = SpellCastBuffs.containerRouting[keepContext]
    if not keepContainer or not abilityId then
        return
    end
    for context, effectsList in pairs(SpellCastBuffs.EffectsList) do
        if context ~= keepContext and SpellCastBuffs.containerRouting[context] == keepContainer then
            for listKey, effect in pairs(effectsList) do
                if effect.id == abilityId and listKey ~= keepUid then
                    effectsList[listKey] = nil
                end
            end
        end
    end
    SpellCastBuffs.MarkDisplayDirty()
end
