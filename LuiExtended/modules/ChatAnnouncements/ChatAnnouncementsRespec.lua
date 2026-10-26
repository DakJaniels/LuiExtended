-- -----------------------------------------------------------------------------
--  LuiExtended - Chat Announcements skill and attribute respec
--  Distributed under The MIT License (MIT) (see LICENSE file)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

--- @type EventManager
local eventManager = GetEventManager()
--- @type string
local moduleName = LUIE.name .. "ChatAnnouncements"

--- @type string
local currencyNotifyChampionText = GetString(LUIE_STRING_CA_CURRENCY_NOTIFY_CHAMPION)
--- @type string
local currencyNotifyAttributesText = GetString(LUIE_STRING_CA_CURRENCY_NOTIFY_ATTRIBUTES)
--- @type string
local currencyNotifySkillsText = GetString(LUIE_STRING_CA_CURRENCY_NOTIFY_SKILLS)
--- @type string
local currencyNotifySkillsRedistributedText = GetString(LUIE_STRING_CA_CURRENCY_NOTIFY_SKILLS_REDISTRIBUTED)
--- @type string
local currencyNotifyMorphsText = GetString(LUIE_STRING_CA_CURRENCY_NOTIFY_MORPHS)
--- @type string
local currencyNotifyMorphsRedistributedText = GetString(LUIE_STRING_CA_CURRENCY_NOTIFY_MORPHS_REDISTRIBUTED)
--- @type string
local currencyNotifySkillLineText = GetString(LUIE_STRING_CA_CURRENCY_NOTIFY_SKILL_LINE)
--- @type string
local vengeancePerksModifiedText = GetString("SI_RESPECTYPE_POINTSRESETTITLE", RESPEC_TYPE_VENGEANCE_PERKS)
--- @type string
local vengeanceLoadoutModifiedText = GetString("SI_RESPECTYPE_POINTSRESETTITLE", RESPEC_TYPE_VENGEANCE_ROLE)

-- Morphs and redistributed commits are not RespecType values. Keep them past RESPEC_TYPE_MAX_VALUE.
--- @type integer
local RESPEC_DISPLAY_MORPHS = RESPEC_TYPE_MAX_VALUE + 1
--- @type integer
local RESPEC_DISPLAY_SKILLS_REDISTRIBUTED = RESPEC_TYPE_MAX_VALUE + 2
--- @type integer
local RESPEC_DISPLAY_MORPHS_REDISTRIBUTED = RESPEC_TYPE_MAX_VALUE + 3

--- Ids passed to PointRespecDisplay. Skills, attributes, champion, subclass, and vengeance use RespecType.
--- Morph and redistributed ids are LuiExtended-only.
--- @class CARespecDisplay
--- @field Skills RespecType
--- @field Attributes RespecType
--- @field Champion RespecType
--- @field SkillLine RespecType
--- @field VengeancePerks RespecType
--- @field VengeanceRole RespecType
--- @field Morphs integer
--- @field SkillsRedistributed integer
--- @field MorphsRedistributed integer

--- @type CARespecDisplay
ChatAnnouncements.RespecDisplay =
{
    Skills = RESPEC_TYPE_SKILLS,
    Attributes = RESPEC_TYPE_ATTRIBUTES,
    Champion = RESPEC_TYPE_CHAMPION,
    SkillLine = RESPEC_TYPE_SUBCLASS,
    VengeancePerks = RESPEC_TYPE_VENGEANCE_PERKS,
    VengeanceRole = RESPEC_TYPE_VENGEANCE_ROLE,
    Morphs = RESPEC_DISPLAY_MORPHS,
    SkillsRedistributed = RESPEC_DISPLAY_SKILLS_REDISTRIBUTED,
    MorphsRedistributed = RESPEC_DISPLAY_MORPHS_REDISTRIBUTED,
}

