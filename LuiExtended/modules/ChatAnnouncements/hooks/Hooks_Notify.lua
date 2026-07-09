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
function ChatAnnouncements.Hooks.RegisterNotify(ctx)
    local alertHandlers = ctx.alertHandlers
    local csaHandlers = ctx.csaHandlers
    local csaCallbackHandlers = ctx.csaCallbackHandlers
    local eventManager = ctx.eventManager
    local moduleName = ctx.moduleName
    local FindCsaCallbackHandler = ctx.FindCsaCallbackHandler
    -- EVENT_DUEL_INVITE_RECEIVED (Alert Handler)
    local function DuelInviteReceivedAlert(inviterCharacterName, inviterDisplayName)
        -- Display CA
        if ChatAnnouncements.SV.Social.DuelCA then
            local finalName = ChatAnnouncements.ResolveNameLink(inviterCharacterName, inviterDisplayName)
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_DUEL_INVITE_RECEIVED), finalName), true)
        end

        -- Display Alert
        if ChatAnnouncements.SV.Social.DuelAlert then
            local finalAlertName = ChatAnnouncements.ResolveNameNoLink(inviterCharacterName, inviterDisplayName)
            local formattedString = zo_strformat(GetString(LUIE_STRING_CA_DUEL_INVITE_RECEIVED), finalAlertName)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, formattedString)
        end

        return true
    end

    -- EVENT_DUEL_INVITE_ACCEPTED (Alert Handler)
    local function DuelInviteAcceptedAlert()
        -- Display CA
        if ChatAnnouncements.SV.Social.DuelCA then
            ChatOutput:Print(GetString(LUIE_STRING_CA_DUEL_INVITE_ACCEPTED), true)
        end

        -- Display Alert
        if ChatAnnouncements.SV.Social.DuelAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(LUIE_STRING_CA_DUEL_INVITE_ACCEPTED))
        end
        PlaySound(SOUNDS.DUEL_ACCEPTED)
        return true
    end

    -- EVENT_DUEL_INVITE_SENT (Alert Handler)
    local function DuelInviteSentAlert(inviteeCharacterName, inviteeDisplayName)
        -- Display CA
        if ChatAnnouncements.SV.Social.DuelCA then
            local finalName = ChatAnnouncements.ResolveNameLink(inviteeCharacterName, inviteeDisplayName)
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_DUEL_INVITE_SENT), finalName), true)
        end

        -- Display Alert
        if ChatAnnouncements.SV.Social.DuelAlert then
            local finalAlertName = ChatAnnouncements.ResolveNameNoLink(inviteeCharacterName, inviteeDisplayName)
            local formattedString = zo_strformat(GetString(LUIE_STRING_CA_DUEL_INVITE_SENT), finalAlertName)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, formattedString)
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
            local reasonName
            local finalName = ChatAnnouncements.ResolveNameLink(targetCharacterName, targetDisplayName)
            if userFacingName then
                ChatOutput:Print(zo_strformat(GetString("LUIE_STRING_CA_DUEL_INVITE_FAILREASON", reason), finalName), true)
            else
                ChatOutput:Print(zo_strformat(GetString("LUIE_STRING_CA_DUEL_INVITE_FAILREASON", reason)), true)
            end
        end

        -- Display Alert
        if ChatAnnouncements.SV.Social.DuelAlert then
            local finalAlertName = ChatAnnouncements.ResolveNameNoLink(targetCharacterName, targetDisplayName)
            local formattedString = zo_strformat(GetString("LUIE_STRING_CA_DUEL_INVITE_FAILREASON", reason), finalAlertName)
            if userFacingName then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, formattedString)
            else
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, (GetString("LUIE_STRING_CA_DUEL_INVITE_FAILREASON", reason)))
            end
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return true
    end

    -- EVENT_DUEL_INVITE_DECLINED (Alert Handler)
    local function DuelInviteDeclinedAlert()
        -- Display CA
        if ChatAnnouncements.SV.Social.DuelCA then
            ChatOutput:Print(GetString(LUIE_STRING_CA_DUEL_INVITE_DECLINED), true)
        end

        -- Display Alert
        if ChatAnnouncements.SV.Social.DuelAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, GetString(LUIE_STRING_CA_DUEL_INVITE_DECLINED))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return true
    end

    -- EVENT_DUEL_INVITE_CANCELED (Alert Handler)
    local function DuelInviteCanceledAlert()
        -- Display CA
        if ChatAnnouncements.SV.Social.DuelCA then
            ChatOutput:Print(GetString(LUIE_STRING_CA_DUEL_INVITE_CANCELED), true)
        end

        -- Display Alert
        if ChatAnnouncements.SV.Social.DuelAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, GetString(LUIE_STRING_CA_DUEL_INVITE_CANCELED))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return true
    end

    -- EVENT_PLEDGE_OF_MARA_RESULT (Alert Handler)
    -- EVENT_LOCKPICK_FAILED (Alert Handler)
    local function LockpickFailedAlert(result)
        if ChatAnnouncements.SV.Notify.NotificationLockpickCA then
            local message = GetString(LUIE_STRING_CA_LOCKPICK_FAILED)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, type = "NOTIFICATION" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
        end
        if ChatAnnouncements.SV.Notify.NotificationLockpickAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(LUIE_STRING_CA_LOCKPICK_FAILED))
        end
        S.g_lockpickBroken = true
        zo_callLater(function ()
                         S.g_lockpickBroken = false
                     end, 200)
        return true
    end

    -- EVENT_JUMP_FAILED (Alert Handler) — home slash attribution
    local function JumpFailedHomeAlert(result)
        if not S.pendingHomeJump then
            return false
        end
        S.pendingHomeJump = false
        if result == JUMP_RESULT_JUMP_FAILED_ZONE_COLLECTIBLE or result == JUMP_RESULT_JUMP_FAILED_SOCIAL_TARGET_ZONE_COLLECTIBLE_LOCKED then
            return false
        end
        local notify = ChatAnnouncements.SV.Notify
        if not (ChatAnnouncements.Enabled and (notify.SlashHomeCA or notify.SlashHomeAlert)) then
            return false
        end
        local message = GetString("SI_JUMPRESULT", result)
        if notify.SlashHomeCA then
            ChatOutput:Print(message, true)
        end
        if notify.SlashHomeAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, message)
        end
        return true
    end

    -- EVENT_SOCIAL_ERROR (Alert Handler)
    local function SocialErrorNotifyAlert(error)
        if error == SOCIAL_RESULT_NO_ERROR or IsSocialErrorIgnoreResponse(error) then
            return false
        end
        local notify = ChatAnnouncements.SV.Notify
        if not (ChatAnnouncements.Enabled and (notify.SocialErrorCA or notify.SocialErrorAlert)) then
            return false
        end
        local message = zo_strformat(GetString("SI_SOCIALACTIONRESULT", error))
        if notify.SocialErrorAlert and ShouldShowSocialErrorInAlert(error) then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, message)
        end
        return true
    end

    -- EVENT_CLIENT_INTERACT_RESULT (Alert Handler)
    local function ClientInteractResult(result, interactTargetName)
        local formatString = GetString("SI_CLIENTINTERACTRESULT", result)
        if formatString ~= "" then
            ChatOutput:Print(zo_strformat(formatString, interactTargetName), true)
            if ChatAnnouncements.SV.Notify.NotificationLockpickAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, zo_strformat(formatString, interactTargetName))
            end
            local sound = ZO_ClientInteractResultSpecificSound[result] or SOUNDS.GENERAL_ALERT_ERROR
            PlaySound(sound)
        end
        return true
    end

    -- EVENT_QUEUE_FOR_CAMPAIGN_RESPONSE (Alert Handler)
    local function QueueForCampaignResponseAlert(response, parameter)
        local responseString = GetString("SI_QUEUEFORCAMPAIGNRESPONSETYPE", response)
        if responseString == "" then
            return false
        end
        local notify = ChatAnnouncements.SV.Notify
        if not (ChatAnnouncements.Enabled and (notify.CampaignQueueCA or notify.CampaignQueueAlert)) then
            return false
        end
        local message = zo_strformat(responseString, parameter)
        if notify.CampaignQueueCA then
            ChatOutput:Print(message, true)
        end
        if notify.CampaignQueueAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, message)
        end
        return true
    end

    -- EVENT_OUTFIT_EQUIP_RESPONSE (Alert Handler)
    local function OutfitEquipResponseAlert(actorCategory, result)
        if actorCategory ~= GAMEPLAY_ACTOR_CATEGORY_PLAYER then
            return false
        end
        local notify = ChatAnnouncements.SV.Notify
        if not (ChatAnnouncements.Enabled and (notify.OutfitEquipCA or notify.OutfitEquipAlert)) then
            return false
        end
        local message
        local alertCategory = UI_ALERT_CATEGORY_ERROR
        local sound = SOUNDS.GENERAL_ALERT_ERROR
        if result == EQUIP_OUTFIT_RESULT_SUCCESS then
            local outfitIndex = GetEquippedOutfitIndex(actorCategory)
            local name
            if outfitIndex == nil then
                name = GetString(SI_NO_OUTFIT_EQUIP_ENTRY)
            else
                name = GetOutfitName(actorCategory, outfitIndex)
                if name == "" then
                    name = zo_strformat("<<1>> <<2>>", GetString(SI_CROWN_STORE_SEARCH_ADDITIONAL_OUTFITS), outfitIndex)
                end
            end
            message = zo_strformat(GetString(LUIE_STRING_SLASHCMDS_OUTFIT_CONFIRMATION), name)
            alertCategory = UI_ALERT_CATEGORY_ALERT
            sound = SOUNDS.NONE
        else
            message = GetString("SI_EQUIPOUTFITRESULT", result)
        end
        if notify.OutfitEquipCA then
            ChatOutput:Print(message, true)
        end
        if notify.OutfitEquipAlert then
            ZO_Alert(alertCategory, sound, message)
        end
        return true
    end

    local function getArmoryBuildDisplayName(buildIndex)
        if buildIndex == nil then
            return nil
        end
        local buildName = GetArmoryBuildName(buildIndex)
        if buildName == "" then
            buildName = zo_strformat(SI_ARMORY_BUILD_DEFAULT_NAME_FORMATTER, buildIndex)
        end
        return buildName
    end

    local function notifyArmoryBuildResponse(eventId, result, buildIndex, isSave)
        local notify = ChatAnnouncements.SV.Notify
        if not (ChatAnnouncements.Enabled and (notify.ArmoryBuildCA or notify.ArmoryBuildCSA or notify.ArmoryBuildAlert)) then
            return
        end

        local isSuccess = isSave and result == ARMORY_BUILD_SAVE_RESULT_SUCCESS
            or not isSave and result == ARMORY_BUILD_RESTORE_RESULT_SUCCESS

        if isSuccess then
            local buildName = getArmoryBuildDisplayName(buildIndex)
            if buildName == nil then
                return
            end
            local titleStringId = isSave and SI_ARMORY_BUILD_SAVE_SUCCESS_DIALOG_TITLE or SI_ARMORY_BUILD_RESTORE_SUCCESS_DIALOG_TITLE
            local bodyStringId = isSave and SI_ARMORY_BUILD_SAVE_SUCCESS_DIALOG_TEXT or SI_ARMORY_BUILD_RESTORE_SUCCESS_DIALOG_TEXT
            local body = zo_strformat(GetString(bodyStringId), buildName)
            local title = GetString(titleStringId)

            if notify.ArmoryBuildCA then
                local formattedString = ColorizeColors.ArmoryBuildColorize:Colorize(body)
                ChatOutput:Print(formattedString, true)
            end
            if notify.ArmoryBuildCSA then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
                messageParams:SetText(title, body)
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end
            if notify.ArmoryBuildAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, body)
            end
        else
            local resultStringId = isSave and "SI_ARMORYBUILDSAVERESULT" or "SI_ARMORYBUILDRESTORERESULT"
            local failureMessage = GetString(resultStringId, result)
            if failureMessage == "" then
                return
            end
            if notify.ArmoryBuildCA then
                ChatOutput:Print(failureMessage, true)
            end
            if notify.ArmoryBuildAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, failureMessage)
            end
        end
    end

    -- EVENT_TRADE_INVITE_FAILED (Alert Handler)
    local function TradeInviteFailedAlert(errorReason, inviteeCharacterName, inviteeDisplayName)
        if ChatAnnouncements.SV.Notify.NotificationTradeCA or ChatAnnouncements.SV.Notify.NotificationTradeAlert then
            local finalName = ChatAnnouncements.ResolveNameLink(inviteeCharacterName, inviteeDisplayName)
            local finalAlertName = ChatAnnouncements.ResolveNameNoLink(inviteeCharacterName, inviteeDisplayName)

            if ChatAnnouncements.SV.Notify.NotificationTradeCA then
                ChatOutput:Print(zo_strformat(GetString("LUIE_STRING_CA_TRADEACTIONRESULT", errorReason), finalName), true)
            end

            if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString("LUIE_STRING_CA_TRADEACTIONRESULT", errorReason), finalAlertName))
            end
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        S.g_tradeTarget = ""
        return true
    end

    -- EVENT_TRADE_INVITE_CONSIDERING (Alert Handler)
    local function TradeInviteConsideringAlert(inviterCharacterName, inviterDisplayName)
        if ChatAnnouncements.SV.Notify.NotificationTradeCA or ChatAnnouncements.SV.Notify.NotificationTradeAlert then
            local finalName = ChatAnnouncements.ResolveNameLink(inviterCharacterName, inviterDisplayName)
            local finalAlertName = ChatAnnouncements.ResolveNameNoLink(inviterCharacterName, inviterDisplayName)
            S.g_tradeTarget = ZO_SELECTED_TEXT:Colorize(zo_strformat("<<C:1>>", finalName))

            if ChatAnnouncements.SV.Notify.NotificationTradeCA then
                ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_TRADE_INVITE_MESSAGE), finalName), true)
            end
            if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_TRADE_INVITE_MESSAGE), finalAlertName))
            end
        end
        return true
    end

    -- EVENT_TRADE_INVITE_WAITING (Alert Handler)
    local function TradeInviteWaitingAlert(inviteeCharacterName, inviteeDisplayName)
        if ChatAnnouncements.SV.Notify.NotificationTradeCA or ChatAnnouncements.SV.Notify.NotificationTradeAlert then
            local finalName = ChatAnnouncements.ResolveNameLink(inviteeCharacterName, inviteeDisplayName)
            local finalAlertName = ChatAnnouncements.ResolveNameNoLink(inviteeCharacterName, inviteeDisplayName)
            S.g_tradeTarget = ZO_SELECTED_TEXT:Colorize(zo_strformat("<<C:1>>", finalName))

            if ChatAnnouncements.SV.Notify.NotificationTradeCA then
                ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_TRADE_INVITE_CONFIRM), finalName), true)
            end
            if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_TRADE_INVITE_CONFIRM), finalAlertName))
            end
        end
        return true
    end

    -- EVENT_TRADE_INVITE_DECLINED (Alert Handler)
    local function TradeInviteDeclinedAlert()
        if ChatAnnouncements.SV.Notify.NotificationTradeCA then
            ChatOutput:Print(GetString(LUIE_STRING_CA_TRADE_INVITE_DECLINED), true)
        end
        if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(LUIE_STRING_CA_TRADE_INVITE_DECLINED))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        S.g_tradeTarget = ""
        S.g_tradeStacksIn = {}
        S.g_tradeStacksOut = {}
        return true
    end

    -- EVENT_TRADE_INVITE_CANCELED (Alert Handler)
    local function TradeInviteCanceledAlert()
        if ChatAnnouncements.SV.Notify.NotificationTradeCA then
            ChatOutput:Print(GetString(LUIE_STRING_CA_TRADE_INVITE_CANCELED), true)
        end
        if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(LUIE_STRING_CA_TRADE_INVITE_CANCELED))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        S.g_tradeTarget = ""
        S.g_tradeStacksIn = {}
        S.g_tradeStacksOut = {}
        return true
    end

    -- EVENT_TRADE_CANCELED (Alert Handler)
    local function TradeCanceledAlert()
        if ChatAnnouncements.SV.Notify.NotificationTradeCA then
            ChatOutput:Print(GetString(SI_TRADE_CANCELED), true)
        end
        if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(SI_TRADE_CANCELED))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)

        eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
        if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
            eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
        end
        if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
            S.g_inventoryStacks = {}
        end

        S.g_tradeTarget = ""
        S.g_tradeStacksIn = {}
        S.g_tradeStacksOut = {}
        S.g_inTrade = false
        return true
    end

    -- EVENT_TRADE_FAILED (Alert Handler)
    local function TradeFailedAlert(reason)
        if ChatAnnouncements.SV.Notify.NotificationTradeCA then
            ChatOutput:Print(GetString("LUIE_STRING_CA_TRADEACTIONRESULT", reason), true)
        end
        if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString("LUIE_STRING_CA_TRADEACTIONRESULT", reason))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)

        S.g_tradeTarget = ""
        S.g_inTrade = false
        return true
    end

    -- EVENT_TRADE_SUCCEEDED (Alert Handler)
    local function TradeSucceededAlert()
        if ChatAnnouncements.SV.Notify.NotificationTradeCA then
            local message = GetString(SI_TRADE_COMPLETE)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, type = "NOTIFICATION", isSystem = true }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
        end
        if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(SI_TRADE_COMPLETE))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)

        if ChatAnnouncements.SV.Inventory.LootTrade then
            for indexOut = 1, 5 do
                if S.g_tradeStacksOut[indexOut] ~= nil then
                    local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    local logPrefix = S.g_tradeTarget ~= "" and ChatAnnouncements.GetContextMessage("CurrencyMessageTradeOut") or ChatAnnouncements.GetContextMessage("CurrencyMessageTradeOutNoName")
                    local item = S.g_tradeStacksOut[indexOut]
                    ChatAnnouncements.ItemCounterDelayOut(item.icon, item.stack, item.itemType, item.itemId, item.itemLink, S.g_tradeTarget, logPrefix, gainOrLoss, false)
                end
            end

            for indexIn = 1, 5 do
                if S.g_tradeStacksIn[indexIn] ~= nil then
                    local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                    local logPrefix = S.g_tradeTarget ~= "" and ChatAnnouncements.GetContextMessage("CurrencyMessageTradeIn") or ChatAnnouncements.GetContextMessage("CurrencyMessageTradeInNoName")
                    local item = S.g_tradeStacksIn[indexIn]
                    ChatAnnouncements.ItemCounterDelay(item.icon, item.stack, item.itemType, item.itemId, item.itemLink, S.g_tradeTarget, logPrefix, gainOrLoss, false)
                end
            end
        end

        eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
        if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
            eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
        end
        if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
            S.g_inventoryStacks = {}
        end

        S.g_tradeTarget = ""
        S.g_tradeStacksIn = {}
        S.g_tradeStacksOut = {}
        S.g_inTrade = false
        return true
    end

    -- EVENT_MAIL_SEND_FAILED (Alert Handler)
    local function MailSendFailedAlert(reason)
        if reason ~= MAIL_SEND_RESULT_CANCELED then
            local function RestoreMailBackupValues()
                S.g_postageAmount = GetQueuedMailPostage()
                S.g_mailAmount = GetQueuedMoneyAttachment()
                S.g_mailCOD = GetQueuedCOD()
            end

            -- Stop currency messages from printing here
            if reason == MAIL_SEND_RESULT_FAIL_INVALID_NAME then
                for i = 1, #ChatAnnouncements.QueuedMessages do
                    if ChatAnnouncements.QueuedMessages[i].type == "CURRENCY" then
                        ChatAnnouncements.QueuedMessages[i].type = "GARBAGE"
                    end
                end
                eventManager:UnregisterForEvent(moduleName, EVENT_CURRENCY_UPDATE)
                zo_callLater(function ()
                                 eventManager:RegisterForEvent(moduleName, EVENT_CURRENCY_UPDATE, ChatAnnouncements.OnCurrencyUpdate)
                             end, 500)
            end

            if ChatAnnouncements.SV.Notify.NotificationMailErrorCA then
                ChatOutput:Print(GetString("SI_SENDMAILRESULT", reason), true)
            end
            if ChatAnnouncements.SV.Notify.NotificationMailErrorAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, GetString("SI_SENDMAILRESULT", reason))
            end
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)

            zo_callLater(RestoreMailBackupValues, 50) -- Prevents values from being cleared by failed message (when inbox is full, the currency change fires first regardless and then is refunded)
        end
        return true
    end

    local Notify = ChatAnnouncements.SV.Notify
    local lastLocalOverlandDifficulty = GetOverlandDifficulty()

    local function OnOverlandDifficultyChanged(_eventId, newValue)
        if not (Notify.ChallengeDifficultyCA or Notify.ChallengeDifficultyAlert) then
            return
        end
        local localDifficulty = GetOverlandDifficulty()
        if newValue ~= localDifficulty then
            return
        end
        if newValue == lastLocalOverlandDifficulty then
            return
        end
        lastLocalOverlandDifficulty = newValue

        local message = GetString("SI_OVERLANDDIFFICULTYTYPE", newValue)
        if Notify.ChallengeDifficultyCA then
            ChatOutput:Print(message, true)
        end
        if Notify.ChallengeDifficultyAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, message)
        end
    end

    eventManager:RegisterForEvent(moduleName, EVENT_OVERLAND_DIFFICULTY_CHANGED, OnOverlandDifficultyChanged)
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED, function ()
        lastLocalOverlandDifficulty = GetOverlandDifficulty()
    end)

    ZO_PreHook("ZO_Alert", function (category, sound, message, ...)
        if message ~= GetString(SI_CHALLENGE_DIFFICULTY_COOLDOWN_ALERT) and message ~= GetString(SI_CHALLENGE_DIFFICULTY_COMBAT_ALERT) then
            return
        end
        if not (Notify.ChallengeDifficultyCA or Notify.ChallengeDifficultyAlert) then
            return true
        end
        if Notify.ChallengeDifficultyCA then
            ChatOutput:Print(message, true)
        end
        if not Notify.ChallengeDifficultyAlert then
            return true
        end
    end)

    ZO_PreHook(alertHandlers, EVENT_LOCKPICK_FAILED, LockpickFailedAlert)
    ZO_PreHook(alertHandlers, EVENT_CLIENT_INTERACT_RESULT, ClientInteractResult)
    ZO_PreHook(alertHandlers, EVENT_QUEUE_FOR_CAMPAIGN_RESPONSE, QueueForCampaignResponseAlert)
    ZO_PreHook(alertHandlers, EVENT_OUTFIT_EQUIP_RESPONSE, OutfitEquipResponseAlert)
    ZO_PreHook(alertHandlers, EVENT_JUMP_FAILED, JumpFailedHomeAlert)
    ZO_PreHook(alertHandlers, EVENT_SOCIAL_ERROR, SocialErrorNotifyAlert)
    ZO_PreHook(alertHandlers, EVENT_DUEL_INVITE_RECEIVED, DuelInviteReceivedAlert)
    ZO_PreHook(alertHandlers, EVENT_DUEL_INVITE_SENT, DuelInviteSentAlert)
    ZO_PreHook(alertHandlers, EVENT_DUEL_INVITE_ACCEPTED, DuelInviteAcceptedAlert)
    ZO_PreHook(alertHandlers, EVENT_DUEL_INVITE_FAILED, DuelInviteFailedAlert)
    ZO_PreHook(alertHandlers, EVENT_DUEL_INVITE_DECLINED, DuelInviteDeclinedAlert)
    ZO_PreHook(alertHandlers, EVENT_DUEL_INVITE_CANCELED, DuelInviteCanceledAlert)
    ZO_PreHook(alertHandlers, EVENT_TRADE_INVITE_FAILED, TradeInviteFailedAlert)
    ZO_PreHook(alertHandlers, EVENT_TRADE_INVITE_CONSIDERING, TradeInviteConsideringAlert)
    ZO_PreHook(alertHandlers, EVENT_TRADE_INVITE_WAITING, TradeInviteWaitingAlert)
    ZO_PreHook(alertHandlers, EVENT_TRADE_INVITE_DECLINED, TradeInviteDeclinedAlert)
    ZO_PreHook(alertHandlers, EVENT_TRADE_INVITE_CANCELED, TradeInviteCanceledAlert)
    ZO_PreHook(alertHandlers, EVENT_TRADE_CANCELED, TradeCanceledAlert)
    ZO_PreHook(alertHandlers, EVENT_TRADE_FAILED, TradeFailedAlert)
    ZO_PreHook(alertHandlers, EVENT_TRADE_SUCCEEDED, TradeSucceededAlert)
    ZO_PreHook(alertHandlers, EVENT_MAIL_SEND_FAILED, MailSendFailedAlert)

    local DUEL_BOUNDARY_WARNING_LIFESPAN_MS = 2000
    local DUEL_BOUNDARY_WARNING_UPDATE_TIME_MS = 2100
    local lastEventTime = 0
    local function CheckBoundary()
        if IsNearDuelBoundary() then
            if ChatAnnouncements.SV.Social.DuelBoundaryCA then
                ChatOutput:Print(GetString(LUIE_STRING_CA_DUEL_NEAR_BOUNDARY_CSA), true)
            end
            if ChatAnnouncements.SV.Social.DuelBoundaryCSA then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.DUEL_BOUNDARY_WARNING)
                messageParams:SetText(GetString(LUIE_STRING_CA_DUEL_NEAR_BOUNDARY_CSA))
                messageParams:SetLifespanMS(DUEL_BOUNDARY_WARNING_LIFESPAN_MS)
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DUEL_NEAR_BOUNDARY)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end
            if ChatAnnouncements.SV.Social.DuelBoundaryAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, (GetString(LUIE_STRING_CA_DUEL_NEAR_BOUNDARY_CSA)))
            end
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
            ChatOutput:Print(resultChatString, true)
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
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, resultCSAString)
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
    ZO_PreHook(csaHandlers, EVENT_DUEL_NEAR_BOUNDARY, DuelNearBoundaryHook)
    ZO_PreHook(csaHandlers, EVENT_DUEL_FINISHED, DuelFinishedHook)
    ZO_PreHook(csaHandlers, EVENT_DUEL_COUNTDOWN, DuelCountdownHook)

    eventManager:RegisterForEvent(moduleName, EVENT_DUEL_STARTED, ChatAnnouncements.DuelStarted)

    eventManager:RegisterForEvent(moduleName .. "ArmoryBuildSave", EVENT_ARMORY_BUILD_SAVE_RESPONSE, function (eventId, result, buildIndex)
        notifyArmoryBuildResponse(eventId, result, buildIndex, true)
    end)
    eventManager:RegisterForEvent(moduleName .. "ArmoryBuildRestore", EVENT_ARMORY_BUILD_RESTORE_RESPONSE, function (eventId, result, buildIndex)
        notifyArmoryBuildResponse(eventId, result, buildIndex, false)
    end)

    -- Helper to create formatted name link for mail target
    local function CreateMailTargetLink(targetName)
        local nameLink
        if zo_strmatch(targetName, "@") == "@" then
            nameLink = ChatAnnouncements.CreateDisplayNameLink(targetName, targetName)
        else
            nameLink = ChatAnnouncements.CreateCharacterLink(targetName)
        end
        return ZO_SELECTED_TEXT:Colorize(nameLink)
    end

    -- Returns whether there is any item attached (required when hooking ZO_MailSend_Gamepad:IsMailValid)
    local function IsAnyItemAttached()
        for i = 1, MAIL_MAX_ATTACHED_ITEMS do
            local queuedFromBag = GetQueuedItemAttachmentInfo(i)
            if queuedFromBag ~= 0 then
                return true
            end
        end
        return false
    end

    -- Hook Gamepad mail validation
    --- @diagnostic disable-next-line: duplicate-set-field
    function ZO_MailSend_Gamepad:IsMailValid(...)
        local to = self.mailView:GetAddress()
        if (not to) or (to == "") then
            return false
        end

        S.g_mailTarget = CreateMailTargetLink(to)

        local subject = self.mailView:GetSubject()
        local hasSubject = subject and (subject ~= "")
        local body = self.mailView:GetBody()
        local hasBody = body and (body ~= "")
        return hasSubject or hasBody or (GetQueuedMoneyAttachment() > 0) or IsAnyItemAttached()
    end

    -- Hook MAIL_SEND.Send to capture mail target and validate COD
    if MAIL_SEND then
        MAIL_SEND.Send = function (self)
            windowManager:SetFocusByName("")

            -- Validate COD mode
            if not self.sendMoneyMode and GetQueuedCOD() == 0 then
                if ChatAnnouncements.SV.Notify.NotificationMailSendCA then
                    ChatOutput:Print(GetString(LUIE_STRING_CA_MAIL_ERROR_NO_COD_VALUE), true)
                end
                if ChatAnnouncements.SV.Notify.NotificationMailSendAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, GetString(LUIE_STRING_CA_MAIL_ERROR_NO_COD_VALUE))
                end
                PlaySound(SOUNDS.NEGATIVE_CLICK)
                return
            end

            -- Capture mail target before send
            local mailTarget = self.to:GetText()
            S.g_mailTarget = CreateMailTargetLink(mailTarget)

            -- Send the mail
            SendMail(self.to:GetText(), self.subject:GetText(), self.body:GetText())
        end
    end
end
