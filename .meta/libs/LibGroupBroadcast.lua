---@meta LibGroupBroadcast
-- Optional dependency. LibGroupBroadcast 2.0.0 (AddOnVersion 95).
-- Field factories are dot calls. Handler and protocol methods are colon calls.
-- `GetHandlerApi` returns the table passed to `Handler:SetApi`.

---@class LGB_FieldOptionsBase
---@field defaultValue any

---@class LGB_NumericFieldOptions: LGB_FieldOptionsBase
---@field defaultValue number|nil
---@field numBits number|nil Between 2 and 32. Calculated from the value range when omitted.
---@field minValue number|nil
---@field maxValue number|nil
---@field precision number|nil Divides before send and multiplies after receive.
---@field trimValues boolean|nil When omitted, an out-of-range value fails the send.

---@class LGB_FlagFieldOptions: LGB_FieldOptionsBase
---@field defaultValue boolean|nil

---@class LGB_ArrayFieldOptions: LGB_FieldOptionsBase
---@field minLength number|nil
---@field maxLength number|nil
---@field defaultValue table|nil

---@class LGB_EnumFieldOptions: LGB_FieldOptionsBase
---@field maxValue number|nil Defaults to the length of the value table.
---@field numBits number|nil

---@class LGB_PercentageFieldOptions: LGB_FieldOptionsBase
---@field defaultValue number|nil Between 0 and 1.
---@field numBits number|nil

---@class LGB_StringFieldOptions: LGB_FieldOptionsBase
---@field characters string|nil Omitted treats the string as bytes.
---@field minLength number|nil Defaults to 0.
---@field maxLength number|nil Defaults to 255.
---@field defaultValue string|nil

---@class LGB_TableFieldOptions: LGB_FieldOptionsBase
---@field defaultValue table|nil

---@class LGB_VariantFieldOptions: LGB_FieldOptionsBase
---@field defaultValue table|nil
---@field maxNumVariants number|nil
---@field numBits number|nil

---@class LGB_ProtocolOptions
---@field isRelevantInCombat boolean|nil
---@field replaceQueuedMessages boolean|nil

---@class LGB_CustomEventOptions
---@field displayName string|nil
---@field description string|nil
---@field userSettings table|nil Must be a UserSettings instance.
---@field isRelevantInCombat boolean|nil

---@class LGB_FieldBase
---@field label string
local LGB_FieldBase = {}

---@return string[]
function LGB_FieldBase:GetWarnings() end

---@class LGB_NumericField: LGB_FieldBase
local LGB_NumericField = {}
---@class LGB_FlagField: LGB_FieldBase
local LGB_FlagField = {}
---@class LGB_ArrayField: LGB_FieldBase
local LGB_ArrayField = {}
---@class LGB_EnumField: LGB_FieldBase
local LGB_EnumField = {}
---@class LGB_OptionalField: LGB_FieldBase
local LGB_OptionalField = {}
---@class LGB_PercentageField: LGB_FieldBase
local LGB_PercentageField = {}
---@class LGB_ReservedField: LGB_FieldBase
local LGB_ReservedField = {}
---@class LGB_StringField: LGB_FieldBase
local LGB_StringField = {}
---@class LGB_TableField: LGB_FieldBase
local LGB_TableField = {}
---@class LGB_VariantField: LGB_FieldBase
local LGB_VariantField = {}

---@class LGB_Protocol
local LGB_Protocol = {}

---@return number
function LGB_Protocol:GetId() end

---@return string
function LGB_Protocol:GetName() end

---@param displayName string
function LGB_Protocol:SetDisplayName(displayName) end

---@return string|nil
function LGB_Protocol:GetDisplayName() end

---@param description string
function LGB_Protocol:SetDescription(description) end

--- The installed function returns `self.displayName`, the same value as `GetDisplayName`.
---@return string|nil
function LGB_Protocol:GetDescription() end

--- `settings` must be a UserSettings instance.
---@param settings table
function LGB_Protocol:SetUserSettings(settings) end

---@return table|nil
function LGB_Protocol:GetUserSettings() end

---@param field LGB_FieldBase
---@return LGB_Protocol
function LGB_Protocol:AddField(field) end

---@param callback fun(unitTag: string, data: table)
---@return LGB_Protocol
function LGB_Protocol:OnData(callback) end

---@return boolean
function LGB_Protocol:IsFinalized() end

