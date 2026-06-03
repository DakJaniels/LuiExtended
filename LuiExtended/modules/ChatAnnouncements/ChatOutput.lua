-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

--- @class ChatOutput
local ChatOutput = {}
ChatAnnouncements.ChatOutput = ChatOutput

local ACTIVATION_HANDLER_NAME = LUIE.name .. "ChatOutput"

local eventManager = GetEventManager()

--- @type table<any, { inner: function, outer: function }>
ChatOutput.wrappers = {}

--- @type table|nil LibChatMessage proxy
ChatOutput.lcm = nil

local activationHandlerRegistered = false
local externalChatCallbacksRegistered = false

local function IsPChatAvailable()
    return pChat ~= nil and not ZO_IsConsoleOrGameCoreUI()
end

local function IsRChatAvailable()
    return rChat ~= nil and not ZO_IsConsoleOrGameCoreUI()
end

--- @return function|nil
local function GetExternalFormatSysMessage()
    if IsPChatAvailable() then
        local formatSysMessage = _G["pChat_FormatSysMessage"] or pChat.formatSysMessage
        if formatSysMessage then
            return formatSysMessage
        end
    end

    if IsRChatAvailable() then
        local formatSysMessage = _G["rChat_FormatSysMessage"] or rChat.formatSysMessage
        if formatSysMessage then
            return formatSysMessage
        end
    end

    if rChat_ZOS and type(rChat_ZOS.FormatSysMessage) == "function" then
        return rChat_ZOS.FormatSysMessage
    end

    return nil
end

local function GetSettings()
    if LUIE.SV and LUIE.SV.ChatOutput then
        return LUIE.SV.ChatOutput
    end
    return LUIE.Defaults and LUIE.Defaults.ChatOutput
end

function ChatOutput.IsLibChatMessageActive()
    return ChatOutput.lcm ~= nil
end

--- pChat / rChat system-message formatters (PC). Bypass only applies when one is present.
function ChatOutput.HasExternalChatFormatter()
    return GetExternalFormatSysMessage() ~= nil
end

--- pChat wraps the LibChatMessage formatter when useSystemMessageChatHandler is enabled.
function ChatOutput.ShouldPChatFormatLibChatMessageProxy()
    if not ChatOutput.lcm or not IsPChatAvailable() then
        return false
    end
    if not ChatOutput.HasExternalChatFormatter() then
        return false
    end
    local db = pChat.db
    if not db then
        return false
    end
    return db.useSystemMessageChatHandler == true
end

function ChatOutput.ShouldUseExternalFormatting()
    local SV = GetSettings()
    if not SV or SV.ChatBypassFormat ~= true then
        return false
    end
    return ChatOutput.HasExternalChatFormatter()
end

--- @param formatStr string|nil
--- @return boolean
function ChatOutput.LuiExtendedFormatUsesMilliseconds(formatStr)
    return type(formatStr) == "string" and zo_strfind(formatStr, "xy", 1, true) ~= nil
end

--- Maps LUIE Timestamp Format tokens (HH, m, xy, …) to a LibChatMessage/os.date format (bracketed literals).
--- @param luiFormat string|nil
--- @return string
function ChatOutput.LuiExtendedFormatToLibChatMessageOsDate(luiFormat)
    if type(luiFormat) ~= "string" or luiFormat == "" then
        return "[%X]"
    end

    local out = luiFormat
    out = string.gsub(out, "xy", "")
    out = string.gsub(out, ":+$", "")
    out = string.gsub(out, "HH", "%%H")
    out = string.gsub(out, "hh", "%%I")
    out = string.gsub(out, "H", "%%H")
    out = string.gsub(out, "h", "%%I")
    out = string.gsub(out, "A", "%%p")
    out = string.gsub(out, "a", "%%p")
    out = string.gsub(out, "m", "%%M")
    out = string.gsub(out, "s", "%%S")

    if out:sub(1, 1) ~= "[" then
        out = "[" .. out .. "]"
    end
    return out
end

