---@meta LibCustomNames
-- Optional dependency. LibCustomNames 2026-10-19 (AddOnVersion 20261019).
-- Dot calls. After the name files load, `nil.lua` nils `GetNamesTable`,
-- then replaces the global with a read-only proxy. Assigning a field does not write.
-- The proxy prints "attempt to update read-only table" unless Torchbug or Zgoo is loaded.
-- Keys are the exact `@account` string from `GetUnitDisplayName`. Lookup is not lowercased.
-- The lowercased lookup in `api.lua` is commented out.
-- Slash commands `/lcn` and `/LibCustomNames`: `version`, `donate`.

--- `{ uncoloredName, coloredName }`.
--- Colored text uses `|cRRGGBB` and `|r`. A missing colored string falls back to the uncolored name.
---@alias LCN_NameEntry { [1]: string, [2]: string|nil }

---@class LibCustomNames
---@field name "LibCustomNames"
---@field version string `2026-10-19` on this install.
---@field author string
LibCustomNames = {}

--- True when this account has an entry. Exact-key check.
---@param username string `@account` name, for example `"@m00nyONE"`.
---@return boolean hasCustomName
function LibCustomNames.HasCustomName(username) end

--- Custom name for this account, or nil when the account has no entry.
--- `colored == false` returns the uncolored name (`entry[1]`).
--- Any other value, including nil, returns the colored name (`entry[2]`), or the uncolored name when the colored string is missing.
---@param username string `@account` name, for example `"@m00nyONE"`.
---@param colored boolean|nil Defaults to colored. Pass `false` for the plain name.
---@return string|nil customName
function LibCustomNames.Get(username, colored) end

--- `Get(username, true)`.
---@param username string `@account` name, for example `"@m00nyONE"`.
---@return string|nil customName
function LibCustomNames.GetColored(username) end

--- `Get(username, false)`.
---@param username string `@account` name, for example `"@m00nyONE"`.
---@return string|nil customName
function LibCustomNames.GetUncolored(username) end

--- One cached `ZO_DeepTableCopy` of the names table.
--- Editing the copy does not change `Get`. Later calls return that same copy.
---@return table<string, LCN_NameEntry> names `@account` to `{ uncoloredName, coloredName }`.
function LibCustomNames.GetAll() end

--- Number of name entries. Computed on the first call that finds at least one.
--- A count of 0 is the "not yet computed" sentinel, so an empty table is recounted.
---@return number count
function LibCustomNames.GetCustomNameCount() end

--- Opens the mail window with the author and a donation subject filled in.
function LibCustomNames.Donate() end

--- `menu.lua` defines an empty `BuildMenu`.
--- `PC/menu.lua` replaces it, registers the LibAddonMenu panel on `EVENT_ADD_ON_LOADED`, then sets this field to nil.
function LibCustomNames.BuildMenu() end

--- Internal names table. Name files write `n["@account"] = { uncolored, colored }` during load.
--- `nil.lua` sets this field to nil. It is not part of the consumer API after load.
---@return table<string, LCN_NameEntry>|nil
function LibCustomNames.GetNamesTable() end
