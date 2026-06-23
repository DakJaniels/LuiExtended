--- @diagnostic disable: unused-function, duplicate-set-field
-- -----------------------------------------------------------------------------
--  LuiExtended — Chat Announcements alert / CSA prehooks (orchestrator)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local S = ChatAnnouncements.State
local B = ChatAnnouncements.Brackets

local ChatOutput = LUIE.ChatOutput

local eventManager = GetEventManager()
local moduleName = LUIE.name .. "ChatAnnouncements"

function ChatAnnouncements.HookFunction()
    if ChatAnnouncements._alertHooksInstalled then
        return
    end
    ChatAnnouncements._alertHooksInstalled = true

    local alertHandlers = ZO_AlertText_GetHandlers()
    local csaHandlers = ZO_CenterScreenAnnounce_GetEventHandlers()
    local csaCallbackHandlers = ZO_CenterScreenAnnounce_GetCallbackHandlers()

    local ctx = ChatAnnouncements.Hooks.BuildContext(alertHandlers, csaHandlers, csaCallbackHandlers, eventManager, moduleName)
    ChatAnnouncements.Hooks.RegisterAll(ctx)
end

--- @param eventId integer
function ChatAnnouncements.TradeInviteAccepted(eventId)
    if ChatAnnouncements.SV.Notify.NotificationTradeCA then
        ChatOutput:Print(GetString(LUIE_STRING_CA_TRADE_INVITE_ACCEPTED), true)
    end
    if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(LUIE_STRING_CA_TRADE_INVITE_ACCEPTED))
    end

    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.LootTrade then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
        S.g_inventoryStacks = {}
        ChatAnnouncements.IndexInventory()
    end
    S.g_inTrade = true
end

--- @param eventId integer
--- @param who string
--- @param tradeIndex integer
--- @param itemSoundCategory integer
function ChatAnnouncements.OnTradeAdded(eventId, who, tradeIndex, itemSoundCategory)
    local index = tradeIndex
    local name, icon, stack = GetTradeItemInfo(who, tradeIndex)
    local itemLink = GetTradeItemLink(who, tradeIndex, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
    local itemId = GetItemLinkItemId(itemLink)
    local itemType = GetItemLinkItemType(itemLink)

    if who == 0 then
        S.g_tradeStacksOut[index] = { icon = icon, stack = stack, itemId = itemId, itemLink = itemLink, itemType = itemType }
    else
        S.g_tradeStacksIn[index] = { icon = icon, stack = stack, itemId = itemId, itemLink = itemLink, itemType = itemType }
    end
end

--- @param eventId integer
--- @param who string
--- @param tradeIndex integer
--- @param itemSoundCategory integer
function ChatAnnouncements.OnTradeRemoved(eventId, who, tradeIndex, itemSoundCategory)
    local indexOut = tradeIndex
    if who == 0 then
        S.g_tradeStacksOut[indexOut] = nil
    else
        S.g_tradeStacksIn[indexOut] = nil
    end
end

function ChatAnnouncements.CheckLFGStatusJoin()
    if not S.g_stopGroupLeaveQueue then
        if not S.g_lfgDisableGroupEvents then
            if IsInLFGGroup() and not S.g_joinLFGOverride then
                if ChatAnnouncements.SV.Group.GroupCA then
                    ChatOutput:Print(GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN_SELF_LFG), true)
                end
                if ChatAnnouncements.SV.Group.GroupAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN_SELF_LFG))
                end
            elseif not IsInLFGGroup() and not S.g_joinLFGOverride then
                local isLeader = IsUnitGroupLeader("player")
                if ChatAnnouncements.SV.Group.GroupCA then
                    if isLeader then
                        ChatOutput:Print(GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN_FORM), true)
                    else
                        ChatOutput:Print(GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN_SELF), true)
                    end
                end
                if ChatAnnouncements.SV.Group.GroupAlert then
                    if isLeader then
                        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN_FORM))
                    else
                        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN_SELF))
                    end
                end
                if isLeader and not IsInLFGGroup() then
                    local groupSize = GetGroupSize()
                    if groupSize == 2 then
                        local unitToJoin
                        if GetUnitDisplayName("group1") == LUIE.PlayerDisplayName then
                            unitToJoin = "group2"
                        else
                            unitToJoin = "group1"
                        end
                        local joinedMemberName = GetUnitName(unitToJoin)
                        local joinedMemberAccountName = GetUnitDisplayName(unitToJoin)
                        local finalName = ChatAnnouncements.ResolveNameLink(joinedMemberName, joinedMemberAccountName)
                        local finalAlertName = ChatAnnouncements.ResolveNameNoLink(joinedMemberName, joinedMemberAccountName)
                        local SendMessage = (zo_strformat(GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN), finalName))
                        local SendAlert = (zo_strformat(GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN), finalAlertName))
                        ChatAnnouncements.PrintJoinStatusNotSelf(SendMessage, SendAlert)
                    end
                end
            end
        end
        S.g_joinLFGOverride = false
    end
end
