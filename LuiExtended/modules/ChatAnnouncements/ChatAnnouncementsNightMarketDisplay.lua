-- -----------------------------------------------------------------------------
-- Night Market EVENT_DISPLAY_ANNOUNCEMENT classification (text match only, not zone 1559).
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

local DARING_RACE_STRING_IDS =
{
    LUIE_STRING_CA_DISPLAY_DARING_RACE_TEMPEST_EARNED,
    LUIE_STRING_CA_DISPLAY_DARING_RACE_VOID_TEARS,
    LUIE_STRING_CA_DISPLAY_DARING_RACE_VOID_COLLAPSE_COMPLETE,
    LUIE_STRING_CA_DISPLAY_DARING_RACE_RAPID_EXTERMINATION_COMPLETE,
    LUIE_STRING_CA_DISPLAY_DARING_RACE_UNSTABLE_CREATIA_COMPLETE,
    LUIE_STRING_CA_DISPLAY_DARING_RACE_SPIDER_NESTS,
    LUIE_STRING_CA_DISPLAY_DARING_RACE_VOID_ESCAPE,
}

local BOULDER_DASH_STRING_IDS =
{
    LUIE_STRING_CA_DISPLAY_BOULDER_DASH_EMERGE_10,
    LUIE_STRING_CA_DISPLAY_BOULDER_DASH_BEGINS,
    LUIE_STRING_CA_DISPLAY_BOULDER_DASH_COMPLETE,
    LUIE_STRING_CA_DISPLAY_BOULDER_DASH_BASH_EARNED,
}

local ARACHNID_STRING_IDS =
{
    LUIE_STRING_CA_DISPLAY_ARACHNID_INVADE_10,
    LUIE_STRING_CA_DISPLAY_ARACHNID_INVASION_BEGINS,
    LUIE_STRING_CA_DISPLAY_ARACHNID_DEFENSE_COMPLETE,
    LUIE_STRING_CA_DISPLAY_ARACHNID_COBWEBS_CLOSE,
    LUIE_STRING_CA_DISPLAY_ARACHNID_DRYLANDS_CLOSE,
    LUIE_STRING_CA_DISPLAY_ARACHNID_ECLIPSE_CLOSE,
}

local GUIDING_LIGHT_STRING_IDS =
{
    LUIE_STRING_CA_DISPLAY_GUIDING_LIGHT_SHINES_10,
    LUIE_STRING_CA_DISPLAY_GUIDING_LIGHT_BEGINS,
    LUIE_STRING_CA_DISPLAY_GUIDING_LIGHT_COMPLETE,
}

local REWARDS_EARNED_STRING_IDS =
{
    LUIE_STRING_CA_DISPLAY_NM_REWARD_GOLDEN_SLEIGHT_EARNED,
    LUIE_STRING_CA_DISPLAY_NM_REWARD_FLAME_AURA_EARNED,
    LUIE_STRING_CA_DISPLAY_NM_REWARD_MAGICAL_MULTITUDES_EARNED,
    LUIE_STRING_CA_DISPLAY_NM_REWARD_ARACS_SACRIFICE_EARNED,
    LUIE_STRING_CA_DISPLAY_NM_REWARD_SWIFT_GALE_EARNED,
    LUIE_STRING_CA_DISPLAY_NM_REWARD_TRANSFUSION_EARNED,
    LUIE_STRING_CA_DISPLAY_NM_REWARD_EXSANGUINATE_EARNED,
    LUIE_STRING_CA_DISPLAY_NM_REWARD_FRENZIED_ZEAL_EARNED,
    LUIE_STRING_CA_DISPLAY_NM_REWARD_REBIRTH_EARNED,
    LUIE_STRING_CA_DISPLAY_NM_REWARD_AGONIZING_TETHER_EARNED,
    LUIE_STRING_CA_DISPLAY_NM_REWARD_BOUNTIFUL_RESOURCES_EARNED,
    LUIE_STRING_CA_DISPLAY_NM_REWARD_SAND_SWIPE_EARNED,
    LUIE_STRING_CA_DISPLAY_NM_REWARD_GOLDEN_SPURS_EARNED,
    LUIE_STRING_CA_DISPLAY_NM_REWARD_HEALTHY_BARGAIN_EARNED,
    LUIE_STRING_CA_DISPLAY_NM_REWARD_VALUED_MARK_EARNED,
}

local SCAVENGING_MAW_STRING_IDS =
{
    LUIE_STRING_CA_DISPLAY_SCAVENGING_MAW_LURKS,
}

