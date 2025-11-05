-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local printToChat = LUIE.PrintToChat
local Debug = LUIE.Debug

local LuiData = LuiData
--- @type Data
local Data = LuiData.Data
--- @type CrownStoreCollectibles
local isShopCollectible = Data.CrownStoreCollectibles
--- @type Effects
local Effects = Data.Effects
--- @type Quests
local Quests = Data.Quests

-- -----------------------------------------------------------------------------
-- ESO API Locals.
-- -----------------------------------------------------------------------------

local eventManager = GetEventManager()
local windowManager = GetWindowManager()
local GetString = GetString
local zo_strformat = zo_strformat


--- @class (partial) ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements
local moduleName = ChatAnnouncements.moduleName

---
--- @param topLevelIndex integer
--- @return string name
local function GetAchievementCategoryInfoName(topLevelIndex)
    local AchievementCategoryInfo = { GetAchievementCategoryInfo(topLevelIndex) }
    local name = AchievementCategoryInfo[1]
    return name
end

---
--- @param topLevelIndex luaindex
--- @param subCategoryIndex luaindex
--- @return string name
local function GetAchievementSubCategoryInfoName(topLevelIndex, subCategoryIndex)
    local AchievementSubCategoryInfo = { GetAchievementSubCategoryInfo(topLevelIndex, subCategoryIndex) }
    local name = AchievementSubCategoryInfo[1]
    return name
end

---
--- @param achievementId integer
--- @return textureName icon
local function GetAchievementInfoIcon(achievementId)
    local AchievementInfo = { GetAchievementInfo(achievementId) }
    local icon = AchievementInfo[4]
    return icon
end

-- Copied from Writ Creator for CSA handling purposes - Only called when WritCreater is detected so shouldn't cause issues
local function isQuestWritQuest(questId)
    local writs = WritCreater.writSearch()
    for k, v in pairs(writs) do
        if v == questId then
            return true
        end
    end
end

-- Copied from Writ Creator for CSA handling purposes - Only called when WritCreater is detected so shouldn't cause issues
local function rejectQuest(questIndex)
    for itemLink, _ in pairs(WritCreater:GetSettings().skipItemQuests) do
        if not WritCreater:GetSettings().skipItemQuests[itemLink] then
            for i = 1, GetJournalQuestNumConditions(questIndex, QUEST_MAIN_STEP_INDEX) do
                if DoesItemLinkFulfillJournalQuestCondition(itemLink, questIndex, 1, i, true) then
                    return itemLink
                end
            end
        end
    end
    return false
end

---
--- @param itemId integer
--- @param stackCount integer
--- @param icon string
--- @param reset boolean
local function DisplayQuestItem(itemId, stackCount, icon, reset)
    -- if LUIE.IsDevDebugEnabled() then
    --     local Debug = LUIE.Debug
    --     local traceback = "Quest Item Details:\n" ..
    --         "--> itemId: " .. tostring(itemId) .. "\n" ..
    --         "--> stackCount: " .. tostring(stackCount) .. "\n" ..
    --         "--> questItemIcon: " .. tostring(icon) .. "\n" ..
    --         "--> reset: " .. tostring(reset)
    --     Debug(traceback)
    -- end
    if not ChatAnnouncements.questItemIndex[itemId] then
        ChatAnnouncements.questItemIndex[itemId] = { stack = 0, counter = 0, icon = icon }
        -- d("New item created with 0 stack")
    end

    if reset then
        -- d(itemId .. " - Decrement by: " .. stackCount)
        ChatAnnouncements.questItemIndex[itemId].counter = ChatAnnouncements.questItemIndex[itemId].counter - stackCount
    else
        -- d(itemId .. " - Increment by: " .. stackCount)
        ChatAnnouncements.questItemIndex[itemId].counter = ChatAnnouncements.questItemIndex[itemId].counter + stackCount
    end
    eventManager:RegisterForUpdate(moduleName .. "QuestItemUpdater", 25, ChatAnnouncements.ResolveQuestItemChange)
end

-- Used by functions calling bar updates
--- @param barParams CenterScreenPlayerProgressBarParams
local function ValidateProgressBarParams(barParams)
    local barType = barParams:GetParams()
    if not (barType and PLAYER_PROGRESS_BAR:GetBarTypeInfoByBarType(barType)) then
        local INVALID_VALUE = -1
        assert(false, string.format("CSAH Bad Bar Params; barType: %d. Triggering Event: %d.", barType or INVALID_VALUE, barParams:GetTriggeringEvent() or INVALID_VALUE))
    end
end

-- Used by functions calling bar updates
local function GetRelevantBarParams(level, previousExperience, currentExperience, championPoints, triggeringEvent)
    local championXpToNextPoint
    if CanUnitGainChampionPoints("player") then
        championXpToNextPoint = GetNumChampionXPInChampionPoint(championPoints)
    end
    if championXpToNextPoint ~= nil and currentExperience > previousExperience then
        local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(PPB_CP, championPoints, previousExperience, currentExperience)
        barParams:SetTriggeringEvent(triggeringEvent)
        return barParams
    else
        local levelSize = GetNumExperiencePointsInLevel(level)
        if levelSize ~= nil and currentExperience > previousExperience then
            local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(PPB_XP, level, previousExperience, currentExperience)
            barParams:SetTriggeringEvent(triggeringEvent)
            return barParams
        end
    end
end

-- Used by functions calling bar updates
local function GetCurrentChampionPointsBarParams(triggeringEvent)
    local championPoints = GetPlayerChampionPointsEarned()
    local currentChampionXP = GetPlayerChampionXP()
    local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(PPB_CP, championPoints, currentChampionXP, currentChampionXP)
    barParams:SetShowNoGain(true)
    barParams:SetTriggeringEvent(triggeringEvent)
    return barParams
end

-- local vars for EVENT_SKILL_XP
local GUILD_SKILL_SHOW_REASONS =
{
    [PROGRESS_REASON_DARK_ANCHOR_CLOSED] = true,
    [PROGRESS_REASON_DARK_FISSURE_CLOSED] = true,
    [PROGRESS_REASON_BOSS_KILL] = true,
}

-- local vars for EVENT_SKILL_XP
local GUILD_SKILL_SHOW_SOUNDS =
{
    [PROGRESS_REASON_DARK_ANCHOR_CLOSED] = SOUNDS.SKILL_XP_DARK_ANCHOR_CLOSED,
    [PROGRESS_REASON_DARK_FISSURE_CLOSED] = SOUNDS.SKILL_XP_DARK_FISSURE_CLOSED,
    [PROGRESS_REASON_BOSS_KILL] = SOUNDS.SKILL_XP_BOSS_KILLED,
}

-- Used by EVENT_SKILL_POINTS_CHANGED (CSA Handler) to ignore skill point updates in certain cases.
local SUPPRESS_SKILL_POINT_CSA_REASONS =
{
    [SKILL_POINT_CHANGE_REASON_IGNORE] = true,
    [SKILL_POINT_CHANGE_REASON_SKILL_RESPEC] = true,
    [SKILL_POINT_CHANGE_REASON_SKILL_RESET] = true,
}

-- EVENT_STYLE_LEARNED (Alert Handler)
local function StyleLearnedHook(itemStyleId, chapterIndex, isDefaultRacialStyle)
    local flag
    if ChatAnnouncements.SV.Inventory.LootShowMotif and ChatAnnouncements.SV.Inventory.LootRecipeHideAlert then
        flag = true
    else
        flag = false
    end

    if not flag then
        if not isDefaultRacialStyle then
            if chapterIndex == ITEM_STYLE_CHAPTER_ALL then
                local text = zo_strformat(SI_NEW_STYLE_LEARNED, GetItemStyleName(itemStyleId))
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
            else
                local text = zo_strformat(SI_NEW_STYLE_CHAPTER_LEARNED, GetItemStyleName(itemStyleId), GetString("SI_ITEMSTYLECHAPTER", chapterIndex))
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
            end
        end
    end
    return true
end

-- EVENT_RECIPE_LEARNED (Alert Handler)
local function RecipeLearnedHook(recipeListIndex, recipeIndex)
    local flag
    if ChatAnnouncements.SV.Inventory.LootShowRecipe and ChatAnnouncements.SV.Inventory.LootRecipeHideAlert then
        flag = true
    else
        flag = false
    end

    if not flag then
        local _, name = GetRecipeInfo(recipeListIndex, recipeIndex)
        local text = zo_strformat(SI_NEW_RECIPE_LEARNED, name)
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.RECIPE_LEARNED, text)
    end
    return true
end

-- EVENT_MULTIPLE_RECIPES_LEARNED (Alert Handler)
--- @param numRecipesUnlocked integer
--- @return boolean|nil
local function MultipleRecipeLearnedHook(numRecipesUnlocked)
    local flag
    if ChatAnnouncements.SV.Inventory.LootShowRecipe and ChatAnnouncements.SV.Inventory.LootRecipeHideAlert then
        flag = true
    else
        flag = false
    end

    if not flag then
        local text = zo_strformat(SI_NEW_RECIPES_LEARNED, numRecipesUnlocked)
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.RECIPE_LEARNED, text)
    end
    return true
end

-- EVENT_LORE_BOOK_ALREADY_KNOWN (Alert Handler)
-- Note: We just hide this alert because it is pointless pretty much (only ever seen in trigger from server lag)
--- @param bookTitle string
--- @return boolean|nil
local function AlreadyKnowBookHook(bookTitle)
    return true
end

-- EVENT_RIDING_SKILL_IMPROVEMENT (Alert Handler)
-- Note: We allow the CSA handler to handle any changes made from skill books in order to properly throttle all messages, and use the alert handler for stables upgrades.
--- @param ridingSkillType RidingTrainType
--- @param previous integer
--- @param current integer
--- @param source RidingTrainSource
--- @return boolean|nil
local function RidingSkillImprovementAlertHook(ridingSkillType, previous, current, source)
    if source == RIDING_TRAIN_SOURCE_STABLES then
        -- If we purchased from the stables, display a currency announcement if relevant
        if ChatAnnouncements.SV.Currency.CurrencyGoldChange then
            local messageType
            if ridingSkillType == RIDING_TRAIN_SPEED then
                messageType = "LUIE_CURRENCY_RIDING_SPEED"
            elseif ridingSkillType == RIDING_TRAIN_CARRYING_CAPACITY then
                messageType = "LUIE_CURRENCY_RIDING_CAPACITY"
            elseif ridingSkillType == RIDING_TRAIN_STAMINA then
                messageType = "LUIE_CURRENCY_RIDING_STAMINA"
            end
            local formattedValue = ZO_CommaDelimitDecimalNumber(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER) + 250)
            local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ChatAnnouncements.Colors.CurrencyDownColorize:ToHex() or ChatAnnouncements.Colors.CurrencyColorize:ToHex()
            local changeType = ZO_CommaDelimitDecimalNumber(250)
            local currencyTypeColor = ChatAnnouncements.Colors.CurrencyGoldColorize:ToHex()
            local currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetKeyboardCurrencyIcon(CURT_MONEY), 16, 16) or ""
            local currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyGoldName, 250)
            local currencyTotal = ChatAnnouncements.SV.Currency.CurrencyGoldShowTotal
            local messageTotal = ChatAnnouncements.SV.Currency.CurrencyMessageTotalGold
            local messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageStable
            ChatAnnouncements.CurrencyPrinter(nil, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, messageType, nil, nil)
        end

        if ChatAnnouncements.SV.Notify.StorageRidingCA then
            local formattedString = ChatAnnouncements.Colors.StorageRidingColorize:Colorize(zo_strformat(SI_RIDING_SKILL_ANNOUCEMENT_SKILL_INCREASE, GetString("SI_RIDINGTRAINTYPE", ridingSkillType), previous, current))
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = formattedString,
                messageType = "MESSAGE"
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Notify.StorageRidingAlert then
            local text = zo_strformat(SI_RIDING_SKILL_ANNOUCEMENT_SKILL_INCREASE, GetString("SI_RIDINGTRAINTYPE", ridingSkillType), previous, current)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
        end

        if ChatAnnouncements.SV.Notify.StorageRidingCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
            messageParams:SetText(GetString(SI_RIDING_SKILL_ANNOUCEMENT_BANNER), zo_strformat(SI_RIDING_SKILL_ANNOUCEMENT_SKILL_INCREASE, GetString("SI_RIDINGTRAINTYPE", ridingSkillType), previous, current))
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RIDING_SKILL_IMPROVEMENT)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end
    end
    return true
end

-- EVENT_LORE_BOOK_LEARNED (Alert Handler)
---
--- @param categoryIndex luaindex
--- @param collectionIndex luaindex
--- @param bookIndex luaindex
--- @param guildIndex luaindex
--- @param isMaxRank boolean
--- @return boolean|nil
local function LoreBookLearnedAlertHook(categoryIndex, collectionIndex, bookIndex, guildIndex, isMaxRank)
    -- if LUIE.IsDevDebugEnabled() then
    --     local Debug = LUIE.Debug
    --     local traceback = "Lore Book Learned Alert Hook:\n" ..
    --         "--> categoryIndex: " .. tostring(categoryIndex) .. "\n" ..
    --         "--> collectionIndex: " .. tostring(collectionIndex) .. "\n" ..
    --         "--> bookIndex: " .. tostring(bookIndex) .. "\n" ..
    --         "--> guildIndex: " .. tostring(guildIndex) .. "\n" ..
    --         "--> isMaxRank: " .. tostring(isMaxRank)
    --     Debug(traceback)
    -- end
    if guildIndex == 0 or isMaxRank then
        -- We only want to fire this event if a player is not part of the guild or if they've reached max level in the guild.
        -- Otherwise, the _SKILL_EXPERIENCE version of this event will send a center screen message instead.
        local name, numCollections, categoryId = GetLoreCategoryInfo(categoryIndex)
        if name == "Crafting Motifs" then
            return
        end

        local collectionName, description, numKnownBooks, totalBooks, hidden, gamepadIcon, collectionId = GetLoreCollectionInfo(categoryIndex, collectionIndex)

        if not hidden or ChatAnnouncements.SV.Lorebooks.LorebookShowHidden then
            local title, icon = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
            local bookName
            local bookLink
            if ChatAnnouncements.SV.BracketOptionLorebook == 1 then
                bookName = string.format("%s", title)
                bookLink = string.format("|H0:LINK_TYPE_LUIE_BOOK:%s:%s:%s|h%s|h", categoryIndex, collectionIndex, bookIndex, bookName)
            else
                bookName = string.format("[%s]", title)
                bookLink = string.format("|H1:LINK_TYPE_LUIE_BOOK:%s:%s:%s|h%s|h", categoryIndex, collectionIndex, bookIndex, bookName)
            end

            local stringPrefix
            local csaPrefix
            if categoryIndex == 1 then
                -- Is a lore book
                stringPrefix = ChatAnnouncements.SV.Lorebooks.LorebookPrefix1
                csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(SI_LORE_LIBRARY_ANNOUNCE_BOOK_LEARNED)
            else
                -- Is a normal book
                stringPrefix = ChatAnnouncements.SV.Lorebooks.LorebookPrefix2
                csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(LUIE_STRING_CA_LOREBOOK_BOOK)
            end

            -- Chat Announcement
            if ChatAnnouncements.SV.Lorebooks.LorebookCA then
                local formattedIcon = ChatAnnouncements.SV.Lorebooks.LorebookIcon and ("|t16:16:" .. icon .. "|t ") or ""
                local stringPart1
                local stringPart2
                if stringPrefix ~= "" then
                    stringPart1 = ChatAnnouncements.Colors.LorebookColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", ChatAnnouncements.bracket1[ChatAnnouncements.SV.Lorebooks.LorebookBracket], stringPrefix, ChatAnnouncements.bracket2[ChatAnnouncements.SV.Lorebooks.LorebookBracket]))
                else
                    stringPart1 = ""
                end
                if ChatAnnouncements.SV.Lorebooks.LorebookCategory then
                    stringPart2 = collectionName ~= "" and ChatAnnouncements.Colors.LorebookColorize2:Colorize(zo_strformat(" <<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), collectionName)) or ChatAnnouncements.Colors.LorebookColorize2:Colorize(zo_strformat(" <<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), GetString(SI_WINDOW_TITLE_LORE_LIBRARY)))
                else
                    stringPart2 = ""
                end

                local finalMessage = zo_strformat("<<1>><<2>><<3>><<4>>", stringPart1, formattedIcon, bookLink, stringPart2)
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
                {
                    message = finalMessage,
                    messageType = "COLLECTIBLE"
                }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end

            -- Alert Announcement
            if ChatAnnouncements.SV.Lorebooks.LorebookAlert then
                local text = collectionName ~= "" and zo_strformat("<<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), collectionName) or zo_strformat(" <<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), GetString(SI_WINDOW_TITLE_LORE_LIBRARY))
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat("<<1>> <<2>>", title, text))
            end

            -- Center Screen Announcement
            if ChatAnnouncements.SV.Lorebooks.LorebookCSA then
                -- Only display a CSA if this is a Lore Book and we have Eidetic Memory books set to not show.
                if (categoryIndex == 1 and ChatAnnouncements.SV.Lorebooks.LorebookCSALoreOnly) or not ChatAnnouncements.SV.Lorebooks.LorebookCSALoreOnly then
                    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.BOOK_ACQUIRED)
                    if collectionName ~= "" then
                        messageParams:SetText(csaPrefix, zo_strformat(LUIE_STRING_CA_LOREBOOK_ADDED_CSA, title, collectionName))
                    else
                        messageParams:SetText(csaPrefix, zo_strformat(LUIE_STRING_CA_LOREBOOK_ADDED_CSA, title, GetString(SI_WINDOW_TITLE_LORE_LIBRARY)))
                    end
                    messageParams:SetIconData(icon, "EsoUI/Art/Achievements/achievements_iconBG.dds")
                    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_LORE_BOOK_LEARNED)
                    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                end
            end
            if not ChatAnnouncements.SV.Lorebooks.LorebookCSA then
                PlaySound(SOUNDS.BOOK_ACQUIRED)
            end
        end
    end
    return true
end

-----------------------------
-- DUEL ALERTS --------------
-----------------------------

-- EVENT_DUEL_INVITE_RECEIVED (Alert Handler)
local function DuelInviteReceivedAlert(inviterCharacterName, inviterDisplayName)
    -- Display CA
    if ChatAnnouncements.SV.Social.DuelCA then
        local finalName = ChatAnnouncements.ResolveNameLink(inviterCharacterName, inviterDisplayName)
        printToChat(zo_strformat(GetString(LUIE_STRING_CA_DUEL_INVITE_RECEIVED), finalName), true)
    end

    -- Display Alert
    if ChatAnnouncements.SV.Social.DuelAlert then
        local finalAlertName = ChatAnnouncements.ResolveNameNoLink(inviterCharacterName, inviterDisplayName)
        local formattedString = zo_strformat(GetString(LUIE_STRING_CA_DUEL_INVITE_RECEIVED), finalAlertName)
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, formattedString)
    end

    return true
end

-- EVENT_DUEL_INVITE_ACCEPTED (Alert Handler)
local function DuelInviteAcceptedAlert()
    -- Display CA
    if ChatAnnouncements.SV.Social.DuelCA then
        printToChat(GetString(LUIE_STRING_CA_DUEL_INVITE_ACCEPTED), true)
    end

    -- Display Alert
    if ChatAnnouncements.SV.Social.DuelAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_DUEL_INVITE_ACCEPTED))
    end
    PlaySound(SOUNDS.DUEL_ACCEPTED)
    return true
end

-- EVENT_DUEL_INVITE_SENT (Alert Handler)
local function DuelInviteSentAlert(inviteeCharacterName, inviteeDisplayName)
    -- Display CA
    if ChatAnnouncements.SV.Social.DuelCA then
        local finalName = ChatAnnouncements.ResolveNameLink(inviteeCharacterName, inviteeDisplayName)
        printToChat(zo_strformat(GetString(LUIE_STRING_CA_DUEL_INVITE_SENT), finalName), true)
    end

    -- Display Alert
    if ChatAnnouncements.SV.Social.DuelAlert then
        local finalAlertName = ChatAnnouncements.ResolveNameNoLink(inviteeCharacterName, inviteeDisplayName)
        local formattedString = zo_strformat(GetString(LUIE_STRING_CA_DUEL_INVITE_SENT), finalAlertName)
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, formattedString)
    end
    return true
end

-- Register Strings here for Alert and CSA Handlers

-- Player to Player replacement strings for Duels
SafeAddString(SI_PLAYER_TO_PLAYER_INCOMING_DUEL, GetString(LUIE_STRING_CA_DUEL_INVITE_RECEIVED), 5)
SafeAddString(SI_DUEL_INVITE_MESSAGE, GetString(LUIE_STRING_CA_DUEL_INVITE_RECEIVED), 5)
SafeAddString(SI_PLAYER_TO_PLAYER_INVITE_DUEL, GetString(LUIE_STRING_CA_DUEL_INVITE_PLAYER), 5)
-- These are likely a standard error response string for Duels
SafeAddString(SI_DUELSTATE1, GetString(LUIE_STRING_CA_DUEL_STATE1), 5)
SafeAddString(SI_DUELSTATE1, GetString(LUIE_STRING_CA_DUEL_STATE2), 5)
-- Group Player to Player notification replacement
SafeAddString(SI_PLAYER_TO_PLAYER_INCOMING_GROUP, GetString(LUIE_STRING_CA_GROUP_INVITE_MESSAGE), 5)
-- Guild Invite Player to Player notification replacements
SafeAddString(SI_PLAYER_TO_PLAYER_INCOMING_GUILD_REQUEST, GetString(LUIE_STRING_CA_GUILD_INCOMING_GUILD_REQUEST), 1)
SafeAddString(SI_GUILD_INVITE_MESSAGE, GetString(LUIE_STRING_CA_GUILD_INVITE_MESSAGE), 3)
-- Friend Invite String Replacements
SafeAddString(SI_PLAYER_TO_PLAYER_INCOMING_FRIEND_REQUEST, GetString(LUIE_STRING_CA_FRIENDS_INCOMING_FRIEND_REQUEST), 5)
-- Quest Share String Replacements
SafeAddString(SI_PLAYER_TO_PLAYER_INCOMING_QUEST_SHARE, GetString(LUIE_STRING_CA_GROUP_INCOMING_QUEST_SHARE_P2P), 5)
SafeAddString(SI_QUEST_SHARE_MESSAGE, GetString(LUIE_STRING_CA_GROUP_INCOMING_QUEST_SHARE_P2P), 5)
-- Trade String Replacements
SafeAddString(SI_PLAYER_TO_PLAYER_INCOMING_TRADE, GetString(LUIE_STRING_CA_TRADE_INVITE_MESSAGE), 1)
SafeAddString(SI_TRADE_INVITE_MESSAGE, GetString(LUIE_STRING_CA_TRADE_INVITE_MESSAGE), 1)
-- Mail String Replacements
SafeAddString(SI_SENDMAILRESULT2, GetString(LUIE_STRING_CA_MAIL_SENDMAILRESULT2), 5)
SafeAddString(SI_SENDMAILRESULT3, GetString(LUIE_STRING_CA_MAIL_SENDMAILRESULT3), 5)

-- EVENT_DUEL_INVITE_FAILED (Alert Handler)
local function DuelInviteFailedAlert(reason, targetCharacterName, targetDisplayName)
    local userFacingName = ZO_GetPrimaryPlayerNameWithSecondary(targetDisplayName, targetCharacterName)
    -- Display CA
    if ChatAnnouncements.SV.Social.DuelCA then
        local finalName = ChatAnnouncements.ResolveNameLink(targetCharacterName, targetDisplayName)
        if userFacingName then
            printToChat(zo_strformat(GetString("LUIE_STRING_CA_DUEL_INVITE_FAILREASON", reason), finalName), true)
        else
            printToChat(zo_strformat(GetString("LUIE_STRING_CA_DUEL_INVITE_FAILREASON", reason)), true)
        end
    end

    -- Display Alert
    if ChatAnnouncements.SV.Social.DuelAlert then
        local finalAlertName = ChatAnnouncements.ResolveNameNoLink(targetCharacterName, targetDisplayName)
        local formattedString = zo_strformat(GetString("LUIE_STRING_CA_DUEL_INVITE_FAILREASON", reason), finalAlertName)
        if userFacingName then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, formattedString)
        else
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString("LUIE_STRING_CA_DUEL_INVITE_FAILREASON", reason)))
        end
    end
    PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    return true
end

-- EVENT_DUEL_INVITE_DECLINED (Alert Handler)
local function DuelInviteDeclinedAlert()
    -- Display CA
    if ChatAnnouncements.SV.Social.DuelCA then
        printToChat(GetString(LUIE_STRING_CA_DUEL_INVITE_DECLINED), true)
    end

    -- Display Alert
    if ChatAnnouncements.SV.Social.DuelAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, GetString(LUIE_STRING_CA_DUEL_INVITE_DECLINED))
    end
    PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    return true
end

-- EVENT_DUEL_INVITE_CANCELED (Alert Handler)
local function DuelInviteCanceledAlert()
    -- Display CA
    if ChatAnnouncements.SV.Social.DuelCA then
        printToChat(GetString(LUIE_STRING_CA_DUEL_INVITE_CANCELED), true)
    end

    -- Display Alert
    if ChatAnnouncements.SV.Social.DuelAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, GetString(LUIE_STRING_CA_DUEL_INVITE_CANCELED))
    end
    PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    return true
end

-- EVENT_PLEDGE_OF_MARA_RESULT (Alert Handler)
local function PledgeOfMaraResultAlert(result, characterName, displayName)
    -- Note: We replace everything here and move it all into the CSA handler event
    return true
end

