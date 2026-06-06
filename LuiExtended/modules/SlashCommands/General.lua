-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local CampaignNames = {}

--- @class (partial) LUIE.SlashCommands
local SlashCommands = LUIE.SlashCommands

local ChatOutput = LUIE.ChatOutput
local zo_strformat = zo_strformat
local pairs = pairs

local companionKeys = {}
for id, name in pairs(LuiData.Data.CollectibleTables.Companions) do
    companionKeys[name] = id
end

local ChatAnnouncements = LUIE.ChatAnnouncements

--- @param alertKey string
--- @return boolean
local function NotifyAlertEnabled(alertKey)
    return ChatAnnouncements and ChatAnnouncements.SV and ChatAnnouncements.SV.Notify and ChatAnnouncements.SV.Notify[alertKey]
end

--- @param message string
--- @param isError boolean
local function SlashHomeAlert(message, isError)
    if NotifyAlertEnabled("SlashHomeAlert") then
        ChatAnnouncements.AnnounceNotifyAlert(message, isError and UI_ALERT_CATEGORY_ERROR or UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE)
    end
end

--- @param message string
--- @param isError boolean
local function SlashCampaignAlert(message, isError)
    if NotifyAlertEnabled("SlashCampaignAlert") then
        ChatAnnouncements.AnnounceNotifyAlert(message, isError and UI_ALERT_CATEGORY_ERROR or UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE)
    end
end

--- @param message string
--- @param isError boolean
local function OutfitEquipSlashAlert(message, isError)
    if NotifyAlertEnabled("OutfitEquipAlert") then
        ChatAnnouncements.AnnounceNotifyAlert(message, isError and UI_ALERT_CATEGORY_ERROR or UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE)
    end
end

-- Slash Command to port to primary home
function SlashCommands.SlashHome(option)
    -- Check option is valid if it exists
    -- Return an error message if no input is entered.
    if option and option ~= "" then
        if option ~= "inside" and option ~= "outside" then
            ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_HOME_TRAVEL_FAILED_OPTION), true)
            SlashHomeAlert(GetString(LUIE_STRING_SLASHCMDS_HOME_TRAVEL_FAILED_OPTION), true)
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
            return
        end
    end

    local primaryHouse = GetHousingPrimaryHouse()
    -- Check if we are in combat
    if IsUnitInCombat("player") then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_HOME_TRAVEL_FAILED_IN_COMBAT), true)
        SlashHomeAlert(GetString(LUIE_STRING_SLASHCMDS_HOME_TRAVEL_FAILED_IN_COMBAT), true)
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    -- Check to make sure we're not in Imperial City
    if IsInImperialCity() then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_HOME_TRAVEL_FAILED_IC), true)
        SlashHomeAlert(GetString(LUIE_STRING_SLASHCMDS_HOME_TRAVEL_FAILED_IC), true)
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    -- Check to make sure we're not in Cyrodiil
    if IsPlayerInAvAWorld() then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_HOME_TRAVEL_FAILED_AVA), true)
        SlashHomeAlert(GetString(LUIE_STRING_SLASHCMDS_HOME_TRAVEL_FAILED_AVA), true)
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    -- Check to make sure we're not in a battleground
    if IsActiveWorldBattleground() then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_HOME_TRAVEL_FAILED_BG), true)
        SlashHomeAlert(GetString(LUIE_STRING_SLASHCMDS_HOME_TRAVEL_FAILED_BG), true)
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    -- Check if user set a primary home
    if primaryHouse == 0 then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_HOME_TRAVEL_FAILED_NOHOME), true)
        SlashHomeAlert(GetString(LUIE_STRING_SLASHCMDS_HOME_TRAVEL_FAILED_NOHOME), true)
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    else
        -- Check whether we should be porting inside or outside
        local outside
        if option and (option == "inside" or option == "outside") then
            if option == "inside" then
                outside = false
            elseif option == "outside" then
                outside = true
            end
        else
            outside = SlashCommands.SV.SlashHomeChoice == 2 and true or false
        end
        ChatAnnouncements.SetPendingHomeJump(true)
        RequestJumpToHouse(primaryHouse, outside)
        local string = outside and GetString(LUIE_STRING_SLASHCMDS_HOME_TRAVEL_SUCCESS_MSG_OUT) or GetString(LUIE_STRING_SLASHCMDS_HOME_TRAVEL_SUCCESS_MSG_IN)
        ChatOutput:Print(string, true)
        SlashHomeAlert(string, false)
    end
