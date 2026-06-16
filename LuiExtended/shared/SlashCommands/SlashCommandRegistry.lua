-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.SlashCommandRegistry
local SlashCommandRegistry = {}
--- @class (partial) LUIE.SlashCommandRegistry
LUIE.SlashCommandRegistry = SlashCommandRegistry

local OtherAddonCompatability = LUIE.OtherAddonCompatability

SlashCommandRegistry.RegistrationNamespace =
{
    SlashCommands = "slashcmds",
    Luie = "luie",
    LamPanels = "lam_panels",
    ModuleExtra = "module_extra",
    Dev = "dev",
}

local ipairs = ipairs
local pairs = pairs
local type = type

--- @type table<string, { libSlashCommanderCommandObjects: table, registeredSlashCommandAliases: string[] }>
local registeredSlashCommandsByNamespace = {}

local function GetSlashCommandRegistrationForNamespace(namespace)
    local registrationRecord = registeredSlashCommandsByNamespace[namespace]
    if not registrationRecord then
        registrationRecord =
        {
            libSlashCommanderCommandObjects = {},
            registeredSlashCommandAliases = {},
        }
        registeredSlashCommandsByNamespace[namespace] = registrationRecord
    end
    return registrationRecord
end

local function AppendRegisteredSlashCommandAliases(namespace, aliases)
    local registrationRecord = GetSlashCommandRegistrationForNamespace(namespace)
    if type(aliases) == "table" then
        for aliasIndex = 1, #aliases do
            registrationRecord.registeredSlashCommandAliases[#registrationRecord.registeredSlashCommandAliases + 1] = aliases[aliasIndex]
        end
    else
        registrationRecord.registeredSlashCommandAliases[#registrationRecord.registeredSlashCommandAliases + 1] = aliases
    end
end

local function ClearSlashCommandAliasesBeforeRegister(aliases)
    if type(aliases) == "table" then
        for aliasIndex = 1, #aliases do
            SLASH_COMMANDS[aliases[aliasIndex]] = nil
        end
    elseif aliases then
        SLASH_COMMANDS[aliases] = nil
    end
end

local function RegisterSubCommandsOnLibSlashCommanderCommand(parentCommand, subCommandDefinitions)
    if not subCommandDefinitions then
        return
    end
    for _, subCommandDefinition in ipairs(subCommandDefinitions) do
        local subCommand = parentCommand:RegisterSubCommand()
        subCommand:AddAlias(subCommandDefinition.alias)
        subCommand:SetCallback(subCommandDefinition.callback)
        if subCommandDefinition.description then
            subCommand:SetDescription(subCommandDefinition.description)
        end
        if subCommandDefinition.autoComplete then
            subCommand:SetAutoComplete(subCommandDefinition.autoComplete)
        end
    end
end

function SlashCommandRegistry.IsAvailable()
    return IsKeyboardUISupported()
        and OtherAddonCompatability.isLibSlashCommanderEnabled
        and LibSlashCommander ~= nil
end

function SlashCommandRegistry.UnregisterAll(namespace)
    local registrationRecord = registeredSlashCommandsByNamespace[namespace]
    if not registrationRecord then
        return
    end
    if OtherAddonCompatability.isLibSlashCommanderEnabled and LibSlashCommander then
        for commandIndex = 1, #registrationRecord.libSlashCommanderCommandObjects do
            LibSlashCommander:Unregister(registrationRecord.libSlashCommanderCommandObjects[commandIndex])
        end
    end
    for aliasIndex = 1, #registrationRecord.registeredSlashCommandAliases do
        SLASH_COMMANDS[registrationRecord.registeredSlashCommandAliases[aliasIndex]] = nil
    end
    registrationRecord.libSlashCommanderCommandObjects = {}
    registrationRecord.registeredSlashCommandAliases = {}
end

--- @param namespace string
--- @param commandRegistration { aliases: string|string[], callback: function, description?: string, subCommands?: table, autoComplete?: table, postRegister?: fun(command) }
--- @return unknown|nil Registered LibSlashCommander command object, or nil when LibSlashCommander is unavailable.
function SlashCommandRegistry.Register(namespace, commandRegistration)
    if not SlashCommandRegistry.IsAvailable() then
        return nil
    end
    ClearSlashCommandAliasesBeforeRegister(commandRegistration.aliases)
    local libSlashCommanderCommand = LibSlashCommander:Register(commandRegistration.aliases, commandRegistration.callback, commandRegistration.description)
    local registrationRecord = GetSlashCommandRegistrationForNamespace(namespace)
    registrationRecord.libSlashCommanderCommandObjects[#registrationRecord.libSlashCommanderCommandObjects + 1] = libSlashCommanderCommand
    AppendRegisteredSlashCommandAliases(namespace, commandRegistration.aliases)

    if commandRegistration.autoComplete then
        libSlashCommanderCommand:SetAutoComplete(commandRegistration.autoComplete)
    end
    RegisterSubCommandsOnLibSlashCommanderCommand(libSlashCommanderCommand, commandRegistration.subCommands)
    if commandRegistration.postRegister then
        commandRegistration.postRegister(libSlashCommanderCommand)
    end
    return libSlashCommanderCommand
end

--- @param namespace string
--- @param slashCommandAlias string
--- @param description string|nil
--- @return nil
function SlashCommandRegistry.WrapExisting(namespace, slashCommandAlias, description)
    if not SlashCommandRegistry.IsAvailable() then
        return
    end
    local existingHandler = SLASH_COMMANDS[slashCommandAlias]
    if not existingHandler or (LibSlashCommander.IsCommand and LibSlashCommander.IsCommand(existingHandler)) then
        return
    end
    SlashCommandRegistry.Register(namespace,
                                  {
                                      aliases = slashCommandAlias,
                                      callback = existingHandler,
                                      description = description,
                                  })
end

function SlashCommandRegistry.UnregisterAlias(namespace, slashCommandAlias)
    if not slashCommandAlias then
        return
    end
    SLASH_COMMANDS[slashCommandAlias] = nil
    local registrationRecord = registeredSlashCommandsByNamespace[namespace]
    if not registrationRecord then
        return
    end
    for aliasIndex = #registrationRecord.registeredSlashCommandAliases, 1, -1 do
        if registrationRecord.registeredSlashCommandAliases[aliasIndex] == slashCommandAlias then
            table.remove(registrationRecord.registeredSlashCommandAliases, aliasIndex)
        end
    end
end
