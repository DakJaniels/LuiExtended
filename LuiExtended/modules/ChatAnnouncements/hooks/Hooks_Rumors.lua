-- -----------------------------------------------------------------------------
--  LuiExtended - Chat Announcements rumor started, completed, and start-failed
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local ChatOutput = LUIE.ChatOutput

local function GetRumorAnnouncementData(rumorId)
    if not RUMOR_MANAGER then
        return nil
    end
    local rumorData = RUMOR_MANAGER:GetRumorData(rumorId)
    if not rumorData then
        rumorData = RUMOR_MANAGER:GetOrCreateRumorData(rumorId)
    end
    return rumorData
end

local function DisplayRumorCenterScreenAnnouncement(titleStringId, centerScreenAnnounceType, soundId, rumorId, chatEnabled, centerScreenEnabled, alertEnabled)
    local rumorData = GetRumorAnnouncementData(rumorId)
    if not rumorData then
        return true
    end

    local rumorTitle = GetString(titleStringId)
    local formattedDisplayName = rumorData:GetFormattedDisplayName()

    if centerScreenEnabled then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, soundId)
        messageParams:SetText(rumorTitle, formattedDisplayName)
        messageParams:SetCSAType(centerScreenAnnounceType)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    elseif chatEnabled or alertEnabled then
        PlaySound(soundId)
    end

    local combinedMessage = zo_strformat("<<1>>: <<2>>", rumorTitle, formattedDisplayName)
    if chatEnabled then
        ChatOutput:Print(combinedMessage)
    end
    if alertEnabled then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, combinedMessage)
    end

    return true
end

--- @param ctx CAHookContext
function ChatAnnouncements.Hooks.RegisterRumors(ctx)
    local alertHandlers = ctx.alertHandlers
    local csaHandlers = ctx.csaHandlers

    -- EVENT_RUMOR_STARTED (CSA Handler)
    -- EsoUI/EsoUI/Ingame/CenterScreenAnnounce/CenterScreenAnnounceHandlers.lua
    local function RumorStarted(rumorId)
        local rumorSettings = ChatAnnouncements.SV.Rumors
        return DisplayRumorCenterScreenAnnouncement(
            SI_RUMOR_STARTED_ANOUNCEMENT_TITLE,
            CENTER_SCREEN_ANNOUNCE_TYPE_RUMOR_ADDED,
            SOUNDS.RUMOR_STARTED,
            rumorId,
            rumorSettings.RumorStartedCA,
            rumorSettings.RumorStartedCSA,
            rumorSettings.RumorStartedAlert
        )
    end

    -- EVENT_RUMOR_COMPLETED (CSA Handler)
    local function RumorCompleted(rumorId)
        local rumorSettings = ChatAnnouncements.SV.Rumors
        return DisplayRumorCenterScreenAnnouncement(
            SI_RUMOR_COMPLETED_ANOUNCEMENT_TITLE,
            CENTER_SCREEN_ANNOUNCE_TYPE_RUMOR_COMPLETED,
            SOUNDS.RUMOR_COMPLETED,
            rumorId,
            rumorSettings.RumorCompleteCA,
            rumorSettings.RumorCompleteCSA,
            rumorSettings.RumorCompleteAlert
        )
    end

    -- EVENT_RUMOR_START_FAILED (Alert Handler)
    -- EsoUI/EsoUI/Ingame/AlertText/AlertHandlers.lua
    local function RumorStartFailed(rumorId, reason)
        local rumorSettings = ChatAnnouncements.SV.Rumors
        local failMessage = GetString("SI_STARTRUMORFAILREASON", reason)
        if rumorSettings.RumorStartFailedAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.GENERAL_ALERT_ERROR, failMessage)
        elseif rumorSettings.RumorStartFailedCA then
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        end
        if rumorSettings.RumorStartFailedCA then
            ChatOutput:Print(failMessage)
        end
        return true
    end

    ZO_PreHook(csaHandlers, EVENT_RUMOR_STARTED, RumorStarted)
    ZO_PreHook(csaHandlers, EVENT_RUMOR_COMPLETED, RumorCompleted)
    ZO_PreHook(alertHandlers, EVENT_RUMOR_START_FAILED, RumorStartFailed)
end
