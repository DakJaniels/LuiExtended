-- -----------------------------------------------------------------------------
--  LuiExtended — Quest condition counter CSA filters (user saved vars)
--  Distributed under The MIT License (MIT) (see LICENSE file)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local ChatOutput = LUIE.ChatOutput

local table_insert = table.insert
local table_sort = table.sort
local tonumber = tonumber
local tostring = tostring
local pairs = pairs
local zo_strformat = zo_strformat
local GetString = GetString

-- Rule keys are stored in ChatAnnouncements.SV.Quests.QuestCounterFilterKeys
local RULE_KEY_FIELD_SEP = "\31"

ChatAnnouncements.QUEST_COUNTER_FILTER_MODE_MILESTONES = "milestones"
ChatAnnouncements.QUEST_COUNTER_FILTER_MODE_SUPPRESS_ALL = "suppress_all"
ChatAnnouncements.QUEST_COUNTER_FILTER_MODE_COMPLETE_ONLY = "complete_only"

ChatAnnouncements.QuestCounterFilterStaging =
{
    questIdentifier = "",
    conditionText = "",
    mode = ChatAnnouncements.QUEST_COUNTER_FILTER_MODE_MILESTONES,
    milestonesText = "",
}

local g_questCounterFilterCacheBuilt = false
local g_questCounterFilterByQuestId = {}
local g_questCounterFilterByQuestName = {}

--- LibAddonMenu `reference = "LUIE_QuestCounterFilter_List"` (PC settings).
--- @return { UpdateChoices: fun(self, choices: string[], choicesValues: string[]?) }|nil
local function GetQuestCounterFilterListControl()
    return rawget(_G, "LUIE_QuestCounterFilter_List")
end

local function RefreshQuestCounterFilterListControl()
    local listControl = GetQuestCounterFilterListControl()
    if listControl then
        listControl:UpdateChoices(ChatAnnouncements.GenerateQuestCounterFilterLAMList())
    end
end

--- @param milestonesText string
--- @return integer[]
function ChatAnnouncements.ParseQuestCounterFilterMilestones(milestonesText)
    local milestones = {}
    if milestonesText == nil or milestonesText == "" then
        return milestones
    end
    for part in milestonesText:gmatch("[^,]+") do
        local value = tonumber(part:match("^%s*(.-)%s*$"))
        if value then
            table_insert(milestones, value)
        end
    end
    return milestones
end

--- @param identifier string
--- @return integer|nil
--- @return string|nil
function ChatAnnouncements.ParseQuestCounterFilterIdentifier(identifier)
    if identifier == nil then
        return nil, nil
    end
    identifier = identifier:match("^%s*(.-)%s*$")
    if identifier == "" then
        return nil, nil
    end
    local questId = tonumber(identifier)
    if questId and questId > 0 then
        return questId, nil
    end
    return nil, identifier
end

--- @param rule table
--- @return string
function ChatAnnouncements.FormatQuestCounterFilterRuleLabel(rule)
    if not rule then
        return ""
    end
    local questPart
    if rule.questId then
        questPart = zo_strformat("[<<1>>]", rule.questId)
        if rule.questName and rule.questName ~= "" then
            questPart = zo_strformat("<<1>> <<2>>", questPart, rule.questName)
        end
    else
        questPart = rule.questName or "?"
    end
    local conditionPart = rule.conditionText
    if conditionPart == nil or conditionPart == "" or conditionPart == "*" then
        conditionPart = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_CONDITION_ALL)
    end
    local modeLabel = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_MODE_MILESTONES)
    if rule.mode == ChatAnnouncements.QUEST_COUNTER_FILTER_MODE_SUPPRESS_ALL then
        modeLabel = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_MODE_SUPPRESS)
    elseif rule.mode == ChatAnnouncements.QUEST_COUNTER_FILTER_MODE_COMPLETE_ONLY then
        modeLabel = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_MODE_COMPLETE)
    end
    return zo_strformat("<<1>> — <<2>> — <<3>>", questPart, conditionPart, modeLabel)
end

function ChatAnnouncements.InvalidateQuestCounterFilterCache()
    g_questCounterFilterCacheBuilt = false
    g_questCounterFilterByQuestId = {}
    g_questCounterFilterByQuestName = {}
end

