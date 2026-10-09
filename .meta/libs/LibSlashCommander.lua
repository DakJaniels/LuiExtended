---@meta LibSlashCommander
-- Optional dependency. LibSlashCommander 1.2.0 (AddOnVersion 45).
-- Commands are `LibSlashCommander.Command` objects. `Register` returns one and also
-- registers it under the global command. Subcommands are the same class.

---@alias LSC_CommandCallback fun(input: string|nil)

---@class LSC_AutoCompleteProvider
local LSC_AutoCompleteProvider = {}

---@param data string[]|nil Numerically indexed labels. Keys used for matching are lowercased.
---@return LSC_AutoCompleteProvider
function LSC_AutoCompleteProvider:New(data) end

---@param prefix string|nil `nil` clears the prefix filter.
function LSC_AutoCompleteProvider:SetPrefix(prefix) end

--- Return false to skip autocomplete for this token.
---@param token string
---@return boolean
function LSC_AutoCompleteProvider:CanComplete(token) end

--- String keys are compared. String values are the labels shown in the result box.
---@return table<string, string>
function LSC_AutoCompleteProvider:GetResultList() end

--- Text written into the chat box when a label is selected. Falls back to `label`.
---@param label string
---@return string
function LSC_AutoCompleteProvider:GetResultFromLabel(label) end

---@class LSC_AutoCompleteSlashCommandsProvider: LSC_AutoCompleteProvider
local LSC_AutoCompleteSlashCommandsProvider = {}

---@return LSC_AutoCompleteSlashCommandsProvider
function LSC_AutoCompleteSlashCommandsProvider:New() end

---@return table<string, string>
function LSC_AutoCompleteSlashCommandsProvider:GetResultList() end

---@class LSC_AutoCompleteSubCommandsProvider: LSC_AutoCompleteProvider
local LSC_AutoCompleteSubCommandsProvider = {}

---@param command LSC_Command
---@return LSC_AutoCompleteSubCommandsProvider
function LSC_AutoCompleteSubCommandsProvider:New(command) end

---@param alias string
---@param description string|nil
---@return string
function LSC_AutoCompleteSubCommandsProvider:FormatLabel(alias, description) end

---@return table<string, string>
function LSC_AutoCompleteSubCommandsProvider:GetResultList() end

---@class LSC_Command
---@field callback LSC_CommandCallback|nil
---@field description string|nil
---@field aliases table<string, LSC_Command>
---@field subCommands table<LSC_Command, LSC_Command>
---@field subCommandAliases table<string, LSC_Command>
---@field parent LSC_Command|nil
local LSC_Command = {}

---@return LSC_Command
function LSC_Command:New() end

---@param description string|nil
function LSC_Command:SetDescription(description) end

--- `alias` is accepted and ignored. The stored description is returned.
---@param alias string|nil
---@return string|nil
function LSC_Command:GetDescription(alias) end

---@param callback LSC_CommandCallback|nil
function LSC_Command:SetCallback(callback) end

--- The parameter is accepted and ignored.
---@param callback function|nil
---@return LSC_CommandCallback|nil
function LSC_Command:GetCallback(callback) end

---@param alias string
function LSC_Command:AddAlias(alias) end

---@param alias string
---@return boolean
function LSC_Command:HasAlias(alias) end

---@param alias string
function LSC_Command:RemoveAlias(alias) end

---@param parent LSC_Command|nil
---@return boolean
function LSC_Command:HasAncestor(parent) end

--- `nil` detaches this command from its parent.
---@param command LSC_Command|nil
function LSC_Command:SetParentCommand(command) end

--- `nil` creates a new child command.
---@param command LSC_Command|nil
---@return LSC_Command
function LSC_Command:RegisterSubCommand(command) end

---@param command LSC_Command
---@return boolean
function LSC_Command:HasSubCommand(command) end

---@param command LSC_Command
function LSC_Command:UnregisterSubCommand(command) end

---@param alias string
---@param command LSC_Command
function LSC_Command:RegisterSubCommandAlias(alias, command) end

---@param alias string
---@return boolean
function LSC_Command:HasSubCommandAlias(alias) end

---@param alias string
---@return LSC_Command|nil
function LSC_Command:GetSubCommandByAlias(alias) end

---@param alias string
function LSC_Command:UnregisterSubCommandAlias(alias) end

--- `nil` or `false` clears autocomplete. `true` uses subcommand names.
--- A string array builds an `LSC_AutoCompleteProvider`.
---@param provider LSC_AutoCompleteProvider|string[]|boolean|nil
---@return LSC_AutoCompleteProvider|nil
function LSC_Command:SetAutoComplete(provider) end

---@param token string
---@return boolean
function LSC_Command:ShouldAutoComplete(token) end

---@return table<string, string>
function LSC_Command:GetAutoCompleteResults() end

---@param label string
---@return string
function LSC_Command:GetAutoCompleteResultFromDisplayText(label) end

---@class LibSlashCommander
---@field Command LSC_Command
---@field AutoCompleteProvider LSC_AutoCompleteProvider
---@field AutoCompleteSlashCommandsProvider LSC_AutoCompleteSlashCommandsProvider
---@field AutoCompleteSubCommandsProvider LSC_AutoCompleteSubCommandsProvider
---@field loadedFiles table<string, number>
---@field descriptions table<string, string|fun(): string>
---@field types table<string, integer>
---@field typeColor table<integer, string>
---@field globalCommand LSC_Command
LibSlashCommander = {}

---@type 1
LibSlashCommander.COMMAND_TYPE_BUILT_IN = 1
---@type 2
LibSlashCommander.COMMAND_TYPE_CHAT_SWITCH = 2
---@type 3
LibSlashCommander.COMMAND_TYPE_EMOTE = 3
---@type 4
LibSlashCommander.COMMAND_TYPE_ADDON = 4

---@param command any
---@return boolean
function LibSlashCommander.IsCommand(command) end

---@param provider any
---@return boolean
function LibSlashCommander.IsAutoCompleteProvider(provider) end

---@param provider any
---@return boolean
function LibSlashCommander.IsAutoCompleteSlashCommandsProvider(provider) end

---@param provider any
---@return boolean
function LibSlashCommander.IsAutoCompleteSubCommandsProvider(provider) end

--- `aliases` is one alias or a list. Both `callback` and `description` are optional.
---@param aliases string|string[]|nil
---@param callback LSC_CommandCallback|nil
---@param description string|nil
---@return LSC_Command
function LibSlashCommander:Register(aliases, callback, description) end

---@param command LSC_Command
function LibSlashCommander:Unregister(command) end

---@param alias string
---@param description string|nil
---@param commandType integer|nil Defaults to `COMMAND_TYPE_ADDON`.
---@return string
function LibSlashCommander:FormatLabel(alias, description, commandType) end

---@param alias string
---@param description string|nil
---@return string
function LibSlashCommander:GenerateLabel(alias, description) end

--- Starts chat input when the chat system is available and the target is allowed.
---@param text string
---@param channel integer|nil
---@param target string|nil
function LibSlashCommander.SafeStartChatInput(text, channel, target) end

---@type LibSlashCommander|nil
LibSlashCommander = LibSlashCommander