---@return boolean
function LGB_Protocol:IsEnabled() end

--- False when there are no fields, no data callback, or a field has warnings.
--- Defaults `isRelevantInCombat` to false and `replaceQueuedMessages` to true.
---@param options LGB_ProtocolOptions|nil
---@return boolean
function LGB_Protocol:Finalize(options) end

--- False when not grouped or a field fails to serialize.
---@param values table
---@param options LGB_ProtocolOptions|nil
---@return boolean
function LGB_Protocol:Send(values, options) end

---@class LGB_Handler
local LGB_Handler = {}

--- Returned later by `LibGroupBroadcast:GetHandlerApi`.
---@param api table
function LGB_Handler:SetApi(api) end

---@param displayName string
function LGB_Handler:SetDisplayName(displayName) end

---@param description string
function LGB_Handler:SetDescription(description) end

--- `settings` must be a UserSettings instance.
---@param settings table
function LGB_Handler:SetUserSettings(settings) end

--- Throws when the id or name is already taken.
---@param eventId number
---@param eventName string
---@param options LGB_CustomEventOptions|nil
---@return fun() fireEvent
function LGB_Handler:DeclareCustomEvent(eventId, eventName, options) end

---@param eventIdOrName number|string
---@return boolean
function LGB_Handler:IsCustomEventEnabled(eventIdOrName) end

--- Throws when the id or name is already taken.
---@param protocolId number
---@param protocolName string
---@return LGB_Protocol
function LGB_Handler:DeclareProtocol(protocolId, protocolName) end

---@class LibGroupBroadcast
LibGroupBroadcast = {}

--- Nil when registration fails.
---@param addonName string
---@param handlerName string|nil
---@return LGB_Handler|nil
function LibGroupBroadcast:RegisterHandler(addonName, handlerName) end

--- Nil when that handler did not call `SetApi`.
---@param handlerName string
---@return table|nil
function LibGroupBroadcast:GetHandlerApi(handlerName) end

---@param eventName string
---@param callback fun(unitTag: string)
---@return boolean
function LibGroupBroadcast:RegisterForCustomEvent(eventName, callback) end

---@param eventName string
---@param callback fun(unitTag: string)
---@return boolean
function LibGroupBroadcast:UnregisterForCustomEvent(eventName, callback) end

---@param valueField LGB_FieldBase
---@param options LGB_ArrayFieldOptions|nil
---@return LGB_ArrayField
function LibGroupBroadcast.CreateArrayField(valueField, options) end

---@param label string
---@param valueTable any[]
---@param options LGB_EnumFieldOptions|nil
---@return LGB_EnumField
function LibGroupBroadcast.CreateEnumField(label, valueTable, options) end

---@param label string
---@param options LGB_FlagFieldOptions|nil
---@return LGB_FlagField
function LibGroupBroadcast.CreateFlagField(label, options) end

---@param label string
---@param options LGB_NumericFieldOptions|nil
---@return LGB_NumericField
function LibGroupBroadcast.CreateNumericField(label, options) end

---@param valueField LGB_FieldBase
---@return LGB_OptionalField
function LibGroupBroadcast.CreateOptionalField(valueField) end

---@param label string
---@param options LGB_PercentageFieldOptions|nil
---@return LGB_PercentageField
function LibGroupBroadcast.CreatePercentageField(label, options) end

---@param label string
---@param numBits number
---@return LGB_ReservedField
function LibGroupBroadcast.CreateReservedField(label, numBits) end

---@param label string
---@param options LGB_StringFieldOptions|nil
---@return LGB_StringField
function LibGroupBroadcast.CreateStringField(label, options) end

---@param label string
---@param valueFields LGB_FieldBase[]
---@param options LGB_TableFieldOptions|nil
---@return LGB_TableField
function LibGroupBroadcast.CreateTableField(label, valueFields, options) end

---@param variants LGB_FieldBase[]
---@param options LGB_VariantFieldOptions|nil
---@return LGB_VariantField
function LibGroupBroadcast.CreateVariantField(variants, options) end

---@return LGB_FieldBase
function LibGroupBroadcast.CreateFieldBaseSubclass() end

--- Separate library instance for Taneth tests. Not connected to the live global.
---@param createWithoutSaveData boolean|nil
---@return LibGroupBroadcast
function LibGroupBroadcast.SetupMockInstance(createWithoutSaveData) end