function ChatOutput.PrependLuiExtendedTimestampToMessage(rawMsg)
    local SV = GetSettings()
    if not SV or SV.TimeStamp ~= true then
        return rawMsg
    end
    local timestring = GetTimeString()
    local timestamp = LUIE.CreateTimestamp(timestring, SV.TimeStampFormat, nil)
    local timestampFormatted = zo_strformat("|c<<1>>[<<2>>]|r ", LUIE.TimeStampColorize, timestamp)
    return timestampFormatted .. rawMsg
end

--- When true, LUIE proxy prints use Timestamp Format below (xy/ms). When false, LibChatMessage os.date preset or custom field applies.
function ChatOutput.UsesLuiExtendedTimestampFormatWithLibChatMessage()
    local SV = GetSettings()
    if not SV then
        return true
    end
    if SV.LcmUseLuiExtendedTimestampFormat == nil then
        return true
    end
    return SV.LcmUseLuiExtendedTimestampFormat == true
end

--- With LibChatMessage, LUIE applies Include Timestamp on proxy prints only in LuiExtended-format mode.
function ChatOutput.ShouldPrependLuiExtendedTimestampOnLibChatMessageProxy()
    local SV = GetSettings()
    if not ChatOutput.lcm or not SV or SV.TimeStamp ~= true then
        return false
    end
    if ChatOutput.ShouldPChatFormatLibChatMessageProxy() then
        return false
    end
    return ChatOutput.UsesLuiExtendedTimestampFormatWithLibChatMessage()
end

--- Apply Include Timestamp + LCM time mode to LibChatMessage APIs.
function ChatOutput.ApplyLibChatMessageTimePrefixSettings()
    if not LibChatMessage or not ChatOutput.lcm then
        return
    end
    local SV = GetSettings()
    if not SV then
        return
    end

    if ChatOutput.ShouldPChatFormatLibChatMessageProxy() then
        LibChatMessage:SetTimePrefixEnabled(false)
        return
    end

    if ChatOutput.UsesLuiExtendedTimestampFormatWithLibChatMessage() then
        LibChatMessage:SetTimePrefixFormat(ChatOutput.LuiExtendedFormatToLibChatMessageOsDate(SV.TimeStampFormat))
        LibChatMessage:SetTimePrefixEnabled(false)
    else
        LibChatMessage:SetTimePrefixEnabled(SV.TimeStamp == true)
    end
end

--- LUIE timestamps must not compete with LibChatMessage tag/time formatters.
function ChatOutput.ShouldApplyLuiExtendedTimestamp()
    if ChatOutput.lcm then
        return false
    end
    local SV = GetSettings()
    if ChatOutput.ShouldUseExternalFormatting() then
        return false
    end
    return SV and SV.TimeStamp == true
end

local function PrintViaLibChatMessage(msg)
    if ChatOutput.lcm then
        if ChatOutput.ShouldPrependLuiExtendedTimestampOnLibChatMessageProxy() then
            msg = ChatOutput.PrependLuiExtendedTimestampToMessage(msg)
        end
        ChatOutput.lcm:Print(msg)
        return true
    end
    return false
end

--- When LibChatMessage is loaded, LUIE must use the proxy so tags, time, and history use LIB_IDENTIFIER routing.
function ChatOutput.ShouldRoutePrintThroughLibChatMessage()
    return ChatOutput.lcm ~= nil
end

local function UsesPrintToAllTabsMethod()
    if ZO_IsConsoleOrGameCoreUI() then
        return true
    end
    local SV = GetSettings()
    return SV and SV.ChatMethod == "Print to All Tabs"
end

local function ApplyExternalSystemFormat(rawMsg)
    local formatSysMessage = GetExternalFormatSysMessage()
    if formatSysMessage then
        local formatted = formatSysMessage(rawMsg)
        if formatted then
            return formatted
        end
    end

    if CHAT_ROUTER then
        local formatter = CHAT_ROUTER:GetRegisteredMessageFormatters()["AddSystemMessage"]
        if formatter then
            local formatted = formatter(rawMsg)
            if formatted then
                return formatted
            end
        end
    end

    return rawMsg
