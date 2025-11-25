-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Load Console Settings API
local SettingsAPI = LUIE.ConsoleSettingsAPI

--- @class (partial) LUIE.SlashCommands
local SlashCommands = LUIE.SlashCommands
--- @type CollectibleTables
local CollectibleTables = LuiData.Data.CollectibleTables

-- Load LibHarvensAddonSettings
local LHAS = LibHarvensAddonSettings

local pairs = pairs
local table_insert = table.insert
local zo_strformat = zo_strformat

local function GetFormattedCollectibleName(id)
    return zo_strformat("<<1>>", GetCollectibleName(id)) -- Remove ^M and ^F
end

--- @generic T
--- @param collectibleTable T | CollectibleTables
--- @return T options
--- @return T optionKeys
local function CreateOptions(collectibleTable)
    local options = {}
    local optionKeys = {}

    if collectibleTable ~= nil then
        for id, _ in pairs(collectibleTable) do
            if IsCollectibleUnlocked(id) then
                local name = GetFormattedCollectibleName(id)
                table_insert(options, name)
                optionKeys[name] = id
            end
        end
    end

    return options, optionKeys
end

local bankerOptions, bankerOptionsKeys = CreateOptions(CollectibleTables.Banker)
local merchantOptions, merchantOptionsKeys = CreateOptions(CollectibleTables.Merchants)
local companionOptions, companionOptionsKeys = CreateOptions(CollectibleTables.Companions)
local armoryOptions, armoryOptionsKeys = CreateOptions(CollectibleTables.Armory)
local deconOptions, deconOptionsKeys = CreateOptions(CollectibleTables.Decon)

local homeOptions = { "Inside", "Outside" }
local homeOptionsKeys = { ["Inside"] = 1, ["Outside"] = 2 }