local ZONE_HUNT_STRING_IDS =
{
    LUIE_STRING_CA_DISPLAY_NM_SCATTER_SWARM,
    LUIE_STRING_CA_DISPLAY_NM_CLEAR_DREGS,
    LUIE_STRING_CA_DISPLAY_NM_DEFEAT_HORDEMOTHER,
    LUIE_STRING_CA_DISPLAY_NM_ATTUNE_PYLONS,
    LUIE_STRING_CA_DISPLAY_NM_DEFEND_PYLONS,
    LUIE_STRING_CA_DISPLAY_NM_DEFEAT_LEVINDA_ZEPHYRA,
    LUIE_STRING_CA_DISPLAY_NM_STOP_RITUAL,
    LUIE_STRING_CA_DISPLAY_NM_DESTROY_AGONYMIUM,
    LUIE_STRING_CA_DISPLAY_NM_DEFEAT_SPIRAL_DESCENDER,
    LUIE_STRING_CA_DISPLAY_NM_OPULENT_ENRAGED,
    LUIE_STRING_CA_DISPLAY_NM_WRIST_CUFF_CRAFTED,
    LUIE_STRING_CA_DISPLAY_NM_WRIST_CUFF_UPGRADED,
}

local ESSENCE_STRING_IDS =
{
    LUIE_STRING_CA_DISPLAY_NM_ESSENCE_WEB_EATER_UNSTABLE,
    LUIE_STRING_CA_DISPLAY_NM_ESSENCE_ARID_VARLET_UNSTABLE,
    LUIE_STRING_CA_DISPLAY_NM_ESSENCE_KNIGHTSHADE_UNSTABLE,
    LUIE_STRING_CA_DISPLAY_NM_ESSENCE_WEB_EATER_DRYLANDS,
    LUIE_STRING_CA_DISPLAY_NM_ESSENCE_WEB_EATER_ECLIPSE,
    LUIE_STRING_CA_DISPLAY_NM_ESSENCE_ARID_VARLET_COBWEBS,
    LUIE_STRING_CA_DISPLAY_NM_ESSENCE_ARID_VARLET_ECLIPSE,
    LUIE_STRING_CA_DISPLAY_NM_ESSENCE_KNIGHTSHADE_COBWEBS,
    LUIE_STRING_CA_DISPLAY_NM_ESSENCE_KNIGHTSHADE_DRYLANDS,
    LUIE_STRING_CA_DISPLAY_NM_AFFINITY_COBWEBS,
    LUIE_STRING_CA_DISPLAY_NM_AFFINITY_DRYLANDS,
    LUIE_STRING_CA_DISPLAY_NM_AFFINITY_ECLIPSE,
}

local MISC_STRING_IDS =
{
    LUIE_STRING_CA_DISPLAY_NM_FACTION_POINTS,
    LUIE_STRING_CA_DISPLAY_NM_SHORT_TERM_BUFFS,
}

local daringRaceLookup = BuildPrimaryTextLookup(DARING_RACE_STRING_IDS)
local boulderDashLookup = BuildPrimaryTextLookup(BOULDER_DASH_STRING_IDS)
local arachnidLookup = BuildPrimaryTextLookup(ARACHNID_STRING_IDS)
local guidingLightLookup = BuildPrimaryTextLookup(GUIDING_LIGHT_STRING_IDS)
local rewardsLookup = BuildPrimaryTextLookup(REWARDS_EARNED_STRING_IDS)
local scavengingMawLookup = BuildPrimaryTextLookup(SCAVENGING_MAW_STRING_IDS)
local zoneHuntLookup = BuildPrimaryTextLookup(ZONE_HUNT_STRING_IDS)
local essenceLookup = BuildPrimaryTextLookup(ESSENCE_STRING_IDS)
local miscLookup = BuildPrimaryTextLookup(MISC_STRING_IDS)

local arachnidRepelledSecondary = GetString(LUIE_STRING_CA_DISPLAY_ARACHNID_INVASION_REPELLED)
local scavengingMawPrefix = GetString(LUIE_STRING_CA_DISPLAY_SCAVENGING_MAW_PREFIX)

--- @param primaryText string|nil
--- @param secondaryText string|nil
--- @return CADisplayAnnouncementSection|nil settings
function ChatAnnouncements.ResolveNightMarketDisplayAnnouncement(primaryText, secondaryText)
    local display = ChatAnnouncements.SV.DisplayAnnouncements
    if not primaryText and not secondaryText then
        return nil
    end

    if primaryText and daringRaceLookup[primaryText] then
        return display.ZoneNightMarket
    end
    if primaryText and boulderDashLookup[primaryText] then
        return display.ZoneNightMarketBoulderDash
    end
    if (primaryText and arachnidLookup[primaryText]) or secondaryText == arachnidRepelledSecondary then
        return display.ZoneNightMarketArachnid
    end
    if primaryText and guidingLightLookup[primaryText] then
        return display.ZoneNightMarketGuidingLight
    end
    if primaryText and rewardsLookup[primaryText] then
        return display.ZoneNightMarketRewards
    end
    if primaryText then
        if scavengingMawLookup[primaryText] then
            return display.ZoneNightMarketScavengingMaw
        end
        if zo_strfind(primaryText, scavengingMawPrefix, 1, true) ~= nil then
            return display.ZoneNightMarketScavengingMaw
        end
        if zoneHuntLookup[primaryText] then
            return display.ZoneNightMarketZoneHunt
        end
        if essenceLookup[primaryText] then
            return display.ZoneNightMarketEssence
        end
        if miscLookup[primaryText] then
            return display.ZoneNightMarketMisc
        end
    end
    return nil
end