--- @type table<integer, string>
local RESPEC_DISPLAY_TEXT =
{
    [ChatAnnouncements.RespecDisplay.Champion] = currencyNotifyChampionText,
    [ChatAnnouncements.RespecDisplay.Attributes] = currencyNotifyAttributesText,
    [ChatAnnouncements.RespecDisplay.Skills] = currencyNotifySkillsText,
    [ChatAnnouncements.RespecDisplay.Morphs] = currencyNotifyMorphsText,
    [ChatAnnouncements.RespecDisplay.SkillLine] = currencyNotifySkillLineText,
    [ChatAnnouncements.RespecDisplay.VengeancePerks] = vengeancePerksModifiedText,
    [ChatAnnouncements.RespecDisplay.VengeanceRole] = vengeanceLoadoutModifiedText,
    [ChatAnnouncements.RespecDisplay.SkillsRedistributed] = currencyNotifySkillsRedistributedText,
    [ChatAnnouncements.RespecDisplay.MorphsRedistributed] = currencyNotifyMorphsRedistributedText,
}

--- @type table<SkillPointAllocationMode, integer>
local SKILL_ALLOCATION_MODE_TO_RESET_TYPE =
{
    [SKILL_POINT_ALLOCATION_MODE_FULL] = ChatAnnouncements.RespecDisplay.Skills,
    [SKILL_POINT_ALLOCATION_MODE_MORPHS_ONLY] = ChatAnnouncements.RespecDisplay.Morphs,
    [SKILL_POINT_ALLOCATION_MODE_SUBCLASS_ONLY] = ChatAnnouncements.RespecDisplay.SkillLine,
}

--- @type table<SkillPointAllocationMode, integer>
local SKILL_ALLOCATION_MODE_TO_REDISTRIBUTED_TYPE =
{
    [SKILL_POINT_ALLOCATION_MODE_FULL] = ChatAnnouncements.RespecDisplay.SkillsRedistributed,
    [SKILL_POINT_ALLOCATION_MODE_MORPHS_ONLY] = ChatAnnouncements.RespecDisplay.MorphsRedistributed,
    [SKILL_POINT_ALLOCATION_MODE_SUBCLASS_ONLY] = ChatAnnouncements.RespecDisplay.SkillLine,
}

--- @type integer
local RESPEC_DISPLAY_REPEAT_WINDOW_MS = 1000

--- @param message string
--- @return nil
local function LogRespecDevDebug(message)
    if LUIE.IsDevDebugEnabled() then
        LUIE:Log("Debug", message)
    end
end

--- @class CARespecPendingState
--- @field respecType integer|nil
--- @field clearGeneration integer

--- @type table<integer, integer>
local lastRespecDisplayMillisecondsByType = {}

--- @type CARespecPendingState
local skillRespecPendingState =
{
    respecType = nil,
    clearGeneration = 0,
}

--- @type integer|nil
local skillRespecCommitType = nil

--- @type CARespecPendingState
local attributeRespecPendingState =
{
    respecType = nil,
    clearGeneration = 0,
}

--- @param pendingState CARespecPendingState
--- @param respecType integer
--- @return nil
local function RememberRespecTypeUntilNextFrame(pendingState, respecType)
    pendingState.respecType = respecType
    pendingState.clearGeneration = pendingState.clearGeneration + 1
    local scheduledClearGeneration = pendingState.clearGeneration
    zo_callLater(function ()
        if pendingState.clearGeneration == scheduledClearGeneration then
            pendingState.respecType = nil
        end
    end, 0)
end

--- @param pendingState CARespecPendingState
--- @return nil
local function ClearPendingRespecType(pendingState)
    pendingState.respecType = nil
    pendingState.clearGeneration = pendingState.clearGeneration + 1
end

-- ZO_SkillPointAllocator:GetPendingPointAllocationDelta is positive when more points will be spent and negative when points come back.
-- ZO_SkillLineAssignmentManager:GetPendingPointAllocationDelta is the same for a skill line swap.
--- @return integer
local function GetNetPendingSkillPointDelta()
    --- @type integer
    local pendingSkillPointDelta = 0
    --- @param skillPointAllocator ZO_SkillPointAllocator
    for _, skillPointAllocator in SKILL_POINT_ALLOCATION_MANAGER:AllocatorIterator() do
        --- @type ZO_SkillLineData
        local skillLineData = skillPointAllocator:GetSkillLineData()
        if skillLineData:IsActive() and not skillLineData:IsClassMastery() then
            pendingSkillPointDelta = pendingSkillPointDelta + skillPointAllocator:GetPendingPointAllocationDelta()
        end
    end
    if SKILL_LINE_ASSIGNMENT_MANAGER then
        pendingSkillPointDelta = pendingSkillPointDelta + SKILL_LINE_ASSIGNMENT_MANAGER:GetPendingPointAllocationDelta()
    end
    return pendingSkillPointDelta
