---@meta LibConsoleDialogs
-- Optional dependency. Not present under live\AddOns.
-- Typed from votans_addons Addons/LibConsoleDialogs/Console/Main.lua.
-- `Create` returns a LibHarvensAddonSettings panel subclass (`dialogSettings`).

---@class LCD_Dialog: LHAS_AddonSettings
---@field headerData { titleText: string }
local LCD_Dialog = {}

--- Same as `Select`.
function LCD_Dialog:Show() end

---@class LibConsoleDialogs
---@field dialogCallStack LCD_Dialog[]
LibConsoleDialogs = {}

--- `allowDefaults` is false. `allowRefresh` is true.
---@param title string
---@return LCD_Dialog
function LibConsoleDialogs:Create(title) end

--- `sceneOrName` is a scene name or a scene object.
--- `buttonInfo` is stored and later read by the scene state callback.
---@param sceneOrName string|any
---@param buttonInfo table
function LibConsoleDialogs:RegisterKeybind(sceneOrName, buttonInfo) end

--- Hides the current scene when the LibHarvens settings scene is showing a selected dialog.
function LibConsoleDialogs:Close() end


