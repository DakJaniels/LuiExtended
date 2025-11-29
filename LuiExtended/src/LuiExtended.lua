-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- **LuiExtended** namespace
---
--- @class (partial) LuiExtended
--- @field __index LuiExtended
--- @field Combat LUIE.CombatInfo
--- @field SpellCastBuffs LUIE.SpellCastBuffs
--- @field name string The addon name
--- @field log_to_chat boolean Whether to output logs to chat
--- @field logger LibDebugLogger|NOP The logger instance
--- @field author string The addon author
--- @field version string The addon version
--- @field SVName string SavedVariables name
--- @field SVVer number SavedVariables version
--- @field Defaults LUIE_Defaults_SV Default settings
--- @field SV LUIE_Defaults_SV Current saved variables
--- @field UI LUIE.UI
LUIE = {}
LUIE.__index = LUIE
-- -----------------------------------------------------------------------------
--- @class (partial) LuiExtended
local LUIE = LUIE
-- -----------------------------------------------------------------------------
LUIE.tag = "LUIE"
LUIE.name = "LuiExtended"
LUIE.version = "7.1.3.4"
LUIE.author = "ArtOfShred, DakJaniels, psypanda, Saenic & SpellBuilder"
LUIE.website = "https://www.esoui.com/downloads/info818-LuiExtended.html"
LUIE.github = "https://github.com/DakJaniels/LuiExtended"
LUIE.feedback = "https://github.com/DakJaniels/LuiExtended/issues"
LUIE.translation = "https://github.com/DakJaniels/LuiExtended/tree/translations"
LUIE.donation = "https://paypal.me/dakjaniels"
-- -----------------------------------------------------------------------------
if not IsConsoleUI() then
    LUIE.LAM = LibAddonMenu2
end
-- -----------------------------------------------------------------------------
-- Saved variables options
--- @diagnostic disable-next-line: missing-fields
LUIE.SV = {}
LUIE.SV.Migrations = {}
LUIE.SVVer = nil
if IsConsoleUI() then
    LUIE.SVVer = 3
else
    LUIE.SVVer = 2
end
LUIE.SVName = "LUIESV"
-- -----------------------------------------------------------------------------
do
    --- @type ZO_CallbackObject
    local callbackObject = ZO_CallbackObject:New()

    function LUIE:FireCallbacks(...)
        return callbackObject:FireCallbacks(...)
    end

    function LUIE:RegisterCallback(...)
        return callbackObject:RegisterCallback(...)
    end

    function LUIE:UnregisterCallback(...)
        return callbackObject:UnregisterCallback(...)
    end
end
-- -----------------------------------------------------------------------------
-- Components
LUIE.Components = {}
-- -----------------------------------------------------------------------------
-- Table to hold cached values so we don't have to ask addon manager each time we run a function.
LUIE.OtherAddonCompatability =
{
    isActionDurationReminderEnabled = false,
    isFancyActionBarEnabled = false,
    isFancyActionBarPlusEnabled = false,
    isWritCreatorEnabled = false
}
-- -----------------------------------------------------------------------------
local LuiData = LuiData
if not LuiData then
    error("LuiData is not enabled", 2)
end
-- -----------------------------------------------------------------------------
-- Default Settings
--- @class LUIE_Defaults_SV
LUIE.Defaults =
{
    CustomIcons               = true,
    CharacterSpecificSV       = false,
    StartupInfo               = false,
    HideAlertFrame            = false,
    AlertFrameAlignment       = 3,
    HideXPBar                 = false,
    TempAlertHome             = false,
    TempAlertCampaign         = false,
    TempAlertOutfit           = false,
    WelcomeVersion            = 0,
    ShowChangeLog             = false,

    -- Modules
    UnitFrames_Enabled        = true,
    InfoPanel_Enabled         = true,
    ActionBar_Enabled         = true,
    CombatInfo_Enabled        = true,
    CombatText_Enabled        = true,
    SpellCastBuff_Enable      = true,
    ChatAnnouncements_Enable  = true,
    SlashCommands_Enable      = true,

    -- Grid settings
    snapToGrid_default        = false,
    snapToGridSize_default    = 15,
    snapToGrid_unitFrames     = false,
    snapToGridSize_unitFrames = 15,
    snapToGrid_buffs          = false,
    snapToGridSize_buffs      = 15,
    -- snapToGrid_combatText     = false,
    -- snapToGridSize_combatText = 15,
}

