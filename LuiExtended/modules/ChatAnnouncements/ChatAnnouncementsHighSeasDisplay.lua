-- -----------------------------------------------------------------------------
-- High Seas of Tamriel EVENT_DISPLAY_ANNOUNCEMENT classification (text match only).
-- Each primary line has its own LUIE string; lookups are built from GetString for localization.
-- Shown only in zone 1570 (Voyage on the Abecean Sea). Matches outside that zone are swallowed.
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

local HIGH_SEAS_STRING_IDS =
{
    LUIE_STRING_CA_DISPLAY_HS_HIGH_SEAS,
    LUIE_STRING_CA_DISPLAY_HS_ENEMY_SHIP,
    LUIE_STRING_CA_DISPLAY_HS_ONE_HULL_BREACH,
    LUIE_STRING_CA_DISPLAY_HS_TWO_HULL_BREACHES,
    LUIE_STRING_CA_DISPLAY_HS_THREE_HULL_BREACHES,
    LUIE_STRING_CA_DISPLAY_HS_FOUR_HULL_BREACHES,
    LUIE_STRING_CA_DISPLAY_HS_TOO_MANY_HULL_BREACHES,
    LUIE_STRING_CA_DISPLAY_HS_UPPER_DECK_BREACHES,
    LUIE_STRING_CA_DISPLAY_HS_RESOLVE_BREAKING,
    LUIE_STRING_CA_DISPLAY_HS_DEFEAT_CHAMPIONS,
    LUIE_STRING_CA_DISPLAY_HS_CHAMPION_ON_DECK,
    LUIE_STRING_CA_DISPLAY_HS_CHAMPION_BELOW_DECKS,
    LUIE_STRING_CA_DISPLAY_HS_ENEMY_FLEES_STARBOARD,
    LUIE_STRING_CA_DISPLAY_HS_ENEMY_FLEES_PORTSIDE,
    LUIE_STRING_CA_DISPLAY_HS_ENEMY_DEFEATED_STARBOARD,
    LUIE_STRING_CA_DISPLAY_HS_ENEMY_DEFEATED_PORTSIDE,
    LUIE_STRING_CA_DISPLAY_HS_DIVING_CHAMBER,
    LUIE_STRING_CA_DISPLAY_HS_TOXIC_CLOUD,
    LUIE_STRING_CA_DISPLAY_HS_BUBBLE_POPPED,
    LUIE_STRING_CA_DISPLAY_HS_REEF_SHARK,
    LUIE_STRING_CA_DISPLAY_HS_GRETCH_FLEES,
    LUIE_STRING_CA_DISPLAY_HS_GRETCH_VENT,
}

-- GetRawZoneName: 1570 is "Voyage on the Abecean Sea". 555 is the overland Abecean Sea.
local HIGH_SEAS_ZONE_ID = 1570

local HIGH_SEAS_SUPPRESSED_SETTINGS =
{
    CA = false,
    CSA = false,
    Alert = false,
}

local highSeasLookup = BuildPrimaryTextLookup(HIGH_SEAS_STRING_IDS)

--- @param primaryText string|nil
--- @param secondaryText string|nil
--- @return CADisplayAnnouncementSection|nil settings
function ChatAnnouncements.ResolveHighSeasDisplayAnnouncement(primaryText, secondaryText)
    local display = ChatAnnouncements.SV.DisplayAnnouncements
    if not primaryText then
        return nil
    end
    if not highSeasLookup[primaryText] then
        return nil
    end

    local zoneId = GetZoneId(GetCurrentMapZoneIndex())
    if zoneId == HIGH_SEAS_ZONE_ID then
        return display.ZoneHighSeas
    end
    return HIGH_SEAS_SUPPRESSED_SETTINGS
end