-- Create Slash Commands Settings Menu
function SlashCommands.CreateConsoleSettings()
    local Defaults = SlashCommands.Defaults
    local Settings = SlashCommands.SV

    -- Register the settings panel
    if not LUIE.SV.SlashCommands_Enable then
        return
    end

    -- Create the addon settings panel
    local panel = LHAS:AddAddon(zo_strformat("<<1>> - <<2>>", LUIE.name, GetString(LUIE_STRING_LAM_SLASHCMDS)),
                                {
                                    allowDefaults = true,
                                    defaultsFunction = function ()
                                        -- Reset to defaults if needed
                                    end,
                                    allowRefresh = true
                                })

    local settingsData = {}

    -- Slash Commands description
    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_DESCRIPTION)
    )

    -- ReloadUI Button
    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_RELOADUI),
        GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        function () ReloadUI("ingame") end
    )

    -- Slash Commands - General Commands Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_SLASHCMDSHEADER_GENERAL)
    )

    -- SlashTrade
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_TRADE),
        GetString(LUIE_STRING_LAM_SLASHCMDS_TRADE_TP),
        function () return Settings.SlashTrade end,
        function (value)
            Settings.SlashTrade = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashTrade
    )

    -- SlashHome
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_HOME),
        GetString(LUIE_STRING_LAM_SLASHCMDS_HOME_TP),
        function () return Settings.SlashHome end,
        function (value)
            Settings.SlashHome = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashHome
    )

    -- Choose Home Option
    local homeItems = {}
    for i, option in ipairs(homeOptions) do
        homeItems[i] = { name = option, data = option }
    end
    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "Choose Inside or Outside for /home",
        nil,
        homeItems,
        function () return homeOptions[Settings.SlashHomeChoice] end,
        function (combobox, value, item)
            Settings.SlashHomeChoice = homeOptionsKeys[value]
        end,
        1,
        "full",
        function () return not Settings.SlashHome end,
        homeOptions[Defaults.SlashHomeChoice]
    )

    -- SlashSetPrimaryHome
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_HOME_SET_PRIMARY),
        GetString(LUIE_STRING_LAM_SLASHCMDS_HOME_SET_PRIMARY_TP),
        function () return Settings.SlashSetPrimaryHome end,
        function (value)
            Settings.SlashSetPrimaryHome = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashSetPrimaryHome
    )

    -- SlashCampaignQ
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_CAMPAIGN),
        GetString(LUIE_STRING_LAM_SLASHCMDS_CAMPAIGN_TP),
        function () return Settings.SlashCampaignQ end,
        function (value)
            Settings.SlashCampaignQ = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashCampaignQ
    )

    -- SlashCompanion
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_COMPANION),
        GetString(LUIE_STRING_LAM_SLASHCMDS_COMPANION_TP),
        function () return Settings.SlashCompanion end,
        function (value)
            Settings.SlashCompanion = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        function () return #companionOptions == 0 end,
        Defaults.SlashCompanion
    )

    -- Choose Companion
    local companionItems = {}
    for i, option in ipairs(companionOptions) do
        companionItems[i] = { name = option, data = option }
    end
    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "Choose Companion to Summon",
        nil,
        companionItems,
        function () return GetFormattedCollectibleName(Settings.SlashCompanionChoice) end,
        function (combobox, value, item)
            Settings.SlashCompanionChoice = companionOptionsKeys[value]
        end,
        1,
        "full",
        function () return not Settings.SlashCompanion end,
        GetFormattedCollectibleName(Defaults.SlashCompanionChoice)
    )

    -- SlashBanker
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_BANKER),
        GetString(LUIE_STRING_LAM_SLASHCMDS_BANKER_TP),
        function () return Settings.SlashBanker end,
        function (value)
            Settings.SlashBanker = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        function () return #bankerOptions == 0 end,
        Defaults.SlashBanker
    )

    -- Choose Banker
    local bankerItems = {}
    for i, option in ipairs(bankerOptions) do
        bankerItems[i] = { name = option, data = option }
    end
    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "Choose Banker to Summon",
        nil,
        bankerItems,
        function () return GetFormattedCollectibleName(Settings.SlashBankerChoice) end,
        function (combobox, value, item)
            Settings.SlashBankerChoice = bankerOptionsKeys[value]
        end,
        1,
        "full",
        function () return not Settings.SlashBanker end,
        GetFormattedCollectibleName(Defaults.SlashBankerChoice)
    )

    -- SlashMerchant
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_MERCHANT),
        GetString(LUIE_STRING_LAM_SLASHCMDS_MERCHANT_TP),
        function () return Settings.SlashMerchant end,
        function (value)
            Settings.SlashMerchant = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        function () return #merchantOptions == 0 end,
        Defaults.SlashMerchant
    )

    -- Choose Merchant
    local merchantItems = {}
    for i, option in ipairs(merchantOptions) do
        merchantItems[i] = { name = option, data = option }
    end
    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "Choose Merchant to Summon",
        nil,
        merchantItems,
        function () return GetFormattedCollectibleName(Settings.SlashMerchantChoice) end,
        function (combobox, value, item)
            Settings.SlashMerchantChoice = merchantOptionsKeys[value]
        end,
        1,
        "full",
        function () return not Settings.SlashMerchant end,
        GetFormattedCollectibleName(Defaults.SlashMerchantChoice)
    )

    -- SlashArmory
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_ARMORY),
        GetString(LUIE_STRING_LAM_SLASHCMDS_ARMORY_TP),
        function () return Settings.SlashArmory end,
        function (value)
            Settings.SlashArmory = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        function () return #armoryOptions == 0 end,
        Defaults.SlashArmory
    )

    -- Choose Armory
    local armoryItems = {}
    for i, option in ipairs(armoryOptions) do
        armoryItems[i] = { name = option, data = option }
    end
    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "Choose Armory Assistant to Summon",
        nil,
        armoryItems,
        function () return GetFormattedCollectibleName(Settings.SlashArmoryChoice) end,
        function (combobox, value, item)
            Settings.SlashArmoryChoice = armoryOptionsKeys[value]
        end,
        1,
        "full",
        function () return not Settings.SlashArmory end,
        GetFormattedCollectibleName(Defaults.SlashArmoryChoice)
    )

    -- SlashDecon
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_DECON),
        zo_strformat(GetString(LUIE_STRING_LAM_SLASHCMDS_DECON_TP), GetCollectibleName(10184)),
        function () return Settings.SlashDecon end,
        function (value)
            Settings.SlashDecon = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        function () return #deconOptions == 0 end,
        Defaults.SlashDecon
    )

    -- Choose Decon
    local deconItems = {}
    for i, option in ipairs(deconOptions) do
        deconItems[i] = { name = option, data = option }
    end
    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "Choose Deconstruction Assistant to Summon",
        nil,
        deconItems,
        function () return GetFormattedCollectibleName(Settings.SlashDeconChoice) end,
        function (combobox, value, item)
            Settings.SlashDeconChoice = deconOptionsKeys[value]
        end,
        1,
        "full",
        function () return not Settings.SlashDecon end,
        GetFormattedCollectibleName(Defaults.SlashDeconChoice)
    )

    -- SlashFence
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_FENCE),
        zo_strformat(GetString(LUIE_STRING_LAM_SLASHCMDS_FENCE_TP), GetCollectibleName(300)),
        function () return Settings.SlashFence end,
        function (value)
            Settings.SlashFence = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashFence
    )

    -- SlashEye
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_EYE),
        GetString(LUIE_STRING_LAM_SLASHCMDS_EYE_TP),
        function () return Settings.SlashEye end,
        function (value)
            Settings.SlashEye = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashEye
    )

    -- SlashPet
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_PET),
        GetString(LUIE_STRING_LAM_SLASHCMDS_PET_TP),
        function () return Settings.SlashPet end,
        function (value)
            Settings.SlashPet = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashPet
    )

    -- SlashPet Message (indented)
    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckbox(
        GetString(LUIE_STRING_LAM_SLASHCMDS_PET_MESSAGE),
        GetString(LUIE_STRING_LAM_SLASHCMDS_PET_MESSAGE_TP),
        function () return Settings.SlashPetMessage end,
        function (value) Settings.SlashPetMessage = value end,
        1,
        "full",
        nil,
        LUIE.Defaults.SlashPetMessage
    )

    -- SlashOutfit
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_OUTFIT),
        GetString(LUIE_STRING_LAM_SLASHCMDS_OUTFIT_TP),
        function () return Settings.SlashOutfit end,
        function (value)
            Settings.SlashOutfit = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashOutfit
    )

    -- SlashReport
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_REPORT),
        GetString(LUIE_STRING_LAM_SLASHCMDS_REPORT_TP),
        function () return Settings.SlashReport end,
        function (value)
            Settings.SlashReport = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashReport
    )

    -- /home Alert (Temp Setting)
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "/home Results - Show Alert (Temp Setting)",
        "Display an alert when the /home command is used.\nNote: This setting will be deprecated in the future when Social Errors Events are implemented in Chat Announcements.",
        function () return LUIE.SV.TempAlertHome end,
        function (value) LUIE.SV.TempAlertHome = value end,
        "full",
        nil,
        LUIE.Defaults.TempAlertHome
    )

    -- /Campaign Results Alert (Temp Setting)
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "/Campaign Results - Show Alert (Temp Setting)",
        "Display an alert when the /campaign command is used.\nNote: This setting will be deprecated in the future when Campaign Queue Events are implemented in Chat Announcements.",
        function () return LUIE.SV.TempAlertCampaign end,
        function (value) LUIE.SV.TempAlertCampaign = value end,
        "full",
        nil,
        LUIE.Defaults.TempAlertCampaign
    )

    -- /Outfit Alert (Temp Setting)
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "/Outfit - Show Alert (Temp Setting)",
        "Display an alert when the /outfit command is used.\nNote: This setting will be deprecated in the future when Outfit Alerts are implemented in Chat Announcements.",
        function () return LUIE.SV.TempAlertOutfit end,
        function (value) LUIE.SV.TempAlertOutfit = value end,
        "full",
        nil,
        LUIE.Defaults.TempAlertOutfit
    )

    -- Slash Commands - Group Commands Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_SLASHCMDSHEADER_GROUP)
    )

    -- SlashReadyCheck
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_READYCHECK),
        GetString(LUIE_STRING_LAM_SLASHCMDS_READYCHECK_TP),
        function () return Settings.SlashReadyCheck end,
        function (value)
            Settings.SlashReadyCheck = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashReadyCheck
    )

    -- SlashRegroup
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_REGROUP),
        GetString(LUIE_STRING_LAM_SLASHCMDS_REGROUP_TP),
        function () return Settings.SlashRegroup end,
        function (value)
            Settings.SlashRegroup = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashRegroup
    )

    -- SlashDisband
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_DISBAND),
        GetString(LUIE_STRING_LAM_SLASHCMDS_DISBAND_TP),
        function () return Settings.SlashDisband end,
        function (value)
            Settings.SlashDisband = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashDisband
    )

    -- SlashGroupLeave
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_LEAVE),
        GetString(LUIE_STRING_LAM_SLASHCMDS_LEAVE_TP),
        function () return Settings.SlashGroupLeave end,
        function (value)
            Settings.SlashGroupLeave = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashGroupLeave
    )

    -- SlashGroupKick
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_KICK),
        GetString(LUIE_STRING_LAM_SLASHCMDS_KICK_TP),
        function () return Settings.SlashGroupKick end,
        function (value)
            Settings.SlashGroupKick = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashGroupKick
    )

    -- SlashGroupRole
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_ROLE),
        GetString(LUIE_STRING_LAM_SLASHCMDS_ROLE_TP),
        function () return Settings.SlashGroupRole end,
        function (value)
            Settings.SlashGroupRole = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashGroupRole
    )

    -- SlashVoteKick
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_VOTEKICK),
        GetString(LUIE_STRING_LAM_SLASHCMDS_VOTEKICK_TP),
        function () return Settings.SlashVoteKick end,
        function (value)
            Settings.SlashVoteKick = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashVoteKick
    )

    -- Slash Commands - Guild Commands Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_SLASHCMDSHEADER_GUILD)
    )

    -- SlashGuildInvite
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_GUILDINVITE),
        GetString(LUIE_STRING_LAM_SLASHCMDS_GUILDINVITE_TP),
        function () return Settings.SlashGuildInvite end,
        function (value)
            Settings.SlashGuildInvite = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashGuildInvite
    )

    -- SlashGuildQuit
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_GUILDQUIT),
        GetString(LUIE_STRING_LAM_SLASHCMDS_GUILDQUIT_TP),
        function () return Settings.SlashGuildQuit end,
        function (value)
            Settings.SlashGuildQuit = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashGuildQuit
    )

    -- SlashGuildKick
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_GUILDKICK),
        GetString(LUIE_STRING_LAM_SLASHCMDS_GUILDKICK_TP),
        function () return Settings.SlashGuildKick end,
        function (value)
            Settings.SlashGuildKick = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashGuildKick
    )

    -- Slash Commands - Social Commands Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_SLASHCMDSHEADER_SOCIAL)
    )

    -- SlashFriend
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_FRIEND),
        GetString(LUIE_STRING_LAM_SLASHCMDS_FRIEND_TP),
        function () return Settings.SlashFriend end,
        function (value)
            Settings.SlashFriend = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashFriend
    )

    -- SlashIgnore
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_IGNORE),
        GetString(LUIE_STRING_LAM_SLASHCMDS_IGNORE_TP),
        function () return Settings.SlashIgnore end,
        function (value)
            Settings.SlashIgnore = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashIgnore
    )

    -- SlashRemoveFriend
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_REMOVEFRIEND),
        GetString(LUIE_STRING_LAM_SLASHCMDS_REMOVEFRIEND_TP),
        function () return Settings.SlashRemoveFriend end,
        function (value)
            Settings.SlashRemoveFriend = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashRemoveFriend
    )

    -- SlashRemoveIgnore
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_REMOVEIGNORE),
        GetString(LUIE_STRING_LAM_SLASHCMDS_REMOVEIGNORE_TP),
        function () return Settings.SlashRemoveIgnore end,
        function (value)
            Settings.SlashRemoveIgnore = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashRemoveIgnore
    )

    -- Slash Commands - Holiday XP Events Commands Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_SLASHCMDSHEADER_HOLIDAY)
    )

    -- SlashCake
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_CAKE),
        GetString(LUIE_STRING_LAM_SLASHCMDS_CAKE_TP),
        function () return Settings.SlashCake end,
        function (value)
            Settings.SlashCake = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashCake
    )

    -- SlashPie
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_PIE),
        GetString(LUIE_STRING_LAM_SLASHCMDS_PIE_TP),
        function () return Settings.SlashPie end,
        function (value)
            Settings.SlashPie = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashPie
    )

    -- SlashMead
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_MEAD),
        GetString(LUIE_STRING_LAM_SLASHCMDS_MEAD_TP),
        function () return Settings.SlashMead end,
        function (value)
            Settings.SlashMead = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashMead
    )

    -- SlashWitch
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_WITCH),
        GetString(LUIE_STRING_LAM_SLASHCMDS_WITCH_TP),
        function () return Settings.SlashWitch end,
        function (value)
            Settings.SlashWitch = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashWitch
    )

    -- Register the settings panel
    if LUIE.SV.SlashCommands_Enable then
        panel:AddSettings(settingsData)
    end
end