-- EVENT_GROUP_INVITE_RESPONSE (Alert Handler)
local function GroupInviteResponseAlert(characterName, response, displayName)
    if response ~= GROUP_INVITE_RESPONSE_ACCEPTED and response ~= GROUP_INVITE_RESPONSE_CONSIDERING_OTHER then
        local message
        local alertMessage
        local finalName
        local finalAlertName

        if response == GROUP_INVITE_RESPONSE_ALREADY_GROUPED_CANT_JOIN then
            finalName = characterName
            finalAlertName = characterName
        else
            local nameCheck1 = ZO_GetPrimaryPlayerName(displayName, characterName, false)
            local nameCheck2 = ZO_GetSecondaryPlayerName(displayName, characterName, false)

            if nameCheck1 == "" then
                finalName = displayName
                finalAlertName = displayName
            elseif nameCheck2 == "" then
                finalName = characterName
                finalAlertName = characterName
            elseif nameCheck1 ~= "" and nameCheck2 ~= "" then
                finalName = ChatAnnouncements.ResolveNameLink(characterName, displayName)
                finalAlertName = ChatAnnouncements.ResolveNameNoLink(characterName, displayName)
            else
                finalName = ""
                finalAlertName = ""
            end
        end

        if response == GROUP_INVITE_RESPONSE_ALREADY_GROUPED and (LUIE.PlayerNameFormatted == characterName or LUIE.PlayerDisplayName == displayName) then
            message = zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_SELF_INVITE))
            alertMessage = zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_SELF_INVITE))
        elseif response == GROUP_INVITE_RESPONSE_ALREADY_GROUPED and (IsPlayerInGroup(characterName) or IsPlayerInGroup(displayName)) then
            message = GetString(SI_GROUP_ALERT_INVITE_PLAYER_ALREADY_MEMBER)
            alertMessage = GetString(SI_GROUP_ALERT_INVITE_PLAYER_ALREADY_MEMBER)
        elseif response == GROUP_INVITE_RESPONSE_IGNORED then
            message = finalName ~= "" and zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", response), finalName) or GetString(SI_PLAYER_BUSY)
            alertMessage = finalAlertName ~= "" and zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", response), finalAlertName) or GetString(SI_PLAYER_BUSY)
        else
            message = finalName ~= "" and zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", response), finalName) or characterName ~= "" and zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", response), characterName) or GetString(SI_PLAYER_BUSY)
            alertMessage = finalAlertName ~= "" and zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", response), finalAlertName) or characterName ~= "" and zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", response), characterName) or GetString(SI_PLAYER_BUSY)
        end

        if ChatAnnouncements.SV.Group.GroupCA or response == GROUP_INVITE_RESPONSE_ALREADY_GROUPED or response == GROUP_INVITE_RESPONSE_ALREADY_GROUPED_CANT_JOIN or response == GROUP_INVITE_RESPONSE_IGNORED or response == GROUP_INVITE_RESPONSE_PLAYER_NOT_FOUND then
            printToChat(message, true)
        end
        if ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertMessage)
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    end
    return true
end

-- EVENT_GROUP_INVITE_ACCEPT_RESPONSE_TIMEOUT (Alert Handler)
local function GroupInviteTimeoutAlert()
    printToChat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_GENERIC_JOIN_FAILURE), true)
    if ChatAnnouncements.SV.Group.GroupAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_GENERIC_JOIN_FAILURE))
    end
    PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    return true
end

-- EVENT_GROUP_NOTIFICATION_MESSAGE (Alert Handler)
local function GroupNotificationMessageAlert(groupMessageCode)
    local message = GetString("SI_GROUPNOTIFICATIONMESSAGE", groupMessageCode)
    if message ~= "" then
        printToChat(message, true)
        if ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, message)
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    end
    return true
end

-- EVENT_GROUP_UPDATE (Alert Handler)
local function GroupUpdateAlert()
    ChatAnnouncements.currentGroupLeaderRawName = GetRawUnitName(GetGroupLeaderUnitTag())
    ChatAnnouncements.currentGroupLeaderDisplayName = GetUnitDisplayName(GetGroupLeaderUnitTag())
end

-- EVENT_GROUP_MEMBER_LEFT (Alert Handler)
local function GroupMemberLeftAlert(characterName, reason, isLocalPlayer, isLeader, displayName, actionRequiredVote)
    ChatAnnouncements.IndexGroupLoot()

    local message = nil
    local alert = nil
    local message2 = nil
    local alert2 = nil
    local sound = SOUNDS.NONE

    local finalName = ChatAnnouncements.ResolveNameLink(characterName, displayName)
    local finalAlertName = ChatAnnouncements.ResolveNameNoLink(characterName, displayName)

    -- Used to check for valid links
    local characterNameLink = ZO_LinkHandler_CreateCharacterLink(characterName)
    local displayNameLink = ZO_LinkHandler_CreateDisplayNameLink(displayName)

    local hasValidNames = characterNameLink ~= "" and displayNameLink ~= ""
    local useDefaultReasonText = false
    if reason == GROUP_LEAVE_REASON_DISBAND then
        if isLeader and not isLocalPlayer then
            useDefaultReasonText = true
        elseif isLeader and isLocalPlayer then
            message = zo_strformat(LUIE_STRING_GROUPDISBANDLEADER)
            alert = zo_strformat(LUIE_STRING_GROUPDISBANDLEADER)
            zo_callLater(function ()
                             ChatAnnouncements.CheckLFGStatusLeave(false)
                         end, 100)
        elseif isLocalPlayer then
            zo_callLater(function ()
                             ChatAnnouncements.CheckLFGStatusLeave(false)
                         end, 100)
        end
        sound = SOUNDS.GROUP_DISBAND
    elseif reason == GROUP_LEAVE_REASON_KICKED then
        if actionRequiredVote then
            if isLocalPlayer then
                zo_callLater(function ()
                                 ChatAnnouncements.CheckLFGStatusLeave(true)
                             end, 100)
                message = zo_strformat(SI_GROUP_ELECTION_KICK_PLAYER_PASSED)
                alert = zo_strformat(SI_GROUP_ELECTION_KICK_PLAYER_PASSED)
            elseif hasValidNames then
                zo_callLater(function ()
                                 ChatAnnouncements.CheckLFGStatusLeave(false)
                             end, 100)
                message = zo_strformat(LUIE_STRING_CA_GROUPFINDER_VOTEKICK_PASSED, finalName)
                alert = zo_strformat(LUIE_STRING_CA_GROUPFINDER_VOTEKICK_PASSED, finalAlertName)
                message2 = zo_strformat(GetString(LUIE_STRING_CA_GROUP_MEMBER_KICKED), finalName)
                alert2 = zo_strformat(GetString(LUIE_STRING_CA_GROUP_MEMBER_KICKED), finalAlertName)
            end
            sound = SOUNDS.GROUP_KICK
        else
            if isLeader and isLocalPlayer then
                message = zo_strformat(LUIE_STRING_GROUPDISBANDLEADER)
                alert = zo_strformat(LUIE_STRING_GROUPDISBANDLEADER)
                zo_callLater(function ()
                                 ChatAnnouncements.CheckLFGStatusLeave(false)
                             end, 100)
                sound = SOUNDS.GROUP_DISBAND
            elseif isLocalPlayer then
                zo_callLater(function ()
                                 ChatAnnouncements.CheckLFGStatusLeave(true)
                             end, 100)
                message = zo_strformat(SI_GROUP_NOTIFICATION_GROUP_SELF_KICKED)
                alert = zo_strformat(SI_GROUP_NOTIFICATION_GROUP_SELF_KICKED)
                sound = SOUNDS.GROUP_KICK
            else
                zo_callLater(function ()
                                 ChatAnnouncements.CheckLFGStatusLeave(false)
                             end, 100)
                useDefaultReasonText = true
                sound = SOUNDS.GROUP_KICK
            end
        end
    elseif reason == GROUP_LEAVE_REASON_VOLUNTARY or reason == GROUP_LEAVE_REASON_LEFT_BATTLEGROUND then
        if not isLocalPlayer then
            useDefaultReasonText = true
            zo_callLater(function ()
                             ChatAnnouncements.CheckLFGStatusLeave(false)
                         end, 100)
        else
            message = (zo_strformat(GetString(LUIE_STRING_CA_GROUP_MEMBER_LEAVE_SELF), finalName))
            alert = (zo_strformat(GetString(LUIE_STRING_CA_GROUP_MEMBER_LEAVE_SELF), finalAlertName))
            zo_callLater(function ()
                             ChatAnnouncements.CheckLFGStatusLeave(false)
                         end, 100)
        end

        sound = SOUNDS.GROUP_LEAVE
    elseif reason == GROUP_LEAVE_REASON_DESTROYED then
        -- do nothing, we don't want to show additional alerts for this case
    end

    if useDefaultReasonText and hasValidNames then
        message = zo_strformat(GetString("LUIE_STRING_GROUPLEAVEREASON", reason), finalName)
        alert = zo_strformat(GetString("LUIE_STRING_GROUPLEAVEREASON", reason), finalAlertName)
    end

    if isLocalPlayer then
        ChatAnnouncements.currentGroupLeaderRawName = GetRawUnitName(GetGroupLeaderUnitTag())
        ChatAnnouncements.currentGroupLeaderDisplayName = GetUnitDisplayName(GetGroupLeaderUnitTag())
    end

    -- Only print this out if we didn't JUST join an LFG group.
    if ChatAnnouncements.stopGroupLeaveQueue or ChatAnnouncements.lfgDisableGroupEvents then
        return true
    else
        if message ~= nil then
            if ChatAnnouncements.SV.Group.GroupCA then
                printToChat(message, true)
            end
            if ChatAnnouncements.SV.Group.GroupAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alert)
            end
            if sound ~= nil then
                PlaySound(sound)
            end
        end

        if message2 ~= nil then
            if ChatAnnouncements.SV.Group.GroupCA then
                printToChat(message2, true)
            end
            if ChatAnnouncements.SV.Group.GroupAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alert2)
            end
        end
    end

    return true
end

-- EVENT_GROUP_MEMBER_JOINED (Alert Handler)
local function OnGroupMemberJoined(characterName, displayName, isLocalPlayer)
    -- Update index for Group Loot
    ChatAnnouncements.IndexGroupLoot()
    ChatAnnouncements.currentGroupLeaderRawName = GetRawUnitName(GetGroupLeaderUnitTag())
    ChatAnnouncements.currentGroupLeaderDisplayName = GetUnitDisplayName(GetGroupLeaderUnitTag())

    -- Determine if the member that joined a group is the player or another member.
    if isLocalPlayer then
        zo_callLater(ChatAnnouncements.CheckLFGStatusJoin, 100)
    else
        -- Get character & display names
        local joinedMemberName = ZO_GetPrimaryPlayerName(displayName, characterName, false)
        local joinedMemberAccountName = ZO_GetSecondaryPlayerName(displayName, characterName, false)
        -- Resolve name links
        local finalName = ChatAnnouncements.ResolveNameLink(joinedMemberName, joinedMemberAccountName)
        local finalAlertName = ChatAnnouncements.ResolveNameNoLink(joinedMemberName, joinedMemberAccountName)
        -- Set final messages to send
        local SendMessage = (zo_strformat(GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN), finalName))
        local SendAlert = (zo_strformat(GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN), finalAlertName))
        zo_callLater(function ()
                         ChatAnnouncements.PrintJoinStatusNotSelf(SendMessage, SendAlert)
                     end, 100)
    end

    return true
end

-- EVENT_LEADER_UPDATE (Alert Handler)
-- Note: This event only fires if the characterId of the leader has changed (it's a new leader)
local function LeaderUpdateAlert(leaderTag)
    local leaderRawName = GetRawUnitName(leaderTag)
    local showAlert = leaderRawName ~= "" and (ChatAnnouncements.currentGroupLeaderRawName ~= "" and ChatAnnouncements.currentGroupLeaderRawName ~= nil)
    ChatAnnouncements.currentGroupLeaderRawName = leaderRawName
    ChatAnnouncements.currentGroupLeaderDisplayName = GetUnitDisplayName(leaderTag)

    -- If for some reason we don't have a valid leader name, bail out now.
    if ChatAnnouncements.currentGroupLeaderRawName == "" or ChatAnnouncements.currentGroupLeaderRawName == nil or ChatAnnouncements.currentGroupLeaderDisplayName == "" or ChatAnnouncements.currentGroupLeaderDisplayName == nil then
        return true
    end

    local displayString
    local alertString
    local finalName = ChatAnnouncements.ResolveNameLink(ChatAnnouncements.currentGroupLeaderRawName, ChatAnnouncements.currentGroupLeaderDisplayName)
    local finalAlertName = ChatAnnouncements.ResolveNameNoLink(ChatAnnouncements.currentGroupLeaderRawName, ChatAnnouncements.currentGroupLeaderDisplayName)

    if LUIE.PlayerNameRaw ~= ChatAnnouncements.currentGroupLeaderRawName then -- If another player became the leader
        displayString = (zo_strformat(GetString(LUIE_STRING_CA_GROUP_LEADER_CHANGED), finalName))
        alertString = (zo_strformat(GetString(LUIE_STRING_CA_GROUP_LEADER_CHANGED), finalAlertName))
    elseif LUIE.PlayerNameRaw == ChatAnnouncements.currentGroupLeaderRawName then -- If the player character became the leader
        displayString = (GetString(LUIE_STRING_CA_GROUP_LEADER_CHANGED_SELF))
        alertString = (GetString(LUIE_STRING_CA_GROUP_LEADER_CHANGED_SELF))
    end

    -- Don't show leader updates when joining LFG.
    if ChatAnnouncements.stopGroupLeaveQueue or ChatAnnouncements.lfgDisableGroupEvents then
        return true
    end

    if showAlert then
        if ChatAnnouncements.SV.Group.GroupCA then
            printToChat(displayString, true)
        end
        if ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertString)
        end
        PlaySound(SOUNDS.GROUP_PROMOTE)
    end
    return true
end

-- EVENT_ACTIVITY_QUEUE_RESULT (Alert Handler)
local function ActivityQueueResultAlert(result)
    if result ~= ACTIVITY_QUEUE_RESULT_SUCCESS then
        if ChatAnnouncements.SV.Group.GroupLFGCA then
            printToChat(GetString("SI_ACTIVITYQUEUERESULT", result), true)
        end
        if ChatAnnouncements.SV.Group.GroupLFGAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, GetString("SI_ACTIVITYQUEUERESULT", result))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    end
    ChatAnnouncements.showRCUpdates = true

    return true
end

-- EVENT_GROUP_ELECTION_FAILED (Alert Handler)
local function GroupElectionFailedAlert(failureType, descriptor)
    if failureType ~= GROUP_ELECTION_FAILURE_NONE then
        if ChatAnnouncements.SV.Group.GroupVoteCA then
            printToChat(GetString("SI_GROUPELECTIONFAILURE", failureType), true)
        end
        if ChatAnnouncements.SV.Group.GroupVoteAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, GetString("SI_GROUPELECTIONFAILURE", failureType))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    end
    return true
end

-- Variables for EVENT_GROUP_ELECTION_RESULT
local GroupElectionResultToSoundId =
{
    [GROUP_ELECTION_RESULT_ELECTION_WON] = SOUNDS.GROUP_ELECTION_RESULT_WON,
    [GROUP_ELECTION_RESULT_ELECTION_LOST] = SOUNDS.GROUP_ELECTION_RESULT_LOST,
    [GROUP_ELECTION_RESULT_ABANDONED] = SOUNDS.GROUP_ELECTION_RESULT_LOST,
}

-- EVENT_GROUP_ELECTION_RESULT (Alert Handler)
local function GroupElectionResultAlert(resultType, descriptor)
    if resultType ~= GROUP_ELECTION_RESULT_IN_PROGRESS and resultType ~= GROUP_ELECTION_RESULT_NOT_APPLICABLE then
        resultType = ZO_GetSimplifiedGroupElectionResultType(resultType)
        local alertText
        local message

        -- Try to find override messages based on the descriptor
        local alertTextOverrideLookup = ZO_GroupElectionResultToAlertTextOverrides[resultType]
        if alertTextOverrideLookup then
            message = alertTextOverrideLookup[descriptor]
            alertText = alertTextOverrideLookup[descriptor]
        end

        -- No override found
        if not alertText then
            local electionType, _, _, targetUnitTag = GetGroupElectionInfo()
            if not targetUnitTag then
                return
            end
            if electionType == GROUP_ELECTION_TYPE_KICK_MEMBER then
                if resultType == GROUP_ELECTION_RESULT_ELECTION_LOST then
                    local kickMemberName = GetUnitName(targetUnitTag)
                    local kickMemberAccountName = GetUnitDisplayName(targetUnitTag)

                    local kickFinalName = ChatAnnouncements.ResolveNameLink(kickMemberName, kickMemberAccountName)
                    local kickFinalAlertName = ChatAnnouncements.ResolveNameNoLink(kickMemberName, kickMemberAccountName)

                    message = zo_strformat(LUIE_STRING_CA_GROUPFINDER_VOTEKICK_FAIL, kickFinalName)
                    alertText = zo_strformat(LUIE_STRING_CA_GROUPFINDER_VOTEKICK_FAIL, kickFinalAlertName)
                else
                    -- Successful kicks are handled in the GROUP_MEMBER_LEFT alert
                    return true
                end
            end
        end

        -- No specific behavior found, so just do the generic alert for the result
        if not alertText then
            message = GetString("SI_GROUPELECTIONRESULT", resultType)
            alertText = GetString("SI_GROUPELECTIONRESULT", resultType)
        end

        if alertText ~= "" then
            if type(alertText) == "function" then
                alertText = alertText()
                message = message()
            end

            if ChatAnnouncements.SV.Group.GroupVoteCA then
                printToChat(message, true)
            end
            if ChatAnnouncements.SV.Group.GroupVoteAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertText)
            end
            PlaySound(GroupElectionResultToSoundId[resultType])
        end
    end
    return true
end

-- EVENT_GROUP_ELECTION_REQUESTED (Alert Handler)
local function GroupElectionRequestedAlert(descriptor)
    local alertText
    local messageText
    if descriptor then
        messageText = ZO_GroupElectionDescriptorToRequestAlertText[descriptor]
        alertText = ZO_GroupElectionDescriptorToRequestAlertText[descriptor]
    end

    if not alertText then
        messageText = ZO_GroupElectionDescriptorToRequestAlertText[ZO_GROUP_ELECTION_DESCRIPTORS.NONE]
        alertText = ZO_GroupElectionDescriptorToRequestAlertText[ZO_GROUP_ELECTION_DESCRIPTORS.NONE]
    end

    if ChatAnnouncements.SV.Group.GroupVoteCA then
        printToChat(messageText, true)
    end
    if ChatAnnouncements.SV.Group.GroupVoteAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertText)
    end
    PlaySound(SOUNDS.GROUP_ELECTION_REQUESTED)
    return true
end

-- EVENT_GROUPING_TOOLS_READY_CHECK_CANCELLED (Alert Handler)
local function GroupReadyCheckCancelAlert(reason)
    local message

    if reason ~= LFG_READY_CHECK_CANCEL_REASON_NOT_IN_READY_CHECK and reason ~= LFG_READY_CHECK_CANCEL_REASON_GROUP_FORMED_SUCCESSFULLY then
        message = GetString("SI_LFGREADYCHECKCANCELREASON", reason)
        if ChatAnnouncements.SV.Group.GroupLFGCA then
            printToChat(message, true)
        end
        if ChatAnnouncements.SV.Group.GroupLFGAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, message)
        end
    end

    -- Stop the cancel message from status update from triggering when any other result here happens.
    ChatAnnouncements.lfgHideStatusCancel = true
    zo_callLater(function ()
                     ChatAnnouncements.lfgHideStatusCancel = false
                 end, 1000)

    -- Sometimes if another player cancels slightly before a player in your group cancels, the "you have been placed in the front of the queue message displays. If this is the case, we want to show queue left for that event."
    if reason ~= LFG_READY_CHECK_CANCEL_REASON_GROUP_REPLACED_IN_QUEUE then
        ChatAnnouncements.showActivityStatus = false
        zo_callLater(function ()
                         ChatAnnouncements.showActivityStatus = true
                     end, 1000)
    end

    ChatAnnouncements.showRCUpdates = true
end

-- EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED (Alert Handler)
local function GroupDifficultyChangeAlert(isVeteranDifficulty)
    local message
    local sound
    if isVeteranDifficulty then
        message = GetString(SI_DUNGEON_DIFFICULTY_CHANGED_TO_VETERAN)
        sound = SOUNDS.DUNGEON_DIFFICULTY_VETERAN
    else
        message = GetString(SI_DUNGEON_DIFFICULTY_CHANGED_TO_NORMAL)
        sound = SOUNDS.DUNGEON_DIFFICULTY_NORMAL
    end

    if ChatAnnouncements.SV.Group.GroupCA then
        printToChat(message, true)
    end
    if ChatAnnouncements.SV.Group.GroupAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, message)
    end
    PlaySound(sound)

    return true
end

-- EVENT_GUILD_SELF_LEFT_GUILD (Alert Handler)
local function GuildSelfLeftAlert(guildId, guildName)
    local GuildIndexData = LUIE.GuildIndexData
    for i = 1, 5 do
        local guild = GuildIndexData[i]
        if guild.name == guildName then
            local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guild.guildAlliance) or ChatAnnouncements.Colors.GuildColorize
            local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guild.guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
            local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guild.guildAlliance), "100%", "100%", guildName) or guildName
            local messageString = (ShouldDisplaySelfKickedFromGuildAlert(guildId)) and SI_GUILD_SELF_KICKED_FROM_GUILD or LUIE_STRING_CA_GUILD_LEAVE_SELF
            local sound = (ShouldDisplaySelfKickedFromGuildAlert(guildId)) and SOUNDS.GENERAL_ALERT_ERROR or SOUNDS.GUILD_SELF_LEFT
            if ChatAnnouncements.SV.Social.GuildCA then
                printToChat(zo_strformat(GetString(messageString), guildNameAlliance), true)
            end
            if ChatAnnouncements.SV.Social.GuildAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(messageString), guildNameAllianceAlert))
            end
            PlaySound(sound)
            break
        end
    end

    return true
end

-- EVENT_SAVE_GUILD_RANKS_RESPONSE (Alert Handler)
local function GuildRanksResponseAlert(guildId, result)
    if result ~= SOCIAL_RESULT_NO_ERROR then
        if ChatAnnouncements.SV.Social.GuildCA then
            printToChat(GetString("SI_SOCIALACTIONRESULT", result), true)
        elseif ChatAnnouncements.SV.Social.GuildAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, GetString("SI_SOCIALACTIONRESULT", result))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    end
    return true
end

-- EVENT_LOCKPICK_FAILED (Alert Handler)
local function LockpickFailedAlert(result)
    if ChatAnnouncements.SV.Notify.NotificationLockpickCA then
        local message = GetString(LUIE_STRING_CA_LOCKPICK_FAILED)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
        {
            message = message,
            messageType = "NOTIFICATION"
        }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end
    if ChatAnnouncements.SV.Notify.NotificationLockpickAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_LOCKPICK_FAILED))
    end
    ChatAnnouncements.lockpickBroken = true
    zo_callLater(function ()
                     ChatAnnouncements.lockpickBroken = false
                 end, 200)
    return true
end

-- EVENT_CLIENT_INTERACT_RESULT (Alert Handler)
local function ClientInteractResult(result, interactTargetName)
    local formatString = GetString("SI_CLIENTINTERACTRESULT", result)
    if formatString ~= "" then
        printToChat(zo_strformat(formatString, interactTargetName))
        if ChatAnnouncements.SV.Notify.NotificationLockpickAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, zo_strformat(formatString, interactTargetName))
        end
        local sound = ZO_ClientInteractResultSpecificSound[result] or SOUNDS.GENERAL_ALERT_ERROR
        PlaySound(sound)
    end
    return true
end

-- EVENT_TRADE_INVITE_FAILED (Alert Handler)
local function TradeInviteFailedAlert(errorReason, inviteeCharacterName, inviteeDisplayName)
    if ChatAnnouncements.SV.Notify.NotificationTradeCA or ChatAnnouncements.SV.Notify.NotificationTradeAlert then
        local finalName = ChatAnnouncements.ResolveNameLink(inviteeCharacterName, inviteeDisplayName)
        local finalAlertName = ChatAnnouncements.ResolveNameNoLink(inviteeCharacterName, inviteeDisplayName)

        if ChatAnnouncements.SV.Notify.NotificationTradeCA then
            printToChat(zo_strformat(GetString("LUIE_STRING_CA_TRADEACTIONRESULT", errorReason), finalName), true)
        end

        if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString("LUIE_STRING_CA_TRADEACTIONRESULT", errorReason), finalAlertName))
        end
    end
    PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    ChatAnnouncements.tradeTarget = ""
    return true
end

-- EVENT_TRADE_INVITE_CONSIDERING (Alert Handler)
local function TradeInviteConsideringAlert(inviterCharacterName, inviterDisplayName)
    if ChatAnnouncements.SV.Notify.NotificationTradeCA or ChatAnnouncements.SV.Notify.NotificationTradeAlert then
        local finalName = ChatAnnouncements.ResolveNameLink(inviterCharacterName, inviterDisplayName)
        local finalAlertName = ChatAnnouncements.ResolveNameNoLink(inviterCharacterName, inviterDisplayName)
        ChatAnnouncements.tradeTarget = ZO_SELECTED_TEXT:Colorize(zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, finalName))

        if ChatAnnouncements.SV.Notify.NotificationTradeCA then
            printToChat(zo_strformat(GetString(LUIE_STRING_CA_TRADE_INVITE_MESSAGE), finalName), true)
        end
        if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_TRADE_INVITE_MESSAGE), finalAlertName))
        end
    end
    return true
end

