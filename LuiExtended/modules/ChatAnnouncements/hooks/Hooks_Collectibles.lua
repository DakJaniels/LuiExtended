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
function ChatAnnouncements.Hooks.RegisterCollectibles(ctx)
    local alertHandlers = ctx.alertHandlers
    local csaHandlers = ctx.csaHandlers
    local csaCallbackHandlers = ctx.csaCallbackHandlers
    local eventManager = ctx.eventManager
    local moduleName = ctx.moduleName
    local FindCsaCallbackHandler = ctx.FindCsaCallbackHandler
    -- EVENT_COLLECTION_UPDATED (CSA Handler) -- Hooked via csaCallbackHandlers[1]
    local function CollectibleUnlockedHook(collectionUpdateType, collectiblesByUnlockState)
        if collectionUpdateType == ZO_COLLECTION_UPDATE_TYPE.UNLOCK_STATE_CHANGED then
            local nowOwnedCollectibles = collectiblesByUnlockState[COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED]
            if nowOwnedCollectibles then
                if #nowOwnedCollectibles > MAX_INDIVIDUAL_COLLECTIBLE_UPDATES then
                    local stringPrefix = ChatAnnouncements.GetModuleMessageFormat("Collectibles", "CollectiblePrefix")
                    local csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(SI_COLLECTIONS_UPDATED_ANNOUNCEMENT_TITLE)

                    if ChatAnnouncements.SV.Collectibles.CollectibleCA then
                        local string1
                        if stringPrefix ~= "" then
                            string1 = ColorizeColors.CollectibleColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", B.bracket1[ChatAnnouncements.SV.Collectibles.CollectibleBracket], stringPrefix, B.bracket2[ChatAnnouncements.SV.Collectibles.CollectibleBracket]))
                        else
                            string1 = ""
                        end
                        local string2 = ColorizeColors.CollectibleColorize2:Colorize(zo_strformat(SI_COLLECTIBLES_UPDATED_ANNOUNCEMENT_BODY, #nowOwnedCollectibles) .. ".")
                        local finalString = zo_strformat("<<1>><<2>>", string1, string2)
                        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalString, type = "COLLECTIBLE" }
                        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
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
                        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, text)
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

                        local stringPrefix = ChatAnnouncements.GetModuleMessageFormat("Collectibles", "CollectiblePrefix")
                        local csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(SI_COLLECTIONS_UPDATED_ANNOUNCEMENT_TITLE)

                        if ChatAnnouncements.SV.Collectibles.CollectibleCA then
                            local link = GetCollectibleLink(collectibleId, B.linkBrackets[ChatAnnouncements.SV.BracketOptionCollectible])
                            local formattedIcon = ChatAnnouncements.SV.Collectibles.CollectibleIcon and string_format("|t16:16:%s|t ", icon) or ""

                            local string1
                            if stringPrefix ~= "" then
                                string1 = ColorizeColors.CollectibleColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", B.bracket1[ChatAnnouncements.SV.Collectibles.CollectibleBracket], stringPrefix, B.bracket2[ChatAnnouncements.SV.Collectibles.CollectibleBracket]))
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
                                string2 = ColorizeColors.CollectibleColorize2:Colorize(zo_strformat(SI_COLLECTIONS_UPDATED_ANNOUNCEMENT_BODY, link, categoryString) .. ".")
                            else
                                string2 = link
                            end
                            local finalString = zo_strformat("<<1>><<2>><<3>>", string1, formattedIcon, string2)
                            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalString, type = "COLLECTIBLE" }
                            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
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
                            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, text)
                        end
                    end
                    return true
                end
            end
        end
    end
    local collectionUpdatedHandler = I.FindCsaCallbackHandler(csaCallbackHandlers, "OnCollectionUpdated", ZO_COLLECTIBLE_DATA_MANAGER)
    if collectionUpdatedHandler then
        ZO_PreHook(collectionUpdatedHandler, "callbackFunction", CollectibleUnlockedHook)
    end
end
