-- -----------------------------------------------------------------------------
--  LuiExtended — LUIE-wide chat output routing (LUIE.SV.ChatOutput)
--  Distributed under The MIT License (MIT) (see LICENSE file)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class LUIE_ChatOutput
local LUIE_ChatOutput = LUIE.ChatOutputClass
local ChatOutput = LUIE.ChatOutput

local ACTIVATION_HANDLER_NAME = LUIE.name .. "ChatOutput"
local LIB_CHAT_MESSAGE_FORMATTER_KEY = "LibChatMessage"

local eventManager = GetEventManager()

-- -----------------------------------------------------------------------------
-- Platform / saved vars
-- -----------------------------------------------------------------------------

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

--- @param self LUIE_ChatOutput
--- @return LUIE_ChatOutputDefaults|nil
function LUIE_ChatOutput:GetChatOutputSavedVars()
    if LUIE.SV and LUIE.SV.ChatOutput then
        return LUIE.SV.ChatOutput
    end
    return LUIE.Defaults and LUIE.Defaults.ChatOutput
end

--- @return table|nil
function LUIE_ChatOutput:GetChatOutputSocialSettings()
    local chatOutputSettings = self:GetChatOutputSavedVars()
    return chatOutputSettings and chatOutputSettings.Social
end

--- True when pChat will save/restore chat (LCM history must stay off).
--- @return boolean
function LUIE_ChatOutput:IsPChatChatRestoreEnabled()
    if not IsPChatAvailable() then
        return false
    end
    local pChatDatabase = pChat.db
    if not pChatDatabase then
        return false
    end
    return pChatDatabase.restoreOnReloadUI == true
        or pChatDatabase.restoreOnLogOut == true
        or pChatDatabase.restoreOnAFK == true
        or pChatDatabase.restoreOnQuit == true
end

--- Disables LibChatMessage history when pChat restore is active (pChat wins).
function LUIE_ChatOutput:DisableLibChatMessageHistoryWhenPChatRestoreIsActive()
    if not LibChatMessage or not self:IsPChatChatRestoreEnabled() then
        return
    end
    if LibChatMessage:IsChatHistoryEnabled() then
        LibChatMessage:SetChatHistoryEnabled(false)
    end
end

function LUIE_ChatOutput:IsLibChatMessageActive()
    return self.libChatMessage ~= nil
end

--- pChat / rChat system-message formatters (PC). Bypass only applies when one is present.
function LUIE_ChatOutput:HasExternalChatFormatter()
    return GetExternalFormatSysMessage() ~= nil
end

--- pChat wraps the LibChatMessage formatter when useSystemMessageChatHandler is enabled.
function LUIE_ChatOutput:ShouldPChatFormatLibChatMessageProxy()
    if not self.libChatMessage or not IsPChatAvailable() then
        return false
    end
    if not self:HasExternalChatFormatter() then
        return false
    end
    local pChatDatabase = pChat.db
    if not pChatDatabase then
        return false
    end
    return pChatDatabase.useSystemMessageChatHandler == true
end

function LUIE_ChatOutput:ShouldUseExternalFormatting()
    local chatOutputSettings = self:GetChatOutputSavedVars()
    if not chatOutputSettings or chatOutputSettings.ChatBypassFormat ~= true then
        return false
    end
    return self:HasExternalChatFormatter()
end

--- @param formatStr string|nil
--- @return boolean
function LUIE_ChatOutput:LuiExtendedFormatUsesMilliseconds(formatStr)
    return type(formatStr) == "string" and zo_strfind(formatStr, "xy", 1, true) ~= nil
end

--- LUIE Timestamp Format token → os.date specifier (token mapping only; never clock values).
local LUIE_TIMESTAMP_TOKEN_TO_OSDATE =
{
    HH = "%H",
    hh = "%I",
    H = "%H",
    h = "%I",
    A = "%p",
    a = "%p",
    m = "%M",
    s = "%S",
}

--- Longest-match-first; same priority as CreateTimestamp.
local LUIE_TIMESTAMP_TOKEN_SCAN_ORDER =
{
    "HH",
    "hh",
    "H",
    "h",
    "A",
    "a",
    "xy",
    "m",
    "s",
}

local LUIE_TIMESTAMP_COLON_SEGMENT_PATTERN = "([^:]+)"

--- @param segment string
--- @return string|nil os.date piece, or nil to omit (xy / empty)
local function MapLuiExtendedTimestampSegmentToOsDate(segment)
    if segment == "" or segment == "xy" then
        return nil
    end
    return LUIE_TIMESTAMP_TOKEN_TO_OSDATE[segment] or segment