-- EVENT_TRADE_INVITE_WAITING (Alert Handler)
local function TradeInviteWaitingAlert(inviteeCharacterName, inviteeDisplayName)
    if ChatAnnouncements.SV.Notify.NotificationTradeCA or ChatAnnouncements.SV.Notify.NotificationTradeAlert then
        local finalName = ChatAnnouncements.ResolveNameLink(inviteeCharacterName, inviteeDisplayName)
        local finalAlertName = ChatAnnouncements.ResolveNameNoLink(inviteeCharacterName, inviteeDisplayName)
        ChatAnnouncements.tradeTarget = ZO_SELECTED_TEXT:Colorize(zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, finalName))

        if ChatAnnouncements.SV.Notify.NotificationTradeCA then
            printToChat(zo_strformat(GetString(LUIE_STRING_CA_TRADE_INVITE_CONFIRM), finalName), true)
        end
        if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_TRADE_INVITE_CONFIRM), finalAlertName))
        end
    end
    return true
end

-- EVENT_TRADE_INVITE_DECLINED (Alert Handler)
local function TradeInviteDeclinedAlert()
    if ChatAnnouncements.SV.Notify.NotificationTradeCA then
        printToChat(GetString(LUIE_STRING_CA_TRADE_INVITE_DECLINED), true)
    end
    if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_TRADE_INVITE_DECLINED))
    end
    PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    ChatAnnouncements.tradeTarget = ""
    ChatAnnouncements.tradeStacksIn = {}
    ChatAnnouncements.tradeStacksOut = {}
    return true
end

-- EVENT_TRADE_INVITE_CANCELED (Alert Handler)
local function TradeInviteCanceledAlert()
    if ChatAnnouncements.SV.Notify.NotificationTradeCA then
        printToChat(GetString(LUIE_STRING_CA_TRADE_INVITE_CANCELED), true)
    end
    if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_TRADE_INVITE_CANCELED))
    end
    PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    ChatAnnouncements.tradeTarget = ""
    ChatAnnouncements.tradeStacksIn = {}
    ChatAnnouncements.tradeStacksOut = {}
    return true
end

-- EVENT_TRADE_CANCELED (Alert Handler)
local function TradeCanceledAlert()
    if ChatAnnouncements.SV.Notify.NotificationTradeCA then
        printToChat(GetString(SI_TRADE_CANCELED), true)
    end
    if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(SI_TRADE_CANCELED))
    end
    PlaySound(SOUNDS.GENERAL_ALERT_ERROR)

    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
    end
    if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
        ChatAnnouncements.inventoryStacks = {}
    end

    ChatAnnouncements.tradeTarget = ""
    ChatAnnouncements.tradeStacksIn = {}
    ChatAnnouncements.tradeStacksOut = {}
    ChatAnnouncements.inTrade = false
    return true
end

-- EVENT_TRADE_FAILED (Alert Handler)
local function TradeFailedAlert(reason)
    if ChatAnnouncements.SV.Notify.NotificationTradeCA then
        printToChat(GetString("LUIE_STRING_CA_TRADEACTIONRESULT", reason), true)
    end
    if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString("LUIE_STRING_CA_TRADEACTIONRESULT", reason))
    end
    PlaySound(SOUNDS.GENERAL_ALERT_ERROR)

    ChatAnnouncements.tradeTarget = ""
    ChatAnnouncements.inTrade = false
    return true
end

-- EVENT_TRADE_SUCCEEDED (Alert Handler)
local function TradeSucceededAlert()
    if ChatAnnouncements.SV.Notify.NotificationTradeCA then
        local message = GetString(SI_TRADE_COMPLETE)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
        {
            message = message,
            messageType = "NOTIFICATION",
            sSystem = true
        }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end
    if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(SI_TRADE_COMPLETE))
    end
    PlaySound(SOUNDS.GENERAL_ALERT_ERROR)

    if ChatAnnouncements.SV.Inventory.LootTrade then
        for indexOut = 1, 5 do
            if ChatAnnouncements.tradeStacksOut[indexOut] ~= nil then
                local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                local logPrefix = ChatAnnouncements.tradeTarget ~= "" and ChatAnnouncements.SV.ContextMessages.CurrencyMessageTradeOut or ChatAnnouncements.SV.ContextMessages.CurrencyMessageTradeOutNoName
                local item = ChatAnnouncements.tradeStacksOut[indexOut]
                ChatAnnouncements.ItemCounterDelayOut(
                    item.icon,
                    item.stack,
                    item.itemType,
                    item.itemId,
                    item.itemLink,
                    ChatAnnouncements.tradeTarget,
                    logPrefix,
                    gainOrLoss,
                    false,
                    nil,
                    nil,
                    nil)
            end
        end

        for indexIn = 1, 5 do
            if ChatAnnouncements.tradeStacksIn[indexIn] ~= nil then
                local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                local logPrefix = ChatAnnouncements.tradeTarget ~= "" and ChatAnnouncements.SV.ContextMessages.CurrencyMessageTradeIn or ChatAnnouncements.SV.ContextMessages.CurrencyMessageTradeInNoName
                local item = ChatAnnouncements.tradeStacksIn[indexIn]
                ChatAnnouncements.ItemCounterDelay(
                    item.icon,
                    item.stack,
                    item.itemType,
                    item.itemId,
                    item.itemLink,
                    ChatAnnouncements.tradeTarget,
                    logPrefix,
                    gainOrLoss,
                    false,
                    nil,
                    nil,
                    nil
                )
            end
        end
    end

    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
    end
    if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
        ChatAnnouncements.inventoryStacks = {}
    end

    ChatAnnouncements.tradeTarget = ""
    ChatAnnouncements.tradeStacksIn = {}
    ChatAnnouncements.tradeStacksOut = {}
    ChatAnnouncements.inTrade = false
    return true
end

-- EVENT_DISCOVERY_EXPERIENCE (Alert Handler)
local function DiscoveryExperienceAlert(subzoneName, level, previousExperience, currentExperience, rank, previousPoints, currentPoints)
    -- Note: We let the CSA Handler take care of this.
    return true
end

-- EVENT_MAIL_SEND_FAILED (Alert Handler)
local function MailSendFailedAlert(reason)
    if reason ~= MAIL_SEND_RESULT_CANCELED then
        local function RestoreMailBackupValues()
            ChatAnnouncements.postageAmount = GetQueuedMailPostage()
            ChatAnnouncements.mailAmount = GetQueuedMoneyAttachment()
            ChatAnnouncements.mailCOD = GetQueuedCOD()
        end

        -- Stop currency messages from printing here
        if reason == MAIL_SEND_RESULT_FAIL_INVALID_NAME then
            for i = 1, #ChatAnnouncements.QueuedMessages do
                if ChatAnnouncements.QueuedMessages[i].messageType == "CURRENCY" then
                    ChatAnnouncements.QueuedMessages[i].messageType = "GARBAGE"
                end
            end
            eventManager:UnregisterForEvent(moduleName, EVENT_CURRENCY_UPDATE)
            zo_callLater(function ()
                             eventManager:RegisterForEvent(moduleName, EVENT_CURRENCY_UPDATE, ChatAnnouncements.OnCurrencyUpdate)
                         end, 500)
        end

        if ChatAnnouncements.SV.Notify.NotificationMailErrorCA then
            printToChat(GetString("SI_SENDMAILRESULT", reason), true)
        end
        if ChatAnnouncements.SV.Notify.NotificationMailErrorAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, GetString("SI_SENDMAILRESULT", reason))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)

        zo_callLater(RestoreMailBackupValues, 50) -- Prevents values from being cleared by failed message (when inbox is full, the currency change fires first regardless and then is refunded)
    end
    return true
end

-- EVENT_LORE_BOOK_LEARNED_SKILL_EXPERIENCE (CSA Handler)
local function LoreBookXPHook(categoryIndex, collectionIndex, bookIndex, guildReputationIndex, skillType, skillIndex, rank, previousXP, currentXP)
    if guildReputationIndex > 0 then
        local collectionName, _, numKnownBooks, totalBooks, hidden = GetLoreCollectionInfo(categoryIndex, collectionIndex)
        local title, icon = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
        local bookName
        local bookLink
        if ChatAnnouncements.SV.BracketOptionLorebook == 1 then
            bookName = string.format("%s", title)
            bookLink = string.format("|H0:LINK_TYPE_LUIE_BOOK:%s:%s:%s|h%s|h", categoryIndex, collectionIndex, bookIndex, bookName)
        else
            bookName = string.format("[%s]", title)
            bookLink = string.format("|H1:LINK_TYPE_LUIE_BOOK:%s:%s:%s|h%s|h", categoryIndex, collectionIndex, bookIndex, bookName)
        end

        local stringPrefix
        local csaPrefix
        if categoryIndex == 1 then
            -- Is a lore book
            stringPrefix = ChatAnnouncements.SV.Lorebooks.LorebookPrefix1
            csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(SI_LORE_LIBRARY_ANNOUNCE_BOOK_LEARNED)
        else
            -- Is a normal book
            stringPrefix = ChatAnnouncements.SV.Lorebooks.LorebookPrefix2
            csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(LUIE_STRING_CA_LOREBOOK_BOOK)
        end

        -- Chat Announcement
        if ChatAnnouncements.SV.Lorebooks.LorebookCA then
            local formattedIcon = ChatAnnouncements.SV.Lorebooks.LorebookIcon and ("|t16:16:" .. icon .. "|t ") or ""
            local stringPart1
            local stringPart2
            if stringPrefix ~= "" then
                stringPart1 = ChatAnnouncements.Colors.LorebookColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", ChatAnnouncements.bracket1[ChatAnnouncements.SV.Lorebooks.LorebookBracket], stringPrefix, ChatAnnouncements.bracket2[ChatAnnouncements.SV.Lorebooks.LorebookBracket]))
            else
                stringPart1 = ""
            end
            if ChatAnnouncements.SV.Lorebooks.LorebookCategory then
                stringPart2 = collectionName ~= "" and ChatAnnouncements.Colors.LorebookColorize2:Colorize(zo_strformat(" <<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), collectionName)) or ChatAnnouncements.Colors.LorebookColorize2:Colorize(zo_strformat(" <<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), GetString(SI_WINDOW_TITLE_LORE_LIBRARY)))
            else
                stringPart2 = ""
            end

            local finalMessage = zo_strformat("<<1>><<2>><<3>><<4>>", stringPart1, formattedIcon, bookLink, stringPart2)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = finalMessage,
                messageType = "COLLECTIBLE"
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        -- Alert Announcement
        if ChatAnnouncements.SV.Lorebooks.LorebookAlert then
            local text = collectionName ~= "" and zo_strformat("<<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), collectionName) or zo_strformat(" <<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), GetString(SI_WINDOW_TITLE_LORE_LIBRARY))
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat("<<1>> <<2>>", title, text))
        end

        -- Center Screen Announcement
        if ChatAnnouncements.SV.Lorebooks.LorebookCSA then
            -- Only display a CSA if this is a Lore Book and we have Eidetic Memory books set to not show.
            if (categoryIndex == 1 and ChatAnnouncements.SV.Lorebooks.LorebookCSALoreOnly) or not ChatAnnouncements.SV.Lorebooks.LorebookCSALoreOnly then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.BOOK_ACQUIRED)
                if not LUIE.SV.HideXPBar then
                    local barType = PLAYER_PROGRESS_BAR:GetBarType(PPB_CLASS_SKILL, skillType, skillIndex)
                    local rankStartXP, nextRankStartXP = GetSkillLineRankXPExtents(skillType, skillIndex, rank)
                    local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(barType, rank, previousXP - rankStartXP, currentXP - rankStartXP)
                    barParams:SetTriggeringEvent(EVENT_LORE_BOOK_LEARNED_SKILL_EXPERIENCE)
                    ValidateProgressBarParams(barParams)
                    messageParams:SetBarParams(barParams)
                end
                if collectionName ~= "" then
                    messageParams:SetText(csaPrefix, zo_strformat(LUIE_STRING_CA_LOREBOOK_ADDED_CSA, title, collectionName))
                else
                    messageParams:SetText(csaPrefix, zo_strformat(LUIE_STRING_CA_LOREBOOK_ADDED_CSA, title, GetString(SI_WINDOW_TITLE_LORE_LIBRARY)))
                end
                messageParams:SetIconData(icon, "EsoUI/Art/Achievements/achievements_iconBG.dds")
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_LORE_BOOK_LEARNED_SKILL_EXPERIENCE)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end
        end
        if not ChatAnnouncements.SV.Lorebooks.LorebookCSA then
            PlaySound(SOUNDS.BOOK_ACQUIRED)
        end
    end
    return true
end

-- EVENT_LORE_COLLECTION_COMPLETED (CSA Handler)
local function LoreCollectionHook(categoryIndex, collectionIndex, bookIndex, guildReputationIndex, isMaxRank)
    if guildReputationIndex == 0 or isMaxRank then
        -- Only fire this message if we're not part of the guild or at max level within the guild.
        local collectionName, description, numKnownBooks, totalBooks, hidden, textureName = GetLoreCollectionInfo(categoryIndex, collectionIndex)
        local stringPrefix = ChatAnnouncements.SV.Lorebooks.LorebookCollectionPrefix
        local csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(SI_LORE_LIBRARY_COLLECTION_COMPLETED_LARGE)
        if not hidden or ChatAnnouncements.SV.Lorebooks.LorebookShowHidden then
            if ChatAnnouncements.SV.Lorebooks.LorebookCollectionCA then
                local formattedIcon
                local stringPart1
                local stringPart2
                if stringPrefix ~= "" then
                    stringPart1 = ChatAnnouncements.Colors.LorebookColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", ChatAnnouncements.bracket1[ChatAnnouncements.SV.Lorebooks.LorebookBracket], stringPrefix, ChatAnnouncements.bracket2[ChatAnnouncements.SV.Lorebooks.LorebookBracket]))
                else
                    stringPart1 = ""
                end
                if textureName ~= "" and textureName ~= nil then
                    formattedIcon = ChatAnnouncements.SV.Lorebooks.LorebookIcon and ("|t16:16:" .. textureName .. "|t ") or ""
                end
                if ChatAnnouncements.SV.Lorebooks.LorebookCategory then
                    stringPart2 = ChatAnnouncements.Colors.LorebookColorize2:Colorize(zo_strformat(SI_LORE_LIBRARY_COLLECTION_COMPLETED_SMALL, collectionName))
                else
                    stringPart2 = ""
                end

                local finalMessage = zo_strformat("<<1>><<2>><<3>>", stringPart1, formattedIcon, stringPart2)
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
                {
                    message = finalMessage,
                    messageType = "COLLECTIBLE"
                }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end

            if ChatAnnouncements.SV.Lorebooks.LorebookCollectionCSA then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.BOOK_COLLECTION_COMPLETED)
                messageParams:SetText(csaPrefix, zo_strformat(SI_LORE_LIBRARY_COLLECTION_COMPLETED_SMALL, collectionName))
                messageParams:SetIconData(textureName, "EsoUI/Art/Achievements/achievements_iconBG.dds")
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_LORE_COLLECTION_COMPLETED)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end

            if ChatAnnouncements.SV.Lorebooks.LorebookCollectionAlert then
                local text = zo_strformat(SI_LORE_LIBRARY_COLLECTION_COMPLETED_SMALL, collectionName)
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
            end
            if not ChatAnnouncements.SV.Lorebooks.LorebookCSA then
                PlaySound(SOUNDS.BOOK_COLLECTION_COMPLETED)
            end
        end
    end
    return true
end

-- EVENT_LORE_COLLECTION_COMPLETED_SKILL_EXPERIENCE (CSA Handler)
local function LoreCollectionXPHook(categoryIndex, collectionIndex, guildReputationIndex, skillType, skillIndex, rank, previousXP, currentXP)
    if guildReputationIndex > 0 then
        local collectionName, description, numKnownBooks, totalBooks, hidden, textureName = GetLoreCollectionInfo(categoryIndex, collectionIndex)
        local stringPrefix = ChatAnnouncements.SV.Lorebooks.LorebookCollectionPrefix
        local csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(SI_LORE_LIBRARY_COLLECTION_COMPLETED_LARGE)
        if not hidden or ChatAnnouncements.SV.Lorebooks.LorebookShowHidden then
            if ChatAnnouncements.SV.Lorebooks.LorebookCollectionCA then
                local formattedIcon
                local stringPart1
                local stringPart2
                if stringPrefix ~= "" then
                    stringPart1 = ChatAnnouncements.Colors.LorebookColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", ChatAnnouncements.bracket1[ChatAnnouncements.SV.Lorebooks.LorebookBracket], stringPrefix, ChatAnnouncements.bracket2[ChatAnnouncements.SV.Lorebooks.LorebookBracket]))
                else
                    stringPart1 = ""
                end
                if textureName ~= "" and textureName ~= nil then
                    formattedIcon = ChatAnnouncements.SV.Lorebooks.LorebookIcon and zo_strformat("<<1>> ", zo_iconFormat(textureName, 16, 16)) or ""
                end
                if ChatAnnouncements.SV.Lorebooks.LorebookCategory then
                    stringPart2 = ChatAnnouncements.Colors.LorebookColorize2:Colorize(zo_strformat(SI_LORE_LIBRARY_COLLECTION_COMPLETED_SMALL, collectionName))
                else
                    stringPart2 = ""
                end

                local finalMessage = zo_strformat("<<1>><<2>><<3>>", stringPart1, formattedIcon, stringPart2)
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
                {
                    message = finalMessage,
                    messageType = "COLLECTIBLE"
                }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end

            if ChatAnnouncements.SV.Lorebooks.LorebookCollectionCSA then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.BOOK_COLLECTION_COMPLETED)
                if not LUIE.SV.HideXPBar then
                    local barType = PLAYER_PROGRESS_BAR:GetBarType(PPB_CLASS_SKILL, skillType, skillIndex)
                    local rankStartXP, nextRankStartXP = GetSkillLineRankXPExtents(skillType, skillIndex, rank)
                    local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(barType, rank, previousXP - rankStartXP, currentXP - rankStartXP)
                    barParams:SetTriggeringEvent(EVENT_LORE_COLLECTION_COMPLETED_SKILL_EXPERIENCE)
                    ValidateProgressBarParams(barParams)
                    messageParams:SetBarParams(barParams)
                end
                messageParams:SetText(csaPrefix, zo_strformat(SI_LORE_LIBRARY_COLLECTION_COMPLETED_SMALL, collectionName))
                messageParams:SetIconData(textureName, "EsoUI/Art/Achievements/achievements_iconBG.dds")
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_LORE_COLLECTION_COMPLETED_SKILL_EXPERIENCE)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end

            if ChatAnnouncements.SV.Lorebooks.LorebookCollectionAlert then
                local text = zo_strformat(SI_LORE_LIBRARY_COLLECTION_COMPLETED_SMALL, collectionName)
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
            end
            if not ChatAnnouncements.SV.Lorebooks.LorebookCSA then
                PlaySound(SOUNDS.BOOK_COLLECTION_COMPLETED)
            end
        end
    end
    return true
end

-- EVENT_SKILL_POINTS_CHANGED (CSA Handler)
local function SkillPointsChangedHook(oldPoints, newPoints, oldPartialPoints, newPartialPoints, changeReason)
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
    local numSkillPointsGained = newPoints - oldPoints
    local stringPrefix = ChatAnnouncements.SV.Skills.SkillPointSkyshard
    local csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(SI_SKYSHARD_GAINED)
    local hasStringPrefix = stringPrefix ~= ""
    local flagDisplay, sound, finalMessage, finalText

    -- check if the skill point change was due to skyshards
    if oldPartialPoints ~= newPartialPoints or changeReason == SKILL_POINT_CHANGE_REASON_SKYSHARD_INSTANT_UNLOCK then
        flagDisplay = true
        sound = SOUNDS.SKYSHARD_GAINED
        if numSkillPointsGained < 0 then
            return
        end
        local numSkyshardsGained = (newPoints * NUM_PARTIAL_SKILL_POINTS_FOR_FULL + newPartialPoints) - (oldPoints * NUM_PARTIAL_SKILL_POINTS_FOR_FULL + oldPartialPoints)
        local largeText = zo_strformat(csaPrefix, numSkyshardsGained)
        local stringPart1, stringPart2

        -- if only the partial points changed, message out the new count of skyshard pieces
        if newPoints == oldPoints then
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SKILL_POINTS_PARTIAL_GAINED)
            local skyshardGainedPoints = zo_strformat(SI_SKYSHARD_GAINED_POINTS, newPartialPoints, NUM_PARTIAL_SKILL_POINTS_FOR_FULL)
            messageParams:SetText(largeText, skyshardGainedPoints)
            finalText = zo_strformat("<<1>> (<<2>>/<<3>>)", largeText, newPartialPoints, NUM_PARTIAL_SKILL_POINTS_FOR_FULL)
            if hasStringPrefix then
                if ChatAnnouncements.SV.Skills.SkillPointsPartial then
                    stringPart1 = ChatAnnouncements.Colors.SkillPointColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", ChatAnnouncements.bracket1[ChatAnnouncements.SV.Skills.SkillPointBracket], largeText, ChatAnnouncements.bracket2[ChatAnnouncements.SV.Skills.SkillPointBracket]))
                else
                    stringPart1 = ChatAnnouncements.Colors.SkillPointColorize1:Colorize(zo_strformat("<<1>>!", largeText))
                end
            else
                stringPart1 = ""
            end
            if ChatAnnouncements.SV.Skills.SkillPointsPartial then
                stringPart2 = ChatAnnouncements.Colors.SkillPointColorize2:Colorize(skyshardGainedPoints)
            else
                stringPart2 = ""
            end
            finalMessage = zo_strformat("<<1>><<2>>", stringPart1, stringPart2)
        else
            local messageText
            -- if there are no leftover skyshard pieces, don't include them in the message
            if newPartialPoints == 0 then
                messageText = zo_strformat(SI_SKILL_POINT_GAINED, numSkillPointsGained)
            else
                messageText = zo_strformat(SI_SKILL_POINT_AND_SKYSHARD_PIECES_GAINED, numSkillPointsGained, newPartialPoints, NUM_PARTIAL_SKILL_POINTS_FOR_FULL)
            end
            messageParams:SetText(largeText, messageText)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SKILL_POINTS_GAINED)
            finalText = messageText
            if hasStringPrefix then
                stringPart1 = ChatAnnouncements.Colors.SkillPointColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", ChatAnnouncements.bracket1[ChatAnnouncements.SV.Skills.SkillPointBracket], largeText, ChatAnnouncements.bracket2[ChatAnnouncements.SV.Skills.SkillPointBracket]))
            else
                stringPart1 = ""
            end
            stringPart2 = ChatAnnouncements.Colors.SkillPointColorize2:Colorize(messageText)
            finalMessage = zo_strformat("<<1>><<2>>.", stringPart1, stringPart2)
        end
    elseif numSkillPointsGained > 0 then
        if not SUPPRESS_SKILL_POINT_CSA_REASONS[changeReason] then
            flagDisplay = true
            sound = SOUNDS.SKILL_POINT_GAINED
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SKILL_POINTS_GAINED)
            local skillPointGained = zo_strformat(SI_SKILL_POINT_GAINED, numSkillPointsGained)
            messageParams:SetText(skillPointGained)
            finalMessage = ChatAnnouncements.Colors.SkillPointColorize2:Colorize(skillPointGained .. ".")
            finalText = skillPointGained .. "."
        end
    end
    if flagDisplay then
        if ChatAnnouncements.SV.Skills.SkillPointCA and finalMessage ~= "" then
            table.insert(ChatAnnouncements.QueuedMessages, { message = finalMessage, messageType = "SKILL" })
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end
        if ChatAnnouncements.SV.Skills.SkillPointCSA then
            messageParams:SetSound(sound)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end
        if ChatAnnouncements.SV.Skills.SkillPointAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, finalText)
        end
        if not ChatAnnouncements.SV.Skills.SkillPointCSA then
            PlaySound(sound)
        end
    end
    return true
end

-- EVENT_SKILL_LINE_ADDED (CSA Handler) -- Hooked via csaCallbackHandlers[2]
local function SkillLineAddedHook(skillLineData)
    if skillLineData:IsAvailable() then
        local skillTypeData = skillLineData:GetSkillTypeData()
        local lineName = skillLineData:GetName()
        local icon = skillTypeData:GetAnnounceIcon()

        if ChatAnnouncements.SV.Skills.SkillLineUnlockCA then
            local formattedIcon = ChatAnnouncements.SV.Skills.SkillLineIcon and zo_strformat("<<1>> ", zo_iconFormatInheritColor(icon, 16, 16)) or ""
            local formattedString = ChatAnnouncements.Colors.SkillLineColorize:Colorize(zo_strformat(LUIE_STRING_CA_SKILL_LINE_ADDED, formattedIcon, lineName))
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = formattedString,
                messageType = "SKILL_GAIN"
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end
        if ChatAnnouncements.SV.Skills.SkillLineUnlockCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.SKILL_LINE_ADDED)
            local formattedIcon = zo_iconFormat(icon, 32, 32)
            -- Note: We set the CSA type to SKILL_POINTS_PARTIAL_GAINED instead of SKILL_LINE_ADDED so this orders itself BEFORE some other events.
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SKILL_POINTS_PARTIAL_GAINED)
            messageParams:SetText(zo_strformat(SI_SKILL_LINE_ADDED, formattedIcon, lineName))
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end
        if ChatAnnouncements.SV.Skills.SkillLineUnlockAlert then
            local formattedIcon = ""
            local text = zo_strformat(SI_SKILL_LINE_ADDED, formattedIcon, lineName)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
        end
        if not ChatAnnouncements.SV.Skills.SkillLineUnlockCSA then
            PlaySound(SOUNDS.SKILL_LINE_ADDED)
        end
        return true
    end
end

