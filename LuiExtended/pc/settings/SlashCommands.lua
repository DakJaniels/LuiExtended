-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Load Settings API
local SettingsAPI = LUIE.SettingsAPI

--- @class (partial) LUIE.SlashCommands
local SlashCommands = LUIE.SlashCommands
--- @type CollectibleTables
local CollectibleTables = LuiData.Data.CollectibleTables

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

function SlashCommands.MigrateSettings()
    local Settings = SlashCommands.SV

    -- Migrate old settings
    if CollectibleTables.Banker[Settings.SlashBankerChoice] == nil then
        local _, id = next(bankerOptionsKeys)
        Settings.SlashBankerChoice = id
    end
    if CollectibleTables.Merchants[Settings.SlashMerchantChoice] == nil then
        local _, id = next(merchantOptionsKeys)
        Settings.SlashMerchantChoice = id
    end
    if CollectibleTables.Companions[Settings.SlashCompanionChoice] == nil then
        local _, id = next(companionOptionsKeys)
        Settings.SlashCompanionChoice = id
    end
    if CollectibleTables.Armory[Settings.SlashArmoryChoice] == nil then
        local _, id = next(armoryOptionsKeys)
        Settings.SlashArmoryChoice = id
    end
    if CollectibleTables.Decon[Settings.SlashDeconChoice] == nil then
        local _, id = next(deconOptionsKeys)
        Settings.SlashDeconChoice = id
    end

    if #bankerOptions == 0 then
        Settings.SlashBanker = false
    end
    if #merchantOptions == 0 then
        Settings.SlashMerchant = false
    end
    if #companionOptions == 0 then
        Settings.SlashCompanion = false
    end
    if #armoryOptions == 0 then
        Settings.SlashArmory = false
    end
    if #deconOptions == 0 then
        Settings.SlashDecon = false
    end
end

-- Load LibAddonMenu
local LAM = LUIE.LAM

