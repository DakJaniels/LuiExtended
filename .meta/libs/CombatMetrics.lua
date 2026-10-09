---@meta CombatMetrics
-- Optional dependency. CombatMetrics 1.7.8 (AddOnVersion 10708).
-- The global is `CMX`.

---@class CMX_ChatLog
---@field enabled boolean
---@field name string Default `"CMX Combat Log"`.
---@field damageOut boolean
---@field healingOut boolean
---@field damageIn boolean
---@field healingIn boolean

---@class CMX_Database
---@field accountwide boolean|nil
---@field chatLog CMX_ChatLog

---@class CMX
---@field name "CombatMetrics"
---@field version "1.7.8"
---@field db CMX_Database|nil Saved variables. Nil until the addon finishes loading.
CMX = {}