end

function ChatOutput.FormatForDisplay(rawMsg)
    if ChatOutput.ShouldUseExternalFormatting() then
        return ApplyExternalSystemFormat(rawMsg)
    end
    return LUIE.FormatMessage(rawMsg, ChatOutput.ShouldApplyLuiExtendedTimestamp())
end

function ChatOutput.PrintToChatWindows(formattedMsg, isSystem)
    local SV = GetSettings()
    if not SV then
        LUIE.AddSystemMessage(formattedMsg)
        return
    end

    if isSystem and SV.ChatSystemAll then
        LUIE.AddSystemMessage(formattedMsg)
        return
    end

    for _, cc in ipairs(ZO_GetChatSystem().containers) do
        for i = 1, #cc.windows do
            if SV.ChatTab[i] == true then
                local chatContainer = cc
                local chatWindow = cc.windows[i]

                local skipWindow = false
                if CMX and CMX.db and CMX.db.chatLog then
                    if chatContainer:GetTabName(i) == CMX.db.chatLog.name then
                        skipWindow = true
                    end
                end

                if not skipWindow then
                    chatContainer:AddEventMessageToWindow(chatWindow, formattedMsg, CHAT_CATEGORY_SYSTEM)
                end
            end
        end
    end
end

function ChatOutput.Print(msg, isSystem)
    if not ZO_GetChatSystem().primaryContainer then
        return
    end

    if msg == "" then
        msg = "[Empty String]"
    end

    local SV = GetSettings()
    if not SV then
        LUIE.AddSystemMessage(msg)
        return
    end

    if PrintViaLibChatMessage(msg) then
        return
    end

    if UsesPrintToAllTabsMethod() then
        if ChatOutput.ShouldUseExternalFormatting() then
            LUIE.AddSystemMessage(ApplyExternalSystemFormat(msg))
        else
            LUIE.AddSystemMessage(LUIE.FormatMessage(msg, ChatOutput.ShouldApplyLuiExtendedTimestamp()))
        end
        return
    end

    ChatOutput.PrintToChatWindows(ChatOutput.FormatForDisplay(msg), isSystem)
end

function ChatOutput.WrapFormatter(eventKey, shouldSuppressFn)
    if not CHAT_ROUTER or not IsChatSystemAvailableForCurrentPlatform() then
        return
    end

    local formatters = CHAT_ROUTER:GetRegisteredMessageFormatters()
    local previous = formatters[eventKey]
    if not previous then
        return
    end

    local existing = ChatOutput.wrappers[eventKey]
    if existing and (existing.inner == previous or existing.outer == previous) then
        return
    end

    local function wrapper(...)
        if shouldSuppressFn(...) then
            return nil
        end
        return previous(...)
    end

    ChatOutput.wrappers[eventKey] = { inner = previous, outer = wrapper }
    CHAT_ROUTER:RegisterMessageFormatter(eventKey, wrapper)
end

local function ShouldSuppressFriendStatus()
    return ChatAnnouncements.Enabled and ChatAnnouncements.SV.Social.FriendStatusCA
end

local function ShouldSuppressFriendIgnore()
    return ChatAnnouncements.Enabled and ChatAnnouncements.SV.Social.FriendIgnoreCA
end

local function ShouldSuppressSocialError(_, error)
    if not ChatAnnouncements.Enabled then
        return false
    end
    if IsSocialErrorIgnoreResponse(error) then
        return false
    end
    return ChatAnnouncements.Internal.ShouldShowSocialErrorInChat(error)
end

function ChatOutput.ChainFormatterSuppressions()
    if not ChatAnnouncements.Enabled then
        return
    end
    ChatOutput.WrapFormatter(EVENT_FRIEND_PLAYER_STATUS_CHANGED, ShouldSuppressFriendStatus)
    ChatOutput.WrapFormatter(EVENT_IGNORE_ADDED, ShouldSuppressFriendIgnore)
    ChatOutput.WrapFormatter(EVENT_IGNORE_REMOVED, ShouldSuppressFriendIgnore)
    ChatOutput.WrapFormatter(EVENT_SOCIAL_ERROR, ShouldSuppressSocialError)