-- -----------------------------------------------------------------------------

LUIE.Fonts =
{
    ["Adventure"] = LUIE_MEDIA_FONTS_ADVENTURE_ADVENTURE_SLUG,
    ["ArchivoNarrow Bold"] = LUIE_MEDIA_FONTS_ARCHIVONARROW_ARCHIVONARROW_BOLD_SLUG,
    ["ArchivoNarrow BoldItalic"] = LUIE_MEDIA_FONTS_ARCHIVONARROW_ARCHIVONARROW_BOLDITALIC_SLUG,
    ["ArchivoNarrow Italic"] = LUIE_MEDIA_FONTS_ARCHIVONARROW_ARCHIVONARROW_ITALIC_SLUG,
    ["ArchivoNarrow Medium"] = LUIE_MEDIA_FONTS_ARCHIVONARROW_ARCHIVONARROW_MEDIUM_SLUG,
    ["ArchivoNarrow MediumItalic"] = LUIE_MEDIA_FONTS_ARCHIVONARROW_ARCHIVONARROW_MEDIUMITALIC_SLUG,
    ["ArchivoNarrow Regular"] = LUIE_MEDIA_FONTS_ARCHIVONARROW_ARCHIVONARROW_REGULAR_SLUG,
    ["ArchivoNarrow SemiBold"] = LUIE_MEDIA_FONTS_ARCHIVONARROW_ARCHIVONARROW_SEMIBOLD_SLUG,
    ["ArchivoNarrow SemiBoldItalic"] = LUIE_MEDIA_FONTS_ARCHIVONARROW_ARCHIVONARROW_SEMIBOLDITALIC_SLUG,
    ["Bazooka"] = LUIE_MEDIA_FONTS_BAZOOKA_BAZOOKA_SLUG,
    ["Consolas"] = "/EsoUI/Common/Fonts/consola.slug",
    ["Cooline"] = LUIE_MEDIA_FONTS_COOLINE_COOLINE_SLUG,
    ["Diogenes"] = LUIE_MEDIA_FONTS_DIOGENES_DIOGENES_SLUG,
    ["EnigmaBold"] = LUIE_MEDIA_FONTS_ENIGMA_ENIGMABOLD_SLUG,
    ["EnigmaReg"] = LUIE_MEDIA_FONTS_ENIGMA_ENIGMAREG_SLUG,
    ["FORCED SQUARE"] = LUIE_MEDIA_FONTS_FORCEDSQUARE_FORCED_SQUARE_SLUG,
    ["Fontin Bold"] = LUIE_MEDIA_FONTS_FONTIN_FONTIN_SANS_B_SLUG,
    ["Fontin Italic"] = LUIE_MEDIA_FONTS_FONTIN_FONTIN_SANS_I_SLUG,
    ["Fontin Regular"] = LUIE_MEDIA_FONTS_FONTIN_FONTIN_SANS_R_SLUG,
    ["Fontin SmallCaps"] = LUIE_MEDIA_FONTS_FONTIN_FONTIN_SANS_SC_SLUG,
    ["Futura Condensed Bold"] = "/EsoUI/Common/Fonts/FTN87.slug",
    ["Futura Condensed Light"] = "/EsoUI/Common/Fonts/FTN47.slug",
    ["Futura Condensed"] = "/EsoUI/Common/Fonts/FTN57.slug",
    ["Ginko"] = LUIE_MEDIA_FONTS_GINKO_GINKO_SLUG,
    ["Heroic"] = LUIE_MEDIA_FONTS_HEROIC_HEROIC_SLUG,
    ["Metamorphous"] = LUIE_MEDIA_FONTS_METAMORPHOUS_METAMORPHOUS_SLUG,
    ["Montserrat Bold"] = LUIE_MEDIA_FONTS_MONTSERRAT_MONTSERRAT_BOLD_SLUG,
    ["Montserrat ExtraBold"] = LUIE_MEDIA_FONTS_MONTSERRAT_MONTSERRAT_EXTRABOLD_SLUG,
    ["Montserrat SemiBold"] = LUIE_MEDIA_FONTS_MONTSERRAT_MONTSERRAT_SEMIBOLD_SLUG,
    ["Porky"] = LUIE_MEDIA_FONTS_PORKY_PORKY_SLUG,
    ["ProFontWindows"] = LUIE_MEDIA_FONTS_PROFONTWINDOWS_PROFONTWINDOWS_SLUG,
    ["Roboto Bold Italic"] = LUIE_MEDIA_FONTS_ROBOTO_ROBOTO_BOLDITALIC_SLUG,
    ["Roboto Bold"] = LUIE_MEDIA_FONTS_ROBOTO_ROBOTO_BOLD_SLUG,
    ["Talisman"] = LUIE_MEDIA_FONTS_TALISMAN_TALISMAN_SLUG,
    ["Trajan Pro Bold"] = LUIE_MEDIA_FONTS_TRAJANPRO_TRAJANPROBOLD_SLUG,
    ["Transformers"] = LUIE_MEDIA_FONTS_TRANSFORMERS_TRANSFORMERS_SLUG,
    ["Univers 55"] = "/EsoUI/Common/Fonts/univers55.slug",
    ["Yellowjacket"] = LUIE_MEDIA_FONTS_YELLOWJACKET_YELLOWJACKET_SLUG,
}

