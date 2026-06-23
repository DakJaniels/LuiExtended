-- -----------------------------------------------------------------------------
--  Chat Announcements — suppress default CHAT_ROUTER social lines when CA owns them
--  Distributed under The MIT License (MIT) (see LICENSE file)
-- -----------------------------------------------------------------------------

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local ChatOutput = LUIE.ChatOutput
local eventManager = GetEventManager()
local moduleName = LUIE.name .. "ChatAnnouncements"

local chatRouterPreHookRegistered = false
local formatterPostHookRegistered = false
local formatterDeferredScheduled = false
local externalChatCallbacksRegistered = false

local SOCIAL_FORMATTER_EVENT_KEYS =
{
    [EVENT_FRIEND_PLAYER_STATUS_CHANGED] = true,
    [EVENT_IGNORE_ADDED] = true,
    [EVENT_IGNORE_REMOVED] = true,
    [EVENT_SOCIAL_ERROR] = true,
}

local function GetChatOutputSocialSettings()
    return LUIE.SV and LUIE.SV.ChatOutput and LUIE.SV.ChatOutput.Social
end

local function IsPChatAvailable()
    return pChat ~= nil and not ZO_IsConsoleOrGameCoreUI()
end

local function IsRChatAvailable()
    return rChat ~= nil and not ZO_IsConsoleOrGameCoreUI()
end

local function ShouldShowSocialErrorInChat(error)
    if ChatAnnouncements.Enabled and ChatAnnouncements.SV and ChatAnnouncements.SV.Notify.SocialErrorCA then
        return not IsSocialErrorIgnoreResponse(error)
    end
    return not ShouldShowSocialErrorInAlert(error)
end

local function ShouldSuppressFriendStatusRouter()
    return ChatAnnouncements.Enabled
end

local function ShouldSuppressFriendIgnoreRouter()
    if not ChatAnnouncements.Enabled then
        return false
    end
    local social = GetChatOutputSocialSettings()
    return social and social.FriendIgnoreCA == true
end

local function ShouldSuppressSocialErrorRouter(_, error)
    if IsSocialErrorIgnoreResponse(error) then
        return false
    end
    return ShouldShowSocialErrorInChat(error)
end

--- @param _ integer
--- @param error integer
function ChatAnnouncements.OnErrorSocialChat(_, error)
    if not ChatAnnouncements.Enabled or not ChatAnnouncements.SV.Notify.SocialErrorCA then
        return
    end
    if not IsSocialErrorIgnoreResponse(error) then
        ChatOutput:Print(zo_strformat(GetString("SI_SOCIALACTIONRESULT", error)))
    end
end

local function RegisterChatRouterPreHookOnce()
    if chatRouterPreHookRegistered or not CHAT_ROUTER or not IsChatSystemAvailableForCurrentPlatform() then
        return
    end
    chatRouterPreHookRegistered = true
    ZO_PreHook(CHAT_ROUTER, "FormatAndAddChatMessage", function (_, eventKey)
        if not ChatAnnouncements.Enabled then
            return false
        end
        if eventKey == EVENT_FRIEND_PLAYER_STATUS_CHANGED then
            return true
        end
        if eventKey == EVENT_IGNORE_ADDED or eventKey == EVENT_IGNORE_REMOVED then
            return ShouldSuppressFriendIgnoreRouter()
        end
        return false
    end)
end

local function RegisterFormatterPostHookOnce()
    if formatterPostHookRegistered or not CHAT_ROUTER or not IsChatSystemAvailableForCurrentPlatform() then
        return
    end
    formatterPostHookRegistered = true
    SecurePostHook(CHAT_ROUTER, "RegisterMessageFormatter", function (_, eventKey)
        if SOCIAL_FORMATTER_EVENT_KEYS[eventKey] then
            zo_callLater(function ()
                             ChatAnnouncements.ChainChatRouterSocialSuppressions()
                         end, 0)
        end
    end)
end

local function RegisterExternalChatFormatterCallbacksOnce()
    if externalChatCallbacksRegistered then
        return
    end
    if not IsPChatAvailable() and not IsRChatAvailable() then
        return
    end
    externalChatCallbacksRegistered = true

    if IsPChatAvailable() then
        CALLBACK_MANAGER:RegisterCallback("pChat_Initialized_EVENT_FRIEND_PLAYER_STATUS_CHANGED", function ()
            ChatAnnouncements.ChainChatRouterSocialSuppressions()
        end)
        CALLBACK_MANAGER:RegisterCallback("pChat_Initialized_EVENT_IGNORE_ADDED", function ()
            ChatAnnouncements.ChainChatRouterSocialSuppressions()
        end)
        CALLBACK_MANAGER:RegisterCallback("pChat_Initialized_EVENT_IGNORE_REMOVED", function ()
            ChatAnnouncements.ChainChatRouterSocialSuppressions()
        end)
    end

    if IsRChatAvailable() then
        CALLBACK_MANAGER:RegisterCallback("rChat_Initialized_EVENT_FRIEND_PLAYER_STATUS_CHANGED", function ()
            ChatAnnouncements.ChainChatRouterSocialSuppressions()
        end)
        CALLBACK_MANAGER:RegisterCallback("rChat_Initialized_EVENT_IGNORE_ADDED", function ()
            ChatAnnouncements.ChainChatRouterSocialSuppressions()
        end)
        CALLBACK_MANAGER:RegisterCallback("rChat_Initialized_EVENT_IGNORE_REMOVED", function ()
            ChatAnnouncements.ChainChatRouterSocialSuppressions()
        end)
    end
end

function ChatAnnouncements.ChainChatRouterSocialSuppressions()
    if not ChatAnnouncements.Enabled then
        return
    end
    RegisterChatRouterPreHookOnce()
    RegisterFormatterPostHookOnce()
    RegisterExternalChatFormatterCallbacksOnce()
    ChatOutput:WrapFormatter(EVENT_FRIEND_PLAYER_STATUS_CHANGED, ShouldSuppressFriendStatusRouter)
    ChatOutput:WrapFormatter(EVENT_IGNORE_ADDED, ShouldSuppressFriendIgnoreRouter)
    ChatOutput:WrapFormatter(EVENT_IGNORE_REMOVED, ShouldSuppressFriendIgnoreRouter)
    ChatOutput:WrapFormatter(EVENT_SOCIAL_ERROR, ShouldSuppressSocialErrorRouter)
    if not formatterDeferredScheduled then
        formatterDeferredScheduled = true
        zo_callLater(function ()
                         ChatAnnouncements.ChainChatRouterSocialSuppressions()
                     end, 1000)
        zo_callLater(function ()
                         ChatAnnouncements.ChainChatRouterSocialSuppressions()
                     end, 3000)
    end
end

function ChatAnnouncements.RegisterSocialChatRouter()
    eventManager:RegisterForEvent(moduleName, EVENT_SOCIAL_ERROR, ChatAnnouncements.OnErrorSocialChat)
    ChatAnnouncements.ChainChatRouterSocialSuppressions()
end
