---@meta LuiExtended option select dialog
-- Types for console Settings_API option list (LUIE_OptionSelect).
-- Row fields match ZO_SharedGamepadEntry_OnInitialized (control.label, control.icon, control.statusIndicator)
-- and the fields SetupOptionSelectDialog writes onto ZO_GamepadEntryData.
-- Dialog fields match ZO_Dialogs_ShowDialog (dialog.data, dialog.info) and
-- ZO_GenericParametricListGamepadDialogTemplate_OnInitialized (dialog.entryList, dialog.setupFunc).
-- entryList.dataIndexToControl is assigned in ZO_ParametricScrollList.

---@class LUIE_OptionSelectItem
---@field name string
---@field data any

---@class LUIE_OptionSelectRequest
---@field title string|nil
---@field items LUIE_OptionSelectItem[]|fun(): LUIE_OptionSelectItem[]
---@field getFunction fun(): any
---@field setFunction fun(combobox: any, value: any, item: LUIE_OptionSelectItem)
---@field kind "face"|"style"|"texture"|nil

--- ZO_MultiIcon is a Texture. SetColor is TextureControl:SetColor, not Control:SetColor.
---@class LUIE_OptionSelectMultiIcon : TextureControl
local LUIE_OptionSelectMultiIcon = {}

function LUIE_OptionSelectMultiIcon:ClearIcons() end

---@param texture string
function LUIE_OptionSelectMultiIcon:AddIcon(texture) end

function LUIE_OptionSelectMultiIcon:Show() end

function LUIE_OptionSelectMultiIcon:Hide() end

--- Submenu entry after ZO_SharedGamepadEntry_OnInitialized.
---@class LUIE_OptionSelectEntryControl : Control
---@field label Control|nil
---@field icon LUIE_OptionSelectMultiIcon|nil
---@field statusIndicator LUIE_OptionSelectMultiIcon|nil

--- Fields added on top of ZO_GamepadEntryData for the option list.
---@class LUIE_OptionSelectEntryData : ZO_GamepadEntryData
---@field name string|nil
---@field isActive boolean|nil
---@field previewFont string|nil
---@field previewTexture string|nil
---@field optionSelectItem LUIE_OptionSelectItem|nil
---@field setup (fun(control: LUIE_OptionSelectEntryControl, data: LUIE_OptionSelectEntryData, ...: any))|nil

---@class LUIE_OptionSelectEntryList
---@field dataIndexToControl table<integer, LUIE_OptionSelectEntryControl>
local LUIE_OptionSelectEntryList = {}

---@param eval fun(data: LUIE_OptionSelectEntryData): boolean
function LUIE_OptionSelectEntryList:SetSelectedDataByEval(eval) end

---@return LUIE_OptionSelectEntryData|nil
function LUIE_OptionSelectEntryList:GetTargetData() end

---@class LUIE_OptionSelectDialogInfo
---@field parametricList { template: string, entryData: LUIE_OptionSelectEntryData }[]

---@class LUIE_OptionSelectDialog
---@field data LUIE_OptionSelectRequest|nil
---@field info LUIE_OptionSelectDialogInfo
---@field entryList LUIE_OptionSelectEntryList|nil
local LUIE_OptionSelectDialog = {}

function LUIE_OptionSelectDialog:setupFunc() end