--- @return table|nil
local function GetQuestCounterFilterKeysTable()
    local questsSv = ChatAnnouncements.SV and ChatAnnouncements.SV.Quests
    if not questsSv then
        return nil
    end
    if questsSv.QuestCounterFilterKeys == nil then
        questsSv.QuestCounterFilterKeys = {}
    end
    return questsSv.QuestCounterFilterKeys
end

--- Rule payload is encoded in each storage string key.
--- @param rule table
--- @return string
function ChatAnnouncements.EncodeQuestCounterFilterRuleKey(rule)
    local questIdPart = rule.questId and tostring(rule.questId) or ""
    local questNamePart = rule.questName or ""
    local conditionPart = rule.conditionText or "*"
    local modePart = rule.mode or ChatAnnouncements.QUEST_COUNTER_FILTER_MODE_MILESTONES
    local milestoneParts = {}
    if rule.milestones then
        for i = 1, #rule.milestones do
            milestoneParts[i] = tostring(rule.milestones[i])
        end
    end
    local milestonesPart = table.concat(milestoneParts, ",")
    return table.concat({ questIdPart, questNamePart, conditionPart, modePart, milestonesPart }, RULE_KEY_FIELD_SEP)
end

--- @param ruleKey string
--- @return string[]
local function SplitQuestCounterFilterRuleKey(ruleKey)
    local parts = {}
    local sep = RULE_KEY_FIELD_SEP
    local startIndex = 1
    while true do
        local sepStart, sepEnd = string.find(ruleKey, sep, startIndex, true)
        if not sepStart then
            table_insert(parts, string.sub(ruleKey, startIndex))
            break
        end
        table_insert(parts, string.sub(ruleKey, startIndex, sepStart - 1))
        startIndex = sepEnd + 1
    end
    return parts
end

--- @param ruleKey string
--- @return table|nil rule
function ChatAnnouncements.DecodeQuestCounterFilterRuleKey(ruleKey)
    if ruleKey == nil or ruleKey == "" then
        return nil
    end
    local parts = SplitQuestCounterFilterRuleKey(ruleKey)
    if #parts < 4 then
        return nil
    end
    local questIdPart = parts[1]
    local questNamePart = parts[2]
    local conditionPart = parts[3]
    local modePart = parts[4]
    local milestonesPart = parts[5]
    local questId = tonumber(questIdPart)
    if questIdPart == "" then
        questId = nil
    end
    local questName = questNamePart
    if questName == "" then
        questName = nil
    end
    if conditionPart == nil or conditionPart == "" then
        conditionPart = "*"
    end
    local milestones = ChatAnnouncements.ParseQuestCounterFilterMilestones(milestonesPart or "")
    return
    {
        questId = questId,
        questName = questName,
        conditionText = conditionPart,
        mode = modePart or ChatAnnouncements.QUEST_COUNTER_FILTER_MODE_MILESTONES,
        milestones = milestones,
        enabled = true,
    }
end

--- @return table[]
function ChatAnnouncements.GetQuestCounterFilterRules()
    local keysTable = GetQuestCounterFilterKeysTable()
    if not keysTable then
        return {}
    end

    local rules = {}
    for ruleKey in pairs(keysTable) do
        local rule = ChatAnnouncements.DecodeQuestCounterFilterRuleKey(ruleKey)
        if rule then
            rule.storageKey = ruleKey
            table_insert(rules, rule)
        end
    end
    return rules
end

local function BuildMilestoneSet(rule)
    local set = {}
    if rule.milestones then
        for i = 1, #rule.milestones do
            set[rule.milestones[i]] = true
        end
    end
    return set
end

local function ConditionMatches(rule, conditionText)
    local filterCondition = rule.conditionText
    if filterCondition == nil or filterCondition == "" or filterCondition == "*" then
        return true
    end
    return filterCondition == conditionText
end

local function RebuildQuestCounterFilterCache()
    g_questCounterFilterByQuestId = {}
    g_questCounterFilterByQuestName = {}
    local filters = ChatAnnouncements.GetQuestCounterFilterRules()
    for index = 1, #filters do
        local rule = filters[index]
        if rule and rule.enabled ~= false then
            rule._milestoneSet = BuildMilestoneSet(rule)
            if rule.questId then
                g_questCounterFilterByQuestId[rule.questId] = g_questCounterFilterByQuestId[rule.questId] or {}
                table_insert(g_questCounterFilterByQuestId[rule.questId], rule)
            end
            if rule.questName and rule.questName ~= "" then
                g_questCounterFilterByQuestName[rule.questName] = g_questCounterFilterByQuestName[rule.questName] or {}
                table_insert(g_questCounterFilterByQuestName[rule.questName], rule)
            end
        end
    end
    g_questCounterFilterCacheBuilt = true
