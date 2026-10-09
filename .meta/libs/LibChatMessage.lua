---@meta LibChatMessage
-- Optional dependency. LibChatMessage 1.2.3 (AddOnVersion 120).
-- `LibChatMessage:Create(longTag, shortTag)`, `LibChatMessage.Create(...)`, and `LibChatMessage(...)` return a proxy.
-- Print methods are on the proxy. Settings methods are on the library.

---@alias LCM_TagPrefixMode 1|2|3
---@alias LCM_TimeFormat "[%X]"|"[%I:%M:%S %p]"|"[%T]"|string

---@class LCM_ChatProxy
---@field longTag string
---@field shortTag string
---@field enabled boolean
local LCM_ChatProxy = {}

--- Color applies to the next printed message, then resets.
--- `ZO_ColorDef` is converted with `ToHex`. A string is `"RRGGBB"`.
---@param color string|ZO_ColorDef
---@return LCM_ChatProxy
function LCM_ChatProxy:SetTagColor(color) end

---@param message string
function LCM_ChatProxy:Print(message) end

---@param formatString string
---@param ... any
function LCM_ChatProxy:Printf(formatString, ...) end

---@param enabled boolean
function LCM_ChatProxy:SetEnabled(enabled) end

---@class LibChatMessage
---@overload fun(longTag: string, shortTag: string): LCM_ChatProxy
---@field TIME_FORMATS LCM_TimeFormat[] `"[%X]"`, `"[%I:%M:%S %p]"`, `"[%T]"`.
LibChatMessage = {}

---@type 1
LibChatMessage.TAG_PREFIX_OFF = 1
---@type 2
LibChatMessage.TAG_PREFIX_LONG = 2
---@type 3
LibChatMessage.TAG_PREFIX_SHORT = 3

---@param longTag string
---@param shortTag string
---@return LCM_ChatProxy
function LibChatMessage.Create(longTag, shortTag) end

--- `optionalReformatter` defaults to a `ZO_LinkHandler_CreateLink` wrapper.
--- Also marks `linkType` in `ZO_VALID_LINK_TYPES_CHAT`.
---@param linkType string
---@param optionalReformatter? fun(linkStyle: number, linkType: string, data: string, displayText: string): string
function LibChatMessage:RegisterCustomChatLink(linkType, optionalReformatter) end

--- Keyboard only. Returns immediately on console.
function LibChatMessage:ClearChat() end

function LibChatMessage:ClearHistory() end

---@return table
function LibChatMessage:GetHistory() end

---@param enabled boolean
function LibChatMessage:SetTimePrefixEnabled(enabled) end

---@return boolean
function LibChatMessage:IsTimePrefixEnabled() end

---@param enabled boolean
function LibChatMessage:SetRegularChatMessageTimePrefixEnabled(enabled) end

---@return boolean
function LibChatMessage:IsRegularChatMessageTimePrefixEnabled() end

--- `format` is an `os.date` pattern. Preset labels `"auto"`, `"12h"`, and `"24h"` are accepted by the slash command, not by this setter.
---@param format LCM_TimeFormat
function LibChatMessage:SetTimePrefixFormat(format) end

---@return string
function LibChatMessage:GetTimePrefixFormat() end

--- Off still stores the long tag when history is enabled.
---@param mode LCM_TagPrefixMode
function LibChatMessage:SetTagPrefixMode(mode) end

---@return LCM_TagPrefixMode
function LibChatMessage:GetTagPrefixMode() end

---@deprecated Use `SetTagPrefixMode`.
--- `true` selects `TAG_PREFIX_SHORT`. `false` selects `TAG_PREFIX_LONG`. It cannot select off.
---@param enabled boolean
function LibChatMessage:SetShortTagPrefixEnabled(enabled) end

---@deprecated Use `GetTagPrefixMode`.
---@return boolean
function LibChatMessage:IsShortTagPrefixEnabled() end

--- Takes effect on the next UI load.
---@param enabled boolean
function LibChatMessage:SetChatHistoryEnabled(enabled) end

---@return boolean
function LibChatMessage:IsChatHistoryEnabled() end

---@return boolean
function LibChatMessage:IsChatHistoryActive() end

---@param maxAge number Seconds.
function LibChatMessage:SetChatHistoryMaxAge(maxAge) end

---@return number
function LibChatMessage:GetChatHistoryMaxAge() end


