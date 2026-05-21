---@meta
-- Optional dependency (LibLazyCrafting.lua). Types for LuiExtended IDE checks only.

--- @class LibLazyCrafting
--- @field name string
--- @field version number
--- @field isCurrentlyCrafting [boolean, string, string] [1] active, [2] kind e.g. "enchanting" / "smithing", [3] reserved
--- @field craftingQueue table<string, table<integer, LibLazyCraftingRequest[]>>
--- @field craftInteractionTables table

--- @class LibLazyCraftingRequest
--- @field type? string e.g. "deconstruct"

--- @type LibLazyCrafting|nil
LibLazyCrafting = LibLazyCrafting