end

--- @param luiFormat string
--- @return string|nil
local function ConvertLuiExtendedTimestampFormatByColonSegments(luiFormat)
    local segments = zo_tokenize(luiFormat, LUIE_TIMESTAMP_COLON_SEGMENT_PATTERN)
    local mapped = {}
    for segmentIndex = 1, #segments do
        local piece = MapLuiExtendedTimestampSegmentToOsDate(segments[segmentIndex])
        if piece then
            mapped[#mapped + 1] = piece
        end
    end
    if #mapped == 0 then
        return nil
    end
    return table.concat(mapped, ":")
end

--- @param luiFormat string
--- @return string
local function ConvertLuiExtendedTimestampFormatByScanner(luiFormat)
    local length = #luiFormat
    local index = 1
    local parts = {}
    while index <= length do
        local matched = false
        for tokenOrderIndex = 1, #LUIE_TIMESTAMP_TOKEN_SCAN_ORDER do
            local token = LUIE_TIMESTAMP_TOKEN_SCAN_ORDER[tokenOrderIndex]
            local tokenLength = #token
            if zo_strsub(luiFormat, index, index + tokenLength - 1) == token then
                if token ~= "xy" then
                    local piece = LUIE_TIMESTAMP_TOKEN_TO_OSDATE[token]
                    if piece then
                        parts[#parts + 1] = piece
                    end
                end
                index = index + tokenLength
                matched = true
                break
            end
        end
        if not matched then
            parts[#parts + 1] = zo_strsub(luiFormat, index, index)
            index = index + 1
        end
    end
    return table.concat(parts)
end

--- Maps LUIE Timestamp Format tokens (HH, m, xy, …) to a LibChatMessage/os.date format (bracketed literals).
--- Uses zo_tokenize colon segments or a plain zo_strsub scan — not zo_strgsub / CreateTimestamp (no clock values).
--- @param luiFormat string|nil
--- @return string
function LUIE_ChatOutput:LuiExtendedFormatToLibChatMessageOsDate(luiFormat)
    if type(luiFormat) ~= "string" or luiFormat == "" then
        return "[%X]"
    end

    local work = luiFormat
    if zo_strsub(work, 1, 1) == "[" and zo_strsub(work, -1, -1) == "]" then
        work = zo_strsub(work, 2, -2)
    end

    local out
    if zo_strfind(work, " ", 1, true) then
        out = ConvertLuiExtendedTimestampFormatByScanner(work)
    else
        out = ConvertLuiExtendedTimestampFormatByColonSegments(work)
        if not out then
            out = ConvertLuiExtendedTimestampFormatByScanner(work)
        end
    end

    out = zo_strgsub(out, ":+$", "")
    if zo_strsub(out, 1, 1) ~= "[" then
        out = "[" .. out .. "]"
    end
    return out
end

function LUIE_ChatOutput:PrependLuiExtendedTimestampToMessage(rawMessage)
    local chatOutputSettings = self:GetChatOutputSavedVars()
    if not chatOutputSettings or chatOutputSettings.TimeStamp ~= true then
        return rawMessage
    end
    local timestring = GetTimeString()
    local timestamp = self:CreateTimestamp(timestring, chatOutputSettings.TimeStampFormat, nil)
    local timestampFormatted = zo_strformat("|c<<1>>[<<2>>]|r ", self.timestampColorHex, timestamp)
    return timestampFormatted .. rawMessage
end

--- True when the string uses LUIE tokens (HH, m, xy, …) rather than LibChatMessage/os.date (%%H, %M, …).
--- @param formatStr string|nil
--- @return boolean
function LUIE_ChatOutput:LooksLikeLuiExtendedTimestampFormat(formatStr)
    return type(formatStr) == "string" and formatStr ~= "" and not zo_strfind(formatStr, "%%", 1, true)
end

--- pChat system-message handler + Show timestamp: LUIE locks LibChatMessage time format UI to Custom sync.
--- @return boolean
function LUIE_ChatOutput:IsLibChatMessageTimeFormatLockedByPChat()
    if not IsPChatAvailable() or not self:ShouldPChatFormatLibChatMessageProxy() then
        return false
    end
    if not pChat or type(pChat.db) ~= "table" then
        return false
    end
    return pChat.db.showTimestamp == true
end

--- Token format used to build LibChatMessage os.date (LUIE Timestamp Format, or pChat timestampFormat when bypass + pChat lock).
--- @return string|nil
function LUIE_ChatOutput:GetTimestampFormatStringForLibChatMessageSync()
    local chatOutputSettings = self:GetChatOutputSavedVars()
    if self:IsLibChatMessageTimeFormatLockedByPChat() and self:ShouldUseExternalFormatting() then
        local pChatDatabase = pChat.db
        if pChatDatabase and type(pChatDatabase.timestampFormat) == "string" and pChatDatabase.timestampFormat ~= "" then
            return pChatDatabase.timestampFormat
        end
    end
    if chatOutputSettings and type(chatOutputSettings.TimeStampFormat) == "string" then
        return chatOutputSettings.TimeStampFormat
    end
    return nil
end

--- Writes LibChatMessage:SetTimePrefixFormat from LUIE/pChat timestamp tokens (token conversion).
function LUIE_ChatOutput:SyncLuiExtendedTimestampFormatToLibChatMessage()
    if not LibChatMessage or not self.libChatMessage then
        return
    end
    local chatOutputSettings = self:GetChatOutputSavedVars()
    if not chatOutputSettings or not self:UsesLuiExtendedTimestampFormatWithLibChatMessage() then
        return
    end
    local formatString = self:GetTimestampFormatStringForLibChatMessageSync()
    LibChatMessage:SetTimePrefixFormat(self:LuiExtendedFormatToLibChatMessageOsDate(formatString))
end

--- When true, LUIE proxy prints use Timestamp Format below (xy/ms). When false, LibChatMessage os.date preset or custom field applies.
function LUIE_ChatOutput:UsesLuiExtendedTimestampFormatWithLibChatMessage()
    local chatOutputSettings = self:GetChatOutputSavedVars()
    if not chatOutputSettings then
        return true
    end
    if chatOutputSettings.LcmUseLuiExtendedTimestampFormat == nil then
        return true
    end
    return chatOutputSettings.LcmUseLuiExtendedTimestampFormat == true
end

--- With LibChatMessage, LUIE prepends timestamps on proxy prints only when sync uses LUIE tokens with milliseconds (xy); otherwise LibChatMessage os.date applies.
function LUIE_ChatOutput:ShouldPrependLuiExtendedTimestampOnLibChatMessageProxy()
    local chatOutputSettings = self:GetChatOutputSavedVars()
    if not self.libChatMessage or not chatOutputSettings or chatOutputSettings.TimeStamp ~= true then
        return false
    end
    if self:ShouldPChatFormatLibChatMessageProxy() then
        return false
    end
    if not self:UsesLuiExtendedTimestampFormatWithLibChatMessage() then
        return false
    end
    return self:LuiExtendedFormatUsesMilliseconds(chatOutputSettings.TimeStampFormat)
end

--- Apply Include Timestamp + LCM time mode to LibChatMessage APIs.
function LUIE_ChatOutput:ApplyLibChatMessageTimePrefixSettings()
    if not LibChatMessage or not self.libChatMessage then
        return
    end
    local chatOutputSettings = self:GetChatOutputSavedVars()
    if not chatOutputSettings then
        return
    end

    if self:IsLibChatMessageTimeFormatLockedByPChat() then
        chatOutputSettings.LcmUseLuiExtendedTimestampFormat = true
    end

    if self:UsesLuiExtendedTimestampFormatWithLibChatMessage() then
        self:SyncLuiExtendedTimestampFormatToLibChatMessage()
    end

    if self:ShouldPChatFormatLibChatMessageProxy() then
        LibChatMessage:SetTimePrefixEnabled(false)
        return
    end

    if self:UsesLuiExtendedTimestampFormatWithLibChatMessage() then
        if self:LuiExtendedFormatUsesMilliseconds(chatOutputSettings.TimeStampFormat) then
            LibChatMessage:SetTimePrefixEnabled(false)
        else
            LibChatMessage:SetTimePrefixEnabled(chatOutputSettings.TimeStamp == true)
        end
    else
        LibChatMessage:SetTimePrefixEnabled(chatOutputSettings.TimeStamp == true)
    end
end

--- When true, LUIE prints via LibChatMessage:Print so tag/time use LibChatMessage settings (not AddSystemMessage + self:FormatMessage).
--- @return boolean
function LUIE_ChatOutput:ShouldRoutePrintThroughLibChatMessageProxy()
    if not self.libChatMessage or self:ShouldUseExternalFormatting() then
        return false
    end
    return self:GetChatOutputSavedVars() ~= nil
end

--- LUIE timestamps for AddSystemMessage / FormatForDisplay only when LibChatMessage is not already applying tag/time.
function LUIE_ChatOutput:ShouldApplyLuiExtendedTimestamp()
    local chatOutputSettings = self:GetChatOutputSavedVars()
    if self:ShouldUseExternalFormatting() then
        return false
    end
    if not chatOutputSettings or chatOutputSettings.TimeStamp ~= true then
        return false
    end
    if not self:ShouldRoutePrintThroughLibChatMessageProxy() then
        return true
    end
    if self:ShouldPChatFormatLibChatMessageProxy() then
        return false
    end
    if self:ShouldPrependLuiExtendedTimestampOnLibChatMessageProxy() then
        return false
    end
    if not self:UsesLuiExtendedTimestampFormatWithLibChatMessage() then
        return false
    end
    if not self:LuiExtendedFormatUsesMilliseconds(chatOutputSettings.TimeStampFormat) then
        return false
    end
    return true
end

--- Removes a leading LCM tag embedded in the message body so LibChatMessage does not duplicate it.
--- @param messageText string
--- @return string
function LUIE_ChatOutput:StripLeadingLibChatMessageTagFromBody(messageText)
    if not self.libChatMessage or type(messageText) ~= "string" or messageText == "" then
        return messageText
    end

    local proxy = self.libChatMessage
    local tagNames = { proxy.shortTag, proxy.longTag }
    local stripped = messageText

    for tagIndex = 1, #tagNames do
        local tagName = tagNames[tagIndex]
        if type(tagName) == "string" and tagName ~= "" then
            local bracketTag = zo_strformat("[%s]", tagName)
            if zo_strsub(stripped, 1, #bracketTag) == bracketTag then
                stripped = zo_strsub(stripped, #bracketTag + 1)
                stripped = zo_strgsub(stripped, "^%s+", "")
                return stripped
            end

            local coloredPattern = "^|c%x%x%x%x%x%x%[" .. tagName .. "%]|r%s*"
            local withoutColoredTag = zo_strgsub(stripped, coloredPattern, "")
            if withoutColoredTag ~= stripped then
                return withoutColoredTag
            end
        end
    end

    return stripped
end

function LUIE_ChatOutput:GetRawMessageForLibChatMessageFormatter(messageText)
    if self:ShouldPrependLuiExtendedTimestampOnLibChatMessageProxy() then
        messageText = self:PrependLuiExtendedTimestampToMessage(messageText)
    end
    return self:StripLeadingLibChatMessageTagFromBody(messageText)
end

--- Runs LibChatMessage (and pChat wrap) formatter without CHAT_ROUTER delivery; records LCM history.
--- @param messageText string
--- @return string|nil
function LUIE_ChatOutput:FormatMessageViaLibChatMessageFormatter(messageText)
    if not self.libChatMessage or not CHAT_ROUTER then
        return nil
    end
    self:ApplyLibChatMessageTimePrefixSettings()
    local messageFormatter = CHAT_ROUTER:GetRegisteredMessageFormatters()[LIB_CHAT_MESSAGE_FORMATTER_KEY]
    if not messageFormatter then
        return nil
    end
    messageText = self:GetRawMessageForLibChatMessageFormatter(messageText)
    local tag = self.libChatMessage:GetTag()
    local formattedEventText = messageFormatter(tag, messageText)
    if formattedEventText then
        return formattedEventText
    end
    return messageText
end

function LUIE_ChatOutput:PrintViaLibChatMessage(messageText)
    if self.libChatMessage then
        -- Re-apply before each print (pChat/LCM init order can leave timePrefixEnabled true).
        self:ApplyLibChatMessageTimePrefixSettings()
        messageText = self:GetRawMessageForLibChatMessageFormatter(messageText)
        self.libChatMessage:Print(messageText)
        return true
    end
    return false
end

function LUIE_ChatOutput:PrintToChatWindowsViaLibChatMessageFormatter(messageText, isSystem)
    local formattedMessage = self:FormatMessageViaLibChatMessageFormatter(messageText)
    if not formattedMessage then
        self:PrintToChatWindows(self:FormatForDisplay(messageText), isSystem, messageText)
        return
    end
    self:PrintToChatWindows(formattedMessage, isSystem, messageText)
end

function LUIE_ChatOutput:UsesPrintToAllTabsMethod()
    if ZO_IsConsoleOrGameCoreUI() then
        return true
    end
    local chatOutputSettings = self:GetChatOutputSavedVars()
    return chatOutputSettings and chatOutputSettings.ChatMethod == "Print to All Tabs"
end

function LUIE_ChatOutput:ApplyExternalSystemFormat(rawMessage)
    local formatSysMessage = GetExternalFormatSysMessage()
    if formatSysMessage then
        local formattedMessage = formatSysMessage(rawMessage)
        if formattedMessage then
            return formattedMessage
        end
    end

    if CHAT_ROUTER then
        local messageFormatter = CHAT_ROUTER:GetRegisteredMessageFormatters()["AddSystemMessage"]
        if messageFormatter then
            local formattedMessage = messageFormatter(rawMessage)
            if formattedMessage then
                return formattedMessage
            end
        end
    end

    return rawMessage
end

function LUIE_ChatOutput:FormatForDisplay(rawMessage)
    if self:ShouldUseExternalFormatting() then
        return self:ApplyExternalSystemFormat(rawMessage)
    end
    return self:FormatMessage(rawMessage, self:ShouldApplyLuiExtendedTimestamp())
end

--- Max tab index on the primary chat container, or across all containers (minimum 1).
--- @return integer
function LUIE_ChatOutput:GetMaxChatTabIndex()
    if not IsChatSystemAvailableForCurrentPlatform() then
        return 5
    end
    local chatSystem = ZO_GetChatSystem()
    if not chatSystem then
        return 5
    end
    local maxWindows = 1
    local primaryContainer = chatSystem.primaryContainer
    if primaryContainer and primaryContainer.windows then
        maxWindows = #primaryContainer.windows
    end
    if chatSystem.containers then
        for _, chatContainer in ipairs(chatSystem.containers) do
            if chatContainer.windows and #chatContainer.windows > maxWindows then
                maxWindows = #chatContainer.windows
            end
        end
    end
    return maxWindows
end

--- LAM registers tab checkboxes at addon load; use this cap and disable slots past the live tab count.
--- @return integer
function LUIE_ChatOutput:GetChatTabSettingsSlotCount()
    return 20
end

--- @param tabIndex integer
--- @return boolean
function LUIE_ChatOutput:IsChatTabIndexActiveForSettings(tabIndex)
    return tabIndex >= 1 and tabIndex <= self:GetMaxChatTabIndex()
end

--- LAM label for a chat tab checkbox (includes primary container tab name when set).
--- @param tabIndex integer
--- @return string
function LUIE_ChatOutput:GetChatTabSettingsLabel(tabIndex)
    local label = zo_strformat(GetString(LUIE_STRING_LAM_CA_CHATTAB), tostring(tabIndex))
    if not IsChatSystemAvailableForCurrentPlatform() then
        return label
    end
    local chatSystem = ZO_GetChatSystem()
    local primaryContainer = chatSystem and chatSystem.primaryContainer
    if primaryContainer and primaryContainer.GetTabName then
        local tabName = primaryContainer:GetTabName(tabIndex)
        if tabName and tabName ~= "" then
            return zo_strformat("<<1>> (<<2>>)", label, tabName)
        end
    end
    return label
end

--- Short LAM half-width label for tab routing row (tab index and optional name).
--- @param tabIndex integer
--- @return string
function LUIE_ChatOutput:GetChatTabSettingsShortLabel(tabIndex)
    if not IsChatSystemAvailableForCurrentPlatform() then
        return zo_strformat(GetString(LUIE_STRING_LAM_CA_CHATTAB_ROW_NONAME), tostring(tabIndex))
    end
    local chatSystem = ZO_GetChatSystem()
    local primaryContainer = chatSystem and chatSystem.primaryContainer
    if primaryContainer and primaryContainer.GetTabName then
        local tabName = primaryContainer:GetTabName(tabIndex)
        if tabName and tabName ~= "" then
            return zo_strformat(GetString(LUIE_STRING_LAM_CA_CHATTAB_ROW), tostring(tabIndex), tabName)
        end
    end
    return zo_strformat(GetString(LUIE_STRING_LAM_CA_CHATTAB_ROW_NONAME), tostring(tabIndex))
end

--- @return table|nil
function LUIE_ChatOutput:GetPrimaryChatContainerForSettings()
    if not IsChatSystemAvailableForCurrentPlatform() then
        return nil
    end
    local chatSystem = ZO_GetChatSystem()
    return chatSystem and chatSystem.primaryContainer or nil
end

--- Per-tab chat UI is available after player activation (ZOS loads chat in its EVENT_PLAYER_ACTIVATED handler first).
--- @return boolean
function LUIE_ChatOutput:IsPlayerActivatedForChatDelivery()
    if not IsChatSystemAvailableForCurrentPlatform() then
        return true
    end
    return IsPlayerActivated()
end

--- @param messageText string
--- @param isSystem boolean|nil
function LUIE_ChatOutput:EnqueuePendingPrint(messageText, isSystem)
    self.pendingPrintQueue[#self.pendingPrintQueue + 1] = { messageText = messageText, isSystem = isSystem }
end

function LUIE_ChatOutput:FlushPendingPrints()
    if #self.pendingPrintQueue == 0 or not self:IsPlayerActivatedForChatDelivery() then
        return
    end
    local queue = self.pendingPrintQueue
    self.pendingPrintQueue = {}
    for i = 1, #queue do
        local entry = queue[i]
        self:PrintWhenReady(entry.messageText, entry.isSystem)
    end
end

--- After ZOS chat load; same routing as Print without readiness gating.
--- @param messageText string
--- @param isSystem boolean|nil
function LUIE_ChatOutput:PrintWhenReady(messageText, isSystem)
    if messageText == "" then
        messageText = "[Empty String]"
    end

    if self.libChatMessage then
        self:ApplyLibChatMessageTimePrefixSettings()
    end

    local chatOutputSettings = self:GetChatOutputSavedVars()
    if not chatOutputSettings then
        self:AddSystemMessage(messageText)
        return
    end

    self:DeliverToSelectedChatTabs(messageText, isSystem)
end

--- When ChatMethod is Print to All Tabs, enable LUIE routing and System filter on every active primary tab.
function LUIE_ChatOutput:SyncChatTabRoutingForAllTabsMethod()
    if not self:UsesPrintToAllTabsMethod() then
        return
    end
    if not self:GetPrimaryChatContainerForSettings() then
        return
    end
    if not LUIE.SV then
        return
    end
    LUIE.SV.ChatOutput = LUIE.SV.ChatOutput or {}
    local chatOutputSettings = LUIE.SV.ChatOutput
    if not chatOutputSettings.ChatTab then
        chatOutputSettings.ChatTab = {}
    end
    local maxTabIndex = self:GetMaxChatTabIndex()
    for tabIndex = 1, maxTabIndex do
        if self:IsChatTabIndexActiveForSettings(tabIndex) then
            chatOutputSettings.ChatTab[tabIndex] = true
            self:SetSystemCategoryEnabledOnTabForSettings(tabIndex, true)
        end
    end
end

--- System category filter on the primary chat container tab (settings UI).
--- @param tabIndex integer
--- @return boolean
function LUIE_ChatOutput:IsSystemCategoryEnabledOnTabForSettings(tabIndex)
    local primaryContainer = self:GetPrimaryChatContainerForSettings()
    if not primaryContainer or not self:IsChatTabIndexActiveForSettings(tabIndex) then
        return false
    end
    return self:IsChatCategoryEnabledOnTab(primaryContainer, tabIndex, CHAT_CATEGORY_SYSTEM)
end

--- @param tabIndex integer
--- @param enabled boolean
function LUIE_ChatOutput:SetSystemCategoryEnabledOnTabForSettings(tabIndex, enabled)
    local primaryContainer = self:GetPrimaryChatContainerForSettings()
    if not primaryContainer or not self:IsChatTabIndexActiveForSettings(tabIndex) then
        return
    end
    if primaryContainer.SetWindowFilterEnabled then
        primaryContainer:SetWindowFilterEnabled(tabIndex, CHAT_CATEGORY_SYSTEM, enabled)
    end
end

--- Same gate ZOS/pChat use before showing a category on a tab (see SharedChatContainer:AddEventMessageToContainer).
--- @param chatContainer table
--- @param tabIndex integer
--- @param category integer
--- @return boolean
function LUIE_ChatOutput:IsChatCategoryEnabledOnTab(chatContainer, tabIndex, category)
    if not IsChatSystemAvailableForCurrentPlatform() then
        return true
    end
    if not chatContainer or not chatContainer.id or not tabIndex then
        return false
    end
    return IsChatContainerTabCategoryEnabled(chatContainer.id, tabIndex, category)
end

--- Same gates as PrintToChatWindows for one primary-container tab (including CMX chat-log skip).
--- @param chatOutputSettings LUIE_ChatOutputDefaults
--- @param tabIndex integer
--- @return boolean
function LUIE_ChatOutput:WouldDeliverToPrimaryTab(chatOutputSettings, tabIndex)
    if not chatOutputSettings or not chatOutputSettings.ChatTab or chatOutputSettings.ChatTab[tabIndex] ~= true then
        return false
    end
    local primaryContainer = self:GetPrimaryChatContainerForSettings()
    if not primaryContainer or not primaryContainer.windows or tabIndex < 1 or tabIndex > #primaryContainer.windows then
        return false
    end
    if LUIE.OtherAddonCompatability.isCombatMetricsEnabled then
        local CMX = CMX
        local db = CMX.db
        if not db then return false end
        local do_chat_logging = db.chatlog and db.chatlog.enabled
        if do_chat_logging and primaryContainer.GetTabName then
            if primaryContainer:GetTabName(tabIndex) == db.chatLog.name then
                return false
            end
        end
    end
    return self:IsChatCategoryEnabledOnTab(primaryContainer, tabIndex, CHAT_CATEGORY_SYSTEM)
end

--- True when at least one primary tab would receive per-tab delivery (see PrintToChatWindows).
--- @param chatOutputSettings LUIE_ChatOutputDefaults|nil
--- @return boolean
function LUIE_ChatOutput:HasDeliverableTab(chatOutputSettings)
    chatOutputSettings = chatOutputSettings or self:GetChatOutputSavedVars()
    if not chatOutputSettings or not chatOutputSettings.ChatTab then
        return false
    end
    local primaryContainer = self:GetPrimaryChatContainerForSettings()
    if not primaryContainer or not primaryContainer.windows then
        return false
    end
    for tabIndex = 1, #primaryContainer.windows do
        if self:WouldDeliverToPrimaryTab(chatOutputSettings, tabIndex) then
            return true
        end
    end
    return false
end

--- @param isSystem boolean|nil
function LUIE_ChatOutput:MaybeWarnNoDeliverableTab(isSystem)
    if self.noDeliverableTabWarningShown then
        return
    end
    local chatOutputSettings = self:GetChatOutputSavedVars()
    if not chatOutputSettings then
        return
    end
    if self:HasDeliverableTab(chatOutputSettings) then
        return
    end
    self.noDeliverableTabWarningShown = true
    self:AddSystemMessage(GetString(LUIE_STRING_LAM_CA_CHATOUTPUT_NO_DELIVERABLE_TAB))
end

--- @param formattedMessage string
--- @param isSystem boolean|nil
--- @param rawMessageText string|nil Passed to gamepad chat log for link extraction; defaults to formattedMessage.
function LUIE_ChatOutput:PrintToChatWindows(formattedMessage, isSystem, rawMessageText)
    local chatOutputSettings = self:GetChatOutputSavedVars()
    if not chatOutputSettings then
        self:AddSystemMessage(formattedMessage)
        return
    end

    local chatContainer = self:GetPrimaryChatContainerForSettings()
    if not chatContainer or not chatContainer.windows then
        return
    end

    for tabIndex = 1, #chatContainer.windows do
        if self:WouldDeliverToPrimaryTab(chatOutputSettings, tabIndex) then
            local chatWindow = chatContainer.windows[tabIndex]
            chatContainer:AddEventMessageToWindow(chatWindow, formattedMessage, CHAT_CATEGORY_SYSTEM)
        end
    end

    self:AddDeliveredLineToGamepadChatLog(formattedMessage, rawMessageText or formattedMessage)
end

--- Delivers via SharedChatContainer:AddEventMessageToWindow on tabs selected in ChatTab[] (see PrintToChatWindows).
function LUIE_ChatOutput:DeliverToSelectedChatTabs(messageText, isSystem)
    self:MaybeWarnNoDeliverableTab(isSystem)
    if self:ShouldUseExternalFormatting() then
        self:PrintToChatWindows(self:ApplyExternalSystemFormat(messageText), isSystem, messageText)
    elseif self.libChatMessage and not self:ShouldUseExternalFormatting() then
        self:PrintToChatWindowsViaLibChatMessageFormatter(messageText, isSystem)
    else
        self:PrintToChatWindows(self:FormatForDisplay(messageText), isSystem, messageText)
    end
end

--- @param messageText string
--- @param isSystem boolean|nil
function LUIE_ChatOutput:Print(messageText, isSystem)
    if not self:IsPlayerActivatedForChatDelivery() then
        self:EnqueuePendingPrint(messageText, isSystem)
        self:RegisterPlayerActivatedHandlerOnce()
        return
    end
    self:PrintWhenReady(messageText, isSystem)
end

--- When per-tab delivery has no target, fall back to CHAT_ROUTER so hooked flows (e.g. group invite) are never silent.
--- @param messageText string
function LUIE_ChatOutput:PrintAnnouncementOrSystemFallback(messageText)
    if not self:IsPlayerActivatedForChatDelivery() then
        self:Print(messageText, true)
        return
    end
    if self:UsesPrintToAllTabsMethod() then
        self:SyncChatTabRoutingForAllTabsMethod()
    end
    if self:HasDeliverableTab() then
        self:PrintWhenReady(messageText, true)
    else
        self:AddSystemMessage(self:FormatForDisplay(messageText))
    end
end

function LUIE_ChatOutput:WrapFormatter(eventKey, shouldSuppressFn)
    if not CHAT_ROUTER or not IsChatSystemAvailableForCurrentPlatform() then
        return
    end

    local registeredMessageFormatters = CHAT_ROUTER:GetRegisteredMessageFormatters()
    local registeredFormatter = registeredMessageFormatters[eventKey]
    if not registeredFormatter then
        return
    end

    local existingWrapper = self.formatterWrappers[eventKey]
    if existingWrapper and existingWrapper.outerFormatter == registeredFormatter then
        return
    end

    local innerFormatter = registeredFormatter

    local function outerFormatter(...)
        if shouldSuppressFn(...) then
            return nil
        end
        return innerFormatter(...)
    end

    self.formatterWrappers[eventKey] = { innerFormatter = innerFormatter, outerFormatter = outerFormatter }
    CHAT_ROUTER:RegisterMessageFormatter(eventKey, outerFormatter)
end

function LUIE_ChatOutput:OnDeferredPlayerActivated()
    if not self:GetPrimaryChatContainerForSettings() then
        return
    end
    self:SyncChatTabRoutingForAllTabsMethod()
    self:DisableLibChatMessageHistoryWhenPChatRestoreIsActive()
    if LUIE.chatOutputSettingsUI then
        LUIE.chatOutputSettingsUI:RefreshChatTabRoutingRows()
    end
end

function LUIE_ChatOutput:RegisterExternalChatInitializerCallbacksOnce()
    if self.externalChatInitializerCallbacksRegistered then
        return
    end
    if not IsPChatAvailable() and not IsRChatAvailable() then
        return
    end
    self.externalChatInitializerCallbacksRegistered = true

    if IsPChatAvailable() then
        CALLBACK_MANAGER:RegisterCallback("pChat_Initialized_AddSystemMessage", function ()
            ChatOutput:ApplyLibChatMessageTimePrefixSettings()
            ChatOutput:DisableLibChatMessageHistoryWhenPChatRestoreIsActive()
        end)
    end
end

function LUIE_ChatOutput:OnChatSystemPlayerActivatedDeferred()
    zo_callLater(function ()
                     ChatOutput:OnDeferredPlayerActivated()
                     ChatOutput:FlushPendingPrints()
                 end, 0)
end

function LUIE_ChatOutput:RegisterPlayerActivatedHandlerOnce()
    if self.playerActivatedHandlerRegistered then
        return
    end
    self.playerActivatedHandlerRegistered = true
    eventManager:RegisterForEvent(ACTIVATION_HANDLER_NAME, EVENT_PLAYER_ACTIVATED, function ()
        ChatOutput:OnChatSystemPlayerActivatedDeferred()
    end)
end

function LUIE_ChatOutput:InitializePrintRouting()
    if LibChatMessage then
        self.libChatMessage = LibChatMessage("LuiExtended", "LUIE")
        self:ApplyLibChatMessageTimePrefixSettings()
        self:DisableLibChatMessageHistoryWhenPChatRestoreIsActive()
    else
        self.libChatMessage = nil
    end

    self:InitializeGamepadChatOutput()
    self:RegisterPlayerActivatedHandlerOnce()
    self:RegisterExternalChatInitializerCallbacksOnce()
    if self:IsPlayerActivatedForChatDelivery() then
        self:OnChatSystemPlayerActivatedDeferred()
    end
end

--- Registers settings UI singleton after ChatOutput exists (called from ChatOutputSettingsUI).
function LUIE.RegisterChatOutputSettingsUI(settingsUi)
    LUIE.chatOutputSettingsUI = settingsUi
end
