---@meta WritCreater
-- Optional dependency. DolgubonsLazyWritCreator 4.0.5.7.8 (AddOnVersion 4057).
-- The global is `WritCreater`.

---@class WritCreater_Settings
---@field useCharacterSettings boolean|nil Read from the character saved vars before this table is chosen.
---@field suppressQuestAnnouncements boolean|nil
--- Item link keys. A false value means that link is eligible for the skip check.
---@field skipItemQuests table<string, boolean>|nil

---@class WritCreater
---@field savedVars table|nil
---@field savedVarsAccountWide table|nil
WritCreater = {}

--- Journal indexes keyed by crafting type. The second return is true when a writ was found.
---@return table<integer, integer> writs
---@return boolean anyFound
function WritCreater.writSearch() end

--- False when saved vars are not ready.
--- Character settings when `savedVars.useCharacterSettings` is set, otherwise the account-wide profile.
---@return WritCreater_Settings|false
function WritCreater:GetSettings() end

---@type WritCreater|nil
WritCreater = WritCreater