end

--- PurchasedChanged, SkillProgressionKeyChanged, OnSkillsCleared, and SkillLineRespecUpdate.
--- @return nil
local function RefreshSkillRespecCommitType()
    --- @type boolean
    local batchSave = SKILLS_AND_ACTION_BAR_MANAGER:DoesSkillPointAllocationModeBatchSave()
    --- @type boolean
    local changesIncurCost = SKILLS_AND_ACTION_BAR_MANAGER:DoPendingChangesIncurCost()
    --- @type SkillPointAllocationMode
    local skillPointAllocationMode = SKILLS_AND_ACTION_BAR_MANAGER:GetSkillPointAllocationMode()
    local pendingSkillPointDelta = GetNetPendingSkillPointDelta()
    LogRespecDevDebug(string.format("pending-change batchSave=%s incurCost=%s mode=%s pendingDelta=%s", tostring(batchSave), tostring(changesIncurCost), tostring(skillPointAllocationMode), tostring(pendingSkillPointDelta)))
    if not batchSave then
        return
    end
    if pendingSkillPointDelta < 0 then
        skillRespecCommitType = SKILL_ALLOCATION_MODE_TO_RESET_TYPE[skillPointAllocationMode]
    elseif changesIncurCost then
        skillRespecCommitType = SKILL_ALLOCATION_MODE_TO_REDISTRIBUTED_TYPE[skillPointAllocationMode]
    else
        skillRespecCommitType = nil
    end
    LogRespecDevDebug("pending-change commitType=" .. tostring(skillRespecCommitType))
end

--- Fired by ZO_SkillsAndActionBarManager:SetSkillPointAllocationMode.
--- @param skillPointAllocationMode SkillPointAllocationMode
--- @param oldSkillPointAllocationMode SkillPointAllocationMode
--- @return nil
local function OnSkillPointAllocationModeChanged(skillPointAllocationMode, oldSkillPointAllocationMode)
    LogRespecDevDebug(string.format("SkillPointAllocationModeChanged new=%s old=%s commitType=%s", tostring(skillPointAllocationMode), tostring(oldSkillPointAllocationMode), tostring(skillRespecCommitType)))
    if skillPointAllocationMode ~= SKILL_POINT_ALLOCATION_MODE_PURCHASE_ONLY then
        skillRespecCommitType = nil
        return
    end
    local respecType = skillRespecCommitType
    skillRespecCommitType = nil
    if not respecType then
        LogRespecDevDebug("mode left batch with no completed skill change; not arming skill announcement")
        return
    end
    LogRespecDevDebug("arming skill announcement type=" .. tostring(respecType))
    RememberRespecTypeUntilNextFrame(skillRespecPendingState, respecType)
end

--- EVENT_SKILL_RESPEC_RESULT (eventId, result)
--- @param eventId integer
--- @param result RespecResult
--- @return nil
local function OnSkillRespecResult(eventId, result)
    local respecType = skillRespecPendingState.respecType
    LogRespecDevDebug(string.format("EVENT_SKILL_RESPEC_RESULT result=%s armedType=%s", tostring(result), tostring(respecType)))
    ClearPendingRespecType(skillRespecPendingState)
    if result == RESPEC_RESULT_SUCCESS and respecType then
        LogRespecDevDebug("skill result success, displaying type=" .. tostring(respecType))
        ChatAnnouncements.PointRespecDisplay(respecType)
    end
end

--- Fired by ZO_Stats_Common:SetAttributePointAllocationMode.
--- @param attributePointAllocationMode AttributePointAllocationMode
--- @param oldAttributePointAllocationMode AttributePointAllocationMode
--- @return nil
local function OnAttributePointAllocationModeChanged(attributePointAllocationMode, oldAttributePointAllocationMode)
    LogRespecDevDebug(string.format("AttributePointAllocationModeChanged new=%s old=%s", tostring(attributePointAllocationMode), tostring(oldAttributePointAllocationMode)))
    if attributePointAllocationMode ~= ATTRIBUTE_POINT_ALLOCATION_MODE_PURCHASE_ONLY then
        return
    end
    if oldAttributePointAllocationMode == ATTRIBUTE_POINT_ALLOCATION_MODE_PURCHASE_ONLY then
        return
    end
    RememberRespecTypeUntilNextFrame(attributeRespecPendingState, ChatAnnouncements.RespecDisplay.Attributes)
