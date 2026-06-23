-- -----------------------------------------------------------------------------
--  LuiExtended — Chat Announcements hooks: Cyrodiil Vengeance loadout CSA
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local Internal = ChatAnnouncements.Internal

--- @param ctx CAHookContext
function ChatAnnouncements.Hooks.RegisterVengeance(ctx)
    if not ZO_VENGEANCE_MANAGER then
        return
    end

    local eventManager = ctx.eventManager
    local moduleName = ctx.moduleName

    local handler = ctx.FindCsaCallbackHandler("VengeanceLoadoutRoleChanged", ZO_VENGEANCE_MANAGER)
    if not handler then
        return
    end

    local function VengeanceLoadoutRoleChangedHook()
        if not Internal.AnyVengeanceLoadoutAnnouncementEnabled() then
            return
        end
        local equippedLoadoutData = ZO_VENGEANCE_MANAGER:GetEquippedLoadoutData()
        if not equippedLoadoutData then
            return true
        end
        local primaryText = zo_strformat(SI_CAMPAIGN_VENGEANCE_LOADOUT_EQUIP_ANNOUNCEMENT, equippedLoadoutData:GetName())
        local secondaryText = GetString(SI_CAMPAIGN_VENGEANCE_LOADOUT_ANNOUNCEMENT_DECRIPTION)
        local formattedMessage = zo_strformat("<<1>>: <<2>>", primaryText, secondaryText)

        if ChatAnnouncements.SV.XP.ExperienceLevelUpCA then
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedMessage, type = "EXPERIENCE" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
        end

        if ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.VENGEANCE_LOADOUT_EQUIPPED_ANNOUNCEMENT)
            messageParams:SetText(primaryText, secondaryText)
            if CENTER_SCREEN_ANNOUNCE_TYPE_VENGEANCE_LOADOUT_EQUIPPED then
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_VENGEANCE_LOADOUT_EQUIPPED)
            end
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        elseif SOUNDS.VENGEANCE_LOADOUT_EQUIPPED_ANNOUNCEMENT then
            PlaySound(SOUNDS.VENGEANCE_LOADOUT_EQUIPPED_ANNOUNCEMENT)
        end

        if ChatAnnouncements.SV.XP.ExperienceLevelUpAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, formattedMessage)
        end

        return true
    end

    ZO_PreHook(handler, "callbackFunction", VengeanceLoadoutRoleChangedHook)
end