end

function SlashCommands.SlashSetPrimaryHome()
    local currentHouse = GetCurrentZoneHouseId()
    if currentHouse ~= nil and currentHouse > 0 then
        local houseName = GetPlayerActiveZoneName()
        if IsOwnerOfCurrentHouse() then
            if IsPrimaryHouse(currentHouse) then
                ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_SLASHCMDS_SET_HOME_FAILED_ALREADY), houseName), true)
                SlashHomeAlert(zo_strformat(GetString(LUIE_STRING_SLASHCMDS_SET_HOME_FAILED_ALREADY), houseName), true)
                PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
                return
            else
                SetHousingPrimaryHouse(currentHouse)
                ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_SLASHCMDS_SET_HOME_SUCCESS_MSG), houseName), true)
                SlashHomeAlert(zo_strformat(GetString(LUIE_STRING_SLASHCMDS_SET_HOME_SUCCESS_MSG), houseName), false)
            end
        else
            ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_SET_HOME_FAILED_NOT_OWNER), true)
            SlashHomeAlert(GetString(LUIE_STRING_SLASHCMDS_SET_HOME_FAILED_NOT_OWNER), true)
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
            return
        end
    else
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_SET_HOME_FAILED_NOHOME), true)
        SlashHomeAlert(GetString(LUIE_STRING_SLASHCMDS_SET_HOME_FAILED_NOHOME), true)
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
end

-- Slash Command to initiate a trade dialogue
function SlashCommands.SlashTrade(option)
    if option == "" or option == nil then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_TRADE_FAILED_NONAME), true)
        if LUIE.ChatAnnouncements.SV.Notify.NotificationTradeAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, (GetString(LUIE_STRING_SLASHCMDS_TRADE_FAILED_NONAME)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    TradeInviteByName(option)
end

local firstRun = true -- Changed by SlashCommands.SlashCampaignQ() when called, used to index available campaigns.

-- Slash Command to queue for a campaign
function SlashCommands.SlashCampaignQ(option)
    -- Return an error message if no input is entered.
    if option == "" or option == nil then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_CAMPAIGN_FAILED_NONAME), true)
        SlashCampaignAlert(GetString(LUIE_STRING_SLASHCMDS_CAMPAIGN_FAILED_NONAME), true)
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    -- Return an error message if the player is in a battleground (can't queue for campaigns in a battleground).
    if IsActiveWorldBattleground() then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_CAMPAIGN_FAILED_BG), true)
        SlashCampaignAlert(GetString(LUIE_STRING_SLASHCMDS_CAMPAIGN_FAILED_BG), true)
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    -- The first time we call this function and it passes a check to make sure input is valid, fill a table with campaign names and their corresponding id.
    if firstRun then
        firstRun = false
        for i = 1, 200 do
            -- TODO: Find a way to determine # of campaigns dynamically instead of iterating.
            local campaignName = zo_strlower(GetCampaignName(i))
            if campaignName ~= "" and campaignName ~= nil then
                CampaignNames[campaignName] = i
            end
        end
    end

    -- If input is valid and the name is in the campaign table, try to queue for the campaign.
    local optionLower = zo_strlower(option)
    if CampaignNames[optionLower] then
        local campaignId = CampaignNames[optionLower]
        local campaignName = GetCampaignName(campaignId)

        if GetAssignedCampaignId() == campaignId then
            local queueAsGroup
            QueueForCampaign(campaignId, queueAsGroup)
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_SLASHCMDS_CAMPAIGN_QUEUE), campaignName), true)
            SlashCampaignAlert(zo_strformat(GetString(LUIE_STRING_SLASHCMDS_CAMPAIGN_QUEUE), campaignName), false)
            return
        else
            ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_CAMPAIGN_FAILED_NOT_ENTERED), true)
            SlashCampaignAlert(GetString(LUIE_STRING_SLASHCMDS_CAMPAIGN_FAILED_NOT_ENTERED), true)
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
            return
        end
    end

    -- Otherwise, return an error message that the campaign doesn't exist.
    ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_CAMPAIGN_FAILED_WRONGCAMPAIGN), true)
    SlashCampaignAlert(GetString(LUIE_STRING_SLASHCMDS_CAMPAIGN_FAILED_WRONGCAMPAIGN), true)
    PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
