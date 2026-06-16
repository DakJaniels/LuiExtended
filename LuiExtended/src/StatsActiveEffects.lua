-- -----------------------------------------------------------------------------
--  LuiExtended — Character Stats "Active Effects" (keyboard + gamepad)
--  Layer 1: EsoUI/Ingame/Stats (GetArtificialEffectInfo + GetUnitBuffInfo gates).
--  Layer 2: LUIE icon/name/tooltip enrichment (EffectOverride.hide does not filter listing).
--  Layer 3: SpellCastBuffs player EffectsList rows absent from unit API.
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local Data = LuiData.Data
local Effects = Data.Effects

local STATS_SCB_PLAYER_CONTEXTS =
{
    player1 = true,
    player2 = true,
    playerb = true,
    playerd = true,
    player_long = true,
    promb_player = true,
    promd_player = true,
}

--- Stats panel lists all unit/artificial rows vanilla would; SpellCastBuffs Hide Reduce is HUD-only.
--- @param abilityId integer
--- @return boolean
function LUIE.ShouldShowStatsActiveEffect(abilityId)
    return true
end

--- @param endsMsOrSec number|nil
--- @return number|nil endTime seconds for UI timers
local function NormalizeScbTimeToSeconds(endsMsOrSec)
    if not endsMsOrSec or endsMsOrSec == 0 then
        return nil
    end
    if endsMsOrSec > 1000000 then
        return endsMsOrSec / 1000
    end
    return endsMsOrSec
end

--- @param rowA table
--- @param rowB table
--- @return boolean
function LUIE.StatsActiveEffectRowComparator(rowA, rowB)
    local leftIsArtificial, rightIsArtificial = rowA.isArtificial, rowB.isArtificial
    if leftIsArtificial ~= rightIsArtificial then
        return leftIsArtificial
    end
    if leftIsArtificial then
        return (rowA.sortOrder or 0) < (rowB.sortOrder or 0)
    end
    return (rowA.endTime or 0) < (rowB.endTime or 0)
end

--- @param rows table
function LUIE.SortStatsActiveEffectRows(rows)
    table.sort(rows, LUIE.StatsActiveEffectRowComparator)
end

--- @param scbEntry table
--- @return string
function LUIE.GetStatsActiveEffectTooltipTextFromScbEntry(scbEntry)
    if not scbEntry then
        return ""
    end
    local abilityId = scbEntry.id
    if scbEntry.tooltip then
        if type(scbEntry.tooltip) == "string" and scbEntry.tooltip ~= "" then
            return scbEntry.tooltip
        end
    end
    if abilityId and type(abilityId) == "number" and abilityId > 0 then
        local dynTip = LUIE.DynamicTooltip(abilityId)
        if dynTip and dynTip ~= "" then
            return dynTip
        end
        if DoesAbilityExist(abilityId) then
            local desc = GetAbilityDescription(abilityId)
            if desc and desc ~= "" then
                return desc
            end
        end
    end
    return scbEntry.name or ""
end

local function CollectUnitBuffAbilityIds()
    local unitAbilityIds = {}
    for buffIndex = 1, GetNumBuffs("player") do
        local _, _, _, buffSlot, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", buffIndex)
        if buffSlot > 0 and abilityId and abilityId > 0 then
            unitAbilityIds[abilityId] = true
        end
    end
    return unitAbilityIds
end

local function HasArtificialStatsRow(rows, artificialEffectId)
    for rowIndex = 1, #rows do
        local row = rows[rowIndex]
        if row.isArtificial and row.artificialEffectId == artificialEffectId then
            return true
        end
    end
    return false
end

local function HasPlayerBattleSpiritStatsRow(rows)
    for rowIndex = 1, #rows do
        local row = rows[rowIndex]
        if row.isArtificial and (row.artificialEffectId == 1 or row.artificialEffectId == 3) then
            return true
        end
        if row.abilityId == 999014 then
            return true
        end
    end
    return false
end

