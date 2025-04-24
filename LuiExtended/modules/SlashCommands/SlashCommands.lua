-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
-- SlashCommands namespace
--- @class (partial) LUIE.SlashCommands
local SlashCommands = {}
SlashCommands.__index = SlashCommands
--- @class (partial) LUIE.SlashCommands
LUIE.SlashCommands = SlashCommands

local pairs = pairs

SlashCommands.Enabled = false
SlashCommands.Defaults =
{
    SlashHome = true,
    SlashHomeChoice = 1,
    SlashSetPrimaryHome = true,
    SlashRegroup = true,
    SlashDisband = true,
    SlashGroupLeave = true,
    SlashGroupKick = true,
    SlashGroupRole = true,
    SlashGuildInvite = true,
    SlashGuildQuit = false,
    SlashGuildKick = false,
    SlashFriend = true,
    SlashIgnore = true,
    SlashRemoveFriend = true,
    SlashRemoveIgnore = true,
    SlashTrade = true,
    SlashVoteKick = true,
    SlashCampaignQ = true,
    SlashBanker = true,
    SlashBankerChoice = 1,
    SlashMerchant = true,
    SlashMerchantChoice = 1,
    SlashArmory = true,
    SlashArmoryChoice = 1,
    SlashDecon = true,
    SlashDeconChoice = 1,
    SlashFence = true,
    SlashEye = true,
    SlashReadyCheck = true,
    SlashOutfit = true,
    SlashCake = true,
    SlashPie = true,
    SlashMead = true,
    SlashWitch = true,
    SlashReport = true,
    SlashPet = true,
    SlashPetMessage = true,
    SlashCompanion = true,
    SlashCompanionChoice = 1,
}
SlashCommands.SV = {}

LUIE.LastMementoUsed = 0              -- Set by the SlashCollectible function, passes this value to CA to display the Memento we used if a slash command is used
LUIE.SlashCollectibleOverride = false -- Set by the SlashCollectible function, flags the CA function to display info on the collectible used even if the CA option are DISABLED.

function SlashCommands.Initialize(enabled)
    -- Load Settings
    local isCharacterSpecific = LUIESV["Default"][GetDisplayName()]["$AccountWide"].CharacterSpecificSV
    if isCharacterSpecific then
        SlashCommands.SV = ZO_SavedVars:New(LUIE.SVName, LUIE.SVVer, "SlashCommands", SlashCommands.Defaults)
    else
        SlashCommands.SV = ZO_SavedVars:NewAccountWide(LUIE.SVName, LUIE.SVVer, "SlashCommands", SlashCommands.Defaults)
    end

    -- Disable module if setting not toggled on
    if not enabled then
        return
    end
    SlashCommands.Enabled = true

    SlashCommands.RegisterSlashCommands()
end

