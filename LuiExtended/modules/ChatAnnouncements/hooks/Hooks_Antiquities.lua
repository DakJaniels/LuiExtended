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
function ChatAnnouncements.Hooks.RegisterAntiquities(ctx)
    local alertHandlers = ctx.alertHandlers
    local csaHandlers = ctx.csaHandlers
    local csaCallbackHandlers = ctx.csaCallbackHandlers
    local eventManager = ctx.eventManager
    local moduleName = ctx.moduleName
    local FindCsaCallbackHandler = ctx.FindCsaCallbackHandler
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
                antiquityLink = string_format("|c%s|H0:LINK_TYPE_LUIANTIQUITY:%s|h%s|h|r", linkColor, antiquityId, formattedName)
            else
                formattedName = ("[" .. antiquityName .. "]")
                antiquityLink = string_format("|c%s|H1:LINK_TYPE_LUIANTIQUITY:%s|h%s|h|r", linkColor, antiquityId, formattedName)
            end

            local formattedIcon = ChatAnnouncements.SV.Antiquities.AntiquityIcon and ("|t16:16:" .. antiquityIcon .. "|t ") or ""

            local messageP1 = ColorizeColors.AntiquityColorize:Colorize(string_format("%s%s%s %s", B.bracket1[ChatAnnouncements.SV.Antiquities.AntiquityPrefixBracket], ChatAnnouncements.GetModuleMessageFormat("Antiquities", "AntiquityPrefix"), B.bracket2[ChatAnnouncements.SV.Antiquities.AntiquityPrefixBracket], formattedIcon))
            local messageP2 = antiquityLink
            local messageP3 = ColorizeColors.AntiquityColorize:Colorize(" " .. ChatAnnouncements.GetModuleMessageFormat("Antiquities", "AntiquitySuffix"))
            local finalMessage = zo_strformat("<<1>><<2>><<3>>", messageP1, messageP2, messageP3)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = "ANTIQUITY" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
        end

        if ChatAnnouncements.SV.Antiquities.AntiquityAlert then
            local alertMessage = zo_strformat("<<1>>: <<2>> <<3>>", ChatAnnouncements.GetModuleMessageFormat("Antiquities", "AntiquityPrefix"), antiquityName, ChatAnnouncements.GetModuleMessageFormat("Antiquities", "AntiquitySuffix"))
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, alertMessage)
        end

        if ChatAnnouncements.SV.Antiquities.AntiquityCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
            local secondaryText = zo_strformat(SI_ANTIQUITY_LEAD_ACQUIRED_TEXT, antiquityData:GetColorizedName())
            messageParams:SetText(GetString(SI_ANTIQUITY_LEAD_ACQUIRED_TITLE), secondaryText)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ANTIQUITY_LEAD_ACQUIRED)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        return true
    end
    ZO_PreHook(csaHandlers, EVENT_ANTIQUITY_LEAD_ACQUIRED, AntiquityLeadAcquired)
end