-- EVENT_ABILITY_PROGRESSION_RANK_UPDATE (CSA Handler)
local function AbilityProgressionRankHook(progressionIndex, rank, maxRank, morph)
    local _, _, _, atMorph = GetAbilityProgressionXPInfo(progressionIndex)
    local name = GetAbilityProgressionAbilityInfo(progressionIndex, morph, rank)

    if atMorph then
        if ChatAnnouncements.SV.Skills.SkillAbilityCA then
            local formattedString = ChatAnnouncements.Colors.SkillLineColorize:Colorize(zo_strformat(SI_MORPH_AVAILABLE_ANNOUNCEMENT, name) .. ".")
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = formattedString,
                messageType = "SKILL_MORPH"
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Skills.SkillAbilityCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.ABILITY_MORPH_AVAILABLE)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ABILITY_PROGRESSION_RANK_MORPH)
            messageParams:SetText(zo_strformat(SI_MORPH_AVAILABLE_ANNOUNCEMENT, name))
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.Skills.SkillAbilityAlert then
            local text = zo_strformat(SI_MORPH_AVAILABLE_ANNOUNCEMENT, name) .. "."
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
        end

        if not ChatAnnouncements.SV.Skills.SkillAbilityCSA then
            PlaySound(SOUNDS.ABILITY_MORPH_AVAILABLE)
        end
    else
        if ChatAnnouncements.SV.Skills.SkillAbilityCA then
            local formattedString = ChatAnnouncements.Colors.SkillLineColorize:Colorize(zo_strformat(LUIE_STRING_CA_ABILITY_RANK_UP, name, rank) .. ".")
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = formattedString,
                messageType = "SKILL"
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Skills.SkillAbilityCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.ABILITY_RANK_UP)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ABILITY_PROGRESSION_RANK_UPDATE)
            messageParams:SetText(zo_strformat(LUIE_STRING_CA_ABILITY_RANK_UP, name, rank))
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.Skills.SkillAbilityAlert then
            local text = zo_strformat(LUIE_STRING_CA_ABILITY_RANK_UP, name, rank) .. "."
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
        end

        if not ChatAnnouncements.SV.Skills.SkillAbilityCSA then
            PlaySound(SOUNDS.ABILITY_RANK_UP)
        end
    end
    return true
end

-- EVENT_SKILL_RANK_UPDATE (CSA Handler)
local function SkillRankUpdateHook(skillType, skillLineIndex, rank)
    -- crafting skill updates get deferred if they're increased while crafting animations are in progress
    -- ZO_Skills_TieSkillInfoHeaderToCraftingSkill handles triggering the deferred center screen announce in that case
    if skillType ~= SKILL_TYPE_RACIAL and (skillType ~= SKILL_TYPE_TRADESKILL or not ZO_CraftingUtils_IsPerformingCraftProcess()) then
        local skillLineData = SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(skillType, skillLineIndex)
        if skillLineData and skillLineData:IsAvailable() then
            local lineName = skillLineData:GetName()

            if ChatAnnouncements.SV.Skills.SkillLineCA then
                local formattedString = ChatAnnouncements.Colors.SkillLineColorize:Colorize(zo_strformat(SI_SKILL_RANK_UP, lineName, rank) .. ".")
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
                {
                    message = formattedString,
                    messageType = "SKILL_LINE"
                }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end

            if ChatAnnouncements.SV.Skills.SkillLineCSA then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.SKILL_LINE_LEVELED_UP)
                messageParams:SetText(zo_strformat(SI_SKILL_RANK_UP, lineName, rank))
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SKILL_RANK_UPDATE)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end

            if ChatAnnouncements.SV.Skills.SkillLineAlert then
                local formattedText = zo_strformat(SI_SKILL_RANK_UP, lineName, rank) .. "."
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, formattedText)
            end

            if not ChatAnnouncements.SV.Skills.SkillLineCSA then
                PlaySound(SOUNDS.SKILL_LINE_LEVELED_UP)
            end
        end
    end
    return true
end

-- EVENT_SKILL_XP_UPDATE (CSA Handler)
local function SkillXPUpdateHook(skillType, skillLineIndex, reason, rank, previousXP, currentXP)
    if (skillType == SKILL_TYPE_GUILD and GUILD_SKILL_SHOW_REASONS[reason]) or reason == PROGRESS_REASON_JUSTICE_SKILL_EVENT then
        if not LUIE.SV.HideXPBar then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_NO_TEXT, SOUNDS.NONE)
            local barType = PLAYER_PROGRESS_BAR:GetBarType(PPB_CLASS_SKILL, skillType, skillLineIndex)
            local rankStartXP, nextRankStartXP = GetSkillLineRankXPExtents(skillType, skillLineIndex, rank)
            local sound = GUILD_SKILL_SHOW_SOUNDS[reason]
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SKILL_XP_UPDATE)
            if rankStartXP ~= nil then
                local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(barType, rank, previousXP - rankStartXP, currentXP - rankStartXP)
                barParams:SetTriggeringEvent(EVENT_SKILL_XP_UPDATE)
                ValidateProgressBarParams(barParams)
                messageParams:SetBarParams(barParams)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            else
                assert(false, string.format("No Rank Start XP %d %d %d %d %d %d", skillType, skillLineIndex, reason, rank, previousXP, currentXP))
            end
        end
    end
    return true
end

-- EVENT_COLLECTION_UPDATED (CSA Handler) -- Hooked via csaCallbackHandlers[1]
local function CollectibleUnlockedHook(collectionUpdateType, collectiblesByUnlockState)
    if collectionUpdateType == ZO_COLLECTION_UPDATE_TYPE.UNLOCK_STATE_CHANGED then
        local nowOwnedCollectibles = collectiblesByUnlockState[COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED]
        if nowOwnedCollectibles then
            if #nowOwnedCollectibles > MAX_INDIVIDUAL_COLLECTIBLE_UPDATES then
                local stringPrefix = ChatAnnouncements.SV.Collectibles.CollectiblePrefix
                local csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(SI_COLLECTIONS_UPDATED_ANNOUNCEMENT_TITLE)

                if ChatAnnouncements.SV.Collectibles.CollectibleCA then
                    local string1
                    if stringPrefix ~= "" then
                        string1 = ChatAnnouncements.Colors.CollectibleColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", ChatAnnouncements.bracket1[ChatAnnouncements.SV.Collectibles.CollectibleBracket], stringPrefix, ChatAnnouncements.bracket2[ChatAnnouncements.SV.Collectibles.CollectibleBracket]))
                    else
                        string1 = ""
                    end
                    local string2 = ChatAnnouncements.Colors.CollectibleColorize2:Colorize(zo_strformat(SI_COLLECTIBLES_UPDATED_ANNOUNCEMENT_BODY, #nowOwnedCollectibles) .. ".")
                    local finalString = zo_strformat("<<1>><<2>>", string1, string2)
                    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
                    {
                        message = finalString,
                        messageType = "COLLECTIBLE"
                    }
                    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
                end

                -- Set message params even if CSA is disabled, we just send a dummy event so the callback handler works correctly.
                -- Note: This also means we don't need to Play Sound if the CSA isn't enabled since a blank one is always sent if the CSA is disabled.
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.COLLECTIBLE_UNLOCKED)
                if ChatAnnouncements.SV.Collectibles.CollectibleCSA then
                    messageParams:SetText(csaPrefix, zo_strformat(SI_COLLECTIBLES_UPDATED_ANNOUNCEMENT_BODY, #nowOwnedCollectibles))
                    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COLLECTIBLES_UPDATED)
                    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                end

                if ChatAnnouncements.SV.Collectibles.CollectibleAlert then
                    local text = zo_strformat(SI_COLLECTIBLES_UPDATED_ANNOUNCEMENT_BODY, #nowOwnedCollectibles) .. "."
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
                end
                return true
            else
                -- local messageParamsObjects = {}
                for _, collectibleData in ipairs(nowOwnedCollectibles) do
                    local collectibleName = collectibleData:GetName()
                    local icon = collectibleData:GetIcon()
                    local categoryData = collectibleData:GetCategoryData()
                    local majorCategory = categoryData:GetId()
                    local majorCategoryTopLevelIndex = GetCategoryInfoFromCollectibleCategoryId(majorCategory)
                    local majorCategoryName = GetCollectibleCategoryInfo(majorCategoryTopLevelIndex)
                    local categoryName = categoryData:GetName()
                    local collectibleId = collectibleData:GetId()

                    local stringPrefix = ChatAnnouncements.SV.Collectibles.CollectiblePrefix
                    local csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(SI_COLLECTIONS_UPDATED_ANNOUNCEMENT_TITLE)

                    if ChatAnnouncements.SV.Collectibles.CollectibleCA then
                        local link = GetCollectibleLink(collectibleId, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionCollectible])
                        local formattedIcon = ChatAnnouncements.SV.Collectibles.CollectibleIcon and string.format("|t16:16:%s|t ", icon) or ""

                        local string1
                        if stringPrefix ~= "" then
                            string1 = ChatAnnouncements.Colors.CollectibleColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", ChatAnnouncements.bracket1[ChatAnnouncements.SV.Collectibles.CollectibleBracket], stringPrefix, ChatAnnouncements.bracket2[ChatAnnouncements.SV.Collectibles.CollectibleBracket]))
                        else
                            string1 = ""
                        end
                        local string2
                        if ChatAnnouncements.SV.Collectibles.CollectibleCategory or ChatAnnouncements.SV.Collectibles.CollectibleSubcategory then
                            local categoryString
                            if ChatAnnouncements.SV.Collectibles.CollectibleCategory and ChatAnnouncements.SV.Collectibles.CollectibleSubcategory then
                                categoryString = (majorCategoryName .. " - " .. categoryName)
                            elseif ChatAnnouncements.SV.Collectibles.CollectibleCategory then
                                categoryString = majorCategoryName
                            else
                                categoryString = categoryName
                            end
                            string2 = ChatAnnouncements.Colors.CollectibleColorize2:Colorize(zo_strformat(SI_COLLECTIONS_UPDATED_ANNOUNCEMENT_BODY, link, categoryString) .. ".")
                        else
                            string2 = link
                        end
                        local finalString = zo_strformat("<<1>><<2>><<3>>", string1, formattedIcon, string2)
                        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
                        {
                            message = finalString,
                            messageType = "COLLECTIBLE"
                        }
                        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
                    end

                    -- Set message params even if CSA is disabled, we just send a dummy event so the callback handler works correctly.
                    -- Note: This also means we don't need to Play Sound if the CSA isn't enabled since a blank one is always sent if the CSA is disabled.
                    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.COLLECTIBLE_UNLOCKED)
                    if ChatAnnouncements.SV.Collectibles.CollectibleCSA then
                        local csaString
                        if ChatAnnouncements.SV.Collectibles.CollectibleCategory or ChatAnnouncements.SV.Collectibles.CollectibleSubcategory then
                            local categoryString
                            if ChatAnnouncements.SV.Collectibles.CollectibleCategory and ChatAnnouncements.SV.Collectibles.CollectibleSubcategory then
                                categoryString = (majorCategoryName .. " - " .. categoryName)
                            elseif ChatAnnouncements.SV.Collectibles.CollectibleCategory then
                                categoryString = majorCategoryName
                            else
                                categoryString = categoryName
                            end
                            csaString = zo_strformat(SI_COLLECTIONS_UPDATED_ANNOUNCEMENT_BODY, collectibleName, categoryString)
                        else
                            csaString = zo_strformat(SI_COLLECTIONS_UPDATED_ANNOUNCEMENT_BODY, collectibleName, categoryName)
                        end
                        messageParams:SetText(csaPrefix, csaString)
                        messageParams:SetIconData(icon, "EsoUI/Art/Achievements/achievements_iconBG.dds")
                        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SINGLE_COLLECTIBLE_UPDATED)
                        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                    end

                    if ChatAnnouncements.SV.Collectibles.CollectibleAlert then
                        local alertString
                        if ChatAnnouncements.SV.Collectibles.CollectibleCategory or ChatAnnouncements.SV.Collectibles.CollectibleSubcategory then
                            local categoryString
                            if ChatAnnouncements.SV.Collectibles.CollectibleCategory and ChatAnnouncements.SV.Collectibles.CollectibleSubcategory then
                                categoryString = (majorCategoryName .. " - " .. categoryName)
                            elseif ChatAnnouncements.SV.Collectibles.CollectibleCategory then
                                categoryString = majorCategoryName
                            else
                                categoryString = categoryName
                            end
                            alertString = zo_strformat(SI_COLLECTIONS_UPDATED_ANNOUNCEMENT_BODY, collectibleName, categoryString .. ".")
                        else
                            alertString = zo_strformat(SI_COLLECTIONS_UPDATED_ANNOUNCEMENT_BODY, collectibleName, categoryName .. ".")
                        end
                        local text = alertString
                        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
                    end
                end
                return true
            end
        end
    end
end

local function ResetQuestRewardStatus()
    ChatAnnouncements.itemReceivedIsQuestReward = false
end

local function ResetQuestAbandonStatus()
    ChatAnnouncements.itemReceivedIsQuestAbandon = false
end

-- EVENT_QUEST_ADDED (CSA Handler)
--- @param journalIndex luaindex
--- @param questName string
--- @param objectiveName string
--- @return boolean
local function QuestAddedHook(journalIndex, questName, objectiveName)
    eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
    ChatAnnouncements.PrintBufferedXP()
    -- Check WritCreater settings first
    if ChatAnnouncements.isWritCreatorEnabled and WritCreater and WritCreater:GetSettings().suppressQuestAnnouncements and isQuestWritQuest(journalIndex) then
        return true
    end
    local questType = GetJournalQuestType(journalIndex)
    local zoneDisplayType = GetJournalQuestZoneDisplayType(journalIndex)
    local questJournalObject = SYSTEMS:GetObject("questJournal")
    local iconTexture = questJournalObject:GetIconTexture(questType, zoneDisplayType)

    -- Add quest to index
    ChatAnnouncements.questIndex[questName] =
    {
        questType = questType,
        instanceDisplayType = zoneDisplayType,
    }

    if ChatAnnouncements.SV.Quests.QuestAcceptCSA then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.QUEST_ACCEPTED)
        if iconTexture then
            messageParams:SetText(zo_strformat(LUIE_STRING_CA_QUEST_ACCEPT_WITH_ICON, zo_iconFormat(iconTexture, "75%", "75%"), questName))
        else
            messageParams:SetText(zo_strformat(SI_NOTIFYTEXT_QUEST_ACCEPT, questName))
        end
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_ADDED)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end

    if ChatAnnouncements.SV.Quests.QuestAcceptAlert then
        local alertString
        if iconTexture and ChatAnnouncements.SV.Quests.QuestIcon then
            alertString = zo_strformat(LUIE_STRING_CA_QUEST_ACCEPT_WITH_ICON, zo_iconFormat(iconTexture, "75%", "75%"), questName)
        else
            alertString = zo_strformat(SI_NOTIFYTEXT_QUEST_ACCEPT, questName)
        end
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertString)
    end

    -- If we don't have either CSA or Alert on (then we want to play a sound here)
    if not ChatAnnouncements.SV.Quests.QuestAcceptCSA then
        PlaySound(SOUNDS.QUEST_ACCEPTED)
    end

    if ChatAnnouncements.SV.Quests.QuestAcceptCA then
        local questNameFormatted
        local stepText = GetJournalQuestStepInfo(journalIndex, 1)
        local formattedString

        if ChatAnnouncements.SV.Quests.QuestLong then
            questNameFormatted = (zo_strformat("|c<<1>><<2>>:|r |c<<3>><<4>>|r", ChatAnnouncements.Colors.QuestColorQuestNameColorize:ToHex(), questName, ChatAnnouncements.Colors.QuestColorQuestDescriptionColorize, stepText))
        else
            questNameFormatted = (zo_strformat("|c<<1>><<2>>|r", ChatAnnouncements.Colors.QuestColorQuestNameColorize:ToHex(), questName))
        end
        if iconTexture and ChatAnnouncements.SV.Quests.QuestIcon then
            formattedString = string.format(GetString(LUIE_STRING_CA_QUEST_ACCEPT) .. zo_iconFormat(iconTexture, 16, 16) .. " " .. questNameFormatted)
        else
            formattedString = string.format("%s%s", GetString(LUIE_STRING_CA_QUEST_ACCEPT), questNameFormatted)
        end

        -- If this message is duplicated by another addon then don't display twice.
        for i = 1, #ChatAnnouncements.QueuedMessages do
            if ChatAnnouncements.QueuedMessages[i].message == formattedString then
                return true
            end
        end
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
        {
            message = formattedString,
            messageType = "QUEST"
        }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end

    return true
end

-- EVENT_QUEST_COMPLETE (CSA Handler)
--- @param questName string
--- @param level integer
--- @param previousExperience integer
--- @param currentExperience integer
--- @param championPoints integer
--- @param questType QuestType
--- @param zoneDisplayType ZoneDisplayType
--- @return boolean
local function QuestCompleteHook(questName, level, previousExperience, currentExperience, championPoints, questType, zoneDisplayType)
    eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
    ChatAnnouncements.PrintBufferedXP()

    local questJournalObject = SYSTEMS:GetObject("questJournal")
    local iconTexture = questJournalObject and questJournalObject:GetIconTexture(questType, zoneDisplayType)

    if ChatAnnouncements.SV.Quests.QuestCompleteCSA then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.QUEST_COMPLETED)
        if iconTexture then
            messageParams:SetText(zo_strformat(LUIE_STRING_CA_QUEST_COMPLETE_WITH_ICON, zo_iconFormat(iconTexture, "75%", "75%"), questName))
        else
            messageParams:SetText(zo_strformat(SI_NOTIFYTEXT_QUEST_COMPLETE, questName))
        end
        if not LUIE.SV.HideXPBar then
            messageParams:SetBarParams(GetRelevantBarParams(level, previousExperience, currentExperience, championPoints, EVENT_QUEST_COMPLETE))
        end
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_COMPLETED)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end

    if ChatAnnouncements.SV.Quests.QuestCompleteAlert then
        local alertString
        if iconTexture and ChatAnnouncements.SV.Quests.QuestIcon then
            alertString = zo_strformat(LUIE_STRING_CA_QUEST_COMPLETE_WITH_ICON, zo_iconFormat(iconTexture, "75%", "75%"), questName)
        else
            alertString = zo_strformat(SI_NOTIFYTEXT_QUEST_COMPLETE, questName)
        end
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertString)
    end

    if ChatAnnouncements.SV.Quests.QuestCompleteCA then
        local questNameFormatted = (zo_strformat("|cFFA500<<1>>|r", questName))
        local formattedString
        if iconTexture and ChatAnnouncements.SV.Quests.QuestIcon then
            formattedString = zo_strformat(LUIE_STRING_CA_QUEST_COMPLETE_WITH_ICON, zo_iconFormat(iconTexture, 16, 16), questNameFormatted)
        else
            formattedString = zo_strformat(SI_NOTIFYTEXT_QUEST_COMPLETE, questNameFormatted)
        end
        -- This event double fires on quest completion, if an equivalent message is already detected in queue, then abort!
        for i = 1, #ChatAnnouncements.QueuedMessages do
            if ChatAnnouncements.QueuedMessages[i].message == formattedString then
                return true
            end
        end
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
        {
            message = formattedString,
            messageType = "QUEST"
        }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end

    -- If we don't have either CSA or Alert on (then we want to play a sound here)
    if not ChatAnnouncements.SV.Quests.QuestCompleteCSA then
        PlaySound(SOUNDS.QUEST_COMPLETED)
    end

    -- We set this variable to true in order to override the [Looted] message syntax that would be applied to a quest reward normally.
    if ChatAnnouncements.SV.Inventory.Loot then
        ChatAnnouncements.itemReceivedIsQuestReward = true
        zo_callLater(ResetQuestRewardStatus, 500)
    end

    return true
end

-- EVENT_OBJECTIVE_COMPLETED (CSA Handler)
-- Note we don't play a sound if the CSA is disabled here because the Quest complete message will already do this.
local function ObjectiveCompletedHook(zoneIndex, poiIndex, level, previousExperience, currentExperience, championPoints)
    local name, _, _, finishedDescription = GetPOIInfo(zoneIndex, poiIndex)
    local nameFormatted
    local formattedText

    if ChatAnnouncements.SV.Quests.QuestLocLong and finishedDescription ~= "" then
        nameFormatted = (zo_strformat("|c<<1>><<2>>:|r |c<<3>><<4>>|r", ChatAnnouncements.Colors.QuestColorLocNameColorize, name, ChatAnnouncements.Colors.QuestColorLocDescriptionColorize, finishedDescription))
    else
        nameFormatted = (zo_strformat("|c<<1>><<2>>|r", ChatAnnouncements.Colors.QuestColorLocNameColorize, name))
    end
    formattedText = zo_strformat(SI_NOTIFYTEXT_OBJECTIVE_COMPLETE, nameFormatted)

    if ChatAnnouncements.SV.Quests.QuestCompleteAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(SI_NOTIFYTEXT_OBJECTIVE_COMPLETE, name))
    end

    if ChatAnnouncements.SV.Quests.QuestCompleteCSA then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.OBJECTIVE_COMPLETED)
        if not LUIE.SV.HideXPBar then
            messageParams:SetBarParams(GetRelevantBarParams(level, previousExperience, currentExperience, championPoints, EVENT_OBJECTIVE_COMPLETED))
        end
        messageParams:SetText(zo_strformat(SI_NOTIFYTEXT_OBJECTIVE_COMPLETE, name), finishedDescription)
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_OBJECTIVE_COMPLETED)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end

    if ChatAnnouncements.SV.Quests.QuestCompleteCA then
        -- This event double fires on quest completion, if an equivalent message is already detected in queue, then abort!
        for i = 1, #ChatAnnouncements.QueuedMessages do
            if ChatAnnouncements.QueuedMessages[i].message == formattedText then
                return true
            end
        end
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
        {
            message = formattedText,
            messageType = "QUEST"
        }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end

    return true
end

-- EVENT_QUEST_CONDITION_COUNTER_CHANGED (CSA Handler)
-- Note: Used for quest failure and updates
local function ConditionCounterHook(journalIndex, questName, conditionText, conditionType, currConditionVal, newConditionVal, conditionMax, isFailCondition, stepOverrideText, isPushed, isComplete, isConditionComplete, isStepHidden, isConditionCompleteChanged)
    -- Check WritCreater settings first
    if ChatAnnouncements.isWritCreatorEnabled and WritCreater and WritCreater:GetSettings().suppressQuestAnnouncements and isQuestWritQuest(journalIndex) then
        return true
    end

    if isStepHidden or (isPushed and isComplete) or (currConditionVal >= newConditionVal) then
        return true
    end

    local messageType      -- This variable represents whether this message is an objective update or failure state message (1 = update, 2 = failure) There are too many conditionals to resolve what we need to print inside them so we do it after setting the formatting.
    local alertMessage     -- Variable for alert message
    local formattedMessage -- Variable for CA Message
    local sound            -- Set correct sound based off context
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)

    if newConditionVal ~= currConditionVal and not isFailCondition then
        sound = isConditionComplete and SOUNDS.QUEST_OBJECTIVE_COMPLETE or SOUNDS.QUEST_OBJECTIVE_INCREMENT
        messageParams:SetSound(sound)
    end

    if isConditionComplete and conditionType == QUEST_CONDITION_TYPE_GIVE_ITEM or conditionType == QUEST_CONDITION_TYPE_TALK_TO then
        -- We set this variable to true in order to override the [Looted] message syntax that would be applied to a quest reward normally.
        if ChatAnnouncements.SV.Inventory.Loot then
            ChatAnnouncements.itemReceivedIsQuestReward = true
            zo_callLater(ResetQuestRewardStatus, 500)
        end
    end

    if isConditionComplete and conditionType == QUEST_CONDITION_TYPE_GIVE_ITEM then
        messageParams:SetText(zo_strformat(SI_TRACKED_QUEST_STEP_DONE, conditionText))
        alertMessage = zo_strformat(SI_TRACKED_QUEST_STEP_DONE, conditionText)
        formattedMessage = zo_strformat(SI_TRACKED_QUEST_STEP_DONE, conditionText)
        messageType = 1
    elseif stepOverrideText == "" then
        if isFailCondition then
            if conditionMax > 1 then
                messageParams:SetText(zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL, conditionText, newConditionVal, conditionMax))
                alertMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL, conditionText, newConditionVal, conditionMax)
                formattedMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL, conditionText, newConditionVal, conditionMax)
            else
                messageParams:SetText(zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL_NO_COUNT, conditionText))
                alertMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL_NO_COUNT, conditionText)
                formattedMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL_NO_COUNT, conditionText)
            end
            messageType = 2
        else
            if conditionMax > 1 and newConditionVal < conditionMax then
                messageParams:SetText(zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE, conditionText, newConditionVal, conditionMax))
                alertMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE, conditionText, newConditionVal, conditionMax)
                formattedMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE, conditionText, newConditionVal, conditionMax)
            else
                messageParams:SetText(zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, conditionText))
                alertMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, conditionText)
                formattedMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, conditionText)
            end
            messageType = 1
        end
    else
        if isFailCondition then
            messageParams:SetText(zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL_NO_COUNT, stepOverrideText))
            alertMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL_NO_COUNT, stepOverrideText)
            formattedMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL_NO_COUNT, stepOverrideText)
            messageType = 2
        else
            messageParams:SetText(zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, stepOverrideText))
            alertMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, stepOverrideText)
            formattedMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, stepOverrideText)
            messageType = 1
        end
    end

    -- Override text if its listed in the override table.
    if Quests.QuestObjectiveCompleteOverride[formattedMessage] then
        messageParams:SetText(Quests.QuestObjectiveCompleteOverride[formattedMessage])
        alertMessage = Quests.QuestObjectiveCompleteOverride[formattedMessage]
        formattedMessage = Quests.QuestObjectiveCompleteOverride[formattedMessage]
    end

    if isConditionComplete then
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_CONDITION_COMPLETED)
    else
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_PROGRESSION_CHANGED)
    end

    if messageType == 1 then
        if ChatAnnouncements.SV.Quests.QuestObjCompleteCA then
            -- This event double fires on quest completion, if an equivalent message is already detected in queue, then abort!
            for i = 1, #ChatAnnouncements.QueuedMessages do
                if ChatAnnouncements.QueuedMessages[i].message == formattedMessage then
                    return true
                end
            end
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = formattedMessage,
                messageType = "MESSAGE" -- We set the message messageType to MESSAGE so if we loot a quest item that progresses the quest this comes after.
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end
        if ChatAnnouncements.SV.Quests.QuestObjCompleteCSA then
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end
        if ChatAnnouncements.SV.Quests.QuestObjCompleteAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertMessage)
        end
        if not ChatAnnouncements.SV.Quests.QuestObjCompleteCSA then
            PlaySound(sound)
        end
    end

    if messageType == 2 then
        if ChatAnnouncements.SV.Quests.QuestFailCA then
            -- This event double fires on quest completion, if an equivalent message is already detected in queue, then abort!
            for i = 1, #ChatAnnouncements.QueuedMessages do
                if ChatAnnouncements.QueuedMessages[i].message == formattedMessage then
                    return true
                end
            end
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = formattedMessage,
                messageType = "MESSAGE"
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end
        if ChatAnnouncements.SV.Quests.QuestFailCSA then
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end
        if ChatAnnouncements.SV.Quests.QuestFailAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertMessage)
        end
        if not ChatAnnouncements.SV.Quests.QuestFailCSA then
            PlaySound(sound)
        end
    end

    return true
