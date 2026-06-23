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
function ChatAnnouncements.Hooks.RegisterSocial(ctx)
    local alertHandlers = ctx.alertHandlers
    local csaHandlers = ctx.csaHandlers
    local csaCallbackHandlers = ctx.csaCallbackHandlers
    local eventManager = ctx.eventManager
    local moduleName = ctx.moduleName
    local FindCsaCallbackHandler = ctx.FindCsaCallbackHandler
    local function PledgeOfMaraResultAlert(result, characterName, displayName)
        -- Note: We replace everything here and move it all into the CSA handler event
        return true
    end

    ZO_PreHook(alertHandlers, EVENT_PLEDGE_OF_MARA_RESULT, PledgeOfMaraResultAlert)
    -- EVENT_PLEDGE_OF_MARA_RESULT (CSA Handler)
    local function PledgeOfMaraHook(result, characterName, displayName)
        -- Display CA (Success or Failure)
        if ChatAnnouncements.SV.Social.PledgeOfMaraCA then
            local finalName = ChatAnnouncements.ResolveNameLink(characterName, displayName)
            ChatOutput:Print(zo_strformat(GetString("LUIE_STRING_CA_MARA_PLEDGEOFMARARESULT", result), finalName), true)
        end

        if ChatAnnouncements.SV.Social.PledgeOfMaraAlert or ChatAnnouncements.SV.Social.PledgeOfMaraCSA then
            local finalAlertName = ChatAnnouncements.ResolveNameNoLink(characterName, displayName)

            -- Display CSA (Success Only)
            if ChatAnnouncements.SV.Social.PledgeOfMaraCSA then
                if result == PLEDGE_OF_MARA_RESULT_PLEDGED then
                    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
                    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_PLEDGE_OF_MARA_RESULT)
                    messageParams:SetText(GetString(SI_RITUAL_OF_MARA_COMPLETION_ANNOUNCE_LARGE), zo_strformat(LUIE_STRING_CA_MARA_PLEDGEOFMARARESULT3, finalAlertName))
                    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                end
            end

            -- Alert (Success or Failure)
            if ChatAnnouncements.SV.Social.PledgeOfMaraAlert then
                -- If the menu setting to only display Alert on Failure state is toggled, then do not display an Alert on successful Mara Event
                if result == PLEDGE_OF_MARA_RESULT_PLEDGED and not ChatAnnouncements.SV.Social.PledgeOfMaraAlertOnlyFail then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(LUIE_STRING_CA_MARA_PLEDGEOFMARARESULT3, finalAlertName))
                elseif result ~= PLEDGE_OF_MARA_RESULT_PLEDGED and result ~= PLEDGE_OF_MARA_RESULT_BEGIN_PLEDGE then
                    ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, zo_strformat(GetString("LUIE_STRING_CA_MARA_PLEDGEOFMARARESULT", result), finalAlertName))
                end
            end
        end

        -- Play alert sound if error result
        if result ~= PLEDGE_OF_MARA_RESULT_PLEDGED and result ~= PLEDGE_OF_MARA_RESULT_BEGIN_PLEDGE then
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        end

        return true
    end
    ZO_PreHook(csaHandlers, EVENT_PLEDGE_OF_MARA_RESULT, PledgeOfMaraHook)
    eventManager:RegisterForEvent(moduleName, EVENT_PLEDGE_OF_MARA_OFFER, ChatAnnouncements.MaraOffer)
end
