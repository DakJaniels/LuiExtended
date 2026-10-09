---@meta LibDebugLogger
-- Optional dependency. LibDebugLogger 2.6.2 (AddOnVersion 307). API version 2.
-- `LibDebugLogger:Create(tag)`, `LibDebugLogger.Create(tag)`, and `LibDebugLogger(tag)` all return a logger.
-- Log methods live on that logger. Library methods live on `LibDebugLogger`.

---@alias LDL_LogLevel "V"|"D"|"I"|"W"|"E"

--- One stored row. Indexes match `ENTRY_*_INDEX`.
---@alias LDL_LogEntry {[1]: number, [2]: string, [3]: integer, [4]: LDL_LogLevel, [5]: string, [6]: string, [7]: string|nil, [8]: integer|nil}

---@class LDL_Logger
---@field enabled boolean
---@field tag string
local LDL_Logger = {}

--- New logger whose tag is `parentTag/tag`.
---@param tag string
---@return LDL_Logger
function LDL_Logger:Create(tag) end

--- Empty string or nil restores the original tag.
---@param tag string|nil
function LDL_Logger:SetSubTag(tag) end

---@param enabled boolean
function LDL_Logger:SetEnabled(enabled) end

--- Nil clears the override.
---@param level LDL_LogLevel|nil
function LDL_Logger:SetMinLevelOverride(level) end

--- Nil clears the override.
---@param enabled boolean|nil
function LDL_Logger:SetLogTracesOverride(enabled) end

--- Values are passed through `tostring`, or `string.format` when the first value contains a formatting token.
---@param level LDL_LogLevel
---@param ... any
function LDL_Logger:Log(level, ...) end

function LDL_Logger:Verbose(...) end

function LDL_Logger:Debug(...) end

function LDL_Logger:Info(...) end

function LDL_Logger:Warn(...) end

function LDL_Logger:Error(...) end

---@class LDL_CallbackName
---@field LOG_CLEARED "LogCleared"
---@field LOG_PRUNED "LogPruned"
---@field LOG_ADDED "LogAdded"

---@class LibDebugLogger
---@overload fun(tag: string): LDL_Logger
---@field callback LDL_CallbackName
---@field DEFAULT_SETTINGS table
---@field TAG_INGAME "UI"
---@field LOG_LEVELS LDL_LogLevel[]
---@field LOG_LEVEL_TO_STRING table<LDL_LogLevel, string>
---@field STR_TO_LOG_LEVEL table<string, LDL_LogLevel>
LibDebugLogger = {}

---@type "V"
LibDebugLogger.LOG_LEVEL_VERBOSE = "V"
---@type "D"
LibDebugLogger.LOG_LEVEL_DEBUG = "D"
---@type "I"
LibDebugLogger.LOG_LEVEL_INFO = "I"
---@type "W"
LibDebugLogger.LOG_LEVEL_WARNING = "W"
---@type "E"
LibDebugLogger.LOG_LEVEL_ERROR = "E"

--- Same strings as `callback.LOG_*`. Kept for older callers.
---@type "LogCleared"
LibDebugLogger.CALLBACK_LOG_CLEARED = "LogCleared"
---@type "LogPruned"
LibDebugLogger.CALLBACK_LOG_PRUNED = "LogPruned"
---@type "LogAdded"
LibDebugLogger.CALLBACK_LOG_ADDED = "LogAdded"

---@type 1
LibDebugLogger.ENTRY_TIME_INDEX = 1
---@type 2
LibDebugLogger.ENTRY_FORMATTED_TIME_INDEX = 2
---@type 3
LibDebugLogger.ENTRY_OCCURENCES_INDEX = 3
---@type 4
LibDebugLogger.ENTRY_LEVEL_INDEX = 4
---@type 5
LibDebugLogger.ENTRY_TAG_INDEX = 5
---@type 6
LibDebugLogger.ENTRY_MESSAGE_INDEX = 6
---@type 7
LibDebugLogger.ENTRY_STACK_INDEX = 7
---@type 8
LibDebugLogger.ENTRY_ERROR_CODE_INDEX = 8

--- Client start, milliseconds.
---@type number
LibDebugLogger.SESSION_START_TIME = 0

--- Approximate UI load time, milliseconds. This is when LibDebugLogger itself loaded.
---@type number
LibDebugLogger.UI_LOAD_START_TIME = 0

--- `LogCleared` receives the empty log table.
--- `LogPruned` receives the first kept index of the old log.
--- `LogAdded` receives the `LDL_LogEntry` and `wasDuplicate`.
--- `RegisterCallback` uses the same arguments as `CALLBACK_MANAGER:RegisterCallback`.
---@return integer
function LibDebugLogger:GetAPIVersion() end

---@deprecated Use `SESSION_START_TIME`.
---@return number
function LibDebugLogger:GetSessionStartTime() end

---@deprecated Use `UI_LOAD_START_TIME`.
---@return number
function LibDebugLogger:GetUiLoadStartTime() end

--- Dot call `LibDebugLogger.Create(tag)` uses that argument as the tag.
--- Colon call `LibDebugLogger:Create(tag)` passes the library as `self` and uses `tag`.
--- `LibDebugLogger(tag)` is the same as the colon call.
---@overload fun(self: LibDebugLogger, tag: string): LDL_Logger
---@param tag string
---@return LDL_Logger
function LibDebugLogger.Create(tag) end

---@return boolean
function LibDebugLogger:IsTraceLoggingEnabled() end

---@param enabled boolean
function LibDebugLogger:SetTraceLoggingEnabled(enabled) end

---@return LDL_LogLevel
function LibDebugLogger:GetMinLogLevel() end

---@param level LDL_LogLevel
function LibDebugLogger:SetMinLogLevel(level) end

---@return LDL_LogEntry[]
function LibDebugLogger:GetLog() end

--- Flips whether a failed `string.format` is appended to the logged message.
---@return boolean
function LibDebugLogger:ToggleFormattingErrors() end

--- Replaces the log table and fires `LogCleared`.
---@return LDL_LogEntry[]
function LibDebugLogger:ClearLog() end

--- Hides `d()`, `df()`, and `CHAT_ROUTER:AddDebugMessage` from the chat window.
---@param enabled boolean
function LibDebugLogger:SetBlockChatOutputEnabled(enabled) end

---@return boolean
function LibDebugLogger:IsBlockChatOutputEnabled() end

--- A table is concatenated. Any other value is returned as-is.
---@param input string|string[]
---@return string
function LibDebugLogger.CombineSplitStringIfNeeded(input) end

---@param callbackName string
---@param callback function
function LibDebugLogger:RegisterCallback(callbackName, callback) end