end

-- EVENT_QUEST_OPTIONAL_STEP_ADVANCED (CSA Handler)
local function OptionalStepHook(text)
    if text ~= "" then
        local message = zo_strformat("|c<<1>><<2>>|r", ChatAnnouncements.Colors.QuestColorQuestDescriptionColorize, text)
        local formattedString = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, message)

        if ChatAnnouncements.SV.Quests.QuestObjCompleteCA then
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = formattedString,
                messageType = "MESSAGE"
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Quests.QuestObjCompleteCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.QUEST_OBJECTIVE_COMPLETE)
            messageParams:SetText(zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, text))
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_PROGRESSION_CHANGED)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.Quests.QuestObjCompleteAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, formattedString)
        end
        if not ChatAnnouncements.SV.Quests.QuestObjCompleteCSA then
            PlaySound(SOUNDS.QUEST_OBJECTIVE_COMPLETE)
        end
    end
    return true
end

-- EVENT_QUEST_REMOVED (Registered through CSA_MiscellaneousHandlers)
local function OnQuestRemoved(eventId, isCompleted, journalIndex, questName, zoneIndex, poiIndex, questID)
    if isCompleted then
        return
    end

    if ChatAnnouncements.SV.Quests.QuestAbandonCA or ChatAnnouncements.SV.Quests.QuestAbandonCSA or ChatAnnouncements.SV.Quests.QuestAbandonAlert then
        local iconTexture

        if ChatAnnouncements.questIndex[questName] then
            local questJournalObject = SYSTEMS:GetObject("questJournal")
            local questType = ChatAnnouncements.questIndex[questName].questType
            local instanceDisplayType = ChatAnnouncements.questIndex[questName].instanceDisplayType
            iconTexture = questJournalObject and questJournalObject:GetIconTexture(questType, instanceDisplayType)
        end

        if ChatAnnouncements.SV.Quests.QuestAbandonCA then
            local questNameFormatted = (zo_strformat("|cFFA500<<1>>|r", questName))
            local formattedString
            if iconTexture and ChatAnnouncements.SV.Quests.QuestIcon then
                formattedString = zo_strformat(LUIE_STRING_CA_QUEST_ABANDONED_WITH_ICON, zo_iconFormat(iconTexture, 16, 16), questNameFormatted)
            else
                formattedString = zo_strformat(LUIE_STRING_CA_QUEST_ABANDONED, questNameFormatted)
            end
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = formattedString,
                messageType = "MESSAGE"
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Quests.QuestAbandonCSA then
            local formattedString
            if iconTexture then
                formattedString = zo_strformat(LUIE_STRING_CA_QUEST_ABANDONED_WITH_ICON, zo_iconFormat(iconTexture, "75%", "75%"), questName)
            else
                formattedString = zo_strformat(LUIE_STRING_CA_QUEST_ABANDONED, questName)
            end
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.QUEST_ABANDONED)
            messageParams:SetText(formattedString)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_ADDED)
            -- CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.Quests.QuestAbandonAlert then
            local formattedString
            if iconTexture and ChatAnnouncements.SV.Quests.QuestIcon then
                formattedString = zo_strformat(LUIE_STRING_CA_QUEST_ABANDONED_WITH_ICON, zo_iconFormat(iconTexture, "75%", "75%"), questName)
            else
                formattedString = zo_strformat(LUIE_STRING_CA_QUEST_ABANDONED, questName)
            end
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, formattedString)
        end
    end
    if not ChatAnnouncements.SV.Quests.QuestAbandonCSA then
        PlaySound(SOUNDS.QUEST_ABANDONED)
    end

    -- We set this variable to true in order to override the message syntax that would be applied to a quest reward normally with [Removed] instead.
    if ChatAnnouncements.SV.Inventory.Loot then
        ChatAnnouncements.itemReceivedIsQuestAbandon = true
        zo_callLater(ResetQuestAbandonStatus, 500)
    end

    ChatAnnouncements.questIndex[questName] = nil
end

-- EVENT_QUEST_ADVANCED (Registered through CSA_MiscellaneousHandlers)
-- Note: Quest Advancement displays all the "appropriate" conditions that the player needs to do to advance the current step
--- - **EVENT_QUEST_ADVANCED **
---
--- @param eventId integer
--- @param questIndex luaindex
--- @param questName string
--- @param isPushed boolean
--- @param isComplete boolean
--- @param mainStepChanged boolean
--- @param soundOverride boolean
local function OnQuestAdvanced(eventId, questIndex, questName, isPushed, isComplete, mainStepChanged, soundOverride)
    -- Check if WritCreater is enabled & then call a copy of a local function from WritCreater to check if this is a Writ Quest
    if ChatAnnouncements.isWritCreatorEnabled and WritCreater and WritCreater:GetSettings().suppressQuestAnnouncements and isQuestWritQuest(questIndex) then
        return
    end

    if not mainStepChanged then
        return
    end

    local sound = SOUNDS.QUEST_OBJECTIVE_STARTED

    for stepIndex = QUEST_MAIN_STEP_INDEX, GetJournalQuestNumSteps(questIndex) do
        local _, visibility, stepType, stepOverrideText, conditionCount = GetJournalQuestStepInfo(questIndex, stepIndex)

        -- Override text if its listed in the override table.
        if Quests.QuestAdvancedOverride[stepOverrideText] then
            stepOverrideText = Quests.QuestAdvancedOverride[stepOverrideText]
        end

        if visibility == nil or visibility == QUEST_STEP_VISIBILITY_OPTIONAL then
            if stepOverrideText ~= "" then
                if ChatAnnouncements.SV.Quests.QuestObjUpdateCA then
                    -- This event sometimes results in duplicate messages - if an equivalent message is already detected in queue, then abort!
                    for i = 1, #ChatAnnouncements.QueuedMessages do
                        if ChatAnnouncements.QueuedMessages[i].message == stepOverrideText then
                            -- Set the old message to blank so it gets skipped by the printer
                            ChatAnnouncements.QueuedMessages[i].message = ""
                        end
                    end
                    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
                    {
                        message = stepOverrideText,
                        messageType = "MESSAGE"
                    }
                    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
                end
                if ChatAnnouncements.SV.Quests.QuestObjUpdateCSA then
                    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, sound)
                    messageParams:SetText(stepOverrideText)
                    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_PROGRESSION_CHANGED)
                    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                    sound = SOUNDS.NONE -- no longer needed, we played it once
                end
                if ChatAnnouncements.SV.Quests.QuestObjUpdateAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, stepOverrideText)
                end
            else
                for conditionIndex = 1, conditionCount do
                    local conditionText, curCount, maxCount, isFailCondition, isConditionComplete, _, isVisible = GetJournalQuestConditionInfo(questIndex, stepIndex, conditionIndex, false)

                    if not (isFailCondition or isConditionComplete) and isVisible then
                        if ChatAnnouncements.SV.Quests.QuestObjUpdateCA then
                            -- This event sometimes results in duplicate messages - if an equivalent message is already detected in queue, then abort!
                            for i = 1, #ChatAnnouncements.QueuedMessages do
                                if ChatAnnouncements.QueuedMessages[i].message == conditionText then
                                    -- Set the old message to blank so it gets skipped by the printer
                                    ChatAnnouncements.QueuedMessages[i].message = ""
                                end
                            end
                            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
                            {
                                message = conditionText,
                                messageType = "MESSAGE"
                            }
                            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
                        end
                        if ChatAnnouncements.SV.Quests.QuestObjUpdateCSA then
                            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, sound)
                            messageParams:SetText(conditionText)
                            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_PROGRESSION_CHANGED)
                            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                            sound = SOUNDS.NONE -- no longer needed, we played it once
                        end
                        if ChatAnnouncements.SV.Quests.QuestObjUpdateAlert then
                            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, conditionText)
                        end
                    end
                end
            end
            -- We send soundOverride = true from OnQuestAdded in order to stop the sound from spamming if CSA isn't on and a quest is accepted.
            if not ChatAnnouncements.SV.Quests.QuestObjUpdateCSA and not soundOverride then
                PlaySound(SOUNDS.QUEST_OBJECTIVE_STARTED)
            end
        end
    end
end

-- EVENT_QUEST_ADDED (Registered through CSA_MiscellaneousHandlers)
local function OnQuestAdded(eventId, questIndex)
    -- Suppress announcements for writ quests if configured
    if ChatAnnouncements.isWritCreatorEnabled and WritCreater and WritCreater:GetSettings().suppressQuestAnnouncements and isQuestWritQuest(questIndex) then
        -- Handle WritCrafter integration
        -- Auto-abandon quests with disallowed materials
        local rejectedMat = rejectQuest(questIndex)
        if rejectedMat then
            local questName = GetJournalQuestName(questIndex)
            printToChat(zo_strformat("Writ Crafter abandoned the <<1>> because it requires <<2>> which was disallowed in settings", questName, rejectedMat), true)
            zo_callLater(function ()
                             AbandonQuest(questIndex)
                         end, 500)
            return
        end

        return true
    end

    OnQuestAdvanced(EVENT_QUEST_ADVANCED, questIndex, nil, nil, nil, true, true)
end

-- EVENT_DISCOVERY_EXPERIENCE (CSA Handler)
local function DiscoveryExperienceHook(subzoneName, level, previousExperience, currentExperience, championPoints)
    eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
    ChatAnnouncements.PrintBufferedXP()

    if ChatAnnouncements.SV.Quests.QuestLocDiscoveryCA then
        local nameFormatted = (zo_strformat("|c<<1>><<2>>|r", ChatAnnouncements.Colors.QuestColorLocNameColorize, subzoneName))
        local formattedString = zo_strformat(LUIE_STRING_CA_QUEST_DISCOVER, nameFormatted)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
        {
            message = formattedString,
            messageType = "QUEST"
        }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end

    if ChatAnnouncements.SV.Quests.QuestLocDiscoveryCSA and not INTERACT_WINDOW:IsShowingInteraction() then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.OBJECTIVE_DISCOVERED)
        if currentExperience > previousExperience then
            if not LUIE.SV.HideXPBar then
                messageParams:SetBarParams(GetRelevantBarParams(level, previousExperience, currentExperience, championPoints, EVENT_DISCOVERY_EXPERIENCE))
            end
        end
        messageParams:SetText(zo_strformat(LUIE_STRING_CA_QUEST_DISCOVER, subzoneName))
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISCOVERY_EXPERIENCE)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end

    if ChatAnnouncements.SV.Quests.QuestLocDiscoveryAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(LUIE_STRING_CA_QUEST_DISCOVER, subzoneName))
    end

    if not ChatAnnouncements.SV.Quests.QuestLocDiscoveryCSA then
        PlaySound(SOUNDS.OBJECTIVE_DISCOVERED)
    end
    return true
end

-- EVENT_POI_DISCOVERED (CSA Handler)
local function PoiDiscoveredHook(zoneIndex, poiIndex)
    eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
    ChatAnnouncements.PrintBufferedXP()

    local name, _, startDescription = GetPOIInfo(zoneIndex, poiIndex)

    if ChatAnnouncements.SV.Quests.QuestLocObjectiveCA then
        local formattedString = (zo_strformat("|c<<1>><<2>>:|r |c<<3>><<4>>|r", ChatAnnouncements.Colors.QuestColorLocNameColorize, name, ChatAnnouncements.Colors.QuestColorLocDescriptionColorize, startDescription))
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
        {
            message = formattedString,
            messageType = "QUEST_POI"
        }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end

    if ChatAnnouncements.SV.Quests.QuestLocObjectiveCSA then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.OBJECTIVE_ACCEPTED)
        messageParams:SetText(zo_strformat(SI_NOTIFYTEXT_OBJECTIVE_DISCOVERED, name), startDescription)
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_POI_DISCOVERED)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end

    if ChatAnnouncements.SV.Quests.QuestLocObjectiveAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(SI_NOTIFYTEXT_OBJECTIVE_DISCOVERED, name), startDescription)
    end
    return true
end

local XP_GAIN_SHOW_REASONS =
{
    [PROGRESS_REASON_PVP_EMPEROR] = true,
    [PROGRESS_REASON_DUNGEON_CHALLENGE] = true,
    [PROGRESS_REASON_OVERLAND_BOSS_KILL] = true,
    [PROGRESS_REASON_SCRIPTED_EVENT] = true,
    [PROGRESS_REASON_LOCK_PICK] = true,
    [PROGRESS_REASON_LFG_REWARD] = true,
}

local XP_GAIN_SHOW_SOUNDS =
{
    [PROGRESS_REASON_OVERLAND_BOSS_KILL] = SOUNDS.OVERLAND_BOSS_KILL,
    [PROGRESS_REASON_LOCK_PICK] = SOUNDS.LOCKPICKING_SUCCESS_CELEBRATION,
}

-- EVENT_EXPERIENCE_GAIN (CSA Handler)
-- Note: This function is prehooked in order to allow the XP bar popup to be hidden. In addition we shift the sound over
local function ExperienceGainHook(reason, level, previousExperience, currentExperience, championPoints)
    local sound = XP_GAIN_SHOW_SOUNDS[reason]

    if XP_GAIN_SHOW_REASONS[reason] and not LUIE.SV.HideXPBar then
        local barParams = GetRelevantBarParams(level, previousExperience, currentExperience, championPoints)
        if barParams then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_NO_TEXT, SOUNDS.NONE)
            barParams:SetSound(sound)
            ValidateProgressBarParams(barParams)
            messageParams:SetBarParams(barParams)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_EXPERIENCE_GAIN)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end
    end

    -- We want to play a sound still even if the bar popup is hidden, but the delay needs to remain intact so we add a blank CSA with sound.
    if XP_GAIN_SHOW_REASONS[reason] and LUIE.SV.HideXPBar and sound ~= nil then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
        messageParams:SetSound(sound)
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_EXPERIENCE_GAIN)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end

    -- Level up notification
    local levelSize = GetNumExperiencePointsInLevel(level)
    if levelSize ~= nil and currentExperience >= levelSize then
        eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
        ChatAnnouncements.PrintBufferedXP()

        local CurrentLevel = level + 1
        if ChatAnnouncements.SV.XP.ExperienceLevelUpCA then
            local icon
            if ChatAnnouncements.SV.XP.ExperienceLevelColorByLevel then
                icon = ChatAnnouncements.SV.XP.ExperienceLevelUpIcon and ZO_XP_BAR_GRADIENT_COLORS[2]:Colorize(" " .. zo_iconFormatInheritColor("LuiExtended/media/unitframes/unitframes_level_normal.dds", 16, 16)) or ""
            else
                icon = ChatAnnouncements.SV.XP.ExperienceLevelUpIcon and (" " .. zo_iconFormat("LuiExtended/media/unitframes/unitframes_level_normal.dds", 16, 16)) or ""
            end

            local CurrentLevelFormatted = ""
            if ChatAnnouncements.SV.XP.ExperienceLevelColorByLevel then
                CurrentLevelFormatted = ZO_XP_BAR_GRADIENT_COLORS[2]:Colorize(GetString(SI_GAMEPAD_QUEST_JOURNAL_QUEST_LEVEL) .. " " .. CurrentLevel)
            else
                CurrentLevelFormatted = ChatAnnouncements.Colors.ExperienceLevelUpColorize:Colorize(GetString(SI_GAMEPAD_QUEST_JOURNAL_QUEST_LEVEL) .. " " .. CurrentLevel)
            end

            local formattedString
            if ChatAnnouncements.SV.XP.ExperienceLevelColorByLevel then
                formattedString = zo_strformat("<<1>><<2>> <<3>><<4>>", ChatAnnouncements.Colors.ExperienceLevelUpColorize:Colorize(GetString(LUIE_STRING_CA_LVL_ANNOUNCE_XP)), icon, CurrentLevelFormatted, ChatAnnouncements.Colors.ExperienceLevelUpColorize:Colorize("!"))
            else
                formattedString = zo_strformat("<<1>><<2>> <<3>><<4>>", ChatAnnouncements.Colors.ExperienceLevelUpColorize:Colorize(GetString(LUIE_STRING_CA_LVL_ANNOUNCE_XP)), icon, CurrentLevelFormatted, ChatAnnouncements.Colors.ExperienceLevelUpColorize:Colorize("!"))
            end
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = formattedString,
                messageType = "EXPERIENCE_LEVEL"
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
            local iconCSA = (" " .. zo_iconFormat("LuiExtended/media/unitframes/unitframes_level_up.dds", "100%", "100%")) or ""
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.LEVEL_UP)
            if ChatAnnouncements.SV.XP.ExperienceLevelUpCSAExpand then
                local levelUpExpanded = zo_strformat("<<1>><<2>> <<3>> <<4>>", GetString(LUIE_STRING_CA_LVL_ANNOUNCE_XP), iconCSA, GetString(SI_GAMEPAD_QUEST_JOURNAL_QUEST_LEVEL), CurrentLevel)
                messageParams:SetText(zo_strformat(SI_LEVEL_UP_NOTIFICATION), levelUpExpanded)
            else
                messageParams:SetText(GetString(SI_LEVEL_UP_NOTIFICATION))
            end
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_LEVEL_GAIN)
            if not LUIE.SV.HideXPBar then
                local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(PPB_XP, level + 1, currentExperience - levelSize, currentExperience - levelSize)
                barParams:SetShowNoGain(true)
                barParams:SetTriggeringEvent(EVENT_EXPERIENCE_GAIN)
                ValidateProgressBarParams(barParams)
                messageParams:SetBarParams(barParams)
            end
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.XP.ExperienceLevelUpAlert then
            local iconAlert = ChatAnnouncements.SV.XP.ExperienceLevelUpIcon and (" " .. zo_iconFormat("LuiExtended/media/unitframes/unitframes_level_up.dds", "75%", "75%")) or ""
            local text = zo_strformat("<<1>><<2>> <<3>> <<4>>!", GetString(LUIE_STRING_CA_LVL_ANNOUNCE_XP), iconAlert, GetString(SI_GAMEPAD_QUEST_JOURNAL_QUEST_LEVEL), CurrentLevel)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
        end

        -- Play Sound even if CSA is disabled
        if not ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
            PlaySound(SOUNDS.LEVEL_UP)
        end
    end

    return true
end

-- Called by EnlightenGainHook()
local function GetEnlightenedGainedAnnouncement(triggeringEvent)
    local formattedString = zo_strformat("<<1>>! <<2>>", GetString(SI_ENLIGHTENED_STATE_GAINED_HEADER), GetString(SI_ENLIGHTENED_STATE_GAINED_DESCRIPTION))
    if ChatAnnouncements.SV.XP.ExperienceEnlightenedCA then
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
        {
            message = formattedString,
            messageType = "EXPERIENCE"
        }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end

    if ChatAnnouncements.SV.XP.ExperienceEnlightenedCSA then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.ENLIGHTENED_STATE_GAINED)
        messageParams:SetText(zo_strformat(SI_ENLIGHTENED_STATE_GAINED_HEADER), zo_strformat(SI_ENLIGHTENED_STATE_GAINED_DESCRIPTION))
        if not LUIE.SV.HideXPBar then
            local barParams = GetCurrentChampionPointsBarParams(triggeringEvent)
            ValidateProgressBarParams(barParams)
            messageParams:SetBarParams(barParams)
        end
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ENLIGHTENMENT_GAINED)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end

    if ChatAnnouncements.SV.XP.ExperienceEnlightenedAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, formattedString)
    end

    if not ChatAnnouncements.SV.XP.ExperienceEnlightenedCSA then
        PlaySound(SOUNDS.ENLIGHTENED_STATE_GAINED)
    end

    return true
end

-- EVENT_ENLIGHTENED_STATE_GAINED (CSA Handler)
local function EnlightenGainHook()
    if IsEnlightenedAvailableForCharacter() then
        return GetEnlightenedGainedAnnouncement(EVENT_ENLIGHTENED_STATE_GAINED)
    end
end

-- EVENT_ENLIGHTENED_STATE_LOST (CSA Handler)
local function EnlightenLostHook()
    if IsEnlightenedAvailableForCharacter() then
        local formattedString = zo_strformat("<<1>>!", GetString(SI_ENLIGHTENED_STATE_LOST_HEADER))

        if ChatAnnouncements.SV.XP.ExperienceEnlightenedCA then
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = formattedString,
                messageType = "EXPERIENCE"
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.XP.ExperienceEnlightenedCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.ENLIGHTENED_STATE_LOST)
            if not LUIE.SV.HideXPBar then
                local barParams = GetCurrentChampionPointsBarParams(EVENT_ENLIGHTENED_STATE_LOST)
                ValidateProgressBarParams(barParams)
                messageParams:SetBarParams(barParams)
            end
            messageParams:SetText(zo_strformat(SI_ENLIGHTENED_STATE_LOST_HEADER))
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ENLIGHTENMENT_LOST)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.XP.ExperienceEnlightenedAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, formattedString)
        end

        if not ChatAnnouncements.SV.XP.ExperienceEnlightenedCSA then
            PlaySound(SOUNDS.ENLIGHTENED_STATE_LOST)
        end
    end

    return true
end

local firstActivation = true
-- EVENT_PLAYER_ACTIVATED (CSA Handler)
local function PlayerActivatedHook()
    if firstActivation then
        firstActivation = false

        if IsEnlightenedAvailableForCharacter() and GetEnlightenedPool() > 0 then
            return GetEnlightenedGainedAnnouncement(EVENT_PLAYER_ACTIVATED)
        end
    end
    return true
end

-- EVENT_RIDING_SKILL_IMPROVEMENT (CSA Handler)
-- Note: This function is effected by a throttle in centerscreenannouncehandlers, we resolve any message that needs to be throttled in this function.
-- Note: We allow the CSA handler to handle any changes made from skill books in order to properly throttle all messages, and use the alert handler for stables upgrades.
local function RidingSkillImprovementHook(ridingSkill, previous, current, source)
    if source == RIDING_TRAIN_SOURCE_ITEM then
        if ChatAnnouncements.SV.Notify.StorageRidingCA then
            -- TODO: Switch to using Recipe/Learn variable in the future
            if ChatAnnouncements.SV.Inventory.Loot then
                local icon
                local bookString
                local value = current - previous
                local learnString = GetString(LUIE_STRING_CA_STORAGE_LEARN)

                if ridingSkill == 1 then
                    if ChatAnnouncements.SV.BracketOptionItem == 1 then
                        bookString = "|H0:item:64700:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
                    else
                        bookString = "|H1:item:64700:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
                    end
                    icon = "|t16:16:/esoui/art/icons/store_ridinglessons_speed.dds|t "
                elseif ridingSkill == 2 then
                    if ChatAnnouncements.SV.BracketOptionItem == 1 then
                        bookString = "|H0:item:64702:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
                    else
                        bookString = "|H1:item:64702:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
                    end
                    icon = "|t16:16:/esoui/art/icons/store_ridinglessons_capacity.dds|t "
                elseif ridingSkill == 3 then
                    if ChatAnnouncements.SV.BracketOptionItem == 1 then
                        bookString = "|H0:item:64701:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
                    else
                        bookString = "|H1:item:64701:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
                    end
                    icon = "|t16:16:/esoui/art/icons/store_ridinglessons_stamina.dds|t "
                end

                local formattedColor = ChatAnnouncements.Colors.StorageRidingBookColorize:ToHex()

                local messageP1 = ChatAnnouncements.SV.Inventory.LootIcons and (icon .. bookString) or bookString
                local formattedString = (messageP1 .. "|r|cFFFFFF x" .. value .. "|r|c" .. formattedColor)
                local messageP2 = string.format(learnString, formattedString)
                local finalMessage = string.format("|c%s%s|r", formattedColor, messageP2)

                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
                {
                    message = finalMessage,
                    messageType = "MESSAGE"
                }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end

            local formattedString = ChatAnnouncements.Colors.StorageRidingColorize:Colorize(zo_strformat(SI_RIDING_SKILL_ANNOUCEMENT_SKILL_INCREASE, GetString("SI_RIDINGTRAINTYPE", ridingSkill), previous, current))
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = formattedString,
                messageType = "MESSAGE"
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Notify.StorageRidingAlert then
            local text = zo_strformat(SI_RIDING_SKILL_ANNOUCEMENT_SKILL_INCREASE, GetString("SI_RIDINGTRAINTYPE", ridingSkill), previous, current)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
        end

        if ChatAnnouncements.SV.Notify.StorageRidingCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
            messageParams:SetText(GetString(SI_RIDING_SKILL_ANNOUCEMENT_BANNER), zo_strformat(SI_RIDING_SKILL_ANNOUCEMENT_SKILL_INCREASE, GetString("SI_RIDINGTRAINTYPE", ridingSkill), previous, current))
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RIDING_SKILL_IMPROVEMENT)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end
    end
    return true
