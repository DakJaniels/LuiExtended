-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.SlashCommandRegistry
local SlashCommandRegistry = LUIE.SlashCommandRegistry
local slashCommandRegistrationNamespace = SlashCommandRegistry.RegistrationNamespace

local SlashCommands = LUIE.SlashCommands

local pairs = pairs
local zo_strlower = zo_strlower

local OUTFIT_SLOT_NUMBER_AUTOCOMPLETE =
{
    "1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
}

local companionNameAutoCompleteList = {}
for _, companionName in pairs(LuiData.Data.CollectibleTables.Companions) do
    companionNameAutoCompleteList[#companionNameAutoCompleteList + 1] = zo_strlower(companionName)
end

local function BuildHomeTravelSubCommandDefinitions()
    return
    {
        {
            alias = "inside",
            callback = function ()
                SlashCommands.SlashHome("inside")
            end,
            description = GetString(LUIE_STRING_LSC_HOME_INSIDE),
        },
        {
            alias = "outside",
            callback = function ()
                SlashCommands.SlashHome("outside")
            end,
            description = GetString(LUIE_STRING_LSC_HOME_OUTSIDE),
        },
    }
end

local function BuildChangeRoleSubCommandDefinitions()
    return
    {
        {
            alias = "tank",
            callback = function ()
                SlashCommands.SlashGroupRole("tank")
            end,
            description = GetString(LUIE_STRING_LSC_CHANGEROLE_TANK),
        },
        {
            alias = "heal",
            callback = function ()
                SlashCommands.SlashGroupRole("heal")
            end,
            description = GetString(LUIE_STRING_LSC_CHANGEROLE_HEAL),
        },
        {
            alias = "dps",
            callback = function ()
                SlashCommands.SlashGroupRole("dps")
            end,
            description = GetString(LUIE_STRING_LSC_CHANGEROLE_DPS),
        },
    }
end

function SlashCommandRegistry.RegisterSlashCommandsModule()
    if not SlashCommandRegistry.IsAvailable() then
        return
    end

    SlashCommandRegistry.UnregisterAll(slashCommandRegistrationNamespace.SlashCommands)

    local slashCommandsSettings = SlashCommands.SV

    SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                  {
                                      aliases = "/kick",
                                      callback = SlashCommands.SlashKick,
                                      description = GetString(LUIE_STRING_LSC_KICK),
                                  })
    SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                  {
                                      aliases = "/invite",
                                      callback = SlashCommands.SlashInvite,
                                      description = GetString(LUIE_STRING_LSC_INVITE),
                                  })
    SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                  {
                                      aliases = "/readycheck",
                                      callback = SlashCommands.SlashReadyCheck,
                                      description = GetString(LUIE_STRING_LSC_READYCHECK),
                                  })

    if slashCommandsSettings.SlashHome then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = "/home",
                                          callback = SlashCommands.SlashHome,
                                          description = GetString(LUIE_STRING_LSC_HOME),
                                          subCommands = BuildHomeTravelSubCommandDefinitions(),
                                      })
    end
    if slashCommandsSettings.SlashSetPrimaryHome then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = "/setprimaryhome",
                                          callback = SlashCommands.SlashSetPrimaryHome,
                                          description = GetString(LUIE_STRING_LSC_SETPRIMARYHOME),
                                      })
    end
    if slashCommandsSettings.SlashTrade then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = "/trade",
                                          callback = SlashCommands.SlashTrade,
                                          description = GetString(LUIE_STRING_LSC_TRADE),
                                      })
    end
    if slashCommandsSettings.SlashCampaignQ then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = "/campaign",
                                          callback = SlashCommands.SlashCampaignQ,
                                          description = GetString(LUIE_STRING_LSC_CAMPAIGN),
                                      })
    end
    if slashCommandsSettings.SlashOutfit then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = "/outfit",
                                          callback = SlashCommands.SlashOutfit,
                                          description = GetString(LUIE_STRING_LSC_OUTFIT),
                                          autoComplete = OUTFIT_SLOT_NUMBER_AUTOCOMPLETE,
                                      })
    end
    if slashCommandsSettings.SlashReport then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = "/report",
                                          callback = SlashCommands.SlashReport,
                                          description = GetString(LUIE_STRING_LSC_REPORT),
                                      })
    end
    if slashCommandsSettings.SlashRegroup then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = "/regroup",
                                          callback = SlashCommands.SlashRegroup,
                                          description = GetString(LUIE_STRING_LSC_REGROUP),
                                      })
    end
    if slashCommandsSettings.SlashDisband then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = "/disband",
                                          callback = SlashCommands.SlashDisband,
                                          description = GetString(LUIE_STRING_LSC_DISBAND),
                                      })
    end
    if slashCommandsSettings.SlashGroupLeave then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = { "/leave", "/leavegroup" },
                                          callback = SlashCommands.SlashGroupLeave,
                                          description = GetString(LUIE_STRING_LSC_LEAVE),
                                      })
    end
    if slashCommandsSettings.SlashGroupKick then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = { "/remove", "/groupkick", "/groupremove" },
                                          callback = SlashCommands.SlashGroupKick,
                                          description = GetString(LUIE_STRING_LSC_GROUPKICK),
                                      })
    end
    if slashCommandsSettings.SlashGroupRole then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = "/changerole",
                                          callback = SlashCommands.SlashGroupRole,
                                          description = GetString(LUIE_STRING_LSC_CHANGEROLE),
                                          subCommands = BuildChangeRoleSubCommandDefinitions(),
                                      })
    end
    if slashCommandsSettings.SlashVoteKick then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = { "/votekick", "/voteremove" },
                                          callback = SlashCommands.SlashVoteKick,
                                          description = GetString(LUIE_STRING_LSC_VOTEKICK),
                                      })
    end
    if slashCommandsSettings.SlashReadyCheck then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = "/ready",
                                          callback = SlashCommands.SlashReadyCheck,
                                          description = GetString(LUIE_STRING_LSC_READY),
                                      })
    end
    if slashCommandsSettings.SlashGuildInvite then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = { "/guildinvite", "/ginvite" },
                                          callback = SlashCommands.SlashGuildInvite,
                                          description = GetString(LUIE_STRING_LSC_GUILDINVITE),
                                      })
    end
    if slashCommandsSettings.SlashGuildKick then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = { "/guildkick", "/gkick" },
                                          callback = SlashCommands.SlashGuildKick,
                                          description = GetString(LUIE_STRING_LSC_GUILDKICK),
                                      })
    end
    if slashCommandsSettings.SlashGuildQuit then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = { "/guildquit", "/gquit", "/guildleave", "/gleave" },
                                          callback = SlashCommands.SlashGuildQuit,
                                          description = GetString(LUIE_STRING_LSC_GUILDQUIT),
                                      })
    end
    if slashCommandsSettings.SlashFriend then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = { "/addfriend", "/friend" },
                                          callback = SlashCommands.SlashFriend,
                                          description = GetString(LUIE_STRING_LSC_FRIEND),
                                      })
    end
    if slashCommandsSettings.SlashIgnore then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = { "/addignore", "/ignore" },
                                          callback = SlashCommands.SlashIgnore,
                                          description = GetString(LUIE_STRING_LSC_IGNORE),
                                      })
    end
    if slashCommandsSettings.SlashRemoveFriend then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = { "/unfriend", "/removefriend" },
                                          callback = SlashCommands.SlashRemoveFriend,
                                          description = GetString(LUIE_STRING_LSC_REMOVEFRIEND),
                                      })
    end
    if slashCommandsSettings.SlashRemoveIgnore then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = { "/unignore", "/removeignore" },
                                          callback = SlashCommands.SlashRemoveIgnore,
                                          description = GetString(LUIE_STRING_LSC_REMOVEIGNORE),
                                      })
    end
    if slashCommandsSettings.SlashCompanion then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = "/companion",
                                          callback = SlashCommands.SlashCompanion,
                                          description = GetString(LUIE_STRING_LSC_COMPANION),
                                          autoComplete = companionNameAutoCompleteList,
                                      })
        for id, name in pairs(LuiData.Data.CollectibleTables.Companions) do
            local command = "/" .. zo_strlower(name)
            SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                          {
                                              aliases = command,
                                              callback = function ()
                                                  SlashCommands.SlashCollectible(id)
                                              end,
                                              description = zo_strformat(GetString(LUIE_STRING_LSC_COMPANION_SUMMON), name),
                                          })
        end
    end
    if slashCommandsSettings.SlashBanker then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = { "/bank", "/banker" },
                                          callback = SlashCommands.SlashBanker,
                                          description = GetString(LUIE_STRING_LSC_BANKER),
                                      })
    end
    if slashCommandsSettings.SlashMerchant then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = { "/sell", "/merchant", "/vendor" },
                                          callback = SlashCommands.SlashMerchant,
                                          description = GetString(LUIE_STRING_LSC_MERCHANT),
                                      })
    end
    if slashCommandsSettings.SlashFence then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = { "/smuggler", "/fence" },
                                          callback = function ()
                                              SlashCommands.SlashCollectible(300)
                                          end,
                                          description = GetString(LUIE_STRING_LSC_FENCE),
                                      })
    end
    if slashCommandsSettings.SlashArmory then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = "/armory",
                                          callback = SlashCommands.SlashArmory,
                                          description = GetString(LUIE_STRING_LSC_ARMORY),
                                      })
    end
    if slashCommandsSettings.SlashDecon then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = { "/decon", "/deconstruction" },
                                          callback = function ()
                                              SlashCommands.SlashCollectible(10184)
                                          end,
                                          description = GetString(LUIE_STRING_LSC_DECON),
                                      })
    end
    if slashCommandsSettings.SlashEye then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = "/eye",
                                          callback = function ()
                                              SlashCommands.SlashCollectible(8006)
                                          end,
                                          description = GetString(LUIE_STRING_LSC_EYE),
                                      })
    end
    if slashCommandsSettings.SlashPet then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = { "/pet", "/pets", "/dismisspet", "/dismisspets" },
                                          callback = SlashCommands.SlashPet,
                                          description = GetString(LUIE_STRING_LSC_PET),
                                      })
    end
    if slashCommandsSettings.SlashCake then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = { "/cake", "/jubilee" },
                                          callback = SlashCommands.SlashCake,
                                          description = GetString(LUIE_STRING_LSC_CAKE),
                                      })
    end
    if slashCommandsSettings.SlashPie then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = { "/pie", "/jester" },
                                          callback = function ()
                                              SlashCommands.SlashCollectible(1167)
                                          end,
                                          description = GetString(LUIE_STRING_LSC_PIE),
                                      })
    end
    if slashCommandsSettings.SlashMead then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = { "/mead", "/newlife" },
                                          callback = function ()
                                              SlashCommands.SlashCollectible(1168)
                                          end,
                                          description = GetString(LUIE_STRING_LSC_MEAD),
                                      })
    end
    if slashCommandsSettings.SlashWitch then
        SlashCommandRegistry.Register(slashCommandRegistrationNamespace.SlashCommands,
                                      {
                                          aliases = { "/witch", "/witchfest" },
                                          callback = function ()
                                              SlashCommands.SlashCollectible(479)
                                          end,
                                          description = GetString(LUIE_STRING_LSC_WITCH),
                                      })
    end
end
