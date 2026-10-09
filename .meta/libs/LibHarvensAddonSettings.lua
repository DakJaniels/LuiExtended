---@meta LibHarvensAddonSettings
-- Optional dependency. LibHarvensAddonSettings 2.2.0 (AddOnVersion 20200).
-- The runtime `version` field in Main.lua is 20109.
-- The settings scene name is "LibHarvensAddonSettingsScene".

---@alias LHAS_SettingType 1|2|3|4|5|6|7|8|9|10

---@class LHAS_AddonOptions
---@field allowDefaults boolean|nil
---@field defaultsFunction function|nil
---@field allowRefresh boolean|nil When true, a callback manager refreshes other rows after a value changes.

---@class LHAS_SettingParams
---@field type LHAS_SettingType
---@field label string|nil
---@field tooltip string|fun(self: LHAS_AddonSettingsControl, control: any): function|nil|nil
---@field getFunction function|nil
---@field setFunction function|nil
---@field default any
---@field disable boolean|fun(): boolean|nil
---@field ignoreDefault boolean|nil
---@field min number|nil
---@field max number|nil
---@field step number|nil
---@field format string|nil Slider format. Defaults to `"%f"`.
---@field unit string|nil
---@field items { name: string, data: any }[]|nil Dropdown rows. `ResetToDefaults` matches `items[i].name` to `default`.
---@field clickHandler function|nil
---@field buttonText string|nil
---@field maxChars integer|nil
---@field textType integer|nil
---@field texture string|nil
---@field atlasStart integer|nil
---@field atlasEnd integer|nil
---@field atlasIndices integer[]|nil
---@field atlasSizeX integer|nil
---@field atlasSizeY integer|nil

---@class LHAS_AddonSettingsControl
---@field type LHAS_SettingType
---@field control any
---@field default any
---@field disable boolean|fun(): boolean|nil
---@field getFunction function|nil
---@field setFunction function|nil
---@field items { name: string, data: any }[]|nil
local LHAS_AddonSettingsControl = {}

---@param params LHAS_SettingParams
function LHAS_AddonSettingsControl:SetupControl(params) end

---@return boolean
function LHAS_AddonSettingsControl:IsDisabled() end

---@param state boolean
function LHAS_AddonSettingsControl:SetEnabled(state) end

function LHAS_AddonSettingsControl:ValueChanged(...) end

function LHAS_AddonSettingsControl:SetValue(...) end

function LHAS_AddonSettingsControl:ResetToDefaults() end

---@return number
function LHAS_AddonSettingsControl:GetHeight() end

---@class LHAS_AddonSettings
---@field name string
---@field selected boolean
---@field allowDefaults boolean|nil
---@field defaultsFunction function|nil
---@field settings LHAS_AddonSettingsControl[]
local LHAS_AddonSettings = {}

---@param name string
---@param options LHAS_AddonOptions|nil
---@return LHAS_AddonSettings
function LHAS_AddonSettings:New(name, options) end

---@param params LHAS_SettingParams
---@param index integer|nil Nil or below 1 appends.
---@return LHAS_AddonSettingsControl setting
---@return integer index
function LHAS_AddonSettings:InsertSetting(params, index) end

---@param params LHAS_SettingParams
---@param index integer|nil
---@param playAnimation boolean|nil PC container animation. Ignored on console.
---@return LHAS_AddonSettingsControl setting
---@return integer index
function LHAS_AddonSettings:AddSetting(params, index, playAnimation) end

---@param params LHAS_SettingParams[]
---@param index integer|nil
---@param playAnimation boolean|nil
---@return LHAS_AddonSettingsControl[] settings
---@return integer[] indexes
function LHAS_AddonSettings:AddSettings(params, index, playAnimation) end

---@param index integer
---@param count integer|nil Defaults to 1.
---@param playAnimation boolean|nil
---@return LHAS_AddonSettingsControl[]
function LHAS_AddonSettings:RemoveSettings(index, count, playAnimation) end

---@param playAnimation boolean|nil
---@return LHAS_AddonSettingsControl[]
function LHAS_AddonSettings:RemoveAllSettings(playAnimation) end

--- `areParams` true compares a params table by building a temporary control.
---@param setting LHAS_AddonSettingsControl|LHAS_SettingParams
---@param areParams boolean|nil
---@return integer|nil
function LHAS_AddonSettings:GetIndexOf(setting, areParams) end

function LHAS_AddonSettings:Select() end

function LHAS_AddonSettings:ResetToDefaults() end

function LHAS_AddonSettings:Clear() end

---@class LibHarvensAddonSettings
---@field version 20109
---@field addons LHAS_AddonSettings[]
---@field AddonSettings LHAS_AddonSettings
---@field AddonSettingsControl LHAS_AddonSettingsControl
LibHarvensAddonSettings = {}

---@type 1
LibHarvensAddonSettings.ST_CHECKBOX = 1
---@type 2
LibHarvensAddonSettings.ST_SLIDER = 2
---@type 3
LibHarvensAddonSettings.ST_EDIT = 3
---@type 4
LibHarvensAddonSettings.ST_DROPDOWN = 4
---@type 5
LibHarvensAddonSettings.ST_COLOR = 5
---@type 6
LibHarvensAddonSettings.ST_BUTTON = 6
---@type 7
LibHarvensAddonSettings.ST_LABEL = 7
---@type 8
LibHarvensAddonSettings.ST_SECTION = 8
---@type 9
LibHarvensAddonSettings.ST_ICONPICKER = 9
---@type 10
LibHarvensAddonSettings.ST_ATLASICONPICKER = 10

--- Returns the existing panel when `name` is already registered. Color markup is stripped.
---@param name string
---@param options LHAS_AddonOptions|nil
---@return LHAS_AddonSettings
function LibHarvensAddonSettings:AddAddon(name, options) end

function LibHarvensAddonSettings:Initialize() end

function LibHarvensAddonSettings:RefreshAddonSettings() end

function LibHarvensAddonSettings:SelectFirstAddon() end

--- Keyboard only.
function LibHarvensAddonSettings:DetachContainer() end

--- Keyboard only.
---@param control any
function LibHarvensAddonSettings:AttachControlToContainer(control) end

--- Keyboard only.
---@param control any
function LibHarvensAddonSettings:AttachContainerToControl(control) end

---@type LibHarvensAddonSettings|nil
LibHarvensAddonSettings = LibHarvensAddonSettings