end

--- EVENT_ATTRIBUTE_RESPEC_RESULT (eventId, result)
--- @param eventId integer
--- @param result RespecResult
--- @return nil
local function OnAttributeRespecResult(eventId, result)
    local respecType = attributeRespecPendingState.respecType
    LogRespecDevDebug(string.format("EVENT_ATTRIBUTE_RESPEC_RESULT result=%s armedType=%s", tostring(result), tostring(respecType)))
    ClearPendingRespecType(attributeRespecPendingState)
    if result == RESPEC_RESULT_SUCCESS and respecType then
        LogRespecDevDebug("attribute result success, displaying type=" .. tostring(respecType))
        ChatAnnouncements.PointRespecDisplay(respecType)
    end
end

--- EVENT_CURRENCY_UPDATE (eventId, currency, currencyLocation, newValue, oldValue, reason)
--- @param eventId integer
--- @param currency CurrencyType
--- @param currencyLocation CurrencyLocation
--- @param newValue integer
--- @param oldValue integer
--- @param reason CurrencyChangeReason
--- @return nil
local function OnRespecDebugCurrencyUpdate(eventId, currency, currencyLocation, newValue, oldValue, reason)
    if reason ~= CURRENCY_CHANGE_REASON_RESPEC_SKILLS
        and reason ~= CURRENCY_CHANGE_REASON_RESPEC_ATTRIBUTES
        and reason ~= CURRENCY_CHANGE_REASON_RESPEC_MORPHS
        and reason ~= CURRENCY_CHANGE_REASON_RESPEC_SUBCLASS
        and reason ~= CURRENCY_CHANGE_REASON_RESPEC_CHAMPION then
        return
    end
    LogRespecDevDebug(string.format("EVENT_CURRENCY_UPDATE currency=%s loc=%s %s -> %s reason=%s", tostring(currency), tostring(currencyLocation), tostring(oldValue), tostring(newValue), tostring(reason)))
end

--- EVENT_SKILL_POINTS_CHANGED (eventId, oldPoints, newPoints, oldPartialPoints, newPartialPoints, changeReason)
--- @param eventId integer
--- @param oldPoints integer
--- @param newPoints integer
--- @param oldPartialPoints integer
--- @param newPartialPoints integer
--- @param changeReason SkillPointReason
--- @return nil
local function OnRespecDebugSkillPointsChanged(eventId, oldPoints, newPoints, oldPartialPoints, newPartialPoints, changeReason)
    LogRespecDevDebug(string.format("EVENT_SKILL_POINTS_CHANGED %s -> %s partial %s -> %s reason=%s", tostring(oldPoints), tostring(newPoints), tostring(oldPartialPoints), tostring(newPartialPoints), tostring(changeReason)))
end

--- EVENT_START_SKILL_RESPEC (eventId, allocationMode, paymentType)
--- @param eventId integer
--- @param allocationMode SkillPointAllocationMode
--- @param paymentType RespecPaymentType
--- @return nil
local function OnRespecDebugStartSkillRespec(eventId, allocationMode, paymentType)
    LogRespecDevDebug(string.format("EVENT_START_SKILL_RESPEC mode=%s payment=%s", tostring(allocationMode), tostring(paymentType)))
end

--- EVENT_START_SKILL_RESPEC_CAST (eventId)
--- @param eventId integer
--- @return nil
local function OnRespecDebugStartSkillRespecCast(eventId)
    LogRespecDevDebug(string.format("EVENT_START_SKILL_RESPEC_CAST mode=%s incurCost=%s", tostring(SKILLS_AND_ACTION_BAR_MANAGER:GetSkillPointAllocationMode()), tostring(SKILLS_AND_ACTION_BAR_MANAGER:DoPendingChangesIncurCost())))
end

