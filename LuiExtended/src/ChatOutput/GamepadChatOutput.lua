-- -----------------------------------------------------------------------------
--  LuiExtended — Gamepad / console chat log sync and link-click guards
--  Distributed under The MIT License (MIT) (see LICENSE file)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class LUIE_ChatOutput
local LUIE_ChatOutput = LUIE.ChatOutputClass
local ChatOutput = LUIE.ChatOutput

local linkCallbacksRegistered = false

--- @param displayMessage string
--- @param rawMessageText string
function LUIE_ChatOutput:AddDeliveredLineToGamepadChatLog(displayMessage, rawMessageText)
    if ZO_ChatSystem_ShouldUseKeyboardChatSystem() or not CHAT_MENU_GAMEPAD then
        return
    end
    CHAT_MENU_GAMEPAD:AddMessage(displayMessage, CHAT_CATEGORY_SYSTEM, nil, nil, rawMessageText, nil, nil)
end

--- @param rawLink string
--- @param mouseButton integer
--- @param linkText string
--- @param linkStyle string
--- @param linkType string
--- @return boolean handled
function LUIE_ChatOutput:OnGamepadChatLink(rawLink, mouseButton, linkText, linkStyle, linkType)
    if ZO_ChatSystem_ShouldUseKeyboardChatSystem() or mouseButton ~= MOUSE_BUTTON_INDEX_LEFT then
        return false
    end
    -- Same filter as CHAT_MENU_GAMEPAD AddMessage + ZO_ExtractLinksFromText(..., ZO_VALID_LINK_TYPES_CHAT).
    -- Other types still run earlier LINK_HANDLER callbacks (e.g. LUIBOOK); this only blocks LINK_NOT_HANDLED.
    if not ZO_VALID_LINK_TYPES_CHAT[linkType] then
        return true
    end
    return false
end

function LUIE_ChatOutput:InitializeGamepadChatOutput()
    if linkCallbacksRegistered then
        return
    end
    linkCallbacksRegistered = true

    local function OnGamepadChatLink(...)
        return ChatOutput:OnGamepadChatLink(...)
    end
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, OnGamepadChatLink)
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, OnGamepadChatLink)
end