end

--- @param journalIndex integer
--- @param questName string
--- @param conditionText string
--- @return table|nil rule
local function FindMatchingQuestCounterFilterRule(journalIndex, questName, conditionText)
    if not g_questCounterFilterCacheBuilt then
        RebuildQuestCounterFilterCache()
    end
    local questId = GetJournalQuestId(journalIndex)
    local candidateRules = {}
    local seen = {}

    local function AddCandidates(list)
        if not list then
            return
        end
        for i = 1, #list do
            local rule = list[i]
            if not seen[rule] then
                seen[rule] = true
                table_insert(candidateRules, rule)
            end
        end
    end

    AddCandidates(g_questCounterFilterByQuestId[questId])
    AddCandidates(g_questCounterFilterByQuestName[questName])

    for i = 1, #candidateRules do
        local rule = candidateRules[i]
        if ConditionMatches(rule, conditionText) then
            return rule
        end
    end
    return nil
end

--- @param rule table
--- @param newConditionVal integer
--- @param isConditionComplete boolean
--- @return boolean
local function RuleAllowsCounterAnnouncement(rule, newConditionVal, isConditionComplete)
    if rule.mode == ChatAnnouncements.QUEST_COUNTER_FILTER_MODE_SUPPRESS_ALL then
        return false
    end
    if rule.mode == ChatAnnouncements.QUEST_COUNTER_FILTER_MODE_COMPLETE_ONLY then
        return isConditionComplete
    end
    if isConditionComplete then
        return true
    end
    if rule._milestoneSet and rule._milestoneSet[newConditionVal] then
        return true
    end
    return false
end

--- @param journalIndex integer
--- @param questName string
--- @param conditionText string
--- @param newConditionVal integer
--- @param isConditionComplete boolean
--- @param conditionMax integer
--- @return boolean true = allow CSA/alerts; false = suppress
function ChatAnnouncements.ShouldAllowQuestConditionCounter(journalIndex, questName, conditionText, newConditionVal, isConditionComplete, conditionMax)
    local questsSv = ChatAnnouncements.SV and ChatAnnouncements.SV.Quests
    if not questsSv or not questsSv.QuestCounterFilterEnable then
        return true
    end
    local rule = FindMatchingQuestCounterFilterRule(journalIndex, questName, conditionText)
    if not rule then
        return true
    end
    return RuleAllowsCounterAnnouncement(rule, newConditionVal, isConditionComplete)
end

--- @param rule table
--- @return boolean success
function ChatAnnouncements.AddQuestCounterFilter(rule)
    local keysTable = GetQuestCounterFilterKeysTable()
    if not keysTable then
        return false
    end
    if not rule.questId and (not rule.questName or rule.questName == "") then
        return false
    end
    rule.enabled = rule.enabled ~= false
    local ruleKey = ChatAnnouncements.EncodeQuestCounterFilterRuleKey(rule)
    keysTable[ruleKey] = true
    ChatAnnouncements.InvalidateQuestCounterFilterCache()
    return true
end

--- @param ruleKey string
function ChatAnnouncements.RemoveQuestCounterFilter(ruleKey)
    local keysTable = GetQuestCounterFilterKeysTable()
    if keysTable and ruleKey and ruleKey ~= "" then
        keysTable[ruleKey] = nil
        ChatAnnouncements.InvalidateQuestCounterFilterCache()
    end
end

function ChatAnnouncements.ClearQuestCounterFilters()
    local keysTable = GetQuestCounterFilterKeysTable()
    if keysTable then
        for ruleKey in pairs(keysTable) do
            keysTable[ruleKey] = nil
        end
        ChatAnnouncements.InvalidateQuestCounterFilterCache()
    end
end

