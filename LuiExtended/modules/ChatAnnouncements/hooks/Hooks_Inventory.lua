-- -----------------------------------------------------------------------------
--  LuiExtended — Chat Announcements hook shared context (CSA / alerts)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local S = ChatAnnouncements.State
local I = ChatAnnouncements.Internal
local B = ChatAnnouncements.Brackets
local ColorizeColors = ChatAnnouncements.Colors
local Data = LuiData.Data
local Quests = Data.Quests
local ChatOutput = LUIE.ChatOutput
local string_format = string.format
local table_insert = table.insert
local windowManager = GetWindowManager()

--- @param ctx CAHookContext
function ChatAnnouncements.Hooks.RegisterInventory(ctx)
    local alertHandlers = ctx.alertHandlers
    local csaHandlers = ctx.csaHandlers
    local csaCallbackHandlers = ctx.csaCallbackHandlers
    local eventManager = ctx.eventManager
    local moduleName = ctx.moduleName
    local FindCsaCallbackHandler = ctx.FindCsaCallbackHandler
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
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, text)
                else
                    local text = zo_strformat(SI_NEW_STYLE_CHAPTER_LEARNED, GetItemStyleName(itemStyleId), GetString("SI_ITEMSTYLECHAPTER", chapterIndex))
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, text)
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
    local function MultipleRecipeLearnedHook(numLearned)
        local flag
        if ChatAnnouncements.SV.Inventory.LootShowRecipe and ChatAnnouncements.SV.Inventory.LootRecipeHideAlert then
            flag = true
        else
            flag = false
        end

        if not flag then
            local text = zo_strformat(SI_NEW_RECIPES_LEARNED, numLearned)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.RECIPE_LEARNED, text)
        end
        return true
    end

    local function RidingSkillImprovementAlertHook(ridingSkill, previous, current, source)
        if source == RIDING_TRAIN_SOURCE_STABLES then
            -- If we purchased from the stables, display a currency announcement if relevant
            if ChatAnnouncements.SV.Currency.CurrencyGoldChange then
                local type
                if ridingSkill == 1 then
                    type = "LUIE_CURRENCY_RIDING_SPEED"
                elseif ridingSkill == 2 then
                    type = "LUIE_CURRENCY_RIDING_CAPACITY"
                elseif ridingSkill == 3 then
                    type = "LUIE_CURRENCY_RIDING_STAMINA"
                end
                local formattedValue = ZO_CommaDelimitDecimalNumber(I.GetCarriedCurrencyAmount(1) + 250)
                local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyDownColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
                local changeType = ZO_CommaDelimitDecimalNumber(250)
                local currencyTypeColor = ColorizeColors.CurrencyGoldColorize:ToHex()
                local currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and "|t16:16:/esoui/art/currency/currency_gold.dds|t" or ""
                local currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyGoldName, 250)
                local currencyTotal = ChatAnnouncements.SV.Currency.CurrencyGoldShowTotal
                local messageTotal = ChatAnnouncements.SV.Currency.CurrencyMessageTotalGold
                local messageChange = ChatAnnouncements.GetContextMessage("CurrencyMessageStable")
                ChatAnnouncements.CurrencyPrinter(nil, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, type)
            end

            if ChatAnnouncements.SV.Notify.StorageRidingCA then
                local formattedString = ColorizeColors.StorageRidingColorize:Colorize(zo_strformat(SI_RIDING_SKILL_ANNOUCEMENT_SKILL_INCREASE, GetString("SI_RIDINGTRAINTYPE", ridingSkill), previous, current))
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, type = "MESSAGE" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
            end

            if ChatAnnouncements.SV.Notify.StorageRidingAlert then
                local text = zo_strformat(SI_RIDING_SKILL_ANNOUCEMENT_SKILL_INCREASE, GetString("SI_RIDINGTRAINTYPE", ridingSkill), previous, current)
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, text)
            end

            if ChatAnnouncements.SV.Notify.StorageRidingCSA then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
                messageParams:SetText(GetString(SI_RIDING_SKILL_ANNOUCEMENT_BANNER), zo_strformat(SI_RIDING_SKILL_ANNOUCEMENT_SKILL_INCREASE, GetString("SI_RIDINGTRAINTYPE", ridingSkill), previous, current))
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RIDING_SKILL_IMPROVEMENT)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
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

                    local formattedColor = ColorizeColors.StorageRidingBookColorize:ToHex()

                    local messageP1 = ChatAnnouncements.SV.Inventory.LootIcons and (icon .. bookString) or bookString
                    local formattedString = (messageP1 .. "|r|cFFFFFF x" .. value .. "|r|c" .. formattedColor)
                    local messageP2 = string_format(learnString, formattedString)
                    local finalMessage = string_format("|c%s%s|r", formattedColor, messageP2)

                    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = "MESSAGE" }
                    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
                end

                local formattedString = ColorizeColors.StorageRidingColorize:Colorize(zo_strformat(SI_RIDING_SKILL_ANNOUCEMENT_SKILL_INCREASE, GetString("SI_RIDINGTRAINTYPE", ridingSkill), previous, current))
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, type = "MESSAGE" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
            end

            if ChatAnnouncements.SV.Notify.StorageRidingAlert then
                local text = zo_strformat(SI_RIDING_SKILL_ANNOUCEMENT_SKILL_INCREASE, GetString("SI_RIDINGTRAINTYPE", ridingSkill), previous, current)
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, text)
            end

            if ChatAnnouncements.SV.Notify.StorageRidingCSA then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
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
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
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
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
                messageParams:SetText(GetString(SI_INVENTORY_BANK_UPGRADE_ANOUNCEMENT_TITLE), zo_strformat(SI_INVENTORY_BANK_UPGRADE_ANOUNCEMENT_DESCRIPTION, previousCapacity, currentCapacity))
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_BANK_CAPACITY_CHANGED)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end
        end
        return true
    end

    -- EVENT_CONSOLIDATED_STATION_SETS_UPDATED (CSA Handler)
    local function ConsolidatedStationSetsUpdatedHook(craftingStationFurnitureId)
        if not HOUSING_EDITOR_STATE:IsLocalPlayerHouseOwner() then
            return true
        end

        local unlockedSetIds = {}
        local previousSetId
        while true do
            local setId = GetNextDirtyUnlockedConsolidatedSmithingItemSetId(previousSetId)
            if not setId then
                break
            end
            table_insert(unlockedSetIds, setId)
            previousSetId = setId
        end

        local numUnlockedSetIds = #unlockedSetIds
        if numUnlockedSetIds == 0 then
            return true
        end

        local inventory = ChatAnnouncements.SV.Inventory
        local messageTitle = GetString(SI_SMITHING_CONSOLIDATED_STATION_SETS_UPDATED_ANNOUNCEMENT_TITLE)
        local messageSubheading
        if numUnlockedSetIds == 1 then
            local setName = GetItemSetName(unlockedSetIds[1])
            messageSubheading = zo_strformat(SI_SMITHING_CONSOLIDATED_STATION_SETS_UPDATED_SINGLE_SET_MESSAGE, setName)
        else
            messageSubheading = zo_strformat(SI_SMITHING_CONSOLIDATED_STATION_SETS_UPDATED_MULTI_SET_MESSAGE, numUnlockedSetIds)
        end

        local stationIcon = select(2, GetPlacedHousingFurnitureInfo(craftingStationFurnitureId))

        if inventory.AttunableStationCA then
            local formattedIcon = inventory.LootIcons and stationIcon and ("|t16:16:" .. stationIcon .. "|t ") or ""
            local finalMessage = zo_strformat("<<1>><<2>>: <<3>>", formattedIcon, messageTitle, messageSubheading)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = "MESSAGE" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
        end

        if inventory.AttunableStationAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat("<<1>> <<2>>", messageTitle, messageSubheading))
        end

        if inventory.AttunableStationCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.CONSOLIDATED_SMITHING_SET_ADDED)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_CONSOLIDATED_STATION_SETS_UPDATED)
            messageParams:SetIconData(stationIcon)
            messageParams:SetText(messageTitle, messageSubheading)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        elseif inventory.AttunableStationCA or inventory.AttunableStationAlert then
            PlaySound(SOUNDS.CONSOLIDATED_SMITHING_SET_ADDED)
        end

        return true
    end

    ZO_PreHook(alertHandlers, EVENT_STYLE_LEARNED, StyleLearnedHook)
    ZO_PreHook(alertHandlers, EVENT_RECIPE_LEARNED, RecipeLearnedHook)
    ZO_PreHook(alertHandlers, EVENT_MULTIPLE_RECIPES_LEARNED, MultipleRecipeLearnedHook)
    ZO_PreHook(alertHandlers, EVENT_RIDING_SKILL_IMPROVEMENT, RidingSkillImprovementAlertHook)
    ZO_PreHook(csaHandlers, EVENT_RIDING_SKILL_IMPROVEMENT, RidingSkillImprovementHook)
    ZO_PreHook(csaHandlers, EVENT_INVENTORY_BAG_CAPACITY_CHANGED, InventoryBagCapacityHook)
    ZO_PreHook(csaHandlers, EVENT_INVENTORY_BANK_CAPACITY_CHANGED, InventoryBankCapacityHook)
    ZO_PreHook(csaHandlers, EVENT_CONSOLIDATED_STATION_SETS_UPDATED, ConsolidatedStationSetsUpdatedHook)

    --- @param self ZO_InventoryManager
    --- @param questItem questItem
    --- @param searchType integer
    --- @diagnostic disable-next-line: duplicate-set-field
    function PLAYER_INVENTORY:AddQuestItem(questItem, searchType)
        local inventory = self.inventories[INVENTORY_QUEST_ITEM]

        questItem.inventory = inventory
        local questIndex = questItem.questIndex
        if not inventory.slots[questIndex] then
            inventory.slots[questIndex] = {}
        end
        questItem.slotIndex = questIndex
        table_insert(inventory.slots[questIndex], questItem)

        if ChatAnnouncements.SV.Inventory.LootQuestAdd or ChatAnnouncements.SV.Inventory.LootQuestRemove then
            I.DisplayQuestItem(questItem.questItemId, questItem.stackCount, questItem.iconFile, false)
        end
    end

    --- @param self ZO_InventoryManager
    --- @param questIndex integer
    --- @diagnostic disable-next-line: duplicate-set-field
    function PLAYER_INVENTORY:ResetQuest(questIndex)
        local inventory = self.inventories[INVENTORY_QUEST_ITEM]
        local itemTable = inventory.slots[questIndex]
        --- @cast itemTable questItem_itemTable
        if itemTable then
            for i = 1, #itemTable do
                if ChatAnnouncements.SV.Inventory.LootQuestAdd or ChatAnnouncements.SV.Inventory.LootQuestRemove then
                    local itemId = itemTable[i].questItemId
                    local stackCount = itemTable[i].stackCount
                    local icon = itemTable[i].iconFile
                    I.DisplayQuestItem(itemId, stackCount, icon, true)
                end
            end
        end
        inventory.slots[questIndex] = nil
    end
end
