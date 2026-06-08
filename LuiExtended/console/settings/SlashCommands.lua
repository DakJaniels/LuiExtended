-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.SlashCommands
local SlashCommands = LUIE.SlashCommands
--- @type CollectibleTables
local CollectibleTables = LuiData.Data.CollectibleTables

-- Load LibHarvensAddonSettings
local LHAS = LibHarvensAddonSettings
local SettingsAPI = LUIE.ConsoleSettingsAPI

local pairs = pairs
local ipairs = ipairs
local table_insert = table.insert
local zo_strformat = zo_strformat
local GetString = GetString
local GetCollectibleName = GetCollectibleName
local IsCollectibleUnlocked = IsCollectibleUnlocked

local function GetFormattedCollectibleName(id)
    return zo_strformat("<<1>>", GetCollectibleName(id)) -- Remove ^M and ^F
end

--- @generic T
--- @param collectibleTable T | CollectibleTables
--- @return function itemsFunction Function that returns fresh array of LHAS dropdown items
local function CreateCollectibleItemsFunction(collectibleTable)
    return function ()
        local items = {}
        if collectibleTable ~= nil then
            for id, _ in pairs(collectibleTable) do
                if IsCollectibleUnlocked(id) then
                    local name = GetFormattedCollectibleName(id)
                    table_insert(items, { name = name, data = id })
                end
            end
        end
        return items
    end
end

local GetBankerItems = CreateCollectibleItemsFunction(CollectibleTables.Banker)
local GetMerchantItems = CreateCollectibleItemsFunction(CollectibleTables.Merchants)
local GetCompanionItems = CreateCollectibleItemsFunction(CollectibleTables.Companions)
local GetArmoryItems = CreateCollectibleItemsFunction(CollectibleTables.Armory)
local GetDeconItems = CreateCollectibleItemsFunction(CollectibleTables.Decon)

-- Home options (create fresh each time to avoid reference sharing)
local function GetHomeItems()
    return
    {
        { name = GetString(LUIE_STRING_LAM_SLASHCMDS_HOME_INSIDE_LABEL),  data = 1 },
        { name = GetString(LUIE_STRING_LAM_SLASHCMDS_HOME_OUTSIDE_LABEL), data = 2 }
    }
end

