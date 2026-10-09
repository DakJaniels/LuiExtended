---@meta LibAddonMenu2
-- Optional dependency. LibAddonMenu-2.0 r43 (library minor 43).
-- Keyboard registration builds a panel control. On console the same calls forward to LibHarvensAddonSettings and `RegisterAddonPanel` returns nothing.
-- Widget option tables below match the comment blocks in controls/*.lua, including dropdown `itemFont`.

---@alias LAM_Width "full"|"half"
---@alias LAM_Stringish string|integer|fun(): string
---@alias LAM_DropdownSort "name-up"|"name-down"|"numeric-up"|"numeric-down"|"value-up"|"value-down"|"numericvalue-up"|"numericvalue-down"

---@class LAM_PanelData
---@field type "panel"
---@field name LAM_Stringish
---@field displayName LAM_Stringish|nil
---@field author LAM_Stringish|nil
---@field version LAM_Stringish|nil
---@field website string|fun(): string|nil
---@field feedback string|fun(): string|nil
---@field translation string|fun(): string|nil
---@field donation string|fun(): string|nil
---@field keywords string|nil
---@field slashCommand string|nil Includes the leading slash.
---@field registerForRefresh boolean|nil
---@field registerForDefaults boolean|nil
---@field resetFunc fun(panel: LAM_PanelData)|nil

---@class LAM_ButtonData
---@field type "button"
---@field name LAM_Stringish
---@field func fun()
---@field tooltip LAM_Stringish|nil
---@field width LAM_Width|nil
---@field disabled boolean|fun(): boolean|nil
---@field icon string|nil
---@field isDangerous boolean|nil
---@field warning LAM_Stringish|nil
---@field helpUrl string|fun(): string|nil
---@field reference string|nil
---@field resetFunc fun(buttonControl: any)|nil

---@class LAM_CheckboxData
---@field type "checkbox"
---@field name LAM_Stringish
---@field getFunc fun(): boolean
---@field setFunc fun(value: boolean)
---@field tooltip LAM_Stringish|nil
---@field width LAM_Width|nil
---@field disabled boolean|fun(): boolean|nil
---@field warning LAM_Stringish|nil
---@field requiresReload boolean|nil
---@field default boolean|fun(): boolean|nil
---@field helpUrl string|fun(): string|nil
---@field reference string|nil
---@field resetFunc fun(checkboxControl: any)|nil

---@class LAM_SliderData
---@field type "slider"
---@field name LAM_Stringish
---@field getFunc fun(): number
---@field setFunc fun(value: number)
---@field min number
---@field max number
---@field step number|nil
---@field clampInput boolean|nil
---@field clampFunction fun(value: number, min: number, max: number): number|nil
---@field decimals integer|nil
---@field autoSelect boolean|nil
---@field inputLocation "below"|"right"|nil
---@field readOnly boolean|nil
---@field tooltip LAM_Stringish|nil
---@field width LAM_Width|nil
---@field disabled boolean|fun(): boolean|nil
---@field warning LAM_Stringish|nil
---@field requiresReload boolean|nil
---@field default number|fun(): number|nil
---@field helpUrl string|fun(): string|nil
---@field reference string|nil
---@field resetFunc fun(sliderControl: any)|nil

---@class LAM_DropdownData
---@field type "dropdown"
---@field name LAM_Stringish
---@field choices string[]
---@field choicesValues any[]|nil
---@field getFunc fun(): any
---@field setFunc fun(value: any)
---@field tooltip LAM_Stringish|nil
---@field choicesTooltips LAM_Stringish[]|nil
---@field sort LAM_DropdownSort|nil
---@field width LAM_Width|nil
---@field scrollable boolean|number|nil
---@field disabled boolean|fun(): boolean|nil
---@field warning LAM_Stringish|nil
---@field requiresReload boolean|nil
---@field default any
---@field helpUrl string|fun(): string|nil
---@field reference string|nil
---@field resetFunc fun(dropdownControl: any)|nil
---@field multiSelect boolean|fun(): boolean|nil
---@field multiSelectTextFormatter string|integer|fun(): string|nil
---@field multiSelectNoSelectionText string|integer|fun(): string|nil
---@field multiSelectMaxSelections number|fun(): number|nil
--- `choiceValue` follows `choicesValues` when present, otherwise the display string. Nil uses the combo default font.
---@field itemFont fun(choiceValue: any, choiceName: string): string|nil

---@class LAM_EditboxData
---@field type "editbox"
---@field name LAM_Stringish
---@field getFunc fun(): string
---@field setFunc fun(text: string)
---@field tooltip LAM_Stringish|nil
---@field isMultiline boolean|nil
---@field isExtraWide boolean|nil
---@field maxChars integer|nil
---@field textType integer|fun(): integer|nil `TEXT_TYPE_*`.
---@field width LAM_Width|nil
---@field disabled boolean|fun(): boolean|nil
---@field warning LAM_Stringish|nil
---@field requiresReload boolean|nil
---@field default any
---@field helpUrl string|fun(): string|nil
---@field reference string|nil
---@field resetFunc fun(editboxControl: any)|nil

---@class LAM_ColorPickerData
---@field type "colorpicker"
---@field name LAM_Stringish
---@field getFunc fun(): number, number, number, number|nil
---@field setFunc fun(r: number, g: number, b: number, a: number|nil)
---@field tooltip LAM_Stringish|nil
---@field width LAM_Width|nil
---@field disabled boolean|fun(): boolean|nil
---@field warning LAM_Stringish|nil
---@field requiresReload boolean|nil
---@field default { r: number, g: number, b: number, a: number|nil }|fun(): { r: number, g: number, b: number, a: number|nil }|nil
---@field helpUrl string|fun(): string|nil
---@field reference string|nil
---@field resetFunc fun(colorpickerControl: any)|nil

---@class LAM_HeaderData
---@field type "header"
---@field name LAM_Stringish
---@field tooltip LAM_Stringish|nil
---@field width LAM_Width|nil
---@field helpUrl string|fun(): string|nil
---@field reference string|nil
---@field resetFunc fun(headerControl: any)|nil

---@class LAM_DescriptionData
---@field type "description"
---@field text LAM_Stringish
---@field title LAM_Stringish|nil
---@field tooltip LAM_Stringish|nil
---@field width LAM_Width|nil
---@field disabled boolean|fun(): boolean|nil
---@field enableLinks boolean|fun(linkData: string, linkText: string, button: integer, control: any)|nil
---@field helpUrl string|fun(): string|nil
---@field reference string|nil
---@field resetFunc fun(descriptionControl: any)|nil

---@class LAM_DividerData
---@field type "divider"
---@field width LAM_Width|nil
---@field height integer|nil
---@field alpha number|nil
---@field reference string|nil

---@class LAM_SubmenuData
---@field type "submenu"
---@field name LAM_Stringish
---@field icon string|fun(): string|nil
---@field iconTextureCoords { [1]: number, [2]: number, [3]: number, [4]: number }|fun(): table|nil
---@field tooltip LAM_Stringish|nil
---@field controls LAM_OptionData[]|nil
---@field disabled boolean|fun(): boolean|nil
---@field disabledLabel boolean|fun(): boolean|nil
---@field helpUrl string|fun(): string|nil
---@field reference string|nil
---@field resetFunc fun(submenuControl: any)|nil

---@class LAM_TextureData
---@field type "texture"
---@field image string
---@field imageWidth integer
---@field imageHeight integer
---@field tooltip LAM_Stringish|nil
---@field width LAM_Width|nil
---@field reference string|nil

---@class LAM_IconPickerData
---@field type "iconpicker"
---@field name LAM_Stringish
---@field choices string[]
---@field getFunc fun(): any
---@field setFunc fun(value: any)
---@field tooltip LAM_Stringish|nil
---@field choicesTooltips LAM_Stringish[]|nil
---@field maxColumns integer|nil
---@field visibleRows number|nil
---@field iconSize integer|nil
---@field defaultColor ZO_ColorDef|nil
---@field width LAM_Width|nil
---@field beforeShow fun(control: any, iconPicker: LAM_IconPickerData): boolean|nil
---@field disabled boolean|fun(): boolean|nil
---@field warning LAM_Stringish|nil
---@field requiresReload boolean|nil
---@field default any
---@field helpUrl string|fun(): string|nil
---@field reference string|nil
---@field resetFunc fun(iconpickerControl: any)|nil

---@class LAM_CustomData
---@field type "custom"
---@field reference string|nil
---@field createFunc fun(customControl: any)|nil
---@field refreshFunc fun(customControl: any)|nil
---@field width LAM_Width|nil
---@field minHeight number|fun(): number|nil
---@field maxHeight number|fun(): number|nil
---@field resetFunc fun(customControl: any)|nil

---@alias LAM_OptionData LAM_ButtonData|LAM_CheckboxData|LAM_SliderData|LAM_DropdownData|LAM_EditboxData|LAM_ColorPickerData|LAM_HeaderData|LAM_DescriptionData|LAM_DividerData|LAM_SubmenuData|LAM_TextureData|LAM_IconPickerData|LAM_CustomData

---@class LAM_HasControlTable
---@field indexed LHAS_SettingParams[]
---@field nameMap table<string, LHAS_SettingParams>

---@class LAM_Util
---@field L table<string, string>
local LAM_Util = {}

---@param default any
---@return any
function LAM_Util.GetDefaultValue(default) end

--- A function is called. A number is passed to `GetString`. Anything else is returned as-is.
---@param value any
---@return any
function LAM_Util.GetStringFromValue(value) end

---@deprecated Use `GetStringFromValue`.
---@param value any
---@return any
function LAM_Util.GetTooltipText(value) end

---@param disabled boolean
---@return ZO_ColorDef
function LAM_Util.GetColorForState(disabled) end

---@param panel any
---@return any
function LAM_Util.GetTopPanel(panel) end

---@param title string
---@param body string
---@param callback fun()
function LAM_Util.ShowConfirmationDialog(title, body, callback) end

---@param control any
function LAM_Util.UpdateWarning(control) end

---@param control any
function LAM_Util.RequestRefreshIfNeeded(control) end

--- `controlName` nil uses `controlData.reference`.
---@param parent any
---@param controlData table
---@param controlName string|nil
---@return any
function LAM_Util.CreateBaseControl(parent, controlData, controlName) end

--- `controlName` nil uses `controlData.reference`.
---@param parent any
---@param controlData table
---@param controlName string|nil
---@return any
function LAM_Util.CreateLabelAndContainerControl(parent, controlData, controlName) end

---@param control any
---@param data table
---@param tooltipData table|nil
function LAM_Util.SetUpTooltip(control, data, tooltipData) end

---@param control any
function LAM_Util.RegisterForRefreshIfNeeded(control) end

---@param control any
function LAM_Util.RegisterForReloadIfNeeded(control) end

--- Nil when the control has no `helpUrl`.
---@param control any
---@return any|nil
function LAM_Util.CreateFAQTexture(control) end

---@return any
function LAM_Util.GetIconPickerMenu() end

---@class LibAddonMenu2
---@field util LAM_Util
---@field requiresReload boolean
---@field currentPanelOpened boolean
---@field LHASConversion { settingTables: table<string, LHAS_AddonSettings>, optionControls: table<string, LAM_HasControlTable> }
LibAddonMenu2 = {}

--- False when this version is not newer than the one already registered.
---@param widgetType string
---@param widgetVersion integer
---@return boolean
function LibAddonMenu2:RegisterWidget(widgetType, widgetVersion) end

--- Keyboard: returns the created panel. Console: registers with LibHarvensAddonSettings and returns nothing.
---@param addonID string Global name of the panel.
---@param panelData LAM_PanelData
---@return any panel
function LibAddonMenu2:RegisterAddonPanel(addonID, panelData) end

--- On console this also registers LibHarvensAddonSettings rows.
---@param addonID string
---@param optionsTable LAM_OptionData[]
function LibAddonMenu2:RegisterOptionControls(addonID, optionsTable) end

--- `panel` is the value returned by `RegisterAddonPanel`.
---@param panel any
function LibAddonMenu2:OpenToPanel(panel) end

---@return any
function LibAddonMenu2:GetAddonPanelContainer() end

---@return any
function LibAddonMenu2:GetAddonSettingsFragment() end

--- Returns nil when LibHarvensAddonSettings is not loaded.
---@param optionsTable LAM_OptionData[]
---@param controlTable LAM_HasControlTable|nil
---@return LAM_HasControlTable|nil
function LibAddonMenu2:convertLamOptionsToHasTable(optionsTable, controlTable) end

---@param addonID string
---@param panelData LAM_PanelData
function LibAddonMenu2:registerConsoleAddonPanel(addonID, panelData) end

---@param addonID string
---@param optionsTable LAM_OptionData[]
function LibAddonMenu2:registerConsoleOptionControls(addonID, optionsTable) end

--- Widget factories. `LibAddonMenu-2.0.lua` sets `LAMCreateControl = LAMCreateControl or {}`.
--- `controlName` nil uses `data.reference`. Each factory returns the created control.
--- `comboboxCount` is incremented by dropdown widgets when the parent has no name.
---@class LAMCreateControl
---@field comboboxCount integer|nil
LAMCreateControl = {}

---@param parent any
---@param panelData LAM_PanelData
---@param controlName string|nil
---@return any
function LAMCreateControl.panel(parent, panelData, controlName) end

---@param parent any
---@param buttonData LAM_ButtonData
---@param controlName string|nil
---@return any
function LAMCreateControl.button(parent, buttonData, controlName) end

---@param parent any
---@param checkboxData LAM_CheckboxData
---@param controlName string|nil
---@return any
function LAMCreateControl.checkbox(parent, checkboxData, controlName) end

---@param parent any
---@param colorpickerData LAM_ColorPickerData
---@param controlName string|nil
---@return any
function LAMCreateControl.colorpicker(parent, colorpickerData, controlName) end

---@param parent any
---@param customData LAM_CustomData
---@param controlName string|nil
---@return any
function LAMCreateControl.custom(parent, customData, controlName) end

---@param parent any
---@param descriptionData LAM_DescriptionData
---@param controlName string|nil
---@return any
function LAMCreateControl.description(parent, descriptionData, controlName) end

---@param parent any
---@param dividerData LAM_DividerData
---@param controlName string|nil
---@return any
function LAMCreateControl.divider(parent, dividerData, controlName) end

---@param parent any
---@param dropdownData LAM_DropdownData
---@param controlName string|nil
---@return any
function LAMCreateControl.dropdown(parent, dropdownData, controlName) end

---@param parent any
---@param editboxData LAM_EditboxData
---@param controlName string|nil
---@return any
function LAMCreateControl.editbox(parent, editboxData, controlName) end

---@param parent any
---@param headerData LAM_HeaderData
---@param controlName string|nil
---@return any
function LAMCreateControl.header(parent, headerData, controlName) end

---@param parent any
---@param iconpickerData LAM_IconPickerData
---@param controlName string|nil
---@return any
function LAMCreateControl.iconpicker(parent, iconpickerData, controlName) end

---@param parent any
---@param sliderData LAM_SliderData
---@param controlName string|nil
---@return any
function LAMCreateControl.slider(parent, sliderData, controlName) end

---@param parent any
---@param submenuData LAM_SubmenuData
---@param controlName string|nil
---@return any
function LAMCreateControl.submenu(parent, submenuData, controlName) end

---@param parent any
---@param textureData LAM_TextureData
---@param controlName string|nil
---@return any
function LAMCreateControl.texture(parent, textureData, controlName) end

---@type LAMCreateControl|nil
LAMCreateControl = LAMCreateControl