end

-- Slash Command to use collectibles based on their collectible id
function SlashCommands.SlashCollectible(id)
    if id == nil or id == "" or id == 1 then
        return
    end

    -- Check to make sure we're not in Imperial City
    if IsInImperialCity() then
        ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_FAILED_IC), GetCollectibleName(id)), true)
        SlashHomeAlert(zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_FAILED_IC), GetCollectibleName(id)), true)
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    -- Check to make sure we're not in Cyrodiil
    if IsPlayerInAvAWorld() then
        ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_FAILED_AVA), GetCollectibleName(id)), true)
        SlashHomeAlert(zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_FAILED_AVA), GetCollectibleName(id)), true)
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    -- Check to make sure we're not in a battleground
    if IsActiveWorldBattleground() then
        ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_FAILED_BG), GetCollectibleName(id)), true)
        SlashHomeAlert(zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_FAILED_BG), GetCollectibleName(id)), true)
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    -- If this is a Banker/Merchant/Fence/Armory/Deconstruction/Companion and we are
    -- in a player home then display a message that the collectible can't be used here.
    if LuiData.Data.CollectibleTables.All[id] ~= nil then
        local currentHouse = GetCurrentZoneHouseId()
        if currentHouse ~= nil and currentHouse > 0 then
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_FAILED_HOME), GetCollectibleName(id)), true)
            SlashHomeAlert(zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_FAILED_HOME), GetCollectibleName(id)), true)
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
            return
        end
    end

    if IsCollectibleUnlocked(id) then
        UseCollectible(id, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        LUIE.SlashCollectibleOverride = true
        if LuiData.Data.CollectibleTables.All[id] == nil then
            LUIE.LastMementoUsed = id
        end
    else
        ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_FAILED_NOTUNLOCKED), GetCollectibleName(id)), true)
        SlashHomeAlert(zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_FAILED_NOTUNLOCKED), GetCollectibleName(id)), true)
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
end

function SlashCommands.SlashCompanion(option)
    if option == nil or option == "" then
        SlashCommands.SlashCollectible(SlashCommands.SV.SlashCompanionChoice)
    elseif companionKeys[option] ~= nil then
        SlashCommands.SlashCollectible(companionKeys[option])
    end
end

function SlashCommands.SlashBanker()
    SlashCommands.SlashCollectible(SlashCommands.SV.SlashBankerChoice)
end

function SlashCommands.SlashMerchant()
    SlashCommands.SlashCollectible(SlashCommands.SV.SlashMerchantChoice)
end

function SlashCommands.SlashArmory()
    SlashCommands.SlashCollectible(SlashCommands.SV.SlashArmoryChoice)
end

function SlashCommands.SlashDecon()
    SlashCommands.SlashCollectible(SlashCommands.SV.SlashDeconChoice)
end

local TOOLS_CATEGORY_ID = 66
local cachedCakeId

local function GetJubileeCakeCollectibleId()
    if not cachedCakeId then
        local categoryData = ZO_COLLECTIBLE_DATA_MANAGER:GetCategoryDataById(TOOLS_CATEGORY_ID)
        local numCollectibles = categoryData:GetNumCollectibles()
        if numCollectibles > 0 then
            cachedCakeId = categoryData:GetCollectibleDataByIndex(numCollectibles):GetId()
        end
    end
    return cachedCakeId
end

function SlashCommands.SlashCake()
    SlashCommands.SlashCollectible(GetJubileeCakeCollectibleId())
end