end

-- EVENT_INVENTORY_BAG_CAPACITY_CHANGED (CSA Handler)
local function InventoryBagCapacityHook(previousCapacity, currentCapacity, previousUpgrade, currentUpgrade)
    if previousCapacity > 0 and previousCapacity ~= currentCapacity and previousUpgrade ~= currentUpgrade then
        if ChatAnnouncements.SV.Notify.StorageBagCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
            messageParams:SetText(GetString(SI_INVENTORY_BAG_UPGRADE_ANOUNCEMENT_TITLE), zo_strformat(SI_INVENTORY_BAG_UPGRADE_ANOUNCEMENT_DESCRIPTION, previousCapacity, currentCapacity))
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_BAG_CAPACITY_CHANGED)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end
    end
    return true
end

-- EVENT_INVENTORY_BANK_CAPACITY_CHANGED (CSA Handler)
local function InventoryBankCapacityHook(previousCapacity, currentCapacity, previousUpgrade, currentUpgrade)
    if previousCapacity > 0 and previousCapacity ~= currentCapacity and previousUpgrade ~= currentUpgrade then
        if ChatAnnouncements.SV.Notify.StorageBagCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
            messageParams:SetText(GetString(SI_INVENTORY_BANK_UPGRADE_ANOUNCEMENT_TITLE), zo_strformat(SI_INVENTORY_BANK_UPGRADE_ANOUNCEMENT_DESCRIPTION, previousCapacity, currentCapacity))
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_BANK_CAPACITY_CHANGED)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end
    end
    return true
end

local CHAMPION_UNLOCKED_LIFESPAN_MS = 12000
-- EVENT_CHAMPION_LEVEL_ACHIEVED (CSA Handler)
local function ChampionLevelAchievedHook(wasChampionSystemUnlocked)
    local icon = ZO_GetChampionPointsIcon()

    if ChatAnnouncements.SV.XP.ExperienceLevelUpCA then
        local formattedIcon = ChatAnnouncements.SV.XP.ExperienceLevelUpIcon and zo_strformat("<<1>> ", zo_iconFormatInheritColor(icon, 16, 16)) or ""
        local formattedString = ChatAnnouncements.Colors.ExperienceLevelUpColorize:Colorize(zo_strformat(GetString(SI_CHAMPION_ANNOUNCEMENT_UNLOCKED), formattedIcon))
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
        {
            message = formattedString,
            messageType = "EXPERIENCE_LEVEL"
        }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end

    if ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.CHAMPION_POINT_GAINED)
        local formattedIcon = zo_strformat("<<1>> ", zo_iconFormat(icon, "100%", "100%"))
        messageParams:SetText(zo_strformat(SI_CHAMPION_ANNOUNCEMENT_UNLOCKED, formattedIcon))
        if not LUIE.SV.HideXPBar then
            if wasChampionSystemUnlocked then
                local championPoints = GetPlayerChampionPointsEarned()
                local currentChampionXP = GetPlayerChampionXP()
                if not LUIE.SV.HideXPBar then
                    local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(PPB_CP, championPoints, currentChampionXP, currentChampionXP)
                    barParams:SetTriggeringEvent(EVENT_CHAMPION_LEVEL_ACHIEVED)
                    barParams:SetShowNoGain(true)
                    ValidateProgressBarParams(barParams)
                    messageParams:SetBarParams(barParams)
                end
            else
                local totalChampionPoints = GetPlayerChampionPointsEarned()
                local championXPGained = 0
                for i = 0, (totalChampionPoints - 1) do
                    championXPGained = championXPGained + GetNumChampionXPInChampionPoint(i)
                end
                if not LUIE.SV.HideXPBar then
                    local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(PPB_CP, 0, 0, championXPGained)
                    barParams:SetTriggeringEvent(EVENT_CHAMPION_LEVEL_ACHIEVED)
                    ValidateProgressBarParams(barParams)
                    messageParams:SetBarParams(barParams)
                end
                messageParams:SetLifespanMS(CHAMPION_UNLOCKED_LIFESPAN_MS)
            end
        end
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_CHAMPION_LEVEL_ACHIEVED)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end

    if ChatAnnouncements.SV.XP.ExperienceLevelUpAlert then
        local formattedIcon = ChatAnnouncements.SV.XP.ExperienceLevelUpIcon and zo_strformat("<<1>> ", zo_iconFormat(icon, "75%", "75%")) or ""
        local text = zo_strformat(GetString(SI_CHAMPION_ANNOUNCEMENT_UNLOCKED), formattedIcon)
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
    end

    if not ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
        PlaySound(SOUNDS.CHAMPION_POINT_GAINED)
    end

    return true
end

local savedEndingPoints = 0 -- We reset this value after the throttled function sends info to the chat printer
local savedPointDelta = 0   -- We reset this value after the throttled function sends info to the chat printer

local function ChampionPointGainedPrinter()
    -- adding one so that we are starting from the first gained point instead of the starting champion points
    local startingPoints = savedEndingPoints - savedPointDelta + 1
    local championPointsByType =
    {
        [CHAMPION_DISCIPLINE_TYPE_WORLD] = 0,
        [CHAMPION_DISCIPLINE_TYPE_COMBAT] = 0,
        [CHAMPION_DISCIPLINE_TYPE_CONDITIONING] = 0,
    }

    while startingPoints <= savedEndingPoints do
        local pointType = GetChampionPointPoolForRank(startingPoints)
        championPointsByType[pointType] = championPointsByType[pointType] + 1
        startingPoints = startingPoints + 1
    end

    if ChatAnnouncements.SV.XP.ExperienceLevelUpCA then
        local formattedString = ChatAnnouncements.Colors.ExperienceLevelUpColorize:Colorize(zo_strformat(SI_CHAMPION_POINT_EARNED, savedPointDelta) .. ": ")
        eventManager:UnregisterForUpdate(moduleName .. "Printer")
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
        {
            message = formattedString,
            messageType = "EXPERIENCE_LEVEL"
        }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 25, ChatAnnouncements.PrintQueuedMessages)
    end

    local secondLine = ""
    if ChatAnnouncements.SV.XP.ExperienceLevelUpCA or ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
        for pointType, amount in pairs(championPointsByType) do
            if amount > 0 then
                local disciplineData = CHAMPION_DATA_MANAGER:FindChampionDisciplineDataByType(pointType)
                if disciplineData == nil then
                    return
                end
                local icon = disciplineData:GetHUDIcon()
                local formattedIcon = ChatAnnouncements.SV.XP.ExperienceLevelUpIcon and zo_strformat(" <<1>>", zo_iconFormat(icon, 16, 16)) or ""
                local disciplineName = disciplineData:GetRawName()

                local formattedString
                if ChatAnnouncements.SV.XP.ExperienceLevelColorByLevel then
                    formattedString = ZO_CP_BAR_GRADIENT_COLORS[pointType][2]:Colorize(zo_strformat(LUIE_STRING_CHAMPION_POINT_TYPE, amount, formattedIcon, disciplineName))
                else
                    formattedString = ChatAnnouncements.Colors.ExperienceLevelUpColorize:Colorize(zo_strformat(LUIE_STRING_CHAMPION_POINT_TYPE, amount, formattedIcon, disciplineName))
                end
                if ChatAnnouncements.SV.XP.ExperienceLevelUpCA then
                    eventManager:UnregisterForUpdate(moduleName .. "Printer")
                    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
                    {
                        message = formattedString,
                        messageType = "EXPERIENCE_LEVEL"
                    }
                    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                    eventManager:RegisterForUpdate(moduleName .. "Printer", 25, ChatAnnouncements.PrintQueuedMessages)
                end
                if ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
                    secondLine = secondLine .. zo_strformat(SI_CHAMPION_POINT_TYPE, amount, icon, disciplineName) .. "\n"
                end
            end
        end
    end

    if ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.CHAMPION_POINT_GAINED)
        messageParams:SetText(zo_strformat(SI_CHAMPION_POINT_EARNED, savedPointDelta), secondLine)
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_CHAMPION_POINT_GAINED)
        messageParams:MarkSuppressIconFrame()
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end

    if ChatAnnouncements.SV.XP.ExperienceLevelUpAlert then
        local text = zo_strformat("<<1>>!", GetString(SI_CHAMPION_POINT_EARNED, savedPointDelta))
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
    end

    if not ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
        PlaySound(SOUNDS.CHAMPION_POINT_GAINED)
    end

    savedEndingPoints = 0
    savedPointDelta = 0

    eventManager:UnregisterForUpdate(moduleName .. "ChampionPointThrottle")
end

-- EVENT_CHAMPION_POINT_GAINED (CSA Handler)
local function ChampionPointGainedHook(pointDelta)
    -- Print throttled XP value
    eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
    ChatAnnouncements.PrintBufferedXP()

    savedEndingPoints = GetPlayerChampionPointsEarned()
    savedPointDelta = savedPointDelta + pointDelta

    eventManager:UnregisterForUpdate(moduleName .. "ChampionPointThrottle")
    eventManager:RegisterForUpdate(moduleName .. "ChampionPointThrottle", 25, ChampionPointGainedPrinter)

    return true
end

-- Local variables and functions for DuelNearBoundaryHook()
local DUEL_BOUNDARY_WARNING_LIFESPAN_MS = 2000
local DUEL_BOUNDARY_WARNING_UPDATE_TIME_MS = 2100
local lastEventTime = 0
local function CheckBoundary()
    if IsNearDuelBoundary() then
        -- Display CA
        if ChatAnnouncements.SV.Social.DuelBoundaryCA then
            printToChat(GetString(LUIE_STRING_CA_DUEL_NEAR_BOUNDARY_CSA), true)
        end

        -- Display CSA
        if ChatAnnouncements.SV.Social.DuelBoundaryCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.DUEL_BOUNDARY_WARNING)
            messageParams:SetText(GetString(LUIE_STRING_CA_DUEL_NEAR_BOUNDARY_CSA))
            messageParams:SetLifespanMS(DUEL_BOUNDARY_WARNING_LIFESPAN_MS)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DUEL_NEAR_BOUNDARY)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        -- Display Alert
        if ChatAnnouncements.SV.Social.DuelBoundaryAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, (GetString(LUIE_STRING_CA_DUEL_NEAR_BOUNDARY_CSA)))
        end

        -- Play Sound if CSA if off
        if not ChatAnnouncements.SV.Social.DuelBoundaryCSA then
            PlaySound(SOUNDS.DUEL_BOUNDARY_WARNING)
        end
    end
end

-- EVENT_DUEL_NEAR_BOUNDARY (CSA Handler)
local function DuelNearBoundaryHook(isInWarningArea)
    if isInWarningArea then
        local nowEventTime = GetFrameTimeMilliseconds()
        eventManager:RegisterForUpdate("EVENT_DUEL_NEAR_BOUNDARY_LUIE", DUEL_BOUNDARY_WARNING_UPDATE_TIME_MS, CheckBoundary)
        if nowEventTime > lastEventTime + DUEL_BOUNDARY_WARNING_UPDATE_TIME_MS then
            lastEventTime = nowEventTime
            CheckBoundary()
        end
    else
        eventManager:UnregisterForUpdate("EVENT_DUEL_NEAR_BOUNDARY_LUIE")
    end
    return true
end

-- EVENT_DUEL_FINISHED (CSA HANDLER)
local function DuelFinishedHook(result, wasLocalPlayersResult, opponentCharacterName, opponentDisplayName)
    -- Setup result format, name, and result sound
    local resultString = wasLocalPlayersResult and GetString("LUIE_STRING_CA_DUEL_SELF_RESULT", result) or GetString("LUIE_STRING_CA_DUEL_RESULT", result)

    local localPlayerWonDuel = (result == DUEL_RESULT_WON and wasLocalPlayersResult) or (result == DUEL_RESULT_FORFEIT and not wasLocalPlayersResult)
    local localPlayerForfeitDuel = (result == DUEL_RESULT_FORFEIT and wasLocalPlayersResult)
    local resultSound
    if localPlayerWonDuel then
        resultSound = SOUNDS.DUEL_WON
    elseif localPlayerForfeitDuel then
        resultSound = SOUNDS.DUEL_FORFEIT
    end

    -- Display CA
    if ChatAnnouncements.SV.Social.DuelWonCA then
        local finalName = ChatAnnouncements.ResolveNameLink(opponentCharacterName, opponentDisplayName)
        local resultChatString
        if wasLocalPlayersResult then
            resultChatString = resultString
        else
            resultChatString = zo_strformat(resultString, finalName)
        end
        printToChat(resultChatString, true)
    end

    if ChatAnnouncements.SV.Social.DuelWonCSA or ChatAnnouncements.SV.Social.DuelWonAlert then
        -- Setup String for CSA/Alert
        local finalAlertName = ChatAnnouncements.ResolveNameNoLink(opponentCharacterName, opponentDisplayName)
        local resultCSAString
        if wasLocalPlayersResult then
            resultCSAString = resultString
        else
            resultCSAString = zo_strformat(resultString, finalAlertName)
        end

        -- Display CSA
        if ChatAnnouncements.SV.Social.DuelWonCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, resultSound)
            messageParams:SetText(resultCSAString)
            messageParams:MarkShowImmediately()
            messageParams:MarkQueueImmediately()
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DUEL_FINISHED)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        -- Display Alert
        if ChatAnnouncements.SV.Social.DuelWonAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, resultCSAString)
        end
    end

    -- Play sound if CSA is not enabled
    if not ChatAnnouncements.SV.Social.DuelWonCSA then
        PlaySound(resultSound)
    end
    return true
end

-- EVENT_DUEL_COUNTDOWN (CSA Handler)
local function DuelCountdownHook(startTimeMS)
    -- Display CSA
    if ChatAnnouncements.SV.Social.DuelStartCSA then
        local displayTime = startTimeMS - GetFrameTimeMilliseconds()
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_COUNTDOWN_TEXT, SOUNDS.DUEL_START)
        messageParams:SetLifespanMS(displayTime)
        messageParams:SetIconData("EsoUI/Art/HUD/HUD_Countdown_Badge_Dueling.dds")
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end
    return true
end

-- EVENT_RAID_TRIAL_STARTED (CSA Handler)
local function RaidStartedHook(raidName, isWeekly)
    -- Display CA
    if ChatAnnouncements.SV.Group.GroupRaidCA then
        local formattedName = zo_strformat("|cFFFFFF<<1>>|r", raidName)
        printToChat(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_STARTED, formattedName), true)
    end

    -- Display CSA
    if ChatAnnouncements.SV.Group.GroupRaidCSA then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.RAID_TRIAL_STARTED)
        messageParams:SetText(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_STARTED, raidName))
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RAID_TRIAL)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end

    -- Display Alert
    if ChatAnnouncements.SV.Group.GroupRaidAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_STARTED, raidName))
    end

    -- Play sound if CSA is not enabled
    if not ChatAnnouncements.SV.Group.GroupRaidCSA then
        PlaySound(SOUNDS.RAID_TRIAL_STARTED)
    end
    return true
end

local TRIAL_COMPLETE_LIFESPAN_MS = 10000
-- EVENT_RAID_TRIAL_COMPLETE (CSA Handler)
local function RaidCompleteHook(raidName, score, totalTime)
    local wasUnderTargetTime = GetRaidDuration() <= GetRaidTargetTime()
    local formattedTime = ZO_FormatTimeMilliseconds(totalTime, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS)
    local vitalityBonus = GetCurrentRaidLifeScoreBonus()
    local vitalityBonusString = tostring(vitalityBonus)
    local currentCount = GetRaidReviveCountersRemaining()
    local maxCount = GetCurrentRaidStartingReviveCounters()

    -- Display CA
    if ChatAnnouncements.SV.Group.GroupRaidCA then
        local formattedName = zo_strformat("|cFFFFFF<<1>>|r", raidName)
        local vitalityCounterString = zo_strformat("<<1>> <<2>>/<<3>>", zo_iconFormatInheritColor("esoui/art/trials/vitalitydepletion.dds", 16, 16), currentCount, maxCount)
        local finalScore = ZO_DEFAULT_ENABLED_COLOR:Colorize(score)
        vitalityBonusString = ZO_DEFAULT_ENABLED_COLOR:Colorize(vitalityBonusString)
        if currentCount == 0 then
            vitalityCounterString = ZO_DISABLED_TEXT:Colorize(vitalityCounterString)
        else
            vitalityCounterString = ZO_DEFAULT_ENABLED_COLOR:Colorize(vitalityCounterString)
        end
        if wasUnderTargetTime then
            formattedTime = ZO_DEFAULT_ENABLED_COLOR:Colorize(formattedTime)
        else
            formattedTime = ZO_ERROR_COLOR:Colorize(formattedTime)
        end

        printToChat(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_COMPLETED_LARGE, formattedName), true)
        printToChat(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_SCORETALLY, finalScore, formattedTime, vitalityBonusString, vitalityCounterString), true)
    end

    -- Display CSA
    if ChatAnnouncements.SV.Group.GroupRaidCSA then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_RAID_COMPLETE_TEXT, SOUNDS.RAID_TRIAL_COMPLETED)
        messageParams:SetEndOfRaidData(
            {
                score,
                formattedTime,
                wasUnderTargetTime,
                vitalityBonus,
                zo_strformat(SI_REVIVE_COUNTER_REVIVES_USED, currentCount, maxCount),
            })
        messageParams:SetText(zo_strformat(SI_TRIAL_COMPLETED_LARGE, raidName))
        messageParams:SetLifespanMS(TRIAL_COMPLETE_LIFESPAN_MS)
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RAID_TRIAL)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end

    -- Display Alert
    if ChatAnnouncements.SV.Group.GroupRaidAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(SI_TRIAL_COMPLETED_LARGE, raidName))
    end

    -- Play sound if CSA is not enabled
    if not ChatAnnouncements.SV.Group.GroupRaidCSA then
        PlaySound(SOUNDS.RAID_TRIAL_COMPLETED)
    end
    return true
end

-- EVENT_RAID_TRIAL_FAILED (CSA Handler)
local function RaidFailedHook(raidName, score)
    -- Display CA
    if ChatAnnouncements.SV.Group.GroupRaidCA then
        local formattedName = zo_strformat("|cFFFFFF<<1>>|r", raidName)
        printToChat(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_FAILED, formattedName), true)
    end

    -- Display CSA
    if ChatAnnouncements.SV.Group.GroupRaidCSA then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.RAID_TRIAL_FAILED)
        messageParams:SetText(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_FAILED, raidName))
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RAID_TRIAL)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end

    -- Display Alert
    if ChatAnnouncements.SV.Group.GroupRaidAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_FAILED, raidName))
    end

    -- Play sound if CSA is not enabled
    if not ChatAnnouncements.SV.Group.GroupRaidCSA then
        PlaySound(SOUNDS.RAID_TRIAL_FAILED)
    end
    return true
end

-- EVENT_RAID_TRIAL_NEW_BEST_SCORE (CSA Handler)
local function RaidBestScoreHook(raidName, score, isWeekly)
    -- Display CA
    if ChatAnnouncements.SV.Group.GroupRaidBestScoreCA then
        local formattedName = zo_strformat("|cFFFFFF<<1>>|r", raidName)
        local formattedString = isWeekly and zo_strformat(SI_TRIAL_NEW_BEST_SCORE_WEEKLY, formattedName) or zo_strformat(SI_TRIAL_NEW_BEST_SCORE_LIFETIME, formattedName)
        printToChat(formattedString, true)
    end

    -- Display CSA
    if ChatAnnouncements.SV.Group.GroupRaidBestScoreCSA then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.RAID_TRIAL_NEW_BEST)
        messageParams:SetText(zo_strformat(isWeekly and SI_TRIAL_NEW_BEST_SCORE_WEEKLY or SI_TRIAL_NEW_BEST_SCORE_LIFETIME, raidName))
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RAID_TRIAL)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end

    -- Display Alert
    if ChatAnnouncements.SV.Group.GroupRaidBestScoreAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(isWeekly and SI_TRIAL_NEW_BEST_SCORE_WEEKLY or SI_TRIAL_NEW_BEST_SCORE_LIFETIME, raidName))
    end

    -- Play sound ONLY if normal score is not set to display, otherwise the audio will overlap
    if not ChatAnnouncements.SV.Group.GroupRaidBestScoreCSA and not (ChatAnnouncements.SV.Group.GroupRaidScoreCA and ChatAnnouncements.SV.Group.GroupRaidScoreCSA and ChatAnnouncements.SV.Group.GroupRaidScoreAlert) then
        PlaySound(SOUNDS.RAID_TRIAL_NEW_BEST)
    end
    return true
end

-- EVENT_RAID_REVIVE_COUNTER_UPDATE (CSA Handler)
local function RaidReviveCounterHook(currentCount, countDelta)
    if not IsRaidInProgress() then
        return
    end
    if countDelta < 0 then
        if ChatAnnouncements.SV.Group.GroupRaidReviveCA then
            local iconCA = zo_iconFormat("EsoUI/Art/Trials/VitalityDepletion.dds", 16, 16)
            printToChat(zo_strformat(LUIE_STRING_CA_GROUP_REVIVE_COUNTER_UPDATED, iconCA))
        end

        if ChatAnnouncements.SV.Group.GroupRaidReviveCSA then
            local iconCSA = zo_iconFormat("EsoUI/Art/Trials/VitalityDepletion.dds", "100%", "100%")
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.RAID_TRIAL_COUNTER_UPDATE)
            messageParams:SetText(zo_strformat(LUIE_STRING_CA_GROUP_REVIVE_COUNTER_UPDATED, iconCSA))
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RAID_TRIAL)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.Group.GroupRaidReviveAlert then
            local iconAlert = zo_iconFormat("EsoUI/Art/Trials/VitalityDepletion.dds", "75%", "75%")
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(LUIE_STRING_CA_GROUP_REVIVE_COUNTER_UPDATED, iconAlert))
        end

        -- Play Sound if CSA is not enabled
        if not ChatAnnouncements.SV.Group.GroupRaidReviveCSA then
            PlaySound(SOUNDS.RAID_TRIAL_COUNTER_UPDATE)
        end
    end
    return true
end

local TRIAL_SCORE_REASON_TO_ASSETS =
{
    [RAID_POINT_REASON_KILL_MINIBOSS] =
    {
        icon = "EsoUI/Art/Trials/trialPoints_normal.dds",
        soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_NORMAL,
    },
    [RAID_POINT_REASON_KILL_BOSS] =
    {
        icon = "EsoUI/Art/Trials/trialPoints_veryHigh.dds",
        soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_VERY_HIGH,
    },

    [RAID_POINT_REASON_BONUS_ACTIVITY_LOW] =
    {
        icon = "EsoUI/Art/Trials/trialPoints_veryLow.dds",
        soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_VERY_LOW,
    },
    [RAID_POINT_REASON_BONUS_ACTIVITY_MEDIUM] =
    {
        icon = "EsoUI/Art/Trials/trialPoints_low.dds",
        soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_LOW,
    },
    [RAID_POINT_REASON_BONUS_ACTIVITY_HIGH] =
    {
        icon = "EsoUI/Art/Trials/trialPoints_high.dds",
        soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_HIGH,
    },

    [RAID_POINT_REASON_SOLO_ARENA_PICKUP_ONE] =
    {
        icon = "EsoUI/Art/Trials/trialPoints_veryLow.dds",
        soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_VERY_LOW,
    },
    [RAID_POINT_REASON_SOLO_ARENA_PICKUP_TWO] =
    {
        icon = "EsoUI/Art/Trials/trialPoints_low.dds",
        soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_LOW,
    },
    [RAID_POINT_REASON_SOLO_ARENA_PICKUP_THREE] =
    {
        icon = "EsoUI/Art/Trials/trialPoints_normal.dds",
        soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_NORMAL,
    },
    [RAID_POINT_REASON_SOLO_ARENA_PICKUP_FOUR] =
    {
        icon = "EsoUI/Art/Trials/trialPoints_high.dds",
        soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_HIGH,
    },
    [RAID_POINT_REASON_SOLO_ARENA_COMPLETE] =
    {
        icon = "EsoUI/Art/Trials/trialPoints_veryHigh.dds",
        soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_VERY_HIGH,
    },
}

-- EVENT_RAID_TRIAL_SCORE_UPDATE (CSA Handler)
local function RaidScoreUpdateHook(scoreUpdateReason, scoreAmount, totalScore)
    local reasonAssets = TRIAL_SCORE_REASON_TO_ASSETS[scoreUpdateReason]
    if reasonAssets then
        -- Display CA
        if ChatAnnouncements.SV.Group.GroupRaidScoreCA then
            local iconCA = zo_iconFormat(reasonAssets.icon, 16, 16)
            printToChat(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_SCORE_UPDATED, iconCA, scoreAmount))
        end

        -- Display CSA
        if ChatAnnouncements.SV.Group.GroupRaidScoreCSA then
            local iconCSA = zo_iconFormat(reasonAssets.icon, "100%", "100%")
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, reasonAssets.soundId)
            messageParams:SetText(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_SCORE_UPDATED, iconCSA, scoreAmount))
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RAID_TRIAL)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        -- Display Alert
        if ChatAnnouncements.SV.Group.GroupRaidScoreAlert then
            local iconAlert = zo_iconFormat(reasonAssets.icon, "75%", "75%")
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_SCORE_UPDATED, iconAlert, scoreAmount))
        end

        -- Play Sound if CSA is not enabled
        if not ChatAnnouncements.SV.Group.GroupRaidScoreCSA then
            PlaySound(reasonAssets.soundId)
        end
    end
    return true
end

