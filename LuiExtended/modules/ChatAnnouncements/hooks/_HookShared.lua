-- -----------------------------------------------------------------------------
--  LuiExtended — Chat Announcements hook shared context (CSA / alerts)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local Internal = ChatAnnouncements.Internal

ChatAnnouncements.Hooks = ChatAnnouncements.Hooks or {}

--- @class CAHookContext
--- @field alertHandlers table
--- @field csaHandlers table
--- @field csaCallbackHandlers table
--- @field eventManager table
--- @field moduleName string
--- @field SV CADefaults
--- @field FindCsaCallbackHandler fun(registrationName: string, callbackManager?: table): table|nil

--- @param csaCallbackHandlers table
--- @param registrationName string
--- @param callbackManager table
--- @return table|nil
function Internal.FindCsaCallbackHandler(csaCallbackHandlers, registrationName, callbackManager)
    for index = 1, #csaCallbackHandlers do
        local handler = csaCallbackHandlers[index]
        if handler.callbackRegistration == registrationName then
            if callbackManager == nil or handler.callbackManager == callbackManager then
                return handler
            end
        end
    end
end

--- @return boolean
function Internal.AnyExperienceLevelUpAnnouncementEnabled()
    local xp = ChatAnnouncements.SV.XP
    return xp.ExperienceLevelUpCA or xp.ExperienceLevelUpCSA or xp.ExperienceLevelUpAlert
end

--- @return boolean
function Internal.AnyVengeanceLoadoutAnnouncementEnabled()
    return Internal.AnyExperienceLevelUpAnnouncementEnabled()
end

--- @return boolean
function Internal.AnyDisplayGeneralAnnouncementEnabled()
    local general = ChatAnnouncements.SV.DisplayAnnouncements.General
    return general.CA or general.CSA or general.Alert
end

--- @param alertHandlers table
--- @param csaHandlers table
--- @param csaCallbackHandlers table
--- @param eventManager table
--- @param moduleName string
--- @return CAHookContext
function ChatAnnouncements.Hooks.BuildContext(alertHandlers, csaHandlers, csaCallbackHandlers, eventManager, moduleName)
    --- @type CAHookContext
    local ctx =
    {
        alertHandlers = alertHandlers,
        csaHandlers = csaHandlers,
        csaCallbackHandlers = csaCallbackHandlers,
        eventManager = eventManager,
        moduleName = moduleName,
        SV = ChatAnnouncements.SV,
        FindCsaCallbackHandler = function (registrationName, callbackManager)
            return Internal.FindCsaCallbackHandler(csaCallbackHandlers, registrationName, callbackManager)
        end,
    }
    return ctx
end

local REGISTER_ORDER =
{
    "RegisterInventory",
    "RegisterLorebooks",
    "RegisterNotify",
    "RegisterGroup",
    "RegisterGuild",
    "RegisterSocial",
    "RegisterSkills",
    "RegisterCollectibles",
    "RegisterQuests",
    "RegisterXP",
    "RegisterDisplayAnnouncements",
    "RegisterAchievement",
    "RegisterAntiquities",
    "RegisterMisc",
    "RegisterVengeance",
    "RegisterCsaCallbacks",
}

--- @param ctx CAHookContext
function ChatAnnouncements.Hooks.RegisterAll(ctx)
    for _, registerName in ipairs(REGISTER_ORDER) do
        local fn = ChatAnnouncements.Hooks[registerName]
        if fn then
            fn(ctx)
        end
    end
end