if not IsConsoleUI() then
    LUIE.Fonts["ProseAntique"] = ZoFontBookPaper:GetFontInfo()
    LUIE.Fonts["Skyrim Handwritten"] = ZoFontBookLetter:GetFontInfo()
    LUIE.Fonts["Trajan Pro"] = ZoFontBookTablet:GetFontInfo()
    LUIE.Fonts["Univers 57"] = ZoFontGame:GetFontInfo()
    LUIE.Fonts["Univers 67"] = ZoFontWinH1:GetFontInfo()
end

if not LUIE.Fonts["LUIE Default Font"] then
    local font = ""

    if IsInGamepadPreferredMode() or IsConsoleUI() then
        font = "$(GAMEPAD_BOLD_FONT)|$(GP_18)|soft-shadow-thick"
    else
        font = "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick"
    end
    LUIE_SystemFont = CreateFont("LUIE_SystemFont", font)
    LUIE.Fonts["LUIE Default Font"] = LUIE_SystemFont:GetFontInfo()
end

-- -----------------------------------------------------------------------------
LUIE.Sounds =
{
    ["Death Recap Killing Blow"] = SOUNDS.DEATH_RECAP_KILLING_BLOW_SHOWN,
    ["LFG Find Replacement"] = SOUNDS.LFG_FIND_REPLACEMENT,
    ["LFG Search Started"] = SOUNDS.LFG_SEARCH_STARTED,
    ["Group Election Requested"] = SOUNDS.GROUP_ELECTION_REQUESTED,
    ["Group Leave"] = SOUNDS.GROUP_LEAVE,
    ["Duel Accepted"] = SOUNDS.DUEL_ACCEPTED,
    ["Duel Boundary Warning"] = SOUNDS.DUEL_BOUNDARY_WARNING,
    ["Duel Forfeit"] = SOUNDS.DUEL_FORFEIT,
    ["Duel Invite Received"] = SOUNDS.DUEL_INVITE_RECEIVED,
    ["Duel Start"] = SOUNDS.DUEL_START,
    ["Duel Won"] = SOUNDS.DUEL_WON,
    ["Trial - Scored Added High"] = SOUNDS.RAID_TRIAL_SCORE_ADDED_HIGH,
    ["Trial - Scored Added Low"] = SOUNDS.RAID_TRIAL_SCORE_ADDED_LOW,
    ["Trial - Scored Added Normal"] = SOUNDS.RAID_TRIAL_SCORE_ADDED_NORMAL,
    ["Trial - Scored Added Very High"] = SOUNDS.RAID_TRIAL_SCORE_ADDED_VERY_HIGH,
    ["Trial - Scored Added Very Low"] = SOUNDS.RAID_TRIAL_SCORE_ADDED_VERY_LOW,
    ["Display Announcement"] = SOUNDS.DISPLAY_ANNOUNCEMENT,
    ["Tel Var Multiplier Up"] = SOUNDS.TELVAR_MULTIPLIERUP,
    ["Book Collection Completed"] = SOUNDS.BOOK_COLLECTION_COMPLETED,
    ["Collectible Unlocked"] = SOUNDS.COLLECTIBLE_UNLOCKED,
    ["Voice Chat Channel Made Active"] = SOUNDS.VOICE_CHAT_ALERT_CHANNEL_MADE_ACTIVE,
    ["Console Game Enter"] = SOUNDS.CONSOLE_GAME_ENTER,
    ["Quest Shared"] = SOUNDS.QUEST_SHARED,
    ["Ultimate Ready"] = SOUNDS.ABILITY_ULTIMATE_READY,
    ["Champion Points Committed"] = SOUNDS.CHAMPION_POINTS_COMMITTED,
    ["Champion Damage Taken"] = SOUNDS.CHAMPION_DAMAGE_TAKEN,
    ["Champion Respec Accept"] = SOUNDS.CHAMPION_RESPEC_ACCEPT,
    ["Champion Star Locked"] = SOUNDS.CHAMPION_STAR_LOCKED,
    ["Champion Cycled"] = SOUNDS.CHAMPION_CYCLED_TO_WARRIOR,
}
-- -----------------------------------------------------------------------------
LUIE.StatusbarTextures =
{
    ["Aluminium"]              = LUIE_MEDIA_UNITFRAMES_TEXTURES_ALUMINIUM_DDS,
    ["Armory"]                 = LUIE_MEDIA_UNITFRAMES_TEXTURES_ARMORY_DDS,
    ["BantoBar"]               = LUIE_MEDIA_UNITFRAMES_TEXTURES_BANTOBAR_DDS,
    ["Bars"]                   = LUIE_MEDIA_UNITFRAMES_TEXTURES_BARS_DDS,
    ["Bumps"]                  = LUIE_MEDIA_UNITFRAMES_TEXTURES_BUMPS_DDS,
    ["Button"]                 = LUIE_MEDIA_UNITFRAMES_TEXTURES_BUTTON_DDS,
    ["Charcoal"]               = LUIE_MEDIA_UNITFRAMES_TEXTURES_CHARCOAL_DDS,
    ["Cilo"]                   = LUIE_MEDIA_UNITFRAMES_TEXTURES_CILO_DDS,
    ["Cloud"]                  = LUIE_MEDIA_UNITFRAMES_TEXTURES_CLOUD_DDS,
    ["Comet"]                  = LUIE_MEDIA_UNITFRAMES_TEXTURES_COMET_DDS,
    ["Dabs"]                   = LUIE_MEDIA_UNITFRAMES_TEXTURES_DABS_DDS,
    ["DarkBottom"]             = LUIE_MEDIA_UNITFRAMES_TEXTURES_DARKBOTTOM_DDS,
    ["Diagonal"]               = LUIE_MEDIA_UNITFRAMES_TEXTURES_DIAGONAL_DDS,
    ["Elder Scrolls Gradient"] = LUIE_MEDIA_UNITFRAMES_TEXTURES_ELDERSCROLLSGRAD_DDS,
    ["Empty"]                  = LUIE_MEDIA_UNITFRAMES_TEXTURES_EMPTY_DDS,
    ["Falumn"]                 = LUIE_MEDIA_UNITFRAMES_TEXTURES_FALUMN_DDS,
    ["Fifths"]                 = LUIE_MEDIA_UNITFRAMES_TEXTURES_FIFTHS_DDS,
    ["Flat"]                   = LUIE_MEDIA_UNITFRAMES_TEXTURES_FLAT_DDS,
    ["Fourths"]                = LUIE_MEDIA_UNITFRAMES_TEXTURES_FOURTHS_DDS,
    ["Frost"]                  = LUIE_MEDIA_UNITFRAMES_TEXTURES_FROST_DDS,
    ["Glamour"]                = LUIE_MEDIA_UNITFRAMES_TEXTURES_GLAMOUR_DDS,
    ["Glamour2"]               = LUIE_MEDIA_UNITFRAMES_TEXTURES_GLAMOUR2_DDS,
    ["Glamour3"]               = LUIE_MEDIA_UNITFRAMES_TEXTURES_GLAMOUR3_DDS,
    ["Glamour4"]               = LUIE_MEDIA_UNITFRAMES_TEXTURES_GLAMOUR4_DDS,
    ["Glamour5"]               = LUIE_MEDIA_UNITFRAMES_TEXTURES_GLAMOUR5_DDS,
    ["Glamour6"]               = LUIE_MEDIA_UNITFRAMES_TEXTURES_GLAMOUR6_DDS,
    ["Glamour7"]               = LUIE_MEDIA_UNITFRAMES_TEXTURES_GLAMOUR7_DDS,
    ["Glass"]                  = LUIE_MEDIA_UNITFRAMES_TEXTURES_GLASS_DDS,
    ["Glaze"]                  = LUIE_MEDIA_UNITFRAMES_TEXTURES_GLAZE_DDS,
    ["Gloss"]                  = LUIE_MEDIA_UNITFRAMES_TEXTURES_GLOSS_DDS,
    ["Grainy"]                 = LUIE_MEDIA_UNITFRAMES_TEXTURES_GRAINY_DDS,
    ["Graphite"]               = LUIE_MEDIA_UNITFRAMES_TEXTURES_GRAPHITE_DDS,
    ["Grid"]                   = LUIE_MEDIA_UNITFRAMES_TEXTURES_GRID_DDS,
    ["Hatched"]                = LUIE_MEDIA_UNITFRAMES_TEXTURES_HATCHED_DDS,
    ["Healbot"]                = LUIE_MEDIA_UNITFRAMES_TEXTURES_HEALBOT_DDS,
    ["Horizontal Gradient 1"]  = LUIE_MEDIA_UNITFRAMES_TEXTURES_HORIZONTALGRAD_DDS,
    ["Horizontal Gradient 2"]  = LUIE_MEDIA_UNITFRAMES_TEXTURES_HORIZONTALGRADV2_DDS,
    ["Inner Glow"]             = LUIE_MEDIA_UNITFRAMES_TEXTURES_INNERGLOW_DDS,
    ["Inner Shadow Glossy"]    = LUIE_MEDIA_UNITFRAMES_TEXTURES_INNERSHADOWGLOSS_DDS,
    ["Inner Shadow"]           = LUIE_MEDIA_UNITFRAMES_TEXTURES_INNERSHADOW_DDS,
    ["LiteStep"]               = LUIE_MEDIA_UNITFRAMES_TEXTURES_LITESTEP_DDS,
    ["LiteStepLite"]           = LUIE_MEDIA_UNITFRAMES_TEXTURES_LITESTEPLITE_DDS,
    ["Lyfe"]                   = LUIE_MEDIA_UNITFRAMES_TEXTURES_LYFE_DDS,
    ["Melli Dark Rough"]       = LUIE_MEDIA_UNITFRAMES_TEXTURES_MELLIDARKROUGH_DDS,
    ["Melli Dark"]             = LUIE_MEDIA_UNITFRAMES_TEXTURES_MELLIDARK_DDS,
    ["Melli"]                  = LUIE_MEDIA_UNITFRAMES_TEXTURES_MELLI_DDS,
    ["Minimalist"]             = LUIE_MEDIA_UNITFRAMES_TEXTURES_MINIMALIST_DDS,
    ["Minimalistic"]           = LUIE_MEDIA_UNITFRAMES_TEXTURES_MINIMALISTIC_DDS,
    ["Otravi"]                 = LUIE_MEDIA_UNITFRAMES_TEXTURES_OTRAVI_DDS,
    ["Outline"]                = LUIE_MEDIA_UNITFRAMES_TEXTURES_OUTLINE_DDS,
    ["Perl v2"]                = LUIE_MEDIA_UNITFRAMES_TEXTURES_PERL2_DDS,
    ["Perl"]                   = LUIE_MEDIA_UNITFRAMES_TEXTURES_PERL_DDS,
    ["Plain"]                  = LUIE_MEDIA_UNITFRAMES_TEXTURES_PLAIN_DDS,
    ["Rain"]                   = LUIE_MEDIA_UNITFRAMES_TEXTURES_RAIN_DDS,
    ["Rocks"]                  = LUIE_MEDIA_UNITFRAMES_TEXTURES_ROCKS_DDS,
    ["Round"]                  = LUIE_MEDIA_UNITFRAMES_TEXTURES_ROUND_DDS,
    ["Ruben"]                  = LUIE_MEDIA_UNITFRAMES_TEXTURES_RUBEN_DDS,
    ["Runes"]                  = LUIE_MEDIA_UNITFRAMES_TEXTURES_RUNES_DDS,
    ["Sand Paper 1"]           = LUIE_MEDIA_UNITFRAMES_TEXTURES_SANDPAPER_DDS,
    ["Sand Paper 2"]           = LUIE_MEDIA_UNITFRAMES_TEXTURES_SANDPAPERV2_DDS,
    ["Shadow"]                 = LUIE_MEDIA_UNITFRAMES_TEXTURES_SHADOW_DDS,
    ["Skewed"]                 = LUIE_MEDIA_UNITFRAMES_TEXTURES_SKEWED_DDS,
    ["Smooth v2"]              = LUIE_MEDIA_UNITFRAMES_TEXTURES_SMOOTHV2_DDS,
    ["Smooth"]                 = LUIE_MEDIA_UNITFRAMES_TEXTURES_SMOOTH_DDS,
    ["Smudge"]                 = LUIE_MEDIA_UNITFRAMES_TEXTURES_SMUDGE_DDS,
    ["Steel"]                  = LUIE_MEDIA_UNITFRAMES_TEXTURES_STEEL_DDS,
    ["Striped"]                = LUIE_MEDIA_UNITFRAMES_TEXTURES_STRIPED_DDS,
    ["Tube"]                   = LUIE_MEDIA_UNITFRAMES_TEXTURES_TUBE_DDS,
    ["Water"]                  = LUIE_MEDIA_UNITFRAMES_TEXTURES_WATER_DDS,
    ["Wglass"]                 = LUIE_MEDIA_UNITFRAMES_TEXTURES_WGLASS_DDS,
    ["Wisps"]                  = LUIE_MEDIA_UNITFRAMES_TEXTURES_WISPS_DDS,
    ["Xeon"]                   = LUIE_MEDIA_UNITFRAMES_TEXTURES_XEON_DDS,
}