--- @param message string
--- @param centerScreenMessage string|nil
--- @param centerScreenSecondLine string|nil
--- @return nil
local function ShowRespecAnnouncement(message, centerScreenMessage, centerScreenSecondLine)
    if ChatAnnouncements.SV.DisplayAnnouncements.Respec.CA then
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, type = "MESSAGE", isSystem = true }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
    end
    if ChatAnnouncements.SV.DisplayAnnouncements.Respec.CSA then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
        if centerScreenSecondLine then
            messageParams:SetText(centerScreenMessage, centerScreenSecondLine)
        else
            messageParams:SetText(centerScreenMessage or message)
        end
        messageParams:SetSound(SOUNDS.DISPLAY_ANNOUNCEMENT)
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end
    if ChatAnnouncements.SV.DisplayAnnouncements.Respec.Alert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, message)
    end
end

--- @type VengeancePerkSlotFlags[]
local VENGEANCE_PERK_SLOTS =
{
    VENGEANCE_PERK_SLOT_RED,
    VENGEANCE_PERK_SLOT_YELLOW,
    VENGEANCE_PERK_SLOT_BLUE,
}

--- @type table<VengeancePerkSlotFlags, integer>|nil
local previousVengeancePerkIndexBySlot

--- @return table<VengeancePerkSlotFlags, integer>
local function ReadVengeancePerkIndexes()
    --- @type table<VengeancePerkSlotFlags, integer>
    local perkIndexBySlot = {}
    --- @param perkSlot VengeancePerkSlotFlags
    for _, perkSlot in ipairs(VENGEANCE_PERK_SLOTS) do
        perkIndexBySlot[perkSlot] = GetIndexOfPerkInSlotForRole(perkSlot)
    end
    return perkIndexBySlot
end

--- GetVengeancePerkNameAtIndex returns an empty string when the slot has no perk.
--- @param perkIndex integer|nil
--- @param perkSlot VengeancePerkSlotFlags
--- @return string|nil
local function FormatVengeancePerkChatText(perkIndex, perkSlot)
    if not perkIndex or perkIndex == 0 then
        return nil
    end
    local rawPerkName = GetVengeancePerkNameAtIndex(perkIndex)
    if not rawPerkName or rawPerkName == "" then
        return nil
    end
    --- @type string
    local perkName = ZO_CachedStrFormat(SI_CAMPAIGN_VENGEANCE_PERK_FORMATTER, rawPerkName)
    --- @type ZO_ColorDef|nil
    local perkColor = ZO_VENGEANCE_MANAGER:GetPerkColorBySlot(perkSlot)
    if perkColor then
        perkName = perkColor:Colorize(perkName)
    end
    local perkIcon = GetVengeancePerkIconAtIndex(perkIndex)
    if perkIcon and perkIcon ~= "" then
        return zo_strformat("<<1>> <<2>>", zo_iconFormat(perkIcon, 16, 16), perkName)
    end
    return perkName
end

