-- -----------------------------------------------------------------------------
-- Dynamic Encounter EVENT_DISPLAY_ANNOUNCEMENT classification (text match only).
-- Each primary line has its own LUIE string; lookups are built from GetString for localization.
-- -----------------------------------------------------------------------------

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local function BuildPrimaryTextLookup(stringIds)
    local lookup = {}
    for i = 1, #stringIds do
        lookup[GetString(stringIds[i])] = true
    end
    return lookup
end

local VAMPIRE_HUNT_STRING_IDS =
{
    LUIE_STRING_CA_DISPLAY_DE_VAMPIRE_HUNT_UNDERWAY,
    LUIE_STRING_CA_DISPLAY_DE_VAMPIRE_HUNT_FAILED,
    LUIE_STRING_CA_DISPLAY_DE_ORILO_DEFEATED,
    LUIE_STRING_CA_DISPLAY_DE_KILL_ORILO,
    LUIE_STRING_CA_DISPLAY_DE_NIMINEH_HEALTH_LOW,
    LUIE_STRING_CA_DISPLAY_DE_NIMINEH_DAISY_UNDER_ATTACK,
    LUIE_STRING_CA_DISPLAY_DE_FOLLOW_NIMINEH_DAISY,
    LUIE_STRING_CA_DISPLAY_DE_DEFEND_NIMINEH_TRACK_ORILO,
    LUIE_STRING_CA_DISPLAY_DE_PROTECT_NIMINEH_DAISY,
    LUIE_STRING_CA_DISPLAY_DE_KILL_THE_VAMPIRES,
    LUIE_STRING_CA_DISPLAY_DE_DESTROY_THE_STONES,
    LUIE_STRING_CA_DISPLAY_DE_DEFEAT_THE_VAMPIRES,
    LUIE_STRING_CA_DISPLAY_DE_FIGHT_OFF_VAMPIRE_AMBUSH,
    LUIE_STRING_CA_DISPLAY_DE_COLLECT_STENDARRS_GIFTS,
    LUIE_STRING_CA_DISPLAY_DE_NIMINEH_DIES_FAIL,
}

local FLOWERVINE_FARM_STRING_IDS =
{
    LUIE_STRING_CA_DISPLAY_DE_FLOWERVINE_UNDERWAY,
    LUIE_STRING_CA_DISPLAY_DE_SAVED_THE_FARM,
    LUIE_STRING_CA_DISPLAY_DE_FAILED_SAVE_FARM,
    LUIE_STRING_CA_DISPLAY_DE_KILLED_CARTEL,
    LUIE_STRING_CA_DISPLAY_DE_TWO_MINUTES_LEFT,
    LUIE_STRING_CA_DISPLAY_DE_MONSTERS_DEFEATED,
    LUIE_STRING_CA_DISPLAY_DE_ELIMINATE_BANDIT_REINFORCEMENTS,
    LUIE_STRING_CA_DISPLAY_DE_WATER_BUCKETS_HORSES,
    LUIE_STRING_CA_DISPLAY_DE_LEAD_HORSES_CORRAL,
    LUIE_STRING_CA_DISPLAY_DE_EXTINGUISH_ALL_FIRES,
    LUIE_STRING_CA_DISPLAY_DE_DEFEAT_THE_BANDITS,
}

local BILSA_DELIVERY_STRING_IDS =
{
    LUIE_STRING_CA_DISPLAY_DE_BILSA_UNDERWAY,
    LUIE_STRING_CA_DISPLAY_DE_BILSA_FAILED,
    LUIE_STRING_CA_DISPLAY_DE_BILSA_SUCCESS,
    LUIE_STRING_CA_DISPLAY_DE_BILSA_HEALTH_LOW,
    LUIE_STRING_CA_DISPLAY_DE_GATHER_VIPER_EEL_HERBS,
    LUIE_STRING_CA_DISPLAY_DE_DEFEND_BILSA_WEREWOLF,
    LUIE_STRING_CA_DISPLAY_DE_ACCOMPANY_BILSA_BRAYLIS,
    LUIE_STRING_CA_DISPLAY_DE_PROTECT_BILSA_BRAYLIS,
    LUIE_STRING_CA_DISPLAY_DE_ESCORT_BILSA_BRAYLIS,
    LUIE_STRING_CA_DISPLAY_DE_DELIVERED_FETID_HERBS,
    LUIE_STRING_CA_DISPLAY_DE_DELIVERED_VIPER_EELS,
}

local MISC_STRING_IDS =
{
    LUIE_STRING_CA_DISPLAY_DE_EVENT_FAILED,
    LUIE_STRING_CA_DISPLAY_DE_EVENT_STARTED,
    LUIE_STRING_CA_DISPLAY_DE_ALREADY_AIDED_HOLGUNN,
    LUIE_STRING_CA_DISPLAY_DE_HELPED_PREVIOUS_ADVENTURE,
}

local vampireHuntLookup = BuildPrimaryTextLookup(VAMPIRE_HUNT_STRING_IDS)
local flowervineFarmLookup = BuildPrimaryTextLookup(FLOWERVINE_FARM_STRING_IDS)
local bilsaDeliveryLookup = BuildPrimaryTextLookup(BILSA_DELIVERY_STRING_IDS)
local miscLookup = BuildPrimaryTextLookup(MISC_STRING_IDS)

--- @param primaryText string|nil
--- @param secondaryText string|nil
--- @return CADisplayAnnouncementSection|nil settings
function ChatAnnouncements.ResolveDynamicEncounterDisplayAnnouncement(primaryText, secondaryText)
    local display = ChatAnnouncements.SV.DisplayAnnouncements
    if not primaryText and not secondaryText then
        return nil
    end

    if not primaryText then
        return nil
    end

    if vampireHuntLookup[primaryText] then
        return display.ZoneDynamicEncounterVampireHunt
    end
    if flowervineFarmLookup[primaryText] then
        return display.ZoneDynamicEncounterFlowervineFarm
    end
    if bilsaDeliveryLookup[primaryText] then
        return display.ZoneDynamicEncounterBilsaDelivery
    end
    if miscLookup[primaryText] then
        return display.ZoneDynamicEncounterMisc
    end
    return nil
end