-- -----------------------------------------------------------------------------
local function readonlytable(t)
    return setmetatable({},
                        {
                            __index = t,
                            __newindex = function (_, key, value)
                                error("Attempt to modify read-only table")
                            end,
                            __metatable = false
                        })
end

--- @class DevEntry
--- @field enabled boolean Whether this developer has special access enabled
--- @field debug boolean Whether debug mode is enabled for this developer

--- @type table<string, DevEntry>
local DEVS = readonlytable
    {
        ["@ArtOfShred"] =
        {
            enabled = false,
            debug = false,
        },
        ["@ArtOfShredPTS"] =
        {
            enabled = false,
            debug = false,
        },
        ["@ArtOfShredLegacy"] =
        {
            enabled = false,
            debug = false,
        },
        ["@HammerOfGlory"] =
        {
            enabled = false,
            debug = false,
        },
        ["@dack_janiels"] =
        {
            enabled = true,
            debug = true,
        },
        ["@dack_janiels.luie"] =
        {
            enabled = true,
            debug = true,
        },
    }

-- @type table<string, DevEntry>
-- LUIE.DEVS = DEVS

-- -----------------------------------------------------------------------------
-- Helper function to check if debug is enabled for current user
function LUIE.IsDevDebugEnabled()
    local currentUser = zo_strformat("<<1>>", GetUnitDisplayName("player"))
    return DEVS[currentUser] and DEVS[currentUser].enabled and DEVS[currentUser].debug