--- EVENT_VENGEANCE_PERKS_UPDATED (eventId). Registered only inside a Vengeance campaign.
--- @param eventId integer
--- @return nil
local function OnVengeancePerksUpdated(eventId)
    local perkIndexBySlot = ReadVengeancePerkIndexes()
    local previousPerkIndexBySlot = previousVengeancePerkIndexBySlot
    previousVengeancePerkIndexBySlot = perkIndexBySlot
    if not previousPerkIndexBySlot then
        return
    end

    local vengeancePerkChangedFormat = GetString(LUIE_STRING_CA_VENGEANCE_PERK_CHANGED)
    local vengeancePerkEquippedFormat = GetString(LUIE_STRING_CA_VENGEANCE_PERK_EQUIPPED)
    local vengeancePerkUnequippedFormat = GetString(LUIE_STRING_CA_VENGEANCE_PERK_UNEQUIPPED)
    local changeMessages = {}
    for _, perkSlot in ipairs(VENGEANCE_PERK_SLOTS) do
        if previousPerkIndexBySlot[perkSlot] ~= perkIndexBySlot[perkSlot] then
            local previousPerkText = FormatVengeancePerkChatText(previousPerkIndexBySlot[perkSlot], perkSlot)
            local perkText = FormatVengeancePerkChatText(perkIndexBySlot[perkSlot], perkSlot)
            local slotName = ZO_VENGEANCE_MANAGER:GetPerkSlotName(perkSlot)
            local perkColor = ZO_VENGEANCE_MANAGER:GetPerkColorBySlot(perkSlot)
            if perkColor then
                slotName = perkColor:Colorize(slotName)
            end
            if previousPerkText and perkText then
                changeMessages[#changeMessages + 1] = zo_strformat(vengeancePerkChangedFormat, slotName, previousPerkText, perkText)
            elseif perkText then
                changeMessages[#changeMessages + 1] = zo_strformat(vengeancePerkEquippedFormat, slotName, perkText)
            elseif previousPerkText then
                changeMessages[#changeMessages + 1] = zo_strformat(vengeancePerkUnequippedFormat, slotName, previousPerkText)
            end
        end
    end
    if #changeMessages == 0 then
        return
    end
    local message = table.concat(changeMessages, "\n")
    LogRespecDevDebug(message)
    ShowRespecAnnouncement(message, vengeancePerksModifiedText, message)
end

local vengeancePerkEventsRegistered = false

--- @return nil
local function RegisterVengeancePerkEvents()
    if vengeancePerkEventsRegistered or not IsCurrentCampaignVengeanceRuleset() then
        return
    end
    previousVengeancePerkIndexBySlot = ReadVengeancePerkIndexes()
    eventManager:RegisterForEvent(moduleName .. "VengeancePerks", EVENT_VENGEANCE_PERKS_UPDATED, OnVengeancePerksUpdated)
    vengeancePerkEventsRegistered = true
end

--- @return nil
local function UnregisterVengeancePerkEvents()
    if not vengeancePerkEventsRegistered then
        return
    end
    eventManager:UnregisterForEvent(moduleName .. "VengeancePerks", EVENT_VENGEANCE_PERKS_UPDATED)
    previousVengeancePerkIndexBySlot = nil
    vengeancePerkEventsRegistered = false
end

--- EVENT_CURRENT_CAMPAIGN_CHANGED and EVENT_PLAYER_ACTIVATED.
--- @return nil
local function OnVengeanceCampaignChanged()
    if IsCurrentCampaignVengeanceRuleset() then
        RegisterVengeancePerkEvents()
    else
        UnregisterVengeancePerkEvents()
    end
end

--- EVENT_FORCE_RESPEC (eventId, respecType)
--- @param eventId integer
--- @param respecType RespecType
--- @return nil
local function OnForceRespec(eventId, respecType)
    LogRespecDevDebug("EVENT_FORCE_RESPEC respecType=" .. tostring(respecType))
    if respecType == RESPEC_TYPE_VENGEANCE_PERKS or respecType == RESPEC_TYPE_VENGEANCE_ROLE then
        ChatAnnouncements.PointRespecDisplay(respecType)
    end
end

--- @type table<string, RespecType>
local RESPEC_ANNOUNCEMENT_PRIMARY_TEXT =
{
    [GetString(SI_RESPECTYPE_POINTSRESETTITLE0)] = RESPEC_TYPE_SKILLS,
    [GetString(SI_RESPECTYPE_POINTSRESETTITLE1)] = RESPEC_TYPE_ATTRIBUTES,
    [GetString(SI_RESPECTYPE_POINTSRESETTITLE2)] = RESPEC_TYPE_CHAMPION,
    [GetString(SI_RESPECTYPE_POINTSRESETTITLE3)] = RESPEC_TYPE_CHAMPION_SLOTS,
    [GetString(SI_RESPECTYPE_POINTSRESETTITLE4)] = RESPEC_TYPE_SUBCLASS,
    [GetString(SI_RESPECTYPE_POINTSRESETTITLE5)] = RESPEC_TYPE_VENGEANCE_PERKS,
    [GetString(SI_RESPECTYPE_POINTSRESETTITLE6)] = RESPEC_TYPE_VENGEANCE_ROLE,
}

--- EVENT_DISPLAY_ANNOUNCEMENT (eventId, primaryText, secondaryText, icon, soundId, lifespanMS, category)
--- @param eventId integer
--- @param primaryText string
--- @param secondaryText string
--- @return nil
local function OnRespecDebugDisplayAnnouncement(eventId, primaryText, secondaryText)
    local respecType = RESPEC_ANNOUNCEMENT_PRIMARY_TEXT[primaryText]
    if respecType == nil then
        return
    end
    LogRespecDevDebug(string.format("EVENT_DISPLAY_ANNOUNCEMENT respecType=%s primary=%q secondary=%q", tostring(respecType), tostring(primaryText), tostring(secondaryText)))
end

--- @return nil
function ChatAnnouncements.RegisterRespecEvents()
    SKILL_POINT_ALLOCATION_MANAGER:RegisterCallback("PurchasedChanged", RefreshSkillRespecCommitType)
    SKILL_POINT_ALLOCATION_MANAGER:RegisterCallback("SkillProgressionKeyChanged", RefreshSkillRespecCommitType)
    SKILL_POINT_ALLOCATION_MANAGER:RegisterCallback("OnSkillsCleared", RefreshSkillRespecCommitType)
    SKILL_LINE_ASSIGNMENT_MANAGER:RegisterCallback("SkillLineRespecUpdate", RefreshSkillRespecCommitType)
    SKILLS_AND_ACTION_BAR_MANAGER:RegisterCallback("SkillPointAllocationModeChanged", OnSkillPointAllocationModeChanged)
    STATS:RegisterCallback("AttributePointAllocationModeChanged", OnAttributePointAllocationModeChanged)
    GAMEPAD_STATS:RegisterCallback("AttributePointAllocationModeChanged", OnAttributePointAllocationModeChanged)
    eventManager:RegisterForEvent(moduleName, EVENT_SKILL_RESPEC_RESULT, OnSkillRespecResult)
    eventManager:RegisterForEvent(moduleName, EVENT_ATTRIBUTE_RESPEC_RESULT, OnAttributeRespecResult)
    eventManager:RegisterForEvent(moduleName .. "VengeanceCampaign", EVENT_CURRENT_CAMPAIGN_CHANGED, OnVengeanceCampaignChanged)
    eventManager:RegisterForEvent(moduleName .. "VengeanceCampaign", EVENT_PLAYER_ACTIVATED, OnVengeanceCampaignChanged)
    OnVengeanceCampaignChanged()
    eventManager:RegisterForEvent(moduleName, EVENT_FORCE_RESPEC, OnForceRespec)
    if LUIE.IsDevDebugEnabled() then
        local respecDebugName = moduleName .. "RespecDebug"
        eventManager:RegisterForEvent(respecDebugName, EVENT_CURRENCY_UPDATE, OnRespecDebugCurrencyUpdate)
        eventManager:RegisterForEvent(respecDebugName, EVENT_SKILL_POINTS_CHANGED, OnRespecDebugSkillPointsChanged)
        eventManager:RegisterForEvent(respecDebugName, EVENT_START_SKILL_RESPEC, OnRespecDebugStartSkillRespec)
        eventManager:RegisterForEvent(respecDebugName, EVENT_START_SKILL_RESPEC_CAST, OnRespecDebugStartSkillRespecCast)
        eventManager:RegisterForEvent(respecDebugName, EVENT_DISPLAY_ANNOUNCEMENT, OnRespecDebugDisplayAnnouncement)
        LogRespecDevDebug("debug listening")
    end
end

--- @param respecType integer
--- @return nil
function ChatAnnouncements.PointRespecDisplay(respecType)
    local nowMilliseconds = GetFrameTimeMilliseconds()
    local previousDisplayMilliseconds = lastRespecDisplayMillisecondsByType[respecType]
    if previousDisplayMilliseconds and (nowMilliseconds - previousDisplayMilliseconds) < RESPEC_DISPLAY_REPEAT_WINDOW_MS then
        LogRespecDevDebug("PointRespecDisplay deduped type=" .. tostring(respecType))
        return
    end
    LogRespecDevDebug("PointRespecDisplay type=" .. tostring(respecType))
    lastRespecDisplayMillisecondsByType[respecType] = nowMilliseconds

    local message = RESPEC_DISPLAY_TEXT[respecType] .. "."
    ShowRespecAnnouncement(message, RESPEC_DISPLAY_TEXT[respecType])
end