-- Create Slash Commands Settings Menu
function SlashCommands.CreateSettings()
    local Defaults = SlashCommands.Defaults
    local Settings = SlashCommands.SV


    if not LUIE.SV.SlashCommands_Enable then
        return
    end

    local panelDataSlashCommands =
    {
        type = "panel",
        name = LUIE.FormatAddonSettingsPanelTitle(LUIE_STRING_LAM_SLASHCMDS),
        displayName = LUIE.FormatAddonSettingsPanelDisplayName(LUIE_STRING_LAM_SLASHCMDS),
        author = LUIE.author .. "\n",
        version = LUIE.version,
        website = LUIE.website,
        feedback = LUIE.feedback,
        translation = LUIE.translation,
        donation = LUIE.donation,
        slashCommand = "/luisc",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsDataSlashCommands = {}

    local homeOptions =
    {
        GetString(LUIE_STRING_LAM_SLASHCMDS_HOME_INSIDE_LABEL),
        GetString(LUIE_STRING_LAM_SLASHCMDS_HOME_OUTSIDE_LABEL),
    }
    local homeOptionsKeys = {}
    for i, label in ipairs(homeOptions) do
        homeOptionsKeys[label] = i
    end

    -- Slash Commands description
    optionsDataSlashCommands[#optionsDataSlashCommands + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_DESCRIPTION)
    )

    -- ReloadUI Button
    optionsDataSlashCommands[#optionsDataSlashCommands + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_RELOADUI),
        GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        function () ReloadUI("ingame") end
    )

    -- Slash Commands - General Commands Submenu
    local generalCommandsControls = {}

    -- SlashTrade
    generalCommandsControls[#generalCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_TRADE),
        GetString(LUIE_STRING_LAM_SLASHCMDS_TRADE_TP),
        function () return Settings.SlashTrade end,
        function (value)
            Settings.SlashTrade = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashTrade,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- SlashHome
    generalCommandsControls[#generalCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_HOME),
        GetString(LUIE_STRING_LAM_SLASHCMDS_HOME_TP),
        function () return Settings.SlashHome end,
        function (value)
            Settings.SlashHome = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashHome,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- Choose Home Option
    generalCommandsControls[#generalCommandsControls + 1] = SettingsAPI.CreateIndentedDropdown(
        GetString(LUIE_STRING_LAM_SLASHCMDS_HOME_CHOICE),
        nil,
        homeOptions,
        function () return homeOptions[Settings.SlashHomeChoice] end,
        function (value) Settings.SlashHomeChoice = homeOptionsKeys[value] end,
        1,
        "full",
        function () return not Settings.SlashHome end,
        Defaults.SlashHomeChoice
    )

    -- SlashSetPrimaryHome
    generalCommandsControls[#generalCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_HOME_SET_PRIMARY),
        GetString(LUIE_STRING_LAM_SLASHCMDS_HOME_SET_PRIMARY_TP),
        function () return Settings.SlashSetPrimaryHome end,
        function (value)
            Settings.SlashSetPrimaryHome = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashSetPrimaryHome,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- SlashCampaignQ
    generalCommandsControls[#generalCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_CAMPAIGN),
        GetString(LUIE_STRING_LAM_SLASHCMDS_CAMPAIGN_TP),
        function () return Settings.SlashCampaignQ end,
        function (value)
            Settings.SlashCampaignQ = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashCampaignQ,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- SlashCompanion
    generalCommandsControls[#generalCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_COMPANION),
        GetString(LUIE_STRING_LAM_SLASHCMDS_COMPANION_TP),
        function () return Settings.SlashCompanion end,
        function (value)
            Settings.SlashCompanion = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        function () return #companionOptions == 0 end,
        Defaults.SlashCompanion,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- Choose Companion
    generalCommandsControls[#generalCommandsControls + 1] = SettingsAPI.CreateIndentedDropdown(
        GetString(LUIE_STRING_LAM_SLASHCMDS_COMPANION_CHOICE),
        nil,
        companionOptions,
        function () return GetFormattedCollectibleName(Settings.SlashCompanionChoice) end,
        function (value) Settings.SlashCompanionChoice = companionOptionsKeys[value] end,
        1,
        "full",
        function () return not Settings.SlashCompanion end,
        Defaults.SlashCompanionChoice
    )

    -- SlashBanker
    generalCommandsControls[#generalCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_BANKER),
        GetString(LUIE_STRING_LAM_SLASHCMDS_BANKER_TP),
        function () return Settings.SlashBanker end,
        function (value)
            Settings.SlashBanker = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        function () return #bankerOptions == 0 end,
        Defaults.SlashBanker,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- Choose Banker
    generalCommandsControls[#generalCommandsControls + 1] = SettingsAPI.CreateIndentedDropdown(
        GetString(LUIE_STRING_LAM_SLASHCMDS_BANKER_CHOICE),
        nil,
        bankerOptions,
        function () return GetFormattedCollectibleName(Settings.SlashBankerChoice) end,
        function (value) Settings.SlashBankerChoice = bankerOptionsKeys[value] end,
        1,
        "full",
        function () return not Settings.SlashBanker end,
        Defaults.SlashBankerChoice
    )

    -- SlashMerchant
    generalCommandsControls[#generalCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_MERCHANT),
        GetString(LUIE_STRING_LAM_SLASHCMDS_MERCHANT_TP),
        function () return Settings.SlashMerchant end,
        function (value)
            Settings.SlashMerchant = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        function () return #merchantOptions == 0 end,
        Defaults.SlashMerchant,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- Choose Merchant
    generalCommandsControls[#generalCommandsControls + 1] = SettingsAPI.CreateIndentedDropdown(
        GetString(LUIE_STRING_LAM_SLASHCMDS_MERCHANT_CHOICE),
        nil,
        merchantOptions,
        function () return GetFormattedCollectibleName(Settings.SlashMerchantChoice) end,
        function (value) Settings.SlashMerchantChoice = merchantOptionsKeys[value] end,
        1,
        "full",
        function () return not Settings.SlashMerchant end,
        Defaults.SlashMerchantChoice
    )

    -- SlashArmory
    generalCommandsControls[#generalCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_ARMORY),
        GetString(LUIE_STRING_LAM_SLASHCMDS_ARMORY_TP),
        function () return Settings.SlashArmory end,
        function (value)
            Settings.SlashArmory = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        function () return #armoryOptions == 0 end,
        Defaults.SlashArmory,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- Choose Armory
    generalCommandsControls[#generalCommandsControls + 1] = SettingsAPI.CreateIndentedDropdown(
        GetString(LUIE_STRING_LAM_SLASHCMDS_ARMORY_CHOICE),
        nil,
        armoryOptions,
        function () return GetFormattedCollectibleName(Settings.SlashArmoryChoice) end,
        function (value) Settings.SlashArmoryChoice = armoryOptionsKeys[value] end,
        1,
        "full",
        function () return not Settings.SlashArmory end,
        Defaults.SlashArmoryChoice
    )

    -- SlashDecon
    generalCommandsControls[#generalCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_DECON),
        zo_strformat(GetString(LUIE_STRING_LAM_SLASHCMDS_DECON_TP), GetCollectibleName(10184)),
        function () return Settings.SlashDecon end,
        function (value)
            Settings.SlashDecon = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        function () return #deconOptions == 0 end,
        Defaults.SlashDecon,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- Choose Decon
    generalCommandsControls[#generalCommandsControls + 1] = SettingsAPI.CreateIndentedDropdown(
        GetString(LUIE_STRING_LAM_SLASHCMDS_DECON_CHOICE),
        nil,
        deconOptions,
        function () return GetFormattedCollectibleName(Settings.SlashDeconChoice) end,
        function (value) Settings.SlashDeconChoice = deconOptionsKeys[value] end,
        1,
        "full",
        function () return not Settings.SlashDecon end,
        Defaults.SlashDeconChoice
    )

    -- SlashFence
    generalCommandsControls[#generalCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_FENCE),
        zo_strformat(GetString(LUIE_STRING_LAM_SLASHCMDS_FENCE_TP), GetCollectibleName(300)),
        function () return Settings.SlashFence end,
        function (value)
            Settings.SlashFence = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashFence,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- SlashEye
    generalCommandsControls[#generalCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_EYE),
        GetString(LUIE_STRING_LAM_SLASHCMDS_EYE_TP),
        function () return Settings.SlashEye end,
        function (value)
            Settings.SlashEye = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashEye,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- SlashPet
    generalCommandsControls[#generalCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_PET),
        GetString(LUIE_STRING_LAM_SLASHCMDS_PET_TP),
        function () return Settings.SlashPet end,
        function (value)
            Settings.SlashPet = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashPet,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- SlashPet Message (indented)
    generalCommandsControls[#generalCommandsControls + 1] = SettingsAPI.CreateIndentedCheckbox(
        GetString(LUIE_STRING_LAM_SLASHCMDS_PET_MESSAGE),
        GetString(LUIE_STRING_LAM_SLASHCMDS_PET_MESSAGE_TP),
        function () return Settings.SlashPetMessage end,
        function (value) Settings.SlashPetMessage = value end,
        1,
        "full",
        nil,
        Defaults.SlashPetMessage
    )

    -- SlashOutfit
    generalCommandsControls[#generalCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_OUTFIT),
        GetString(LUIE_STRING_LAM_SLASHCMDS_OUTFIT_TP),
        function () return Settings.SlashOutfit end,
        function (value)
            Settings.SlashOutfit = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashOutfit,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- SlashReport
    generalCommandsControls[#generalCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_REPORT),
        GetString(LUIE_STRING_LAM_SLASHCMDS_REPORT_TP),
        function () return Settings.SlashReport end,
        function (value)
            Settings.SlashReport = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashReport,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    optionsDataSlashCommands[#optionsDataSlashCommands + 1] = SettingsAPI.CreateSubmenuOption(
        GetString(LUIE_STRING_LAM_SLASHCMDSHEADER_GENERAL),
        generalCommandsControls
    )

    -- Slash Commands - Group Commands Options Submenu
    local groupCommandsControls = {}

    -- SlashReadyCheck
    groupCommandsControls[#groupCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_READYCHECK),
        GetString(LUIE_STRING_LAM_SLASHCMDS_READYCHECK_TP),
        function () return Settings.SlashReadyCheck end,
        function (value)
            Settings.SlashReadyCheck = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashReadyCheck,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- SlashRegroup
    groupCommandsControls[#groupCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_REGROUP),
        GetString(LUIE_STRING_LAM_SLASHCMDS_REGROUP_TP),
        function () return Settings.SlashRegroup end,
        function (value)
            Settings.SlashRegroup = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashRegroup,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- SlashDisband
    groupCommandsControls[#groupCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_DISBAND),
        GetString(LUIE_STRING_LAM_SLASHCMDS_DISBAND_TP),
        function () return Settings.SlashDisband end,
        function (value)
            Settings.SlashDisband = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashDisband,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- SlashGroupLeave
    groupCommandsControls[#groupCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_LEAVE),
        GetString(LUIE_STRING_LAM_SLASHCMDS_LEAVE_TP),
        function () return Settings.SlashGroupLeave end,
        function (value)
            Settings.SlashGroupLeave = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashGroupLeave,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- SlashGroupKick
    groupCommandsControls[#groupCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_KICK),
        GetString(LUIE_STRING_LAM_SLASHCMDS_KICK_TP),
        function () return Settings.SlashGroupKick end,
        function (value)
            Settings.SlashGroupKick = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashGroupKick,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- SlashGroupRole
    groupCommandsControls[#groupCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_ROLE),
        GetString(LUIE_STRING_LAM_SLASHCMDS_ROLE_TP),
        function () return Settings.SlashGroupRole end,
        function (value)
            Settings.SlashGroupRole = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashGroupRole,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- SlashVoteKick
    groupCommandsControls[#groupCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_VOTEKICK),
        GetString(LUIE_STRING_LAM_SLASHCMDS_VOTEKICK_TP),
        function () return Settings.SlashVoteKick end,
        function (value)
            Settings.SlashVoteKick = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashVoteKick,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    optionsDataSlashCommands[#optionsDataSlashCommands + 1] = SettingsAPI.CreateSubmenuOption(
        GetString(LUIE_STRING_LAM_SLASHCMDSHEADER_GROUP),
        groupCommandsControls
    )

    -- Slash Commands - Guild Commands Options Submenu
    local guildCommandsControls = {}

    -- SlashGuildInvite
    guildCommandsControls[#guildCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_GUILDINVITE),
        GetString(LUIE_STRING_LAM_SLASHCMDS_GUILDINVITE_TP),
        function () return Settings.SlashGuildInvite end,
        function (value)
            Settings.SlashGuildInvite = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashGuildInvite,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- SlashGuildQuit
    guildCommandsControls[#guildCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_GUILDQUIT),
        GetString(LUIE_STRING_LAM_SLASHCMDS_GUILDQUIT_TP),
        function () return Settings.SlashGuildQuit end,
        function (value)
            Settings.SlashGuildQuit = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashGuildQuit,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- SlashGuildKick
    guildCommandsControls[#guildCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_GUILDKICK),
        GetString(LUIE_STRING_LAM_SLASHCMDS_GUILDKICK_TP),
        function () return Settings.SlashGuildKick end,
        function (value)
            Settings.SlashGuildKick = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashGuildKick,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    optionsDataSlashCommands[#optionsDataSlashCommands + 1] = SettingsAPI.CreateSubmenuOption(
        GetString(LUIE_STRING_LAM_SLASHCMDSHEADER_GUILD),
        guildCommandsControls
    )

    -- Slash Commands - Social Commands Options Submenu
    local socialCommandsControls = {}

    -- SlashFriend
    socialCommandsControls[#socialCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_FRIEND),
        GetString(LUIE_STRING_LAM_SLASHCMDS_FRIEND_TP),
        function () return Settings.SlashFriend end,
        function (value)
            Settings.SlashFriend = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashFriend,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- SlashIgnore
    socialCommandsControls[#socialCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_IGNORE),
        GetString(LUIE_STRING_LAM_SLASHCMDS_IGNORE_TP),
        function () return Settings.SlashIgnore end,
        function (value)
            Settings.SlashIgnore = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashIgnore,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- SlashRemoveFriend
    socialCommandsControls[#socialCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_REMOVEFRIEND),
        GetString(LUIE_STRING_LAM_SLASHCMDS_REMOVEFRIEND_TP),
        function () return Settings.SlashRemoveFriend end,
        function (value)
            Settings.SlashRemoveFriend = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashRemoveFriend,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- SlashRemoveIgnore
    socialCommandsControls[#socialCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_REMOVEIGNORE),
        GetString(LUIE_STRING_LAM_SLASHCMDS_REMOVEIGNORE_TP),
        function () return Settings.SlashRemoveIgnore end,
        function (value)
            Settings.SlashRemoveIgnore = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashRemoveIgnore,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    optionsDataSlashCommands[#optionsDataSlashCommands + 1] = SettingsAPI.CreateSubmenuOption(
        GetString(LUIE_STRING_LAM_SLASHCMDSHEADER_SOCIAL),
        socialCommandsControls
    )

    -- Holiday XP Buffs are applied by the event now and not an item. No need to have these settings. Commented, maybe we can repurpose the code.
    -- Slash Commands - Holiday XP Events Commands Options Submenu
    local holidayCommandsControls = {}

    -- SlashCake
    holidayCommandsControls[#holidayCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_CAKE),
        GetString(LUIE_STRING_LAM_SLASHCMDS_CAKE_TP),
        function () return Settings.SlashCake end,
        function (value)
            Settings.SlashCake = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashCake,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- SlashPie
    holidayCommandsControls[#holidayCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_PIE),
        GetString(LUIE_STRING_LAM_SLASHCMDS_PIE_TP),
        function () return Settings.SlashPie end,
        function (value)
            Settings.SlashPie = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashPie,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- SlashMead
    holidayCommandsControls[#holidayCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_MEAD),
        GetString(LUIE_STRING_LAM_SLASHCMDS_MEAD_TP),
        function () return Settings.SlashMead end,
        function (value)
            Settings.SlashMead = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashMead,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    -- SlashWitch
    holidayCommandsControls[#holidayCommandsControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_WITCH),
        GetString(LUIE_STRING_LAM_SLASHCMDS_WITCH_TP),
        function () return Settings.SlashWitch end,
        function (value)
            Settings.SlashWitch = value
            SlashCommands.RegisterSlashCommands()
        end,
        "full",
        nil,
        Defaults.SlashWitch,
        GetString(LUIE_STRING_LAM_RELOADUI_SLASH_WARNING)
    )

    optionsDataSlashCommands[#optionsDataSlashCommands + 1] = SettingsAPI.CreateSubmenuOption(
        GetString(LUIE_STRING_LAM_SLASHCMDSHEADER_HOLIDAY),
        holidayCommandsControls
    )

    -- Register the settings panel
    LAM:RegisterAddonPanel(LUIE.name .. "SlashCommandsOptions", panelDataSlashCommands)
    LAM:RegisterOptionControls(LUIE.name .. "SlashCommandsOptions", optionsDataSlashCommands)
end