function SlashCommands.RegisterSlashCommands()
    -- ZO_GetChatSystem().textEntry.slashCommandAutoComplete:InvalidateSlashCommandCache()
    SlashCommandAutoComplete:InvalidateSlashCommandCache()

    -- Register commands that replace default functions
    SLASH_COMMANDS["/kick"] = SlashCommands.SlashKick             -- This command is always registered since it is also a default emote
    SLASH_COMMANDS["/invite"] = SlashCommands.SlashInvite         -- This command is always registered since it is also a default command
    SLASH_COMMANDS["/readycheck"] = SlashCommands.SlashReadyCheck -- This command is always registered since it is also a default command

    -- Add commands based off menu options
    if SlashCommands.SV.SlashHome then
        SLASH_COMMANDS["/home"] = SlashCommands.SlashHome
    end
    if SlashCommands.SV.SlashSetPrimaryHome then
        SLASH_COMMANDS["/setprimaryhome"] = SlashCommands.SlashSetPrimaryHome
    end
    if SlashCommands.SV.SlashTrade then
        SLASH_COMMANDS["/trade"] = SlashCommands.SlashTrade
    end
    if SlashCommands.SV.SlashCampaignQ then
        SLASH_COMMANDS["/campaign"] = SlashCommands.SlashCampaignQ
    end
    if SlashCommands.SV.SlashOutfit then
        SLASH_COMMANDS["/outfit"] = SlashCommands.SlashOutfit
    end
    if SlashCommands.SV.SlashReport then
        SLASH_COMMANDS["/report"] = SlashCommands.SlashReport
    end
    if SlashCommands.SV.SlashRegroup then
        SLASH_COMMANDS["/regroup"] = SlashCommands.SlashRegroup
    end
    if SlashCommands.SV.SlashDisband then
        SLASH_COMMANDS["/disband"] = SlashCommands.SlashDisband
    end
    if SlashCommands.SV.SlashGroupLeave then
        SLASH_COMMANDS["/leave"] = SlashCommands.SlashGroupLeave
        SLASH_COMMANDS["/leavegroup"] = SlashCommands.SlashGroupLeave
    end
    if SlashCommands.SV.SlashGroupKick then
        SLASH_COMMANDS["/remove"] = SlashCommands.SlashGroupKick
        SLASH_COMMANDS["/groupkick"] = SlashCommands.SlashGroupKick
        SLASH_COMMANDS["/groupremove"] = SlashCommands.SlashGroupKick
    end
    if SlashCommands.SV.SlashGroupRole then
        SLASH_COMMANDS["/changerole"] = SlashCommands.SlashGroupRole
    end
    if SlashCommands.SV.SlashVoteKick then
        SLASH_COMMANDS["/votekick"] = SlashCommands.SlashVoteKick
        SLASH_COMMANDS["/voteremove"] = SlashCommands.SlashVoteKick
    end
    if SlashCommands.SV.SlashReadyCheck then
        SLASH_COMMANDS["/ready"] = SlashCommands.SlashReadyCheck
    end
    if SlashCommands.SV.SlashGuildInvite then
        SLASH_COMMANDS["/guildinvite"] = SlashCommands.SlashGuildInvite
        SLASH_COMMANDS["/ginvite"] = SlashCommands.SlashGuildInvite
    end
    if SlashCommands.SV.SlashGuildKick then
        SLASH_COMMANDS["/guildkick"] = SlashCommands.SlashGuildKick
        SLASH_COMMANDS["/gkick"] = SlashCommands.SlashGuildKick
    end
    if SlashCommands.SV.SlashGuildQuit then
        SLASH_COMMANDS["/guildquit"] = SlashCommands.SlashGuildQuit
        SLASH_COMMANDS["/gquit"] = SlashCommands.SlashGuildQuit
        SLASH_COMMANDS["/guildleave"] = SlashCommands.SlashGuildQuit
        SLASH_COMMANDS["/gleave"] = SlashCommands.SlashGuildQuit
    end
    if SlashCommands.SV.SlashFriend then
        SLASH_COMMANDS["/addfriend"] = SlashCommands.SlashFriend
        SLASH_COMMANDS["/friend"] = SlashCommands.SlashFriend
    end
    if SlashCommands.SV.SlashIgnore then
        SLASH_COMMANDS["/addignore"] = SlashCommands.SlashIgnore
        SLASH_COMMANDS["/ignore"] = SlashCommands.SlashIgnore
    end
    if SlashCommands.SV.SlashRemoveFriend then
        SLASH_COMMANDS["/unfriend"] = SlashCommands.SlashRemoveFriend
        SLASH_COMMANDS["/removefriend"] = SlashCommands.SlashRemoveFriend
    end
    if SlashCommands.SV.SlashRemoveIgnore then
        SLASH_COMMANDS["/unignore"] = SlashCommands.SlashRemoveIgnore
        SLASH_COMMANDS["/removeignore"] = SlashCommands.SlashRemoveIgnore
    end
    if SlashCommands.SV.SlashCompanion then
        for id, name in pairs(LuiData.Data.CollectibleTables.Companions) do
            local command = "/" .. zo_strlower(name)
            SLASH_COMMANDS[command] = function (...)
                SlashCommands.SlashCollectible(id)
            end
        end
        SLASH_COMMANDS["/companion"] = SlashCommands.SlashCompanion
    end
    if SlashCommands.SV.SlashBanker then
        SLASH_COMMANDS["/bank"] = SlashCommands.SlashBanker
        SLASH_COMMANDS["/banker"] = SlashCommands.SlashBanker
    end
    if SlashCommands.SV.SlashMerchant then
        SLASH_COMMANDS["/sell"] = SlashCommands.SlashMerchant
        SLASH_COMMANDS["/merchant"] = SlashCommands.SlashMerchant
        SLASH_COMMANDS["/vendor"] = SlashCommands.SlashMerchant
    end
    if SlashCommands.SV.SlashFence then
        SLASH_COMMANDS["/smuggler"] = function (...)
            SlashCommands.SlashCollectible(300)
        end
        SLASH_COMMANDS["/fence"] = function (...)
            SlashCommands.SlashCollectible(300)
        end
    end
    if SlashCommands.SV.SlashArmory then
        SLASH_COMMANDS["/armory"] = SlashCommands.SlashArmory
    end
    if SlashCommands.SV.SlashDecon then
        SLASH_COMMANDS["/decon"] = function (...)
            SlashCommands.SlashCollectible(10184)
        end
        SLASH_COMMANDS["/deconstruction"] = function (...)
            SlashCommands.SlashCollectible(10184)
        end
    end
    if SlashCommands.SV.SlashEye then
        SLASH_COMMANDS["/eye"] = function (...)
            SlashCommands.SlashCollectible(8006)
        end
    end

    if SlashCommands.SV.SlashPet then
        SLASH_COMMANDS["/pet"] = SlashCommands.SlashPet
        SLASH_COMMANDS["/pets"] = SlashCommands.SlashPet
        SLASH_COMMANDS["/dismisspet"] = SlashCommands.SlashPet
        SLASH_COMMANDS["/dismisspets"] = SlashCommands.SlashPet
    end
    if SlashCommands.SV.SlashCake then
        SLASH_COMMANDS["/cake"] = function (...)
            SlashCommands.SlashCollectible(13520)
        end
        SLASH_COMMANDS["/jubilee"] = function (...)
            SlashCommands.SlashCollectible(13520)
        end
    end
    if SlashCommands.SV.SlashPie then
        SLASH_COMMANDS["/pie"] = function (...)
            SlashCommands.SlashCollectible(1167)
        end
        SLASH_COMMANDS["/jester"] = function (...)
            SlashCommands.SlashCollectible(1167)
        end
    end
    if SlashCommands.SV.SlashMead then
        SLASH_COMMANDS["/mead"] = function (...)
            SlashCommands.SlashCollectible(1168)
        end
        SLASH_COMMANDS["/newlife"] = function (...)
            SlashCommands.SlashCollectible(1168)
        end
    end
    if SlashCommands.SV.SlashWitch then
        SLASH_COMMANDS["/witch"] = function (...)
            SlashCommands.SlashCollectible(479)
        end
        SLASH_COMMANDS["/witchfest"] = function (...)
            SlashCommands.SlashCollectible(479)
        end
    end
end