end

-- -----------------------------------------------------------------------------

-- do
--     local g_loggingEnabled = LUIE.IsDevDebugEnabled()
--     function ZO_Scene:Log(message)
--         if g_loggingEnabled then
--             CHAT_ROUTER:AddSystemMessage(string.format("%s - %s - %s", ZO_Scene_GetOriginColor():Colorize(GetString("SI_SCENEMANAGERMESSAGEORIGIN", ZO_REMOTE_SCENE_CHANGE_ORIGIN)), self.name, message))
--         end
--     end

--     function ZO_SceneManager_Follower:Log(message, sceneName)
--         if g_loggingEnabled then
--             if sceneName then
--                 CHAT_ROUTER:AddSystemMessage(string.format("%s - %s - %s", ZO_Scene_GetOriginColor():Colorize(GetString("SI_SCENEMANAGERMESSAGEORIGIN", ZO_REMOTE_SCENE_CHANGE_ORIGIN)), message, sceneName))
--             else
--                 CHAT_ROUTER:AddSystemMessage(string.format("%s - %s", ZO_Scene_GetOriginColor():Colorize(GetString("SI_SCENEMANAGERMESSAGEORIGIN", ZO_REMOTE_SCENE_CHANGE_ORIGIN)), message))
--             end
--         end
--     end
-- end
