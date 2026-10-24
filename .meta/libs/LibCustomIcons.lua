---@meta LibCustomIcons
-- Optional dependency. LibCustomIcons 2026-10-19 (AddOnVersion 20261019).
-- Dot calls. After the icon files load, `nil.lua` nils `GetStaticTable` and `GetAnimatedTable`,
-- then replaces the global with a read-only proxy. Assigning a field does not write.
-- The proxy prints "attempt to update read-only table" unless Torchbug or Zgoo is loaded.
-- Keys are the exact `@account` string from `GetUnitDisplayName`. Lookup is not lowercased.
-- `icons/animated.lua` also stores a few keys with no `@`.
-- Slash commands `/lci` and `/LibCustomIcons`: `version`, `donate`, `integrity`.

--- `{ texturePath, columns, rows, fps }`. `fps` may be fractional.
--- A compiled row longer than 4, not returned today, would be
--- `texturePath, columns, rows, fps, left, right, top, bottom, width, height`.
---@alias LCI_AnimatedIcon { [1]: string, [2]: number, [3]: number, [4]: number }

--- `{ texturePath, left, right, top, bottom, width, height }` in pixels.
--- `GetStatic` divides the edges by `width` and `height`.
---@alias LCI_CompiledStaticIcon { [1]: string, [2]: number, [3]: number, [4]: number, [5]: number, [6]: number, [7]: number }

--- A path, or a compiled cell inside a shared texture.
---@alias LCI_StaticIcon string|LCI_CompiledStaticIcon

---@class LibCustomIcons
---@field name "LibCustomIcons"
---@field version string `2026-10-19` on this install.
---@field author string
LibCustomIcons = {}

--- Folder name for new icon files: `"misc"` plus `(os.date("%Y") - 2018)`.
--- `2026` loads as `"misc8"`.
---@return string folderName
function LibCustomIcons.GetCurrentFolder() end

--- True when this account has a static icon.
---@param username string `@account` name, for example `"@m00nyONE"`.
---@return boolean hasStatic
function LibCustomIcons.HasStatic(username) end

--- True when this account has an animated icon.
---@param username string `@account` name, for example `"@m00nyONE"`.
---@return boolean hasAnimated
function LibCustomIcons.HasAnimated(username) end

--- True when this account has a static icon or an animated icon.
---@param username string `@account` name, for example `"@m00nyONE"`.
---@return boolean hasIcon
function LibCustomIcons.HasIcon(username) end

--- Path and normalized texture coords for `SetTexture` / `SetTextureCoords`.
--- A string entry returns `path, 0, 1, 0, 1`.
--- A compiled table returns `texture, left/width, right/width, top/height, bottom/height`.
--- A missing key returns `nil, 0, 1, 0, 1`.
---@param username string `@account` name, for example `"@m00nyONE"`.
---@return string|nil texturePath
---@return number left
---@return number right
---@return number top
---@return number bottom
function LibCustomIcons.GetStatic(username) end

--- The stored animated entry, or nil.
--- This is one table, `{ texturePath, columns, rows, fps }`.
--- The eight-value unpack in `api.lua` is commented out and is not what callers receive.
---@param username string `@account` name, for example `"@m00nyONE"`.
---@return LCI_AnimatedIcon|nil animatedIcon
function LibCustomIcons.GetAnimated(username) end

--- One cached `ZO_DeepTableCopy` of the static table.
--- Editing the copy does not change `GetStatic`. Later calls return that same copy.
--- Values are path strings, or compiled tables when an entry was stored that way.
---@return table<string, LCI_StaticIcon> staticIcons `@account` to icon.
function LibCustomIcons.GetAllStatic() end

--- One cached `ZO_DeepTableCopy` of the animated table.
--- Editing the copy does not change `GetAnimated`. Later calls return that same copy.
---@return table<string, LCI_AnimatedIcon> animatedIcons `@account` to `{ texturePath, columns, rows, fps }`.
function LibCustomIcons.GetAllAnimated() end

--- Number of static entries. Computed on the first call that finds at least one.
--- A count of 0 is the "not yet computed" sentinel, so an empty table is recounted.
---@return number count
function LibCustomIcons.GetStaticCount() end

--- Number of animated entries. Same cache rule as `GetStaticCount`.
---@return number count
function LibCustomIcons.GetAnimatedCount() end

--- `GetStaticCount() + GetAnimatedCount()`.
--- An account that has both a static icon and an animated icon is counted twice.
---@return number count
function LibCustomIcons.GetIconCount() end

--- Opens the mail window with the author and a donation subject filled in.
function LibCustomIcons.Donate() end

--- Asks for confirmation, then checks icon textures and prints a report.
--- Registered as the LAM "Check" button and as `/lci integrity`.
function LibCustomIcons.IntegrityCheck() end

--- Registers the LibAddonMenu panel on `EVENT_ADD_ON_LOADED`, then sets this field to nil.
function LibCustomIcons.BuildMenu() end

--- Internal static table. Icon files write `s["@account"] = path` or a compiled table during load.
--- `nil.lua` sets this field to nil. It is not part of the consumer API after load.
---@return table<string, LCI_StaticIcon>|nil
function LibCustomIcons.GetStaticTable() end

--- Internal animated table. Icon files write `a["@account"] = { path, columns, rows, fps }` during load.
--- `nil.lua` sets this field to nil. It is not part of the consumer API after load.
---@return table<string, LCI_AnimatedIcon>|nil
function LibCustomIcons.GetAnimatedTable() end
