-- -----------------------------------------------------------------------------
-- Pyre Lord EVENT_DISPLAY_ANNOUNCEMENT classification (text match only).
-- Each primary line has its own LUIE string; lookups are built from GetString for localization.
-- -----------------------------------------------------------------------------

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local function BuildPrimaryTextLookup(stringIds)
    local lookup = {}
    for index = 1, #stringIds do
        lookup[GetString(stringIds[index])] = true
    end
    return lookup
end

local PYRE_LORD_STRING_IDS =
{
    LUIE_STRING_CA_DISPLAY_PL_ALIGNS_COVENANT,
    LUIE_STRING_CA_DISPLAY_PL_ALIGNS_PACT,
    LUIE_STRING_CA_DISPLAY_PL_ALIGNS_DOMINION,
    LUIE_STRING_CA_DISPLAY_PL_STIRS,
    LUIE_STRING_CA_DISPLAY_PL_AWAKENS,
    LUIE_STRING_CA_DISPLAY_PL_VANISHES,
    LUIE_STRING_CA_DISPLAY_PL_VANQUISHED,
    LUIE_STRING_CA_DISPLAY_PL_SLUMBER,
    LUIE_STRING_CA_DISPLAY_PL_ENTREAT,
}

local pyreLordLookup = BuildPrimaryTextLookup(PYRE_LORD_STRING_IDS)

--- @param primaryText string|nil
--- @param secondaryText string|nil
--- @return CADisplayAnnouncementSection|nil settings
function ChatAnnouncements.ResolvePyreLordDisplayAnnouncement(primaryText, secondaryText)
    if not primaryText then
        return nil
    end
    if not pyreLordLookup[primaryText] then
        return nil
    end
    return ChatAnnouncements.SV.DisplayAnnouncements.ZonePyreLord
end