--- LAM dropdown choices (PC settings).
--- @return string[]
--- @return string[]
function ChatAnnouncements.GenerateQuestCounterFilterLAMList()
    local options, values = {}, {}
    local rules = ChatAnnouncements.GetQuestCounterFilterRules()
    table_sort(rules, function (a, b)
        return ChatAnnouncements.FormatQuestCounterFilterRuleLabel(a) < ChatAnnouncements.FormatQuestCounterFilterRuleLabel(b)
    end)
    for index = 1, #rules do
        local rule = rules[index]
        options[index] = ChatAnnouncements.FormatQuestCounterFilterRuleLabel(rule)
        values[index] = rule.storageKey
    end
    return options, values
end

--- @return table { name: string, data: string }[]
function ChatAnnouncements.GenerateQuestCounterFilterListItems()
    local items = {}
    local rules = ChatAnnouncements.GetQuestCounterFilterRules()
    for index = 1, #rules do
        local rule = rules[index]
        items[index] =
        {
            name = ChatAnnouncements.FormatQuestCounterFilterRuleLabel(rule),
            data = rule.storageKey,
        }
    end
    table_sort(items, function (a, b)
        return a.name < b.name
    end)
    return items
end

--- @return boolean
function ChatAnnouncements.TryAddQuestCounterFilterFromStaging()
    local staging = ChatAnnouncements.QuestCounterFilterStaging
    local questId, questName = ChatAnnouncements.ParseQuestCounterFilterIdentifier(staging.questIdentifier)
    if not questId and not questName then
        return false
    end
    local conditionText = staging.conditionText or ""
    conditionText = conditionText:match("^%s*(.-)%s*$")
    if conditionText == "" then
        conditionText = "*"
    end
    local mode = staging.mode or ChatAnnouncements.QUEST_COUNTER_FILTER_MODE_MILESTONES
    local milestones = {}
    if mode == ChatAnnouncements.QUEST_COUNTER_FILTER_MODE_MILESTONES then
        milestones = ChatAnnouncements.ParseQuestCounterFilterMilestones(staging.milestonesText or "")
    end
    local rule =
    {
        questId = questId,
        questName = questName,
        conditionText = conditionText,
        mode = mode,
        milestones = milestones,
        enabled = true,
    }
    if not ChatAnnouncements.AddQuestCounterFilter(rule) then
        return false
    end
    local label = ChatAnnouncements.FormatQuestCounterFilterRuleLabel(rule)
    ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_ADDED), label), true)
    staging.questIdentifier = ""
    staging.conditionText = ""
    staging.milestonesText = ""
    staging.mode = ChatAnnouncements.QUEST_COUNTER_FILTER_MODE_MILESTONES
    return true
end

local QUEST_COUNTER_FILTER_DIALOG = "LUIE_MANAGE_CA_QUEST_COUNTER_FILTERS"
local QUEST_COUNTER_FILTER_CLEAR_DIALOG = "LUIE_CLEAR_CA_QUEST_COUNTER_FILTERS"

function ChatAnnouncements.RegisterQuestCounterFilterDialogs()
    LUIE.RegisterBlacklistDialog(
        QUEST_COUNTER_FILTER_DIALOG,
        GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_MANAGE),
        function ()
            return ChatAnnouncements.GenerateQuestCounterFilterListItems()
        end,
        function (itemData)
            ChatAnnouncements.RemoveQuestCounterFilter(itemData)
            ChatOutput:Print(GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_REMOVED), true)
            LUIE.RefreshBlacklistDialog(QUEST_COUNTER_FILTER_DIALOG)
        end,
        nil,
        function ()
            ChatAnnouncements.ClearQuestCounterFilters()
            LUIE.RefreshBlacklistDialog(QUEST_COUNTER_FILTER_DIALOG)
        end,
        GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_REMLIST_HEADER),
        GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_LIST_EMPTY)
    )
end

function ChatAnnouncements.ShowQuestCounterFilterManageDialog()
    LUIE.ShowBlacklistDialog(QUEST_COUNTER_FILTER_DIALOG)
end

function ChatAnnouncements.RegisterQuestCounterFilterClearDialog()
    LUIE.RegisterDialogueButton(
        QUEST_COUNTER_FILTER_CLEAR_DIALOG,
        GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_CLEAR),
        GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_CLEAR_DIALOG),
        function ()
            ChatAnnouncements.ClearQuestCounterFilters()
            ChatOutput:Print(GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_CLEARED), true)
        end
    )
end