-- Create Slash Commands Settings Menu
function SlashCommands.CreateConsoleSettings()
    local Defaults = SlashCommands.Defaults
    local Settings = SlashCommands.SV

    -- Register the settings panel
    if not LUIE.SV.SlashCommands_Enable then
        return
    end

    -- Create the addon settings panel
    local panel = LHAS:AddAddon(LUIE.FormatAddonSettingsPanelTitle(LUIE_STRING_LAM_SLASHCMDS),
                                {
                                    allowDefaults = true,
                                    defaultsFunction = function ()
                                        -- Reset to defaults if needed
                                    end
                                })

    -- Collect initial settings for main menu
    local initialSettings = {}

    -- Slash Commands description
    initialSettings[#initialSettings + 1] =
    {
        type = LHAS.ST_LABEL,
        label = GetString(LUIE_STRING_LAM_SLASHCMDS_DESCRIPTION)
    }

    -- ReloadUI Button
    initialSettings[#initialSettings + 1] =
    {
        type = LHAS.ST_BUTTON,
        label = GetString(LUIE_STRING_LAM_RELOADUI),
        tooltip = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        buttonText = GetString(LUIE_STRING_LAM_RELOADUI),
        clickHandler = function () ReloadUI("ingame") end
    }

    local sectionGroups = {}

    -- Helper function to build section settings
    local function buildSectionSettings(sectionName, settingsBuilder)
        local sectionSettings = {}
        settingsBuilder(sectionSettings)
        sectionGroups[sectionName] = sectionSettings
    end

    -- Build General Commands Section
    buildSectionSettings("GeneralCommands", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_SLASHCMDSHEADER_GENERAL),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_SLASH_GENERAL),
        }

        -- SlashTrade
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_TRADE),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_TRADE_TP),
            getFunction = function () return Settings.SlashTrade end,
            setFunction = function (value)
                Settings.SlashTrade = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashTrade
        }

        -- SlashHome
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_HOME),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_HOME_TP),
            getFunction = function () return Settings.SlashHome end,
            setFunction = function (value)
                Settings.SlashHome = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashHome
        }

        -- Choose Home Option
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_HOME_CHOICE),
            items = GetHomeItems,
            getFunction = function ()
                return { data = Settings.SlashHomeChoice }
            end,
            setFunction = function (combobox, value, item)
                Settings.SlashHomeChoice = item.data
            end,
            default = Defaults.SlashHomeChoice,
            disable = function () return not Settings.SlashHome end
        }

        -- SlashSetPrimaryHome
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_HOME_SET_PRIMARY),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_HOME_SET_PRIMARY_TP),
            getFunction = function () return Settings.SlashSetPrimaryHome end,
            setFunction = function (value)
                Settings.SlashSetPrimaryHome = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashSetPrimaryHome
        }

        -- SlashCampaignQ
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_CAMPAIGN),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_CAMPAIGN_TP),
            getFunction = function () return Settings.SlashCampaignQ end,
            setFunction = function (value)
                Settings.SlashCampaignQ = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashCampaignQ
        }

        -- SlashCompanion
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_COMPANION),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_COMPANION_TP),
            getFunction = function () return Settings.SlashCompanion end,
            setFunction = function (value)
                Settings.SlashCompanion = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashCompanion,
            disable = function () return #GetCompanionItems() == 0 end
        }

        -- Choose Companion
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_COMPANION_CHOICE),
            items = GetCompanionItems,
            getFunction = function ()
                return { data = Settings.SlashCompanionChoice }
            end,
            setFunction = function (combobox, value, item)
                Settings.SlashCompanionChoice = item.data
            end,
            default = Defaults.SlashCompanionChoice,
            disable = function () return not Settings.SlashCompanion end
        }

        -- SlashBanker
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_BANKER),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_BANKER_TP),
            getFunction = function () return Settings.SlashBanker end,
            setFunction = function (value)
                Settings.SlashBanker = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashBanker,
            disable = function () return #GetBankerItems() == 0 end
        }

        -- Choose Banker
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_BANKER_CHOICE),
            items = GetBankerItems,
            getFunction = function ()
                return { data = Settings.SlashBankerChoice }
            end,
            setFunction = function (combobox, value, item)
                Settings.SlashBankerChoice = item.data
            end,
            default = Defaults.SlashBankerChoice,
            disable = function () return not Settings.SlashBanker end
        }

        -- SlashMerchant
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_MERCHANT),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_MERCHANT_TP),
            getFunction = function () return Settings.SlashMerchant end,
            setFunction = function (value)
                Settings.SlashMerchant = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashMerchant,
            disable = function () return #GetMerchantItems() == 0 end
        }

        -- Choose Merchant
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_MERCHANT_CHOICE),
            items = GetMerchantItems,
            getFunction = function ()
                return { data = Settings.SlashMerchantChoice }
            end,
            setFunction = function (combobox, value, item)
                Settings.SlashMerchantChoice = item.data
            end,
            default = Defaults.SlashMerchantChoice,
            disable = function () return not Settings.SlashMerchant end
        }

        -- SlashArmory
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_ARMORY),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_ARMORY_TP),
            getFunction = function () return Settings.SlashArmory end,
            setFunction = function (value)
                Settings.SlashArmory = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashArmory,
            disable = function () return #GetArmoryItems() == 0 end
        }

        -- Choose Armory
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_ARMORY_CHOICE),
            items = GetArmoryItems,
            getFunction = function ()
                return { data = Settings.SlashArmoryChoice }
            end,
            setFunction = function (combobox, value, item)
                Settings.SlashArmoryChoice = item.data
            end,
            default = Defaults.SlashArmoryChoice,
            disable = function () return not Settings.SlashArmory end
        }

        -- SlashDecon
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_DECON),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_SLASHCMDS_DECON_TP), GetCollectibleName(10184)),
            getFunction = function () return Settings.SlashDecon end,
            setFunction = function (value)
                Settings.SlashDecon = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashDecon,
            disable = function () return #GetDeconItems() == 0 end
        }

        -- Choose Decon
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_DECON_CHOICE),
            items = GetDeconItems,
            getFunction = function ()
                return { data = Settings.SlashDeconChoice }
            end,
            setFunction = function (combobox, value, item)
                Settings.SlashDeconChoice = item.data
            end,
            default = Defaults.SlashDeconChoice,
            disable = function () return not Settings.SlashDecon end
        }

        -- SlashFence
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_FENCE),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_SLASHCMDS_FENCE_TP), GetCollectibleName(300)),
            getFunction = function () return Settings.SlashFence end,
            setFunction = function (value)
                Settings.SlashFence = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashFence
        }

        -- SlashEye
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_EYE),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_EYE_TP),
            getFunction = function () return Settings.SlashEye end,
            setFunction = function (value)
                Settings.SlashEye = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashEye
        }

        -- SlashPet
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_PET),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_PET_TP),
            getFunction = function () return Settings.SlashPet end,
            setFunction = function (value)
                Settings.SlashPet = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashPet
        }

        -- SlashPet Message (indented)
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_PET_MESSAGE),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_PET_MESSAGE_TP),
            getFunction = function () return Settings.SlashPetMessage end,
            setFunction = function (value) Settings.SlashPetMessage = value end,
            default = Defaults.SlashPetMessage
        }

        -- SlashOutfit
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_OUTFIT),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_OUTFIT_TP),
            getFunction = function () return Settings.SlashOutfit end,
            setFunction = function (value)
                Settings.SlashOutfit = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashOutfit
        }

        -- SlashReport
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_REPORT),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_REPORT_TP),
            getFunction = function () return Settings.SlashReport end,
            setFunction = function (value)
                Settings.SlashReport = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashReport
        }
    end)

    -- Build Group Commands Options Section
    buildSectionSettings("GroupCommands", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_SLASHCMDSHEADER_GROUP),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_SLASH_GROUP),
        }

        -- SlashReadyCheck
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_READYCHECK),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_READYCHECK_TP),
            getFunction = function () return Settings.SlashReadyCheck end,
            setFunction = function (value)
                Settings.SlashReadyCheck = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashReadyCheck
        }

        -- SlashRegroup
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_REGROUP),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_REGROUP_TP),
            getFunction = function () return Settings.SlashRegroup end,
            setFunction = function (value)
                Settings.SlashRegroup = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashRegroup
        }

        -- SlashDisband
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_DISBAND),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_DISBAND_TP),
            getFunction = function () return Settings.SlashDisband end,
            setFunction = function (value)
                Settings.SlashDisband = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashDisband
        }

        -- SlashGroupLeave
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_LEAVE),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_LEAVE_TP),
            getFunction = function () return Settings.SlashGroupLeave end,
            setFunction = function (value)
                Settings.SlashGroupLeave = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashGroupLeave
        }

        -- SlashGroupKick
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_KICK),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_KICK_TP),
            getFunction = function () return Settings.SlashGroupKick end,
            setFunction = function (value)
                Settings.SlashGroupKick = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashGroupKick
        }

        -- SlashGroupRole
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_ROLE),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_ROLE_TP),
            getFunction = function () return Settings.SlashGroupRole end,
            setFunction = function (value)
                Settings.SlashGroupRole = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashGroupRole
        }

        -- SlashVoteKick
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_VOTEKICK),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_VOTEKICK_TP),
            getFunction = function () return Settings.SlashVoteKick end,
            setFunction = function (value)
                Settings.SlashVoteKick = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashVoteKick
        }
    end)

    -- Build Guild Commands Options Section
    buildSectionSettings("GuildCommands", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_SLASHCMDSHEADER_GUILD),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_SLASH_GUILD),
        }

        -- SlashGuildInvite
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_GUILDINVITE),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_GUILDINVITE_TP),
            getFunction = function () return Settings.SlashGuildInvite end,
            setFunction = function (value)
                Settings.SlashGuildInvite = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashGuildInvite
        }

        -- SlashGuildQuit
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_GUILDQUIT),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_GUILDQUIT_TP),
            getFunction = function () return Settings.SlashGuildQuit end,
            setFunction = function (value)
                Settings.SlashGuildQuit = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashGuildQuit
        }

        -- SlashGuildKick
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_GUILDKICK),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_GUILDKICK_TP),
            getFunction = function () return Settings.SlashGuildKick end,
            setFunction = function (value)
                Settings.SlashGuildKick = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashGuildKick
        }
    end)

    -- Build Social Commands Options Section
    buildSectionSettings("SocialCommands", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_SLASHCMDSHEADER_SOCIAL),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_SLASH_SOCIAL),
        }

        -- SlashFriend
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_FRIEND),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_FRIEND_TP),
            getFunction = function () return Settings.SlashFriend end,
            setFunction = function (value)
                Settings.SlashFriend = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashFriend
        }

        -- SlashIgnore
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_IGNORE),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_IGNORE_TP),
            getFunction = function () return Settings.SlashIgnore end,
            setFunction = function (value)
                Settings.SlashIgnore = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashIgnore
        }

        -- SlashRemoveFriend
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_REMOVEFRIEND),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_REMOVEFRIEND_TP),
            getFunction = function () return Settings.SlashRemoveFriend end,
            setFunction = function (value)
                Settings.SlashRemoveFriend = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashRemoveFriend
        }

        -- SlashRemoveIgnore
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_REMOVEIGNORE),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_REMOVEIGNORE_TP),
            getFunction = function () return Settings.SlashRemoveIgnore end,
            setFunction = function (value)
                Settings.SlashRemoveIgnore = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashRemoveIgnore
        }
    end)

    -- Build Holiday XP Events Commands Options Section
    buildSectionSettings("HolidayCommands", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_SLASHCMDSHEADER_HOLIDAY),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_SLASH_HOLIDAY),
        }

        -- SlashCake
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_CAKE),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_CAKE_TP),
            getFunction = function () return Settings.SlashCake end,
            setFunction = function (value)
                Settings.SlashCake = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashCake
        }

        -- SlashPie
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_PIE),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_PIE_TP),
            getFunction = function () return Settings.SlashPie end,
            setFunction = function (value)
                Settings.SlashPie = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashPie
        }

        -- SlashMead
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_MEAD),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_MEAD_TP),
            getFunction = function () return Settings.SlashMead end,
            setFunction = function (value)
                Settings.SlashMead = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashMead
        }

        -- SlashWitch
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_SLASHCMDS_WITCH),
            tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_WITCH_TP),
            getFunction = function () return Settings.SlashWitch end,
            setFunction = function (value)
                Settings.SlashWitch = value
                SlashCommands.RegisterSlashCommands()
            end,
            default = Defaults.SlashWitch
        }
    end)

    local allSettings = {}
    SettingsAPI:AppendSettingsList(allSettings, initialSettings)
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_SLASHCMDSHEADER_GENERAL), sectionGroups["GeneralCommands"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_SLASHCMDSHEADER_GROUP), sectionGroups["GroupCommands"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_SLASHCMDSHEADER_GUILD), sectionGroups["GuildCommands"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_SLASHCMDSHEADER_SOCIAL), sectionGroups["SocialCommands"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_SLASHCMDSHEADER_HOLIDAY), sectionGroups["HolidayCommands"])
    panel:AddSettings(allSettings)
end