local function AppendArtificialStatsRows(rows)
    for effectId in ZO_GetNextActiveArtificialEffectIdIter do
        local displayName, iconFile, effectType, sortOrder, startTime, endTime = GetArtificialEffectInfo(effectId)
        if (effectId == 1 or effectId == 3) and not LUIE.ShouldShowPlayerBattleSpirit() then
            -- Cyro Vengeance has no Battle Spirit artificial effect.
        elseif LUIE.IsDisplayableArtificialEffectType(effectType) then
            rows[#rows + 1] =
            {
                isArtificial = true,
                isArtificialTooltip = true,
                artificialEffectId = effectId,
                sortOrder = sortOrder,
                displayName = displayName,
                displayIcon = iconFile,
                effectType = effectType,
                startTime = startTime,
                endTime = endTime,
                tooltipTitle = displayName,
            }
        end
    end
end

local function AppendPlayerBattleSpiritStatsFallback(rows)
    local spellCastBuffs = LUIE.SpellCastBuffs
    if not spellCastBuffs or not spellCastBuffs.ShouldCreatePlayerBattleSpiritFallback then
        return
    end
    if HasPlayerBattleSpiritStatsRow(rows) then
        return
    end
    if not spellCastBuffs.ShouldCreatePlayerBattleSpiritFallback() then
        return
    end
    local abilityId = 999014
    local displayName = LUIE.GetStatsActiveEffectDisplayName(abilityId, "")
    local displayIcon = LUIE.GetStatsActiveEffectIcon(abilityId, "/esoui/art/icons/artificialeffect_battle-spirit.dds")
    rows[#rows + 1] =
    {
        isArtificial = false,
        isArtificialTooltip = false,
        isSyntheticFromScb = true,
        abilityId = abilityId,
        displayName = displayName,
        displayIcon = displayIcon,
        effectType = BUFF_EFFECT_TYPE_BUFF,
        startTime = GetGameTimeSeconds(),
        endTime = GetGameTimeSeconds(),
        tooltipTitle = displayName,
        tooltipText = GetArtificialEffectTooltipText(1),
        buffSlot = nil,
    }
end

local function AppendUnitBuffStatsRows(rows)
    for buffIndex = 1, GetNumBuffs("player") do
        local buffName, startTime, endTime, buffSlot, stackCount, iconFile, _, effectType, _, _, abilityId = GetUnitBuffInfo("player", buffIndex)
        if buffSlot > 0 and buffName ~= "" then
            local displayName = LUIE.GetStatsActiveEffectDisplayName(abilityId, buffName)
            local displayIcon = LUIE.GetStatsActiveEffectIcon(abilityId, iconFile)
            local resolvedType = LUIE.ResolveStatsActiveEffectType(abilityId, effectType)
            rows[#rows + 1] =
            {
                isArtificial = false,
                isArtificialTooltip = false,
                buffIndex = buffIndex,
                buffSlot = buffSlot,
                abilityId = abilityId,
                stackCount = stackCount,
                displayName = displayName,
                displayIcon = displayIcon,
                effectType = resolvedType,
                startTime = startTime,
                endTime = endTime,
                tooltipTitle = displayName,
                tooltipText = LUIE.GetStatsActiveEffectTooltipText(abilityId, buffSlot, startTime, endTime),
                thirdLine = LUIE.GetStatsActiveEffectThirdLine(abilityId, endTime - startTime),
            }
        end
    end
end

--- @param abilityId integer|nil
--- @param rows table[]
--- @param unitAbilityIds table
--- @param supplementAbilityIds table
--- @return boolean
local function ShouldSkipScbSupplementId(abilityId, rows, unitAbilityIds, supplementAbilityIds)
    if not abilityId or type(abilityId) ~= "number" or abilityId <= 0 then
        return true
    end
    if unitAbilityIds[abilityId] then
        return true
    end
    if supplementAbilityIds[abilityId] then
        return true
    end
    if abilityId == 999014 and not LUIE.ShouldShowPlayerBattleSpirit() then
        return true
    end
    -- Dedupe only when Layer 1 already listed the artificial row (not merely active on the API).
    if abilityId == 999014 and (HasArtificialStatsRow(rows, 1) or HasArtificialStatsRow(rows, 3)) then
        return true
    end
    if abilityId == 63601 and HasArtificialStatsRow(rows, 0) then
        return true
    end
    return false
end

local function AppendScbSupplementStatsRows(rows, unitAbilityIds)
    local spellCastBuffs = LUIE.SpellCastBuffs
    if not spellCastBuffs or not spellCastBuffs.EffectsList then
        return
    end
    local supplementAbilityIds = {}
    for contextKey in pairs(STATS_SCB_PLAYER_CONTEXTS) do
        local effectsList = spellCastBuffs.EffectsList[contextKey]
        if effectsList then
            for _, scbEntry in pairs(effectsList) do
                if type(scbEntry) == "table" and scbEntry.id then
                    local abilityId = scbEntry.id
                    if not ShouldSkipScbSupplementId(abilityId, rows, unitAbilityIds, supplementAbilityIds) then
                        supplementAbilityIds[abilityId] = true
                        local startTime = NormalizeScbTimeToSeconds(scbEntry.starts) or GetGameTimeSeconds()
                        local endTime = NormalizeScbTimeToSeconds(scbEntry.ends)
                        local displayName = LUIE.GetStatsActiveEffectDisplayName(abilityId, scbEntry.name or "")
                        local displayIcon = scbEntry.icon or LUIE.GetStatsActiveEffectIcon(abilityId, "")
                        local effectType = scbEntry.type or BUFF_EFFECT_TYPE_BUFF
                        if effectType == 1 then
                            effectType = BUFF_EFFECT_TYPE_BUFF
                        elseif effectType == 2 then
                            effectType = BUFF_EFFECT_TYPE_DEBUFF
                        end
                        effectType = LUIE.ResolveStatsActiveEffectType(abilityId, effectType)
                        rows[#rows + 1] =
                        {
                            isArtificial = false,
                            isArtificialTooltip = false,
                            isSyntheticFromScb = true,
                            abilityId = abilityId,
                            stackCount = scbEntry.stack,
                            displayName = displayName,
                            displayIcon = displayIcon,
                            effectType = effectType,
                            startTime = startTime,
                            endTime = endTime or startTime,
                            tooltipTitle = displayName,
                            tooltipText = LUIE.GetStatsActiveEffectTooltipTextFromScbEntry(scbEntry),
                            buffSlot = nil,
                        }
                    end
                end
            end
        end
    end
end
--- Build active effect rows for Character Stats (vanilla + LUIE + SCB supplement).
--- @return table[]
function LUIE.BuildStatsActiveEffectRows()
    local rows = {}
    local unitAbilityIds = CollectUnitBuffAbilityIds()
    AppendArtificialStatsRows(rows)
    AppendUnitBuffStatsRows(rows)
    AppendScbSupplementStatsRows(rows, unitAbilityIds)
    AppendPlayerBattleSpiritStatsFallback(rows)
    LUIE.SortStatsActiveEffectRows(rows)
    return rows
end

--- @param abilityId integer
--- @param startTime number
--- @param endTime number
--- @return number timer
--- @return number value2
--- @return number value3
function LUIE.ResolveStatsActiveEffectTooltipValues(abilityId, startTime, endTime)
    local timer = endTime - startTime
    local value2, value3 = 0, 0
    local effectOverride = Effects.EffectOverride[abilityId]
    if effectOverride then
        if effectOverride.tooltipValue2 then
            value2 = effectOverride.tooltipValue2
        elseif effectOverride.tooltipValue2Mod then
            value2 = zo_floor(timer + effectOverride.tooltipValue2Mod + 0.5)
        elseif effectOverride.tooltipValue2Id then
            value2 = zo_floor((GetAbilityDuration(effectOverride.tooltipValue2Id) or 0) + 0.5) / 1000
        end
        value3 = effectOverride.tooltipValue3 or 0
    end
    timer = zo_floor((timer * 10) + 0.5) / 10
    return timer, value2, value3
end

--- @param abilityId integer
--- @param buffSlot integer|nil
--- @param startTime number
--- @param endTime number
--- @return string
function LUIE.GetStatsActiveEffectTooltipText(abilityId, buffSlot, startTime, endTime)
    local timer, value2, value3 = LUIE.ResolveStatsActiveEffectTooltipValues(abilityId, startTime, endTime)
    local override = Effects.EffectOverride[abilityId]
    local tooltipText
    if LUIE.ResolveVeteranDifficulty() and override and override.tooltipVeteran then
        tooltipText = zo_strformat(override.tooltipVeteran, timer, value2, value3)
    else
        tooltipText = (override and override.tooltip) and zo_strformat(override.tooltip, timer, value2, value3) or GetAbilityDescription(abilityId)
    end
    if (tooltipText == "" or tooltipText == nil) and buffSlot then
        local effectDesc = GetAbilityEffectDescription(buffSlot)
        if effectDesc ~= "" then
            tooltipText = effectDesc
        end
    end
    if Effects.TooltipUseDefault[abilityId] and buffSlot then
        local effectDesc = GetAbilityEffectDescription(buffSlot)
        if effectDesc ~= "" then
            tooltipText = LUIE.UpdateMundusTooltipSyntax(abilityId, effectDesc)
        end
    end
    local dynTip = LUIE.DynamicTooltip(abilityId)
    if dynTip then
        tooltipText = dynTip
    end
    if tooltipText ~= "" and tooltipText ~= nil then
        tooltipText = string.match(tooltipText, ".*%S")
    end
    if LUIE.SpellCastBuffs and LUIE.SpellCastBuffs.SV and not LUIE.SpellCastBuffs.SV.TooltipCustom and buffSlot then
        tooltipText = GetAbilityEffectDescription(buffSlot)
        tooltipText = StringOnlyGSUB(tooltipText, "\n$", "")
    end
    if (tooltipText == "" or tooltipText == nil) and buffSlot then
        tooltipText = GetAbilityEffectDescription(buffSlot)
        tooltipText = StringOnlyGSUB(tooltipText or "", "\n$", "")
    end
    return tooltipText or ""
end

--- @param abilityId integer
--- @param buffName string
--- @return string
function LUIE.GetStatsActiveEffectDisplayName(abilityId, buffName)
    local effectOverride = abilityId and Effects.EffectOverride[abilityId]
    if effectOverride and effectOverride.name then
        return effectOverride.name
    end
    if abilityId and DoesAbilityExist(abilityId) then
        local abilityName = GetAbilityName(abilityId, "player")
        if abilityName and abilityName ~= "" then
            return abilityName
        end
    end
    return buffName
end

--- @param abilityId integer
--- @param iconFile string
--- @return string
function LUIE.GetStatsActiveEffectIcon(abilityId, iconFile)
    if abilityId and DoesAbilityExist(abilityId) then
        local icon = GetAbilityIcon(abilityId)
        if icon and icon ~= "" then
            return icon
        end
    end
    return iconFile
end

--- @param abilityId integer
--- @param effectType BuffEffectType
--- @return BuffEffectType
function LUIE.ResolveStatsActiveEffectType(abilityId, effectType)
    local effectOverride = Effects.EffectOverride[abilityId]
    if effectOverride and effectOverride.type then
        return effectOverride.type
    end
    return effectType
end

--- @param abilityId integer
--- @param durationSec number
--- @return string|nil
function LUIE.GetStatsActiveEffectThirdLine(abilityId, durationSec)
    if Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].duration then
        durationSec = durationSec + Effects.EffectOverride[abilityId].duration
    end
    return nil
end

--- @param abilityId integer|nil
--- @param effectType integer|nil
--- @return integer
function LUIE.GetStatsActiveEffectTooltipBuffType(abilityId, effectType)
    local buffType = effectType or LUIE_BUFF_TYPE_NONE
    if not abilityId then
        return buffType
    end
    if Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].unbreakable then
        buffType = buffType + 2
    end
    if Effects.EffectGroundDisplay[abilityId] then
        buffType = buffType + 4
    end
    if Effects.AddGroundDamageAura[abilityId] or (Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].groundLabel) then
        buffType = buffType + 6
    end
    if Effects.FakePlayerOfflineAura[abilityId] then
        if Effects.FakePlayerOfflineAura[abilityId].ground then
            buffType = 6
        else
            buffType = 5
        end
    end
    return buffType
end

--- @param labelAbilityId integer|string|nil
--- @param isArtificial boolean
--- @return integer|string
function LUIE.FormatStatsActiveEffectAbilityIdLabel(labelAbilityId, isArtificial)
    if not isArtificial then
        return labelAbilityId or "None"
    end
    if labelAbilityId == 0 then
        return 63601
    elseif labelAbilityId == 1 then
        return "1 (Battle Spirit)"
    elseif labelAbilityId == 2 then
        return "2 (LFG)"
    elseif labelAbilityId == 3 then
        return "3 (Battle Spirit IC)"
    elseif labelAbilityId == 4 then
        return "4 (BG Deserter)"
    elseif labelAbilityId == 5 then
        return "5 (Underdog Damage)"
    elseif labelAbilityId == 6 then
        return "6 (Underdog Healing)"
    elseif labelAbilityId == 7 then
        return "7 (Solo Queue XP)"
    elseif labelAbilityId == 8 then
        return "8 (Solo Queue AP)"
    end
    return "Artificial"
end

--- @param row table
--- @return string
function LUIE.GetStatsActiveEffectRowTooltipText(row)
    if row.isArtificial then
        return GetArtificialEffectTooltipText(row.artificialEffectId)
    end
    if row.tooltipText and row.tooltipText ~= "" then
        return row.tooltipText
    end
    if row.buffSlot and row.abilityId then
        return LUIE.GetStatsActiveEffectTooltipText(row.abilityId, row.buffSlot, row.startTime, row.endTime)
    end
    if row.isSyntheticFromScb then
        return row.tooltipText or ""
    end
    return ""
end