function ChatAnnouncements.ShowQuestCounterFilterClearDialog()
    if ZO_Dialogs_ShowDialog then
        ZO_Dialogs_ShowDialog(QUEST_COUNTER_FILTER_CLEAR_DIALOG)
    else
        ZO_Dialogs_ShowGamepadDialog(QUEST_COUNTER_FILTER_CLEAR_DIALOG)
    end
end

--- @param settings table
--- @param Settings table
--- @param Defaults table
--- @param panel table|nil
--- @param settingsApi table|nil LUIE.ConsoleSettingsAPI for panel refresh
function ChatAnnouncements.AppendQuestCounterFilterSettings(settings, Settings, Defaults, panel, settingsApi)
    local LHAS = LibHarvensAddonSettings
    local filterMasterDisabled = function ()
        return not LUIE.SV.ChatAnnouncements_Enable
    end
    local filterDisabled = function ()
        return filterMasterDisabled() or not Settings.Quests.QuestCounterFilterEnable
    end
    local modeItems =
    {
        { name = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_MODE_MILESTONES), data = ChatAnnouncements.QUEST_COUNTER_FILTER_MODE_MILESTONES    },
        { name = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_MODE_SUPPRESS),   data = ChatAnnouncements.QUEST_COUNTER_FILTER_MODE_SUPPRESS_ALL  },
        { name = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_MODE_COMPLETE),   data = ChatAnnouncements.QUEST_COUNTER_FILTER_MODE_COMPLETE_ONLY },
    }
    local staging = ChatAnnouncements.QuestCounterFilterStaging

    local function milestonesDisabled()
        return filterDisabled() or staging.mode ~= ChatAnnouncements.QUEST_COUNTER_FILTER_MODE_MILESTONES
    end

    do
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_DESCRIPTION),
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_ENABLE),
            tooltip = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_ENABLE_TP),
            getFunction = function ()
                return Settings.Quests.QuestCounterFilterEnable
            end,
            setFunction = function (value)
                Settings.Quests.QuestCounterFilterEnable = value
            end,
            default = Defaults.Quests.QuestCounterFilterEnable,
            disable = filterMasterDisabled,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_QUEST_ID),
            tooltip = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_QUEST_ID_TP),
            getFunction = function ()
                return staging.questIdentifier or ""
            end,
            setFunction = function (value)
                staging.questIdentifier = value
            end,
            disable = filterDisabled,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_CONDITION),
            tooltip = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_CONDITION_TP),
            getFunction = function ()
                return staging.conditionText or ""
            end,
            setFunction = function (value)
                staging.conditionText = value
            end,
            disable = filterDisabled,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_MODE),
            tooltip = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_MODE_TP),
            items = modeItems,
            getFunction = function ()
                return staging.mode
            end,
            setFunction = function (value)
                staging.mode = value
            end,
            default = ChatAnnouncements.QUEST_COUNTER_FILTER_MODE_MILESTONES,
            disable = filterDisabled,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_MILESTONES),
            tooltip = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_MILESTONES_TP),
            getFunction = function ()
                return staging.milestonesText or ""
            end,
            setFunction = function (value)
                staging.milestonesText = value
            end,
            disable = milestonesDisabled,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_ADD),
            tooltip = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_ADD_TP),
            buttonText = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_ADD),
            clickHandler = function ()
                if ChatAnnouncements.TryAddQuestCounterFilterFromStaging() then
                    if panel and settingsApi then
                        settingsApi:RefreshPanel(panel)
                    end
                else
                    ChatOutput:Print(GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_ADD_FAILED), true)
                end
            end,
            disable = filterDisabled,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_CLEAR),
            tooltip = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_CLEAR_DIALOG),
            buttonText = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_CLEAR),
            clickHandler = function ()
                ChatAnnouncements.ShowQuestCounterFilterClearDialog()
            end,
            disable = filterDisabled,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_MANAGE),
            tooltip = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_MANAGE_TP),
            buttonText = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_MANAGE),
            clickHandler = function ()
                ChatAnnouncements.ShowQuestCounterFilterManageDialog()
            end,
            disable = filterDisabled,
        }
    end
end