end

local function OnDeferredPlayerActivated()
    if not ChatAnnouncements.Enabled or not ZO_GetChatSystem().primaryContainer then
        return
    end
    ChatOutput.ChainFormatterSuppressions()
end

local function RegisterExternalChatRechainCallbacks()
    if externalChatCallbacksRegistered then
        return
    end
    if not IsPChatAvailable() and not IsRChatAvailable() then
        return
    end
    externalChatCallbacksRegistered = true

    if IsPChatAvailable() then
        CALLBACK_MANAGER:RegisterCallback("pChat_Initialized_AddSystemMessage", function ()
            ChatOutput.ApplyLibChatMessageTimePrefixSettings()
        end)
        CALLBACK_MANAGER:RegisterCallback("pChat_Initialized_EVENT_FRIEND_PLAYER_STATUS_CHANGED", function ()
            ChatOutput.WrapFormatter(EVENT_FRIEND_PLAYER_STATUS_CHANGED, ShouldSuppressFriendStatus)
        end)
        CALLBACK_MANAGER:RegisterCallback("pChat_Initialized_EVENT_IGNORE_ADDED", function ()
            ChatOutput.WrapFormatter(EVENT_IGNORE_ADDED, ShouldSuppressFriendIgnore)
        end)
        CALLBACK_MANAGER:RegisterCallback("pChat_Initialized_EVENT_IGNORE_REMOVED", function ()
            ChatOutput.WrapFormatter(EVENT_IGNORE_REMOVED, ShouldSuppressFriendIgnore)
        end)
    end

    if IsRChatAvailable() then
        CALLBACK_MANAGER:RegisterCallback("rChat_Initialized_EVENT_FRIEND_PLAYER_STATUS_CHANGED", function ()
            ChatOutput.WrapFormatter(EVENT_FRIEND_PLAYER_STATUS_CHANGED, ShouldSuppressFriendStatus)
        end)
        CALLBACK_MANAGER:RegisterCallback("rChat_Initialized_EVENT_IGNORE_ADDED", function ()
            ChatOutput.WrapFormatter(EVENT_IGNORE_ADDED, ShouldSuppressFriendIgnore)
        end)
        CALLBACK_MANAGER:RegisterCallback("rChat_Initialized_EVENT_IGNORE_REMOVED", function ()
            ChatOutput.WrapFormatter(EVENT_IGNORE_REMOVED, ShouldSuppressFriendIgnore)
        end)
    end
end

local function RegisterActivationHandler()
    if activationHandlerRegistered then
        return
    end
    activationHandlerRegistered = true
    eventManager:RegisterForEvent(ACTIVATION_HANDLER_NAME, EVENT_PLAYER_ACTIVATED, function ()
        zo_callLater(OnDeferredPlayerActivated, 0)
    end)
end

function ChatOutput.InitializePrintRouting()
    if LibChatMessage then
        ChatOutput.lcm = LibChatMessage("LuiExtended", "LUIE")
        ChatOutput.ApplyLibChatMessageTimePrefixSettings()
    else
        ChatOutput.lcm = nil
    end
end

function ChatOutput.InitializeRouterIntegration(caModuleEnabled)
    if not caModuleEnabled then
        return
    end

    RegisterExternalChatRechainCallbacks()
    RegisterActivationHandler()

    if ZO_GetChatSystem().primaryContainer then
        zo_callLater(OnDeferredPlayerActivated, 0)
    end
end

--- @param caModuleEnabled boolean Chat Announcements module enabled (not just SV loaded)
function ChatOutput.Initialize(caModuleEnabled)
    ChatOutput.InitializePrintRouting()
    ChatOutput.InitializeRouterIntegration(caModuleEnabled)
end
