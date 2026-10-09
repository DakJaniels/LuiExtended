---@meta LibMediaProvider
-- Optional dependency. LibMediaProvider 1.1 r39 (AddOnVersion 39).
-- The global is the external API table from `InitializeAPI`, not the internal object.
-- Colon calls match the wrapper (`self` is ignored).

---@class LMP_MediaType
---@field BACKGROUND "background"
---@field BORDER "border"
---@field FONT "font"
---@field STATUSBAR "statusbar"
---@field SOUND "sound"

---@alias LMP_MediaTypeName "background"|"border"|"font"|"statusbar"|"sound"
--- Fonts and textures are paths. Sounds are `SOUNDS` ids. Empty string data is stored as-is; `Fetch` returns nil for `""`.
---@alias LMP_MediaData string|integer

---@class LibMediaProvider
---@field MediaType LMP_MediaType
--- Empty tables kept for old callers. Registered media is not stored here.
---@field MediaTable table<LMP_MediaTypeName, table>
LibMediaProvider = {}

--- Returns false when `key` is already registered. Does not overwrite.
---@param mediatype string Lowercased before lookup.
---@param key string
---@param data LMP_MediaData
---@return boolean
function LibMediaProvider:Register(mediatype, key, data) end

--- On console, blacklisted CJK fonts return `"$(MEDIUM_FONT)"`.
--- Missing keys fall back to the default key for that type.
---@param mediatype LMP_MediaTypeName|string
---@param key string
---@return LMP_MediaData|nil
function LibMediaProvider:Fetch(mediatype, key) end

--- On console, a blacklisted font key is false.
--- `key` nil checks whether the media type exists.
---@param mediatype LMP_MediaTypeName|string
---@param key string|nil
---@return boolean
function LibMediaProvider:IsValid(mediatype, key) end

--- Shared copy of the media table for this type, including the real font filename of console-blacklisted fonts.
---@param mediatype LMP_MediaTypeName|string
---@return table<string, LMP_MediaData>|nil
function LibMediaProvider:HashTable(mediatype) end

--- Sorted media keys. Nil when the type has no table.
---@param mediatype LMP_MediaTypeName|string
---@return string[]|nil
function LibMediaProvider:List(mediatype) end

---@param mediatype LMP_MediaTypeName|string
---@return string|nil
function LibMediaProvider:GetDefault(mediatype) end

--- Sets the default only when the type has media for `key` and no default is set yet.
---@param mediatype LMP_MediaTypeName|string
---@param key string
---@return boolean
function LibMediaProvider:SetDefault(mediatype, key) end

---@type LibMediaProvider|nil
LibMediaProvider = LibMediaProvider