--- @param Settings CADefaults
--- @param Defaults CADefaults
--- @param listChoices string[]
--- @param listValues string[]
--- @return table[]
function ChatAnnouncements.BuildQuestCounterFilterPCControls(Settings, Defaults, listChoices, listValues)
    local staging = ChatAnnouncements.QuestCounterFilterStaging
    local modeChoices =
    {
        GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_MODE_MILESTONES),
        GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_MODE_SUPPRESS),
        GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_MODE_COMPLETE),
    }
    local modeValues =
    {
        ChatAnnouncements.QUEST_COUNTER_FILTER_MODE_MILESTONES,
        ChatAnnouncements.QUEST_COUNTER_FILTER_MODE_SUPPRESS_ALL,
        ChatAnnouncements.QUEST_COUNTER_FILTER_MODE_COMPLETE_ONLY,
    }
    local function filterMasterDisabled()
        return not LUIE.SV.ChatAnnouncements_Enable
    end
    local function filterDisabled()
        return filterMasterDisabled() or not Settings.Quests.QuestCounterFilterEnable
    end
    local function milestonesDisabled()
        return filterDisabled() or staging.mode ~= ChatAnnouncements.QUEST_COUNTER_FILTER_MODE_MILESTONES
    end

    return
    {
        {
            type = "description",
            text = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_DESCRIPTION),
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_ENABLE),
            tooltip = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_ENABLE_TP),
            getFunc = function ()
                return Settings.Quests.QuestCounterFilterEnable
            end,
            setFunc = function (value)
                Settings.Quests.QuestCounterFilterEnable = value
            end,
            width = "full",
            disabled = filterMasterDisabled,
            default = Defaults.Quests.QuestCounterFilterEnable,
        },
        {
            type = "editbox",
            name = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_QUEST_ID),
            tooltip = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_QUEST_ID_TP),
            getFunc = function ()
                return staging.questIdentifier or ""
            end,
            setFunc = function (value)
                staging.questIdentifier = value
            end,
            width = "half",
            disabled = filterDisabled,
            default = "",
        },
        {
            type = "editbox",
            name = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_CONDITION),
            tooltip = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_CONDITION_TP),
            getFunc = function ()
                return staging.conditionText or ""
            end,
            setFunc = function (value)
                staging.conditionText = value
            end,
            width = "half",
            disabled = filterDisabled,
            default = "",
        },
        {
            type = "dropdown",
            name = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_MODE),
            tooltip = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_MODE_TP),
            choices = modeChoices,
            choicesValues = modeValues,
            getFunc = function ()
                return staging.mode
            end,
            setFunc = function (value)
                staging.mode = value
            end,
            width = "full",
            disabled = filterDisabled,
            default = ChatAnnouncements.QUEST_COUNTER_FILTER_MODE_MILESTONES,
        },
        {
            type = "editbox",
            name = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_MILESTONES),
            tooltip = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_MILESTONES_TP),
            getFunc = function ()
                return staging.milestonesText or ""
            end,
            setFunc = function (value)
                staging.milestonesText = value
            end,
            width = "full",
            disabled = milestonesDisabled,
            default = "",
        },
        {
            type = "button",
            name = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_ADD),
            tooltip = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_ADD_TP),
            func = function ()
                if ChatAnnouncements.TryAddQuestCounterFilterFromStaging() then
                    RefreshQuestCounterFilterListControl()
                else
                    ChatOutput:Print(GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_ADD_FAILED), true)
                end
            end,
            width = "half",
            disabled = filterDisabled,
        },
        {
            type = "button",
            name = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_CLEAR),
            tooltip = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_CLEAR_TP),
            func = function ()
                ZO_Dialogs_ShowDialog("LUIE_CLEAR_CA_QUEST_COUNTER_FILTERS")
            end,
            width = "half",
            disabled = filterDisabled,
        },
        {
            type = "dropdown",
            name = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_REMLIST),
            tooltip = GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_REMLIST_TP),
            choices = listChoices,
            choicesValues = listValues,
            scrollable = 7,
            sort = "name-up",
            getFunc = function ()
                RefreshQuestCounterFilterListControl()
            end,
            setFunc = function (value)
                ChatAnnouncements.RemoveQuestCounterFilter(value)
                ChatOutput:Print(GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_REMOVED), true)
                RefreshQuestCounterFilterListControl()
            end,
            width = "full",
            disabled = filterDisabled,
            reference = "LUIE_QuestCounterFilter_List",
        },
    }
end
