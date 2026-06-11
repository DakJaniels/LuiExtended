-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.SlashCommandRegistry
local SlashCommandRegistry = LUIE.SlashCommandRegistry
local slashCommandRegistrationNamespace = SlashCommandRegistry.RegistrationNamespace

local PANEL_SLASH_COMMANDS =
{
    { "/luiset", LUIE_STRING_LSC_PANEL_LUISET },
    { "/luisc",  LUIE_STRING_LSC_PANEL_LUISC  },
    { "/luiuf",  LUIE_STRING_LSC_PANEL_LUIUF  },
    { "/luiab",  LUIE_STRING_LSC_PANEL_LUIAB  },
    { "/luiscb", LUIE_STRING_LSC_PANEL_LUISCB },
    { "/luica",  LUIE_STRING_LSC_PANEL_LUICA  },
    { "/luici",  LUIE_STRING_LSC_PANEL_LUICI  },
    { "/luict",  LUIE_STRING_LSC_PANEL_LUICT  },
    { "/luiip",  LUIE_STRING_LSC_PANEL_LUIIP  },
}

function SlashCommandRegistry.WrapPanelSlashCommands()
    if not SlashCommandRegistry.IsAvailable() then
        return
    end
    for panelIndex = 1, #PANEL_SLASH_COMMANDS do
        local panelSlashCommandEntry = PANEL_SLASH_COMMANDS[panelIndex]
        SlashCommandRegistry.WrapExisting(slashCommandRegistrationNamespace.LamPanels, panelSlashCommandEntry[1], GetString(panelSlashCommandEntry[2]))
    end
end

function SlashCommandRegistry.RegisterLuieSlashCommand()
    if not SlashCommandRegistry.IsAvailable() then
        SLASH_COMMANDS["/luie"] = LUIE.OnLuieSlashCommand
        return
    end

    SlashCommandRegistry.UnregisterAll(slashCommandRegistrationNamespace.Luie)

    SlashCommandRegistry.Register(slashCommandRegistrationNamespace.Luie,
                                  {
                                      aliases = "/luie",
                                      description = GetString(LUIE_STRING_LSC_LUIE),
                                      callback = function (remainingInput)
                                          remainingInput = zo_strtrim(remainingInput or "")
                                          if remainingInput == "" then
                                              LUIE.LuieSlashCommandPrintUsage()
                                              return
                                          end
                                          LUIE.OnLuieSlashCommand(remainingInput)
                                      end,
                                      postRegister = function (luieRootCommand)
                                          local savedVariablesStatusSubCommand = luieRootCommand:RegisterSubCommand()
                                          savedVariablesStatusSubCommand:AddAlias("svstatus")
                                          savedVariablesStatusSubCommand:SetDescription(GetString(LUIE_STRING_LSC_LUIE_SVSTATUS))
                                          savedVariablesStatusSubCommand:SetCallback(function ()
                                              LUIE.LuieSlashCommandSvStatus()
                                          end)

                                          local debugEnvironmentSubCommand = luieRootCommand:RegisterSubCommand()
                                          debugEnvironmentSubCommand:AddAlias("debug")
                                          debugEnvironmentSubCommand:SetDescription(GetString(LUIE_STRING_LSC_LUIE_DEBUG))
                                          debugEnvironmentSubCommand:SetCallback(function (debugAction)
                                              LUIE.LuieSlashCommandDebug(debugAction)
                                          end)
                                          debugEnvironmentSubCommand:SetAutoComplete({ "on", "off", "status" })
                                      end,
                                  })
end

function SlashCommandRegistry.WrapModuleExtraSlashCommands()
    if not SlashCommandRegistry.IsAvailable() then
        return
    end
    SlashCommandRegistry.WrapExisting(slashCommandRegistrationNamespace.ModuleExtra, "/luiecc", GetString(LUIE_STRING_LSC_LUIECC))
    SlashCommandRegistry.WrapExisting(slashCommandRegistrationNamespace.ModuleExtra, "/luiefoodbuff", GetString(LUIE_STRING_LSC_LUIEFOODBUFF))
end

local DEV_SLASH_COMMAND_DESCRIPTIONS =
{
    ["/luieufdebug"] = LUIE_STRING_LSC_DEV_UFDEBUG,
    ["/luiufsm"] = LUIE_STRING_LSC_DEV_UFSM,
    ["/luiufraid"] = LUIE_STRING_LSC_DEV_UFRAID,
    ["/luiufplayer"] = LUIE_STRING_LSC_DEV_UFPLAYER,
    ["/luiuftar"] = LUIE_STRING_LSC_DEV_UFTAR,
    ["/luiufava"] = LUIE_STRING_LSC_DEV_UFAVA,
    ["/luiufpet"] = LUIE_STRING_LSC_DEV_UFPET,
    ["/luiufboss"] = LUIE_STRING_LSC_DEV_UFBOSS,
    ["/luiufcomp"] = LUIE_STRING_LSC_DEV_UFCOMP,
    ["/luiufall"] = LUIE_STRING_LSC_DEV_UFALL,
    ["/luiufdumpfonts"] = LUIE_STRING_LSC_DEV_UFDUMPFONTS,
    ["/filter"] = LUIE_STRING_LSC_DEV_FILTER,
    ["/ground"] = LUIE_STRING_LSC_DEV_GROUND,
    ["/zonecheck"] = LUIE_STRING_LSC_DEV_ZONECHECK,
    ["/zonecheckfull"] = LUIE_STRING_LSC_DEV_ZONECHECKFULL,
    ["/abilitydump"] = LUIE_STRING_LSC_DEV_ABILITYDUMP,
    ["/scbpool"] = LUIE_STRING_LSC_DEV_SCBPOOL,
}

function SlashCommandRegistry.WrapDevSlashCommands()
    if not SlashCommandRegistry.IsAvailable() then
        return
    end
    for slashCommandAlias, descriptionStringId in pairs(DEV_SLASH_COMMAND_DESCRIPTIONS) do
        if SLASH_COMMANDS[slashCommandAlias] then
            SlashCommandRegistry.WrapExisting(slashCommandRegistrationNamespace.Dev, slashCommandAlias, GetString(descriptionStringId))
        end
    end
end

function SlashCommandRegistry.ApplyPostInitSlashCommandIntegration()
    if not IsKeyboardUISupported() then
        return
    end
    SlashCommandRegistry.WrapPanelSlashCommands()
    SlashCommandRegistry.RegisterLuieSlashCommand()
    SlashCommandRegistry.WrapModuleExtraSlashCommands()
    SlashCommandRegistry.WrapDevSlashCommands()
end
