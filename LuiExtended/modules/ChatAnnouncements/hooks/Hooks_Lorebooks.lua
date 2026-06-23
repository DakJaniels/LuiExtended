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
function ChatAnnouncements.Hooks.RegisterLorebooks(ctx)
    local alertHandlers = ctx.alertHandlers
    local csaHandlers = ctx.csaHandlers
    local csaCallbackHandlers = ctx.csaCallbackHandlers
    local eventManager = ctx.eventManager
    local moduleName = ctx.moduleName
    local FindCsaCallbackHandler = ctx.FindCsaCallbackHandler
    -- EVENT_LORE_BOOK_ALREADY_KNOWN (Alert Handler)
    -- Note: We just hide this alert because it is pointless pretty much (only ever seen in trigger from server lag)
    local function AlreadyKnowBookHook(bookTitle)
        return true
    end

    -- EVENT_LORE_BOOK_LEARNED (Alert Handler)
    local function LoreBookLearnedAlertHook(categoryIndex, collectionIndex, bookIndex, guildReputationIndex, isMaxRank)
        if guildReputationIndex == 0 or isMaxRank then
            -- We only want to fire this event if a player is not part of the guild or if they've reached max level in the guild.
            -- Otherwise, the _SKILL_EXPERIENCE version of this event will send a center screen message instead.
            local name, numCollections, categoryId = GetLoreCategoryInfo(categoryIndex)
            if name == "Crafting Motifs" then
                return
            end

            local collectionName, _, numKnownBooks, totalBooks, hidden = GetLoreCollectionInfo(categoryIndex, collectionIndex)

            if not hidden or ChatAnnouncements.SV.Lorebooks.LorebookShowHidden then
                local title, icon = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
                local bookName
                local bookLink
                if ChatAnnouncements.SV.BracketOptionLorebook == 1 then
                    bookName = string_format("%s", title)
                    bookLink = string_format("|H0:LINK_TYPE_LUIBOOK:%s:%s:%s|h%s|h", categoryIndex, collectionIndex, bookIndex, bookName)
                else
                    bookName = string_format("[%s]", title)
                    bookLink = string_format("|H1:LINK_TYPE_LUIBOOK:%s:%s:%s|h%s|h", categoryIndex, collectionIndex, bookIndex, bookName)
                end

                local stringPrefix
                local csaPrefix
                if categoryIndex == 1 then
                    -- Is a lore book
                    stringPrefix = ChatAnnouncements.GetModuleMessageFormat("Lorebooks", "LorebookPrefix1")
                    csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(SI_LORE_LIBRARY_ANNOUNCE_BOOK_LEARNED)
                else
                    -- Is a normal book
                    stringPrefix = ChatAnnouncements.GetModuleMessageFormat("Lorebooks", "LorebookPrefix2")
                    csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(LUIE_STRING_CA_LOREBOOK_BOOK)
                end

                -- Chat Announcement
                if ChatAnnouncements.SV.Lorebooks.LorebookCA then
                    local formattedIcon = ChatAnnouncements.SV.Lorebooks.LorebookIcon and ("|t16:16:" .. icon .. "|t ") or ""
                    local stringPart1
                    local stringPart2
                    if stringPrefix ~= "" then
                        stringPart1 = ColorizeColors.LorebookColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", B.bracket1[ChatAnnouncements.SV.Lorebooks.LorebookBracket], stringPrefix, B.bracket2[ChatAnnouncements.SV.Lorebooks.LorebookBracket]))
                    else
                        stringPart1 = ""
                    end
                    if ChatAnnouncements.SV.Lorebooks.LorebookCategory then
                        stringPart2 = collectionName ~= "" and ColorizeColors.LorebookColorize2:Colorize(zo_strformat(" <<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), collectionName)) or ColorizeColors.LorebookColorize2:Colorize(zo_strformat(" <<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), GetString(SI_WINDOW_TITLE_LORE_LIBRARY)))
                    else
                        stringPart2 = ""
                    end

                    local finalMessage = zo_strformat("<<1>><<2>><<3>><<4>>", stringPart1, formattedIcon, bookLink, stringPart2)
                    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = "COLLECTIBLE" }
                    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
                end

                -- Alert Announcement
                if ChatAnnouncements.SV.Lorebooks.LorebookAlert then
                    local text = collectionName ~= "" and zo_strformat("<<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), collectionName) or zo_strformat(" <<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), GetString(SI_WINDOW_TITLE_LORE_LIBRARY))
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat("<<1>> <<2>>", title, text))
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
    -- LORE CSA / ALERTS --------
    -----------------------------

    -- EVENT_LORE_BOOK_LEARNED_SKILL_EXPERIENCE (CSA Handler)
    local function LoreBookXPHook(categoryIndex, collectionIndex, bookIndex, guildReputationIndex, skillType, skillIndex, rank, previousXP, currentXP)
        if guildReputationIndex > 0 then
            local collectionName, _, numKnownBooks, totalBooks, hidden = GetLoreCollectionInfo(categoryIndex, collectionIndex)
            local title, icon = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
            local bookName
            local bookLink
            if ChatAnnouncements.SV.BracketOptionLorebook == 1 then
                bookName = string_format("%s", title)
                bookLink = string_format("|H0:LINK_TYPE_LUIBOOK:%s:%s:%s|h%s|h", categoryIndex, collectionIndex, bookIndex, bookName)
            else
                bookName = string_format("[%s]", title)
                bookLink = string_format("|H1:LINK_TYPE_LUIBOOK:%s:%s:%s|h%s|h", categoryIndex, collectionIndex, bookIndex, bookName)
            end

            local stringPrefix
            local csaPrefix
            if categoryIndex == 1 then
                -- Is a lore book
                stringPrefix = ChatAnnouncements.GetModuleMessageFormat("Lorebooks", "LorebookPrefix1")
                csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(SI_LORE_LIBRARY_ANNOUNCE_BOOK_LEARNED)
            else
                -- Is a normal book
                stringPrefix = ChatAnnouncements.GetModuleMessageFormat("Lorebooks", "LorebookPrefix2")
                csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(LUIE_STRING_CA_LOREBOOK_BOOK)
            end

            -- Chat Announcement
            if ChatAnnouncements.SV.Lorebooks.LorebookCA then
                local formattedIcon = ChatAnnouncements.SV.Lorebooks.LorebookIcon and ("|t16:16:" .. icon .. "|t ") or ""
                local stringPart1
                local stringPart2
                if stringPrefix ~= "" then
                    stringPart1 = ColorizeColors.LorebookColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", B.bracket1[ChatAnnouncements.SV.Lorebooks.LorebookBracket], stringPrefix, B.bracket2[ChatAnnouncements.SV.Lorebooks.LorebookBracket]))
                else
                    stringPart1 = ""
                end
                if ChatAnnouncements.SV.Lorebooks.LorebookCategory then
                    stringPart2 = collectionName ~= "" and ColorizeColors.LorebookColorize2:Colorize(zo_strformat(" <<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), collectionName)) or ColorizeColors.LorebookColorize2:Colorize(zo_strformat(" <<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), GetString(SI_WINDOW_TITLE_LORE_LIBRARY)))
                else
                    stringPart2 = ""
                end

                local finalMessage = zo_strformat("<<1>><<2>><<3>><<4>>", stringPart1, formattedIcon, bookLink, stringPart2)
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = "COLLECTIBLE" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
            end

            -- Alert Announcement
            if ChatAnnouncements.SV.Lorebooks.LorebookAlert then
                local text = collectionName ~= "" and zo_strformat("<<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), collectionName) or zo_strformat(" <<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), GetString(SI_WINDOW_TITLE_LORE_LIBRARY))
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat("<<1>> <<2>>", title, text))
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
                        I.ValidateProgressBarParams(barParams)
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
            local stringPrefix = ChatAnnouncements.GetModuleMessageFormat("Lorebooks", "LorebookCollectionPrefix")
            local csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(SI_LORE_LIBRARY_COLLECTION_COMPLETED_LARGE)
            if not hidden or ChatAnnouncements.SV.Lorebooks.LorebookShowHidden then
                if ChatAnnouncements.SV.Lorebooks.LorebookCollectionCA then
                    local formattedIcon
                    local stringPart1
                    local stringPart2
                    if stringPrefix ~= "" then
                        stringPart1 = ColorizeColors.LorebookColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", B.bracket1[ChatAnnouncements.SV.Lorebooks.LorebookBracket], stringPrefix, B.bracket2[ChatAnnouncements.SV.Lorebooks.LorebookBracket]))
                    else
                        stringPart1 = ""
                    end
                    if textureName ~= "" and textureName ~= nil then
                        formattedIcon = ChatAnnouncements.SV.Lorebooks.LorebookIcon and ("|t16:16:" .. textureName .. "|t ") or ""
                    end
                    if ChatAnnouncements.SV.Lorebooks.LorebookCategory then
                        stringPart2 = ColorizeColors.LorebookColorize2:Colorize(zo_strformat(SI_LORE_LIBRARY_COLLECTION_COMPLETED_SMALL, collectionName))
                    else
                        stringPart2 = ""
                    end

                    local finalMessage = zo_strformat("<<1>><<2>><<3>>", stringPart1, formattedIcon, stringPart2)
                    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = "COLLECTIBLE" }
                    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
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
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, text)
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
            local stringPrefix = ChatAnnouncements.GetModuleMessageFormat("Lorebooks", "LorebookCollectionPrefix")
            local csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(SI_LORE_LIBRARY_COLLECTION_COMPLETED_LARGE)
            if not hidden or ChatAnnouncements.SV.Lorebooks.LorebookShowHidden then
                if ChatAnnouncements.SV.Lorebooks.LorebookCollectionCA then
                    local formattedIcon
                    local stringPart1
                    local stringPart2
                    if stringPrefix ~= "" then
                        stringPart1 = ColorizeColors.LorebookColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", B.bracket1[ChatAnnouncements.SV.Lorebooks.LorebookBracket], stringPrefix, B.bracket2[ChatAnnouncements.SV.Lorebooks.LorebookBracket]))
                    else
                        stringPart1 = ""
                    end
                    if textureName ~= "" and textureName ~= nil then
                        formattedIcon = ChatAnnouncements.SV.Lorebooks.LorebookIcon and zo_strformat("<<1>> ", zo_iconFormat(textureName, 16, 16)) or ""
                    end
                    if ChatAnnouncements.SV.Lorebooks.LorebookCategory then
                        stringPart2 = ColorizeColors.LorebookColorize2:Colorize(zo_strformat(SI_LORE_LIBRARY_COLLECTION_COMPLETED_SMALL, collectionName))
                    else
                        stringPart2 = ""
                    end

                    local finalMessage = zo_strformat("<<1>><<2>><<3>>", stringPart1, formattedIcon, stringPart2)
                    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = "COLLECTIBLE" }
                    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
                end

                if ChatAnnouncements.SV.Lorebooks.LorebookCollectionCSA then
                    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.BOOK_COLLECTION_COMPLETED)
                    if not LUIE.SV.HideXPBar then
                        local barType = PLAYER_PROGRESS_BAR:GetBarType(PPB_CLASS_SKILL, skillType, skillIndex)
                        local rankStartXP, nextRankStartXP = GetSkillLineRankXPExtents(skillType, skillIndex, rank)
                        local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(barType, rank, previousXP - rankStartXP, currentXP - rankStartXP)
                        barParams:SetTriggeringEvent(EVENT_LORE_COLLECTION_COMPLETED_SKILL_EXPERIENCE)
                        I.ValidateProgressBarParams(barParams)
                        messageParams:SetBarParams(barParams)
                    end
                    messageParams:SetText(csaPrefix, zo_strformat(SI_LORE_LIBRARY_COLLECTION_COMPLETED_SMALL, collectionName))
                    messageParams:SetIconData(textureName, "EsoUI/Art/Achievements/achievements_iconBG.dds")
                    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_LORE_COLLECTION_COMPLETED_SKILL_EXPERIENCE)
                    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                end

                if ChatAnnouncements.SV.Lorebooks.LorebookCollectionAlert then
                    local text = zo_strformat(SI_LORE_LIBRARY_COLLECTION_COMPLETED_SMALL, collectionName)
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, text)
                end
                if not ChatAnnouncements.SV.Lorebooks.LorebookCSA then
                    PlaySound(SOUNDS.BOOK_COLLECTION_COMPLETED)
                end
            end
        end
        return true
    end

    ZO_PreHook(alertHandlers, EVENT_LORE_BOOK_ALREADY_KNOWN, AlreadyKnowBookHook)
    ZO_PreHook(alertHandlers, EVENT_LORE_BOOK_LEARNED, LoreBookLearnedAlertHook)
    ZO_PreHook(csaHandlers, EVENT_LORE_BOOK_LEARNED_SKILL_EXPERIENCE, LoreBookXPHook)
    ZO_PreHook(csaHandlers, EVENT_LORE_COLLECTION_COMPLETED, LoreCollectionHook)
    ZO_PreHook(csaHandlers, EVENT_LORE_COLLECTION_COMPLETED_SKILL_EXPERIENCE, LoreCollectionXPHook)
end