-- EVENT_ACTIVITY_FINDER_ACTIVITY_COMPLETE (CSA Handler)
local function ActivityFinderCompleteHook()
    local message = GetString(SI_ACTIVITY_FINDER_ACTIVITY_COMPLETE_ANNOUNCEMENT_TEXT)
    if ChatAnnouncements.SV.Group.GroupLFGCompleteCA then
        printToChat(message, true)
    end

    if ChatAnnouncements.SV.Group.GroupLFGCompleteCSA then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.LFG_COMPLETE_ANNOUNCEMENT)
        messageParams:SetText(message)
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ACTIVITY_COMPLETE)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end

    if ChatAnnouncements.SV.Group.GroupLFGCompleteAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, message)
    end

    if not ChatAnnouncements.SV.Group.GroupLFGCompleteCSA then
        PlaySound(SOUNDS.LFG_COMPLETE_ANNOUNCEMENT)
    end

    return true
end

local g_previousEndlessDungeonProgression = { 0, 0, 0 } -- Stage, Cycle, Arc

local function GetEndlessDungeonProgressMessageParams()
    local stage, cycle, arc = ENDLESS_DUNGEON_MANAGER:GetProgression()
    local previousStage, previousCycle, previousArc = unpack(g_previousEndlessDungeonProgression)
    if stage == 1 and cycle == 1 and arc == 1 then
        -- Force the initial CSA to roll over from all 0s to all 1s.
        previousStage, previousCycle, previousArc = 0, 0, 0
    end

    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_ROLLING_METER_PROGRESS_TEXT, SOUNDS.NONE)
    local stageIcon, cycleIcon, arcIcon = ZO_EndlessDungeonManager.GetProgressionIcons()
    local stageNarration, cycleNarration, arcNarration = ZO_EndlessDungeonManager.GetProgressionNarrationDescriptions(stage, cycle, arc)
    local progressData =
    {
        {
            iconTexture = arcIcon,
            narrationDescription = arcNarration,
            initialValue = previousArc,
            finalValue = arc,
        },
        {
            iconTexture = cycleIcon,
            narrationDescription = cycleNarration,
            initialValue = previousCycle,
            finalValue = cycle,
        },
        {
            iconTexture = stageIcon,
            narrationDescription = stageNarration,
            initialValue = previousStage,
            finalValue = stage,
        },
    }
    messageParams:SetRollingMeterProgressData(progressData)

    -- Update the previous progression values.
    g_previousEndlessDungeonProgression[1] = stage
    g_previousEndlessDungeonProgression[2] = cycle
    g_previousEndlessDungeonProgression[3] = arc

    return messageParams
end

local function RefreshEndlessDungeonProgressionState()
    local stage, cycle, arc = ENDLESS_DUNGEON_MANAGER:GetProgression()
    g_previousEndlessDungeonProgression[1] = stage
    g_previousEndlessDungeonProgression[2] = cycle
    g_previousEndlessDungeonProgression[3] = arc
end

ENDLESS_DUNGEON_MANAGER:RegisterCallback("StateChanged", RefreshEndlessDungeonProgressionState)

local function UpdateEndlessDungeonTrackers()
    ENDLESS_DUNGEON_HUD_TRACKER:UpdateProgress()
    ENDLESS_DUNGEON_BUFF_TRACKER_GAMEPAD:UpdateProgress()
    if ENDLESS_DUNGEON_BUFF_TRACKER_KEYBOARD then
        ENDLESS_DUNGEON_BUFF_TRACKER_KEYBOARD:UpdateProgress()
    end
end

local ZoneIds =
{
    [1413] = "Endless Archive", -- Dungeon - Endless Archive
    [1436] = "Endless Archive", -- Dungeon - Endless Archive
    [888] = "Craglorn",         -- Zone - Craglorn
    [584] = "Imperial City",    -- Imperial City (Overland)
    [643] = "Imperial City",    -- Imperial City (Sewers)
    [635] = "Dragonstar Arena", -- Dragonstar Arena
}

local MapIds =
{
    [988] = "Maelstrom Arena", -- Vale of the Surreal (Maelstrom Arena - Stage 1)
    [963] = "Maelstrom Arena", -- Seht's Balcony (Maelstrom Arena - Stage 2)
    [2567] = "Endless Archive",
    -- TODO - Need MapIds for Stage 3-9
}

local function ResolveDisplayAnnouncementMessages(messageType)
    local settings
    if messageType == "Imperial City" then
        settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.ZoneIC
    elseif messageType == "Craglorn" then
        settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.ZoneCraglorn
    elseif messageType == "Maelstrom Arena" then
        settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.ArenaMaelstrom
    elseif messageType == "Dragonstar Arena" then
        settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.ArenaDragonstar
    elseif messageType == "Endless Archive" then
        settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.DungeonEndlessArchive
    end
    return settings
end

-- EVENT_DISPLAY_ANNOUNCEMENT (CSA Handler)
local function DisplayAnnouncementHook(primaryText, secondaryText, icon, soundId, lifespanMS, category)
    -- Disable Respec Display Announcement since we handle this from loot announcements (using Respec scroll)
    if primaryText == GetString(SI_RESPECTYPE_POINTSRESETTITLE1) then
        return true
    end

    -- Setup CSA with default function (don't display CSA here yet, we filter to check)
    soundId = soundId == "" and SOUNDS.DISPLAY_ANNOUNCEMENT or soundId

    local messageParams
    if category == CSA_CATEGORY_ENDLESS_DUNGEON_STAGE_STARTED_TEXT then
        -- Endless Dungeon Progression CSA special case
        messageParams = GetEndlessDungeonProgressMessageParams()
        if not messageParams then
            -- The progression did not change; this should never happen.
            return
        end
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ENDLESS_DUNGEON_PROGRESS)
        messageParams:SetOnDisplayCallback(UpdateEndlessDungeonTrackers)
    else
        -- Standard Display Announcement
        messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(category, soundId)
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
    end

    if soundId then
        messageParams:SetSound(soundId)
    end

    if icon ~= ZO_NO_TEXTURE_FILE then
        messageParams:SetIconData(icon)
    end

    if lifespanMS > 0 then
        messageParams:SetLifespanMS(lifespanMS)
    end

    -- Sanitize text.
    if primaryText == "" then
        primaryText = nil
    end
    if secondaryText == "" then
        secondaryText = nil
    end

    -- No message so return
    if primaryText == nil and secondaryText == nil then
        return
    end

    -- Check zoneId or mapId if needed
    local zoneId = GetZoneId(GetCurrentMapZoneIndex())
    local mapId = GetCurrentMapId() -- Some areas don't have proper zoneIds (Maelstrom Arena)
    local messageType
    if ZoneIds[zoneId] then
        messageType = ZoneIds[zoneId]
    elseif MapIds[mapId] then
        messageType = MapIds[mapId]
    end

    local settings     -- local variable for pulling SV
    local debugDisable -- flag to disable debug when its enabled

    -- Settings either use the subcategory settings or the generic settings if no subcategory
    if primaryText == GetString(SI_RESPECTYPE_POINTSRESETTITLE0) or primaryText == GetString(SI_RESPECTYPE_POINTSRESETTITLE1) then
        settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.Respec
        debugDisable = true
        -- Update message syntax here
        if primaryText == GetString(SI_RESPECTYPE_POINTSRESETTITLE0) then
            primaryText = GetString(LUIE_STRING_CA_CURRENCY_NOTIFY_SKILLS)
        end
        if primaryText == GetString(SI_RESPECTYPE_POINTSRESETTITLE1) then
            primaryText = GetString(LUIE_STRING_CA_CURRENCY_NOTIFY_ATTRIBUTES)
        end
    elseif primaryText == GetString(LUIE_STRING_CA_DISPLAY_ANNOUNCEMENT_GROUPENTER_D) or primaryText == GetString(LUIE_STRING_CA_DISPLAY_ANNOUNCEMENT_GROUPLEAVE_D) then
        settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.GroupArea
        debugDisable = true
        -- Update message syntax here
        if primaryText == GetString(LUIE_STRING_CA_DISPLAY_ANNOUNCEMENT_GROUPENTER_D) then
            primaryText = GetString(LUIE_STRING_CA_DISPLAY_ANNOUNCEMENT_GROUPENTER_C)
        end
        if primaryText == GetString(LUIE_STRING_CA_DISPLAY_ANNOUNCEMENT_GROUPLEAVE_D) then
            primaryText = GetString(LUIE_STRING_CA_DISPLAY_ANNOUNCEMENT_GROUPLEAVE_C)
        end
    elseif messageType then
        settings = ResolveDisplayAnnouncementMessages(messageType)
        debugDisable = true
    else
        settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.General
    end

    -- Debug function
    if ChatAnnouncements.SV.DisplayAnnouncements.Debug and not debugDisable then
        CHAT_ROUTER:AddSystemMessage("EVENT_DISPLAY_ANNOUNCEMENT: If you see this message please post a screenshot and context for the event on the LUI Extended ESOUI page.")
        if primaryText then
            CHAT_ROUTER:AddSystemMessage("Primary Text: " .. primaryText)
        end
        if secondaryText then
            CHAT_ROUTER:AddSystemMessage("Secondary Text: " .. secondaryText)
        end
        local zoneid = GetZoneId(GetCurrentMapZoneIndex())
        CHAT_ROUTER:AddSystemMessage("Zone Id: " .. zoneid)
        local mapid = GetCurrentMapId()
        CHAT_ROUTER:AddSystemMessage("Map Id: " .. mapid)
    end

    -- Display CA if enabled
    if settings.CA then
        -- Some formatting may be needed for CA:
        local caPrimary = primaryText
        local caSecondary = secondaryText
        local language = GetCVar("language.2")
        -- Extra formatting in Imperial City: Remove "Entered: " and format it and add it back on and color the message.
        -- Note we don't want to mess with strings outside of EN localization for now (TODO)
        -- Custom formatting for IC messages
        if settings == LUIE.ChatAnnouncements.SV.DisplayAnnouncements.ZoneIC and language == "en" then
            local prefix = GetString(LUIE_STRING_CA_DISPLAY_ANNOUNCEMENT_IC_TITLE_PREFIX)
            caPrimary = StringOnlyGSUB(primaryText, prefix, "")
            caPrimary = settings.Description and string.format("%s|c%s%s: |r", prefix, ChatAnnouncements.Colors.QuestColorLocNameColorize, caPrimary) or string.format("%s|c%s%s|r", prefix, ChatAnnouncements.Colors.QuestColorLocNameColorize, caPrimary)
            caSecondary = settings.Description and string.format("|c%s%s|r", ChatAnnouncements.Colors.QuestColorLocDescriptionColorize, caSecondary) or ""
            printToChat(caPrimary .. caSecondary)
            -- Add an "!" to the CA for Craglorn buffs
        elseif settings == LUIE.ChatAnnouncements.SV.DisplayAnnouncements.ZoneCraglorn and language == "en" then
            caPrimary = primaryText .. "!"
            printToChat(caPrimary)
            -- Add an "!" to the Maelstrom Arena Round CA messages (VMA messages have two lines other then the rounds)
        elseif settings == LUIE.ChatAnnouncements.SV.DisplayAnnouncements.ArenaMaelstrom and secondaryText == nil then
            caPrimary = primaryText .. "!"
            printToChat(caPrimary)
        else
            if primaryText and secondaryText then
                printToChat(caPrimary .. ": " .. caSecondary)
            elseif primaryText then
                printToChat(caPrimary)
            elseif secondaryText then
                printToChat(caSecondary)
            end
        end
    end

    -- Display CSA if enabled
    if settings.CSA then
        messageParams:SetText(primaryText, secondaryText)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end

    -- Display Alert if enabled
    if settings.Alert then
        if primaryText and secondaryText then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, (primaryText .. ": " .. secondaryText))
        elseif primaryText then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, primaryText)
        elseif secondaryText then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, secondaryText)
        end
    end

    -- If the CSA is disabled, play a sound if Chat Announcement or Alert are enabled
    if (settings.CA or settings.Alert) and not settings.CSA then
        if soundId then
            PlaySound(soundId)
            -- Fallback sound if no soundId
        else
            PlaySound(SOUNDS.DISPLAY_ANNOUNCEMENT)
        end
    end

    return true
end

-- EVENT_ACHIEVEMENT_AWARDED (CSA Handler)
local function AchievementAwardedHook(name, points, id)
    local topLevelIndex, categoryIndex, achievementIndex = GetCategoryInfoFromAchievementId(id)

    -- Bail out if this achievement comes from unwanted category & we don't always show CSA
    if ChatAnnouncements.SV.Achievement.AchievementCategoryIgnore[topLevelIndex] and not ChatAnnouncements.SV.Achievement.AchievementCompleteAlwaysCSA then
        return true
    end

    -- Display CSA
    if ChatAnnouncements.SV.Achievement.AchievementCompleteCSA then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.ACHIEVEMENT_AWARDED)
        local icon = GetAchievementInfoIcon(id)
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ACHIEVEMENT_AWARDED)
        messageParams:SetText(ChatAnnouncements.SV.Achievement.AchievementCompleteMsg, zo_strformat(name))
        messageParams:SetIconData(icon, "EsoUI/Art/Achievements/achievements_iconBG.dds")
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end

    -- Bail out if this achievement comes from unwanted category
    if ChatAnnouncements.SV.Achievement.AchievementCategoryIgnore[topLevelIndex] then
        return true
    end

    if ChatAnnouncements.SV.Achievement.AchievementCompleteCA then
        local link = zo_strformat(GetAchievementLink(id, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionAchievement]))
        local catName = GetAchievementCategoryInfoName(topLevelIndex)
        local subcatName = categoryIndex ~= nil and GetAchievementSubCategoryInfoName(topLevelIndex, categoryIndex) or "General"
        local icon = GetAchievementInfoIcon(id)
        icon = ChatAnnouncements.SV.Achievement.AchievementIcon and ("|t16:16:" .. icon .. "|t ") or ""

        -- Build string parts without using string.format on pre-formatted strings
        local stringpart1 = ChatAnnouncements.Colors.AchievementColorize1:Colorize(
            ChatAnnouncements.bracket1[ChatAnnouncements.SV.Achievement.AchievementBracketOptions] ..
            ChatAnnouncements.SV.Achievement.AchievementCompleteMsg ..
            ChatAnnouncements.bracket2[ChatAnnouncements.SV.Achievement.AchievementBracketOptions] .. " " ..
            icon .. link
        )

        local stringpart2 = ""
        if ChatAnnouncements.SV.Achievement.AchievementCompPercentage then
            stringpart2 = ChatAnnouncements.SV.Achievement.AchievementColorProgress and
                ChatAnnouncements.Colors.AchievementColorize2:Colorize(" (") ..
                "|c71DE73100%|r" ..
                ChatAnnouncements.Colors.AchievementColorize2:Colorize(")") or
                ChatAnnouncements.Colors.AchievementColorize2:Colorize(" (100%)")
        end

        local stringpart3 = ""
        if ChatAnnouncements.SV.Achievement.AchievementCategory then
            stringpart3 = ChatAnnouncements.Colors.AchievementColorize2:Colorize(
                " " .. ChatAnnouncements.bracket1[ChatAnnouncements.SV.Achievement.AchievementCatBracketOptions] ..
                catName ..
                (ChatAnnouncements.SV.Achievement.AchievementSubcategory and (" - " .. subcatName) or "") ..
                ChatAnnouncements.bracket2[ChatAnnouncements.SV.Achievement.AchievementCatBracketOptions]
            )
        end

        -- Concatenate final string without using string.format
        local finalString = stringpart1 .. stringpart2 .. stringpart3
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
        {
            message = finalString,
            messageType = "ACHIEVEMENT"
        }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end

    -- Display Alert
    if ChatAnnouncements.SV.Achievement.AchievementCompleteAlert then
        local alertMessage = zo_strformat("<<1>>: <<2>>", ChatAnnouncements.SV.Achievement.AchievementCompleteMsg, name)
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertMessage)
    end

    -- Play sound if CSA is disabled
    if not ChatAnnouncements.SV.Achievement.AchievementCompleteCSA then
        PlaySound(SOUNDS.ACHIEVEMENT_AWARDED)
    end

    return true
end

-- EVENT_PLEDGE_OF_MARA_RESULT (CSA Handler)
local function PledgeOfMaraHook(result, characterName, displayName)
    -- Display CA (Success or Failure)
    if ChatAnnouncements.SV.Social.PledgeOfMaraCA then
        local finalName = ChatAnnouncements.ResolveNameLink(characterName, displayName)
        printToChat(zo_strformat(GetString("LUIE_STRING_CA_MARA_PLEDGEOFMARARESULT", result), finalName), true)
    end

    if ChatAnnouncements.SV.Social.PledgeOfMaraAlert or ChatAnnouncements.SV.Social.PledgeOfMaraCSA then
        local finalAlertName = ChatAnnouncements.ResolveNameNoLink(characterName, displayName)

        -- Display CSA (Success Only)
        if ChatAnnouncements.SV.Social.PledgeOfMaraCSA then
            if result == PLEDGE_OF_MARA_RESULT_PLEDGED then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_PLEDGE_OF_MARA_RESULT)
                messageParams:SetText(GetString(SI_RITUAL_OF_MARA_COMPLETION_ANNOUNCE_LARGE), zo_strformat(LUIE_STRING_CA_MARA_PLEDGEOFMARARESULT3, finalAlertName))
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end
        end

        -- Alert (Success or Failure)
        if ChatAnnouncements.SV.Social.PledgeOfMaraAlert then
            -- If the menu setting to only display Alert on Failure state is toggled, then do not display an Alert on successful Mara Event
            if result == PLEDGE_OF_MARA_RESULT_PLEDGED and not ChatAnnouncements.SV.Social.PledgeOfMaraAlertOnlyFail then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(LUIE_STRING_CA_MARA_PLEDGEOFMARARESULT3, finalAlertName))
            elseif result ~= PLEDGE_OF_MARA_RESULT_PLEDGED and result ~= PLEDGE_OF_MARA_RESULT_BEGIN_PLEDGE then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, zo_strformat(GetString("LUIE_STRING_CA_MARA_PLEDGEOFMARARESULT", result), finalAlertName))
            end
        end
    end

    -- Play alert sound if error result
    if result ~= PLEDGE_OF_MARA_RESULT_PLEDGED and result ~= PLEDGE_OF_MARA_RESULT_BEGIN_PLEDGE then
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    end

    return true
end

-- EVENT_ANTIQUITY_LEAD_ACQUIRED (CSA Handler)
local function AntiquityLeadAcquired(antiquityId)
    -- Get antiquity data
    local antiquityData = ANTIQUITY_DATA_MANAGER:GetAntiquityData(antiquityId)
    -- Get name
    local antiquityName = antiquityData:GetName()

    if ChatAnnouncements.SV.Antiquities.AntiquityCA then
        local antiquityColor = GetAntiquityQualityColor(antiquityData:GetQuality())
        local antiquityIcon = antiquityData:GetIcon()

        local formattedName
        local antiquityLink
        local linkColor = antiquityColor:ToHex()
        if ChatAnnouncements.SV.Antiquities.AntiquityBracket == 1 then
            formattedName = antiquityName
            antiquityLink = string.format("|c%s|H0:LINK_TYPE_LUIE_ANTIQUITY:%s|h%s|h|r", linkColor, antiquityId, formattedName)
        else
            formattedName = ("[" .. antiquityName .. "]")
            antiquityLink = string.format("|c%s|H1:LINK_TYPE_LUIE_ANTIQUITY:%s|h%s|h|r", linkColor, antiquityId, formattedName)
        end

        local formattedIcon = ChatAnnouncements.SV.Antiquities.AntiquityIcon and ("|t16:16:" .. antiquityIcon .. "|t ") or ""

        local messageP1 = ChatAnnouncements.Colors.AntiquityColorize:Colorize(string.format("%s%s%s %s", ChatAnnouncements.bracket1[ChatAnnouncements.SV.Antiquities.AntiquityPrefixBracket], ChatAnnouncements.SV.Antiquities.AntiquityPrefix, ChatAnnouncements.bracket2[ChatAnnouncements.SV.Antiquities.AntiquityPrefixBracket], formattedIcon))
        local messageP2 = antiquityLink
        local messageP3 = ChatAnnouncements.Colors.AntiquityColorize:Colorize(" " .. ChatAnnouncements.SV.Antiquities.AntiquitySuffix)
        local finalMessage = zo_strformat("<<1>><<2>><<3>>", messageP1, messageP2, messageP3)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
        {
            message = finalMessage,
            messageType = "ANTIQUITY"
        }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end

    if ChatAnnouncements.SV.Antiquities.AntiquityAlert then
        local alertMessage = zo_strformat("<<1>>: <<2>> <<3>>", ChatAnnouncements.SV.Antiquities.AntiquityPrefix, antiquityName, ChatAnnouncements.SV.Antiquities.AntiquitySuffix)
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertMessage)
    end

    if ChatAnnouncements.SV.Antiquities.AntiquityCSA then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
        local secondaryText = zo_strformat(SI_ANTIQUITY_LEAD_ACQUIRED_TEXT, antiquityData:GetColorizedName())
        messageParams:SetText(GetString(SI_ANTIQUITY_LEAD_ACQUIRED_TITLE), secondaryText)
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ANTIQUITY_LEAD_ACQUIRED)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end

    return true
end

local function Hook1()
    local alertHandlers = ZO_AlertText_GetHandlers()
    ZO_PreHook(alertHandlers, EVENT_LORE_BOOK_ALREADY_KNOWN, AlreadyKnowBookHook)
    ZO_PreHook(alertHandlers, EVENT_RIDING_SKILL_IMPROVEMENT, RidingSkillImprovementAlertHook)
    ZO_PreHook(alertHandlers, EVENT_LORE_BOOK_LEARNED, LoreBookLearnedAlertHook)
    ZO_PreHook(alertHandlers, EVENT_DUEL_INVITE_RECEIVED, DuelInviteReceivedAlert)
    ZO_PreHook(alertHandlers, EVENT_DUEL_INVITE_SENT, DuelInviteSentAlert)
    ZO_PreHook(alertHandlers, EVENT_DUEL_INVITE_ACCEPTED, DuelInviteAcceptedAlert)
    ZO_PreHook(alertHandlers, EVENT_DUEL_INVITE_FAILED, DuelInviteFailedAlert)
    ZO_PreHook(alertHandlers, EVENT_DUEL_INVITE_DECLINED, DuelInviteDeclinedAlert)
    ZO_PreHook(alertHandlers, EVENT_DUEL_INVITE_CANCELED, DuelInviteCanceledAlert)
    ZO_PreHook(alertHandlers, EVENT_PLEDGE_OF_MARA_RESULT, PledgeOfMaraResultAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_INVITE_RESPONSE, GroupInviteResponseAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_INVITE_ACCEPT_RESPONSE_TIMEOUT, GroupInviteTimeoutAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_NOTIFICATION_MESSAGE, GroupNotificationMessageAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_UPDATE, GroupUpdateAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_MEMBER_LEFT, GroupMemberLeftAlert)
    ZO_PreHook(alertHandlers, EVENT_LEADER_UPDATE, LeaderUpdateAlert)
    ZO_PreHook(alertHandlers, EVENT_ACTIVITY_QUEUE_RESULT, ActivityQueueResultAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_ELECTION_FAILED, GroupElectionFailedAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_ELECTION_RESULT, GroupElectionResultAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_ELECTION_REQUESTED, GroupElectionRequestedAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUPING_TOOLS_READY_CHECK_CANCELLED, GroupReadyCheckCancelAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED, GroupDifficultyChangeAlert)

    ZO_PreHook(alertHandlers, EVENT_GROUP_MEMBER_JOINED, OnGroupMemberJoined)
end

local function Hook2()
    local alertHandlers = ZO_AlertText_GetHandlers()
    ZO_PreHook(alertHandlers, EVENT_GUILD_SELF_LEFT_GUILD, GuildSelfLeftAlert)
    ZO_PreHook(alertHandlers, EVENT_SAVE_GUILD_RANKS_RESPONSE, GuildRanksResponseAlert)
    ZO_PreHook(alertHandlers, EVENT_LOCKPICK_FAILED, LockpickFailedAlert)
    ZO_PreHook(alertHandlers, EVENT_CLIENT_INTERACT_RESULT, ClientInteractResult)
    ZO_PreHook(alertHandlers, EVENT_TRADE_INVITE_FAILED, TradeInviteFailedAlert)
    ZO_PreHook(alertHandlers, EVENT_TRADE_INVITE_CONSIDERING, TradeInviteConsideringAlert)
    ZO_PreHook(alertHandlers, EVENT_TRADE_INVITE_WAITING, TradeInviteWaitingAlert)
    ZO_PreHook(alertHandlers, EVENT_TRADE_INVITE_DECLINED, TradeInviteDeclinedAlert)
    ZO_PreHook(alertHandlers, EVENT_TRADE_INVITE_CANCELED, TradeInviteCanceledAlert)
    ZO_PreHook(alertHandlers, EVENT_TRADE_CANCELED, TradeCanceledAlert)
    ZO_PreHook(alertHandlers, EVENT_TRADE_FAILED, TradeFailedAlert)
    ZO_PreHook(alertHandlers, EVENT_TRADE_SUCCEEDED, TradeSucceededAlert)
    ZO_PreHook(alertHandlers, EVENT_DISCOVERY_EXPERIENCE, DiscoveryExperienceAlert)
    ZO_PreHook(alertHandlers, EVENT_MAIL_SEND_FAILED, MailSendFailedAlert)

    ZO_PreHook(alertHandlers, EVENT_STYLE_LEARNED, StyleLearnedHook)
    ZO_PreHook(alertHandlers, EVENT_RECIPE_LEARNED, RecipeLearnedHook)
    ZO_PreHook(alertHandlers, EVENT_MULTIPLE_RECIPES_LEARNED, MultipleRecipeLearnedHook)
end

