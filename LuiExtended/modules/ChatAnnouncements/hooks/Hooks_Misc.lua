-- -----------------------------------------------------------------------------
--  LuiExtended — Chat Announcements hook shared context (CSA / alerts)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

--- @param _ctx CAHookContext
function ChatAnnouncements.Hooks.RegisterMisc(_ctx)
    ChatAnnouncements.PlayerToPlayerHook()
end