-- Slash Command to equip a chosen outfit by number
function SlashCommands.SlashOutfit(option)
    if option == "" or option == nil then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_OUTFIT_NOT_VALID))
        OutfitEquipSlashAlert(GetString(LUIE_STRING_SLASHCMDS_OUTFIT_NOT_VALID), true)
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    local valid = tonumber(option)
    if not valid or valid > 10 then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_OUTFIT_NOT_VALID))
        OutfitEquipSlashAlert(GetString(LUIE_STRING_SLASHCMDS_OUTFIT_NOT_VALID), true)
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    local numOutfits = GetNumUnlockedOutfits(GAMEPLAY_ACTOR_CATEGORY_PLAYER)

    if valid > numOutfits then
        ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_SLASHCMDS_OUTFIT_NOT_UNLOCKED), valid))
        OutfitEquipSlashAlert(zo_strformat(GetString(LUIE_STRING_SLASHCMDS_OUTFIT_NOT_UNLOCKED), valid), true)
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    EquipOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER, valid)
    -- Chat confirmation; top-right alert is handled by EVENT_OUTFIT_EQUIP_RESPONSE when enabled.
    local name = GetOutfitName(GAMEPLAY_ACTOR_CATEGORY_PLAYER, valid)
    if name == "" then
        name = zo_strformat("<<1>> <<2>>", GetString(SI_CROWN_STORE_SEARCH_ADDITIONAL_OUTFITS), valid)
    end
    ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_SLASHCMDS_OUTFIT_CONFIRMATION), name))
end

-- Slash Command to report a player by given name and attach useful information
function SlashCommands.SlashReport(player)
    local location = GetPlayerLocationName()
    local currenttime = GetTimeString()
    local currentdate = GetDateStringFromTimestamp(GetTimeStamp())
    local server = GetWorldName()
    local text = "I've encountered a suspicious player.\n\nName: <<1>>\nLocation: <<2>>\nDate & Time: <<3>> <<4>>\nServer: <<5>>"

    -- Set the category to report a player
    HELP_CUSTOMER_SERVICE_ASK_FOR_HELP_KEYBOARD:SelectCategory(2)
    -- Set the subcategory (default: Other)
    HELP_CUSTOMER_SERVICE_ASK_FOR_HELP_KEYBOARD:SelectSubcategory(4)

    -- Populate the reporting window name and description
    ZO_Help_Ask_For_Help_Keyboard_Control:GetNamedChild("DetailsTextLineField"):SetText(player)
    ZO_Help_Ask_For_Help_Keyboard_Control:GetNamedChild("DescriptionBodyField"):SetText(zo_strformat(text, player, location, currentdate, currenttime, server))

    -- Open the reporting window
    HELP_CUSTOMER_SUPPORT_KEYBOARD:OpenScreen(HELP_CUSTOMER_SERVICE_ASK_FOR_HELP_KEYBOARD_FRAGMENT)
end

local petIds =
{
    [23304] = "[Familiar]",           -- Summon Unstable Familiar (Sorcerer)
    [23319] = "[Clannfear]",          -- Summon Unstable Clannfear (Sorcerer)
    [23316] = "[Volatile Familiar]",  -- Summon Volatile Familiar (Sorcerer)
    [24613] = "[Winged Twilight]",    -- Summon Winged Twilight (Sorcerer)
    [24636] = "[Twilight Tormentor]", -- Summon Twilight Tormentor (Sorcerer)
    [24639] = "[Twilight Matriarch]", -- Summon Twilight Matriarch (Sorcerer)
    [85982] = "[Feral Guardian]",     -- Feral Guardian (Warden)
    [85986] = "[Eternal Guardian]",   -- Eternal Guardian (Warden)
    [85990] = "[Wild Guardian]",      -- Wild Guardian (Warden)
}

-- Slash Command to dismiss pets and optionally non-combat pets
function SlashCommands.SlashPet()
    for i = 1, GetNumBuffs("player") do
        local _, _, _, buffSlot, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        if petIds[abilityId] then
            CancelBuff(buffSlot)
            if SlashCommands.SV.SlashPetMessage then
                local petName = petIds[abilityId]
                local message = zo_strformat(GetString(LUIE_STRING_DISMISS_PET), petName)
                ChatOutput:Print(message)
            end
        end
    end
end

LUIE.CampaignNames = CampaignNames