--- ALERT & EVENT HANDLER PREHOOK FUNCTIONS!
function ChatAnnouncements.HookFunction()
    -- Part 1 of hook registration. Split into a function to resolve the lua error of having more than 60 upvalues.
    Hook1()

    -- This function isn't needed if CA isn't enabled so only load it if CA is enabled
    if ChatAnnouncements.Enabled then
        eventManager:RegisterForEvent(moduleName, EVENT_GROUP_TYPE_CHANGED, ChatAnnouncements.OnGroupTypeChanged)
    end
    eventManager:RegisterForEvent(moduleName, EVENT_GROUP_INVITE_RECEIVED, ChatAnnouncements.OnGroupInviteReceived)
    eventManager:RegisterForEvent(moduleName, EVENT_GROUP_ELECTION_NOTIFICATION_ADDED, ChatAnnouncements.VoteNotify)
    eventManager:RegisterForEvent(moduleName, EVENT_GROUPING_TOOLS_NO_LONGER_LFG, ChatAnnouncements.LFGLeft)
    eventManager:RegisterForEvent(moduleName, EVENT_GROUPING_TOOLS_LFG_JOINED, ChatAnnouncements.GroupingToolsLFGJoined)
    eventManager:RegisterForEvent(moduleName, EVENT_ACTIVITY_FINDER_STATUS_UPDATE, ChatAnnouncements.ActivityStatusUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_GROUPING_TOOLS_READY_CHECK_UPDATED, ChatAnnouncements.ReadyCheckUpdate)

    -- Part 2 of hook registration. Split into a function to resolve the lua error of having more than 60 upvalues.
    Hook2()

    local csaHandlers = ZO_CenterScreenAnnounce_GetEventHandlers()
    local csaCallbackHandlers = ZO_CenterScreenAnnounce_GetCallbackHandlers()

    -- Unregister the ZOS events for handling Quest Removal/Advanced/Added to replace with our own functions
    eventManager:UnregisterForEvent("CSA_MiscellaneousHandlers", EVENT_QUEST_REMOVED)
    eventManager:UnregisterForEvent("CSA_MiscellaneousHandlers", EVENT_QUEST_ADVANCED)
    eventManager:UnregisterForEvent("CSA_MiscellaneousHandlers", EVENT_QUEST_ADDED)
    eventManager:RegisterForEvent("CSA_MiscellaneousHandlers", EVENT_QUEST_REMOVED, OnQuestRemoved)
    eventManager:RegisterForEvent("CSA_MiscellaneousHandlers", EVENT_QUEST_ADVANCED, OnQuestAdvanced)
    eventManager:RegisterForEvent("CSA_MiscellaneousHandlers", EVENT_QUEST_ADDED, OnQuestAdded)

    ZO_PreHook(csaHandlers, EVENT_LORE_BOOK_LEARNED_SKILL_EXPERIENCE, LoreBookXPHook)
    ZO_PreHook(csaHandlers, EVENT_LORE_COLLECTION_COMPLETED, LoreCollectionHook)
    ZO_PreHook(csaHandlers, EVENT_LORE_COLLECTION_COMPLETED_SKILL_EXPERIENCE, LoreCollectionXPHook)
    ZO_PreHook(csaHandlers, EVENT_SKILL_POINTS_CHANGED, SkillPointsChangedHook)
    ZO_PreHook(csaCallbackHandlers[2], "callbackFunction", SkillLineAddedHook)
    ZO_PreHook(csaHandlers, EVENT_ABILITY_PROGRESSION_RANK_UPDATE, AbilityProgressionRankHook)
    ZO_PreHook(csaHandlers, EVENT_SKILL_RANK_UPDATE, SkillRankUpdateHook)
    ZO_PreHook(csaHandlers, EVENT_SKILL_XP_UPDATE, SkillXPUpdateHook)
    ZO_PreHook(csaCallbackHandlers[1], "callbackFunction", CollectibleUnlockedHook)
    ZO_PreHook(csaHandlers, EVENT_QUEST_ADDED, QuestAddedHook)
    ZO_PreHook(csaHandlers, EVENT_QUEST_COMPLETE, QuestCompleteHook)
    ZO_PreHook(csaHandlers, EVENT_OBJECTIVE_COMPLETED, ObjectiveCompletedHook)
    ZO_PreHook(csaHandlers, EVENT_QUEST_CONDITION_COUNTER_CHANGED, ConditionCounterHook)
    ZO_PreHook(csaHandlers, EVENT_QUEST_OPTIONAL_STEP_ADVANCED, OptionalStepHook)
    ZO_PreHook(csaHandlers, EVENT_DISCOVERY_EXPERIENCE, DiscoveryExperienceHook)
    ZO_PreHook(csaHandlers, EVENT_POI_DISCOVERED, PoiDiscoveredHook)
    ZO_PreHook(csaHandlers, EVENT_EXPERIENCE_GAIN, ExperienceGainHook)
    ZO_PreHook(csaHandlers, EVENT_ENLIGHTENED_STATE_GAINED, EnlightenGainHook)
    ZO_PreHook(csaHandlers, EVENT_ENLIGHTENED_STATE_LOST, EnlightenLostHook)
    ZO_PreHook(csaHandlers, EVENT_PLAYER_ACTIVATED, PlayerActivatedHook)
    ZO_PreHook(csaHandlers, EVENT_RIDING_SKILL_IMPROVEMENT, RidingSkillImprovementHook)
    ZO_PreHook(csaHandlers, EVENT_INVENTORY_BAG_CAPACITY_CHANGED, InventoryBagCapacityHook)
    ZO_PreHook(csaHandlers, EVENT_INVENTORY_BANK_CAPACITY_CHANGED, InventoryBankCapacityHook)
    ZO_PreHook(csaHandlers, EVENT_CHAMPION_LEVEL_ACHIEVED, ChampionLevelAchievedHook)
    ZO_PreHook(csaHandlers, EVENT_CHAMPION_POINT_GAINED, ChampionPointGainedHook)
    ZO_PreHook(csaHandlers, EVENT_DUEL_NEAR_BOUNDARY, DuelNearBoundaryHook)
    ZO_PreHook(csaHandlers, EVENT_DUEL_FINISHED, DuelFinishedHook)
    ZO_PreHook(csaHandlers, EVENT_DUEL_COUNTDOWN, DuelCountdownHook)

    eventManager:RegisterForEvent(moduleName, EVENT_DUEL_STARTED, ChatAnnouncements.DuelStarted)

    ZO_PreHook(csaHandlers, EVENT_RAID_TRIAL_STARTED, RaidStartedHook)
    ZO_PreHook(csaHandlers, EVENT_RAID_TRIAL_COMPLETE, RaidCompleteHook)
    ZO_PreHook(csaHandlers, EVENT_RAID_TRIAL_FAILED, RaidFailedHook)
    ZO_PreHook(csaHandlers, EVENT_RAID_TRIAL_NEW_BEST_SCORE, RaidBestScoreHook)
    ZO_PreHook(csaHandlers, EVENT_RAID_REVIVE_COUNTER_UPDATE, RaidReviveCounterHook)
    ZO_PreHook(csaHandlers, EVENT_RAID_TRIAL_SCORE_UPDATE, RaidScoreUpdateHook)
    ZO_PreHook(csaHandlers, EVENT_ACTIVITY_FINDER_ACTIVITY_COMPLETE, ActivityFinderCompleteHook)
    ZO_PreHook(csaHandlers, EVENT_DISPLAY_ANNOUNCEMENT, DisplayAnnouncementHook)
    ZO_PreHook(csaHandlers, EVENT_ACHIEVEMENT_AWARDED, AchievementAwardedHook)
    ZO_PreHook(csaHandlers, EVENT_PLEDGE_OF_MARA_RESULT, PledgeOfMaraHook)

    eventManager:RegisterForEvent(moduleName, EVENT_PLEDGE_OF_MARA_OFFER, ChatAnnouncements.MaraOffer)

    ZO_PreHook(csaHandlers, EVENT_ANTIQUITY_LEAD_ACQUIRED, AntiquityLeadAcquired)

    ChatAnnouncements.PlayerToPlayerHook()


    -- Required when hooking ZO_MailSend_Gamepad:IsValid()
    -- Returns whether there is any item attached.
    local function IsAnyItemAttached(bagId, slotIndex)
        for i = 1, MAIL_MAX_ATTACHED_ITEMS do
            local queuedFromBag = GetQueuedItemAttachmentInfo(i)
            if queuedFromBag ~= 0 then -- Slot is filled.
                return true
            end
        end
        return false
    end

    -- Hook Gamepad mail name function
    local orgIsMailValid = ZO_MailSend_Gamepad.IsMailValid
    --- @diagnostic disable-next-line: duplicate-set-field
    function ZO_MailSend_Gamepad:IsMailValid(...)
        orgIsMailValid(self, ...)
        local to = self.mailView:GetAddress()
        if (not to) or (to == "") then
            return false
        end

        local nameLink
        if zo_strmatch(to, "@") == "@" then
            if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
                nameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(to, nil, DISPLAY_NAME_LINK_TYPE, to)
            else
                nameLink = ZO_LinkHandler_CreateLink(to, nil, DISPLAY_NAME_LINK_TYPE, to)
            end
        else
            if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
                nameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(to, nil, CHARACTER_LINK_TYPE, to)
            else
                nameLink = ZO_LinkHandler_CreateLink(to, nil, CHARACTER_LINK_TYPE, to)
            end
        end
        ChatAnnouncements.mailTarget = ZO_SELECTED_TEXT:Colorize(nameLink)

        local subject = self.mailView:GetSubject()
        local hasSubject = subject and (subject ~= "")
        local body = self.mailView:GetBody()
        local hasBody = body and (body ~= "")
        return hasSubject or hasBody or (GetQueuedMoneyAttachment() > 0) or IsAnyItemAttached()
    end

    -- Hook MAIL_SEND.Send to get name of player we send to.
    if MAIL_SEND then
        do
            local originalSend = MAIL_SEND.Send
            --- @diagnostic disable-next-line: duplicate-set-field
            function MAIL_SEND:Send(...)
                -- if LUIE.IsDevDebugEnabled() then
                --     LUIE.Debug("MAIL_SEND:Send has been hooked!")
                -- end
                windowManager:SetFocusByName("")

                if not self.sendMoneyMode and GetQueuedCOD() == 0 then
                    if ChatAnnouncements.SV.Notify.NotificationMailSendCA then
                        printToChat(GetString(LUIE_STRING_CA_MAIL_ERROR_NO_COD_VALUE), true)
                    end
                    if ChatAnnouncements.SV.Notify.NotificationMailSendAlert then
                        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, GetString(LUIE_STRING_CA_MAIL_ERROR_NO_COD_VALUE))
                    end
                    PlaySound(SOUNDS.NEGATIVE_CLICK)
                else
                    SendMail(self.to:GetText(), self.subject:GetText(), self.body:GetText())

                    local mailTarget = self.to:GetText()
                    local nameLink
                    -- Here we look for @ character in the sent mail, if the player send to an account then we want the link to be an account name link, otherwise, it's a character name link.
                    if zo_strmatch(mailTarget, "@") == "@" then
                        if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
                            nameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(mailTarget, nil, DISPLAY_NAME_LINK_TYPE, mailTarget)
                        else
                            nameLink = ZO_LinkHandler_CreateLink(mailTarget, nil, DISPLAY_NAME_LINK_TYPE, mailTarget)
                        end
                    else
                        if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
                            nameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(mailTarget, nil, CHARACTER_LINK_TYPE, mailTarget)
                        else
                            nameLink = ZO_LinkHandler_CreateLink(mailTarget, nil, CHARACTER_LINK_TYPE, mailTarget)
                        end
                    end
                    ChatAnnouncements.mailTarget = ZO_SELECTED_TEXT:Colorize(nameLink)
                end
                originalSend(self, ...)
            end
        end
    end
    ---
    --- @param self ZO_InventoryManager
    --- @param questItem questItem
    --- @param searchType any
    --- @diagnostic disable-next-line: duplicate-set-field
    function ZO_InventoryManager:AddQuestItem(questItem, searchType)
        local inventory = self.inventories[INVENTORY_QUEST_ITEM]

        questItem.inventory = inventory
        -- store all tools and items in a subtable under the questIndex for faster access
        local questIndex = questItem.questIndex
        if not inventory.slots[questIndex] then
            inventory.slots[questIndex] = {}
        end
        questItem.slotIndex = questIndex
        table.insert(inventory.slots[questIndex], questItem)

        -- Display Item if set to display
        if ChatAnnouncements.SV.Inventory.LootQuestAdd or ChatAnnouncements.SV.Inventory.LootQuestRemove then
            DisplayQuestItem(questItem.questItemId, questItem.stackCount, questItem.iconFile, false)
        end
    end

    ---
    --- @param self ZO_InventoryManager
    --- @param questIndex integer
    --- @diagnostic disable-next-line: duplicate-set-field
    function ZO_InventoryManager:ResetQuest(questIndex)
        local inventory = self.inventories[INVENTORY_QUEST_ITEM]
        local itemTable = inventory.slots[questIndex]
        --- @cast itemTable questItem_itemTable
        if itemTable then
            -- remove all quest items from search
            for i = 1, #itemTable do
                -- Display Item if set to display
                if ChatAnnouncements.SV.Inventory.LootQuestAdd or ChatAnnouncements.SV.Inventory.LootQuestRemove then
                    local itemId = itemTable[i].questItemId
                    local stackCount = itemTable[i].stackCount
                    local icon = itemTable[i].iconFile
                    DisplayQuestItem(itemId, stackCount, icon, true)
                end
            end
        end
        inventory.slots[questIndex] = nil
    end

    -- Called by hooked TryGroupInviteByName function
    -- TODO: Maybe see about links for names here for non-menu
    local function CompleteGroupInvite(characterOrDisplayName, sentFromChat, displayInvitedMessage, isMenu)
        local isLeader = IsUnitGroupLeader("player")
        local groupSize = GetGroupSize()

        if isLeader and groupSize == SMALL_GROUP_SIZE_THRESHOLD then
            ZO_Dialogs_ShowPlatformDialog("LARGE_GROUP_INVITE_WARNING", characterOrDisplayName, { mainTextParams = { SMALL_GROUP_SIZE_THRESHOLD } })
        else
            GroupInviteByName(characterOrDisplayName)

            ZO_Menu_SetLastCommandWasFromMenu(not sentFromChat)
            if isMenu then
                local link
                if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
                    link = ZO_LinkHandler_CreateLinkWithoutBrackets(characterOrDisplayName, nil, CHARACTER_LINK_TYPE, characterOrDisplayName)
                else
                    link = ZO_LinkHandler_CreateLink(characterOrDisplayName, nil, CHARACTER_LINK_TYPE, characterOrDisplayName)
                end
                printToChat(zo_strformat(GetString(LUIE_STRING_CA_GROUP_INVITE_MENU), link), true)
                if ChatAnnouncements.SV.Group.GroupAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_GROUP_INVITE_MENU), ZO_FormatUserFacingCharacterOrDisplayName(characterOrDisplayName)))
                end
            else
                printToChat(zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_INVITED), ZO_FormatUserFacingCharacterOrDisplayName(characterOrDisplayName)), true)
                if ChatAnnouncements.SV.Group.GroupAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_INVITED), ZO_FormatUserFacingCharacterOrDisplayName(characterOrDisplayName)))
                end
            end
        end
    end

    -- HOOK Group Invite function so we can modify CA/Alert here
    ---
    --- @param characterOrDisplayName string
    --- @param sentFromChat boolean
    --- @param displayInvitedMessage boolean
    --- @param isMenu boolean
    TryGroupInviteByName = function (characterOrDisplayName, sentFromChat, displayInvitedMessage, isMenu)
        if IsPlayerInGroup(characterOrDisplayName) then
            printToChat(GetString(SI_GROUP_ALERT_INVITE_PLAYER_ALREADY_MEMBER), true)
            if ChatAnnouncements.SV.Group.GroupAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, SI_GROUP_ALERT_INVITE_PLAYER_ALREADY_MEMBER)
            end
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
            return
        end

        local isLeader = IsUnitGroupLeader("player")
        local groupSize = GetGroupSize()

        if not isLeader and groupSize > 0 then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_ONLY_LEADER_CAN_INVITE))
            return
        end

        if IsConsoleUI() then
            local displayName = characterOrDisplayName

            local function GroupInviteCallback(success)
                if success then
                    CompleteGroupInvite(displayName, sentFromChat, displayInvitedMessage, isMenu)
                end
            end

            ZO_ConsoleAttemptInteractOrError(GroupInviteCallback, displayName, ZO_PLAYER_CONSOLE_INFO_REQUEST_DONT_BLOCK, ZO_CONSOLE_CAN_COMMUNICATE_ERROR_ALERT, ZO_ID_REQUEST_TYPE_DISPLAY_NAME, displayName)
        else
            if IsIgnored(characterOrDisplayName) then
                printToChat(GetString(LUIE_STRING_IGNORE_ERROR_GROUP), true)
                if ChatAnnouncements.SV.Group.GroupAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, LUIE_STRING_IGNORE_ERROR_GROUP)
                end
                PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
                return
            end

            CompleteGroupInvite(characterOrDisplayName, sentFromChat, displayInvitedMessage, isMenu)
        end
    end

    ChatAnnouncements.GuildHooks()

    -- Replace the default DeclineLFGReadyCheckNotification function to display the message that we are not in queue any longer + LFG activity join event.
    local zos_DeclineLFGReadyCheckNotification = DeclineLFGReadyCheckNotification
    DeclineLFGReadyCheckNotification = function (self)
        zos_DeclineLFGReadyCheckNotification()

        local message = (GetString(SI_LFGREADYCHECKCANCELREASON3))
        ChatAnnouncements.showRCUpdates = true
        ChatAnnouncements.weDeclinedTheQueue = true
        zo_callLater(function ()
                         ChatAnnouncements.weDeclinedTheQueue = false
                     end, 1000)

        if ChatAnnouncements.SV.Group.GroupLFGQueueCA then
            printToChat(message, true)
        end
        if ChatAnnouncements.SV.Group.GroupLFGQueueAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, message)
        end
    end
end

function ChatAnnouncements.GuildHooks()
    -- Hook for EVENT_GUILD_MEMBER_ADDED
    --- @diagnostic disable-next-line: duplicate-set-field
    function ZO_GuildRosterManager:OnGuildMemberAdded(guildId, displayName)
        self:RefreshData()

        local data = self:FindDataByDisplayName(displayName)
        if data and data.rankId ~= DEFAULT_INVITED_RANK then
            local hasCharacter, rawCharacterName, zone, class, alliance, level, championPoints = GetGuildMemberCharacterInfo(self.guildId, data.index)
            local displayNameLink = ChatAnnouncements.ResolveNameLink(rawCharacterName, displayName)
            local guildName = self.guildName
            local guildAlliance = GetGuildAlliance(guildId)
            local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ChatAnnouncements.Colors.GuildColorize
            local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
            local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName

            if ChatAnnouncements.SV.Social.GuildCA then
                printToChat(zo_strformat(GetString(LUIE_STRING_CA_GUILD_ROSTER_ADDED), displayNameLink, guildNameAlliance), true)
            end
            if ChatAnnouncements.SV.Social.GuildAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_GUILD_ROSTER_ADDED), displayName, guildNameAllianceAlert))
            end
            PlaySound(SOUNDS.GUILD_ROSTER_ADDED)
        end
    end

    -- Hook for EVENT_GUILD_MEMBER_REMOVED
    --- @diagnostic disable-next-line: duplicate-set-field
    function ZO_GuildRosterManager:OnGuildMemberRemoved(guildId, rawCharacterName, displayName)
        local displayNameLink = ChatAnnouncements.ResolveNameLink(rawCharacterName, displayName)
        local guildName = self.guildName
        local guildAlliance = GetGuildAlliance(guildId)
        local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ChatAnnouncements.Colors.GuildColorize
        local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
        local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName

        if ChatAnnouncements.SV.Social.GuildCA then
            printToChat(zo_strformat(GetString(LUIE_STRING_CA_GUILD_ROSTER_LEFT), displayNameLink, guildNameAlliance), true)
        end
        if ChatAnnouncements.SV.Social.GuildAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_GUILD_ROSTER_LEFT), displayName, guildNameAllianceAlert))
        end
        PlaySound(SOUNDS.GUILD_ROSTER_REMOVED)

        self:RefreshData()
    end

    local EVENT_NAMESPACE = "GuildRoster"
    -- Unregister ZOS Guild Roster events and replace with our own.
    eventManager:UnregisterForEvent(EVENT_NAMESPACE, EVENT_GUILD_PLAYER_RANK_CHANGED)
    eventManager:UnregisterForEvent(EVENT_NAMESPACE, EVENT_GUILD_MEMBER_PROMOTE_SUCCESSFUL)
    eventManager:UnregisterForEvent(EVENT_NAMESPACE, EVENT_GUILD_MEMBER_DEMOTE_SUCCESSFUL)
    eventManager:RegisterForEvent(EVENT_NAMESPACE, EVENT_GUILD_PLAYER_RANK_CHANGED, ChatAnnouncements.GuildPlayerRankChanged)
    eventManager:RegisterForEvent(EVENT_NAMESPACE, EVENT_GUILD_MEMBER_PROMOTE_SUCCESSFUL, ChatAnnouncements.GuildMemberPromoteSuccessful)
    eventManager:RegisterForEvent(EVENT_NAMESPACE, EVENT_GUILD_MEMBER_DEMOTE_SUCCESSFUL, ChatAnnouncements.GuildMemberDemoteSuccessful)

    -- Hook for Guild Invite function used from Guild Menu
    ---
    --- @param guildId integer
    --- @param displayName string
    function ZO_TryGuildInvite(guildId, displayName)
        -- TODO: Update when more alerts are added to CA
        if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_INVITE) then
            ZO_AlertEvent(EVENT_SOCIAL_ERROR, SOCIAL_RESULT_NO_INVITE_PERMISSION)
            return
        end

        -- TODO: Update when more alerts are added to CA
        if GetNumGuildMembers(guildId) == MAX_GUILD_MEMBERS then
            ZO_AlertEvent(EVENT_SOCIAL_ERROR, SOCIAL_RESULT_NO_ROOM)
            return
        end

        local guildName = GetGuildName(guildId)
        local guildAlliance = GetGuildAlliance(guildId)
        local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ChatAnnouncements.Colors.GuildColorize
        local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
        local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName

        if IsConsoleUI() then
            local function GuildInviteCallback(success)
                if success then
                    GuildInvite(guildId, displayName)
                    if ChatAnnouncements.SV.Social.GuildCA then
                        printToChat(zo_strformat(LUIE_STRING_CA_GUILD_ROSTER_INVITED_MESSAGE, UndecorateDisplayName(displayName), guildNameAlliance), true)
                    end
                    if ChatAnnouncements.SV.Social.GuildAlert then
                        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(LUIE_STRING_CA_GUILD_ROSTER_INVITED_MESSAGE, UndecorateDisplayName(displayName), guildNameAllianceAlert))
                    end
                end
            end

            ZO_ConsoleAttemptInteractOrError(GuildInviteCallback, displayName, ZO_PLAYER_CONSOLE_INFO_REQUEST_DONT_BLOCK, ZO_CONSOLE_CAN_COMMUNICATE_ERROR_ALERT, ZO_ID_REQUEST_TYPE_DISPLAY_NAME, displayName)
        else
            -- TODO: This needs fixed in the API so that character names are also factored in here. This check here is just about pointless as it stands.
            if IsIgnored(displayName) then
                if ChatAnnouncements.SV.Social.GuildCA then
                    printToChat(GetString(LUIE_STRING_IGNORE_ERROR_GUILD), true)
                end
                if ChatAnnouncements.SV.Social.GuildAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_IGNORE_ERROR_GUILD))
                end
                PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
                return
            end

            GuildInvite(guildId, displayName)
            if ChatAnnouncements.SV.Social.GuildCA then
                printToChat(zo_strformat(LUIE_STRING_CA_GUILD_ROSTER_INVITED_MESSAGE, displayName, guildNameAlliance), true)
            end
            if ChatAnnouncements.SV.Social.GuildAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(LUIE_STRING_CA_GUILD_ROSTER_INVITED_MESSAGE, displayName, guildNameAllianceAlert))
            end
        end
    end

    -- Called when changing guilds in the Guild tab
    local originalSetGuildId = GUILD_SHARED_INFO.SetGuildId
    --- @diagnostic disable-next-line: duplicate-set-field
    function GUILD_SHARED_INFO:SetGuildId(guildId)
        self.guildId = guildId
        self:Refresh(guildId)
        -- Set selected guild for use when resolving Rank/Heraldry updates
        ChatAnnouncements.selectedGuild = guildId
    end

    -- Called when changing guilds in the Guild tab or leaving/joining a guild
    local originalRefresh = GUILD_SHARED_INFO.Refresh
    --- @diagnostic disable-next-line: duplicate-set-field
    function GUILD_SHARED_INFO:Refresh(guildId)
        if self.guildId and self.guildId == guildId then
            local count = GetControl(self.control, "Count")
            local numGuildMembers, numOnline = GetGuildInfo(guildId)

            --- @diagnostic disable-next-line: need-check-nil
            count:SetText(zo_strformat(SI_GUILD_NUM_MEMBERS_ONLINE_FORMAT, numOnline, numGuildMembers))

            self.canDepositToBank = DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_BANK_DEPOSIT)
            if self.canDepositToBank then
                self.bankIcon:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
            else
                self.bankIcon:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
            end

            self.canUseTradingHouse = DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_TRADING_HOUSE)
            if self.canUseTradingHouse then
                self.tradingHouseIcon:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
            else
                self.tradingHouseIcon:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
            end

            self.canUseHeraldry = DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_HERALDRY)
            if self.canUseHeraldry then
                self.heraldryIcon:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
            else
                self.heraldryIcon:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
            end
        end
        -- Set selected guild for use when resolving Rank/Heraldry updates
        ChatAnnouncements.selectedGuild = guildId
    end
end
