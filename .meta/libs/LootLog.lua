---@meta LootLog
-- Optional dependency. LootLog 4.10.4.3 (AddOnVersion 410043).
-- Context menu callbacks return a label string id and a click function, or nothing to hide the row.

---@alias LootLog_ContextMenuCallback fun(data: LootLog_HistoryRow): integer|string|nil, fun()|nil

---@class LootLog_HistoryRow
---@field itemLink string|nil
---@field contact string|nil

---@class LootLog
---@field name "LootLog"
---@field title string
---@field url string
---@field defaults table
---@field vars table Saved settings, including `historyHours`.
---@field history table<integer, table>
---@field notable { whitelist: table<integer, boolean>, blacklist: table<integer, boolean>, traits: table<integer, boolean> }
LootLog = {}

---@param func LootLog_ContextMenuCallback
function LootLog.RegisterContextMenuItem(func) end

---@param noActiveCheck boolean|nil
function LootLog.RefreshHistory(noActiveCheck) end

function LootLog.InitializeHistory() end

function LootLog.LazyInitializeHistory() end

--- 0 not collectible, 1 uncollected, 2 collected.
---@param itemLink string
---@return integer
function LootLog.GetItemLinkCollectionStatus(itemLink) end

---@param itemLink string
---@param itemId integer|nil
---@return boolean
function LootLog.IsItemNotable(itemLink, itemId) end

---@param itemLink string
---@param checkInventory boolean|nil
---@return boolean
function LootLog.IsItemLinkUncollected(itemLink, checkInventory) end

---@param itemLink string
---@return boolean
function LootLog.IsItemLinkTradeable(itemLink) end

---@param itemLink string
---@param quantity integer
---@param notable boolean|nil
---@param receivedBy string|nil Nil logs the item as personal loot.
function LootLog.LogItem(itemLink, quantity, notable, receivedBy) end

---@param character string
---@return string
function LootLog.GetAccountName(character) end

--- A string is an item or collectible link. Any other value is treated as an antiquity id.
---@param link string|integer
---@return string
function LootLog.GetLinkName(link) end

--- A string is an item or collectible link. Any other value uses `GetAntiquityLeadIcon`.
---@param link string|integer
---@return string
function LootLog.GetLinkIcon(link) end

function LootLog.ExpireOldData() end

function LootLog.ExpireAllData() end

---@param text string
function LootLog.Msg(text) end

function LootLog.OpenSettingsPanel() end

---@type LootLog|nil
LootLog = LootLog
