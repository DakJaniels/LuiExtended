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
function ChatAnnouncements.Hooks.RegisterAchievement(ctx)
    local alertHandlers = ctx.alertHandlers
    local csaHandlers = ctx.csaHandlers
    local csaCallbackHandlers = ctx.csaCallbackHandlers
    local eventManager = ctx.eventManager
    local moduleName = ctx.moduleName
    local FindCsaCallbackHandler = ctx.FindCsaCallbackHandler
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
            local icon = select(4, GetAchievementInfo(id))
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ACHIEVEMENT_AWARDED)
            messageParams:SetText(ChatAnnouncements.GetModuleMessageFormat("Achievement", "AchievementCompleteMsg"), zo_strformat(name))
            messageParams:SetIconData(icon, "EsoUI/Art/Achievements/achievements_iconBG.dds")
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        -- Bail out if this achievement comes from unwanted category
        if ChatAnnouncements.SV.Achievement.AchievementCategoryIgnore[topLevelIndex] then
            return true
        end

        if ChatAnnouncements.SV.Achievement.AchievementCompleteCA then
            local link = zo_strformat(GetAchievementLink(id, B.linkBrackets[ChatAnnouncements.SV.BracketOptionAchievement]))
            local catName = GetAchievementCategoryInfo(topLevelIndex)
            local subcatName = categoryIndex ~= nil and GetAchievementSubCategoryInfo(topLevelIndex, categoryIndex) or GetString(SI_JOURNAL_PROGRESS_CATEGORY_GENERAL)
            local _, _, _, icon = GetAchievementInfo(id)
            icon = ChatAnnouncements.SV.Achievement.AchievementIcon and ("|t16:16:" .. icon .. "|t ") or ""

            -- Build string parts without using string_format on pre-formatted strings
            local stringpart1 = ColorizeColors.AchievementColorize1:Colorize(
                B.bracket1[ChatAnnouncements.SV.Achievement.AchievementBracketOptions] ..
                ChatAnnouncements.GetModuleMessageFormat("Achievement", "AchievementCompleteMsg") ..
                B.bracket2[ChatAnnouncements.SV.Achievement.AchievementBracketOptions] .. " " ..
                icon .. link
            )

            local stringpart2 = ""
            if ChatAnnouncements.SV.Achievement.AchievementCompPercentage then
                stringpart2 = ChatAnnouncements.SV.Achievement.AchievementColorProgress and
                    ColorizeColors.AchievementColorize2:Colorize(" (") ..
                    "|c71DE73100%|r" ..
                    ColorizeColors.AchievementColorize2:Colorize(")") or
                    ColorizeColors.AchievementColorize2:Colorize(" (100%)")
            end

            local stringpart3 = ""
            if ChatAnnouncements.SV.Achievement.AchievementCategory then
                stringpart3 = ColorizeColors.AchievementColorize2:Colorize(
                    " " .. B.bracket1[ChatAnnouncements.SV.Achievement.AchievementCatBracketOptions] ..
                    catName ..
                    (ChatAnnouncements.SV.Achievement.AchievementSubcategory and (" - " .. subcatName) or "") ..
                    B.bracket2[ChatAnnouncements.SV.Achievement.AchievementCatBracketOptions]
                )
            end

            -- Concatenate final string without using string_format
            local finalString = stringpart1 .. stringpart2 .. stringpart3
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalString, type = "ACHIEVEMENT" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
        end

        -- Display Alert
        if ChatAnnouncements.SV.Achievement.AchievementCompleteAlert then
            local alertMessage = zo_strformat("<<1>>: <<2>>", ChatAnnouncements.GetModuleMessageFormat("Achievement", "AchievementCompleteMsg"), name)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, alertMessage)
        end

        -- Play sound if CSA is disabled
        if not ChatAnnouncements.SV.Achievement.AchievementCompleteCSA then
            PlaySound(SOUNDS.ACHIEVEMENT_AWARDED)
        end

        return true
    end
    ZO_PreHook(csaHandlers, EVENT_ACHIEVEMENT_AWARDED, AchievementAwardedHook)
end
