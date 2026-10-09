---@meta pChat
-- Optional dependency. pChat 10.0.7.6 (AddOnVersion 10007060). PC only.
-- `pChat.formatSysMessage` and the global `pChat_FormatSysMessage` are the same function.

---@class pChat_Database
---@field showTimestamp boolean
---@field timestampFormat string
---@field timestampcolorislcol boolean
---@field colours { timestamp: string }
---@field useSystemMessageChatHandler boolean
---@field restoreOnReloadUI boolean
---@field restoreOnLogOut boolean
---@field restoreOnAFK boolean
---@field restoreOnQuit boolean

---@class pChat
---@field db pChat_Database|nil Saved variables. Nil until the addon finishes loading.
pChat = {}

--- Formats a system-channel status message, including the timestamp when `db.showTimestamp` is set.
---@param statusMessage string
---@return string
function pChat.formatSysMessage(statusMessage) end

---@param statusMessage string
---@return string
function pChat_FormatSysMessage(statusMessage) end

---@type pChat|nil
pChat = pChat
