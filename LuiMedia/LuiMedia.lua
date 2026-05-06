-- -----------------------------------------------------------------------------
--  LuiMedia - Media Library for LuiExtended
--  Provides fonts, sounds, and statusbar textures
--  Distributed under The MIT License (MIT) (see LICENSE file)
-- -----------------------------------------------------------------------------

local LMP = LibMediaProvider
local eventManager = GetEventManager()

LuiMedia = {}
LuiMedia.__index = LuiMedia
LuiMedia.__name = "LuiMedia"
LuiMedia.__version = 7133

-- -----------------------------------------------------------------------------
-- Font Name Constants
-- -----------------------------------------------------------------------------
local FONT_ADVENTURE = "Adventure"
local FONT_ARCHIVONARROW_BOLD = "ArchivoNarrow Bold"
local FONT_ARCHIVONARROW_BOLDITALIC = "ArchivoNarrow BoldItalic"
local FONT_ARCHIVONARROW_ITALIC = "ArchivoNarrow Italic"
local FONT_ARCHIVONARROW_MEDIUM = "ArchivoNarrow Medium"
local FONT_ARCHIVONARROW_MEDIUMITALIC = "ArchivoNarrow MediumItalic"
local FONT_ARCHIVONARROW_REGULAR = "ArchivoNarrow Regular"
local FONT_ARCHIVONARROW_SEMIBOLD = "ArchivoNarrow SemiBold"
local FONT_ARCHIVONARROW_SEMIBOLDITALIC = "ArchivoNarrow SemiBoldItalic"
local FONT_BAZOOKA = "Bazooka"
local FONT_CONSOLAS = "Consolas"
local FONT_COOLINE = "Cooline"
local FONT_DIOGENES = "Diogenes"
local FONT_ENIGMA_BOLD = "EnigmaBold"
local FONT_ENIGMA_REG = "EnigmaReg"
local FONT_FORCED_SQUARE = "FORCED SQUARE"
local FONT_FONTIN_BOLD = "Fontin Bold"
local FONT_FONTIN_ITALIC = "Fontin Italic"
local FONT_FONTIN_REGULAR = "Fontin Regular"
local FONT_FONTIN_SMALLCAPS = "Fontin SmallCaps"
local FONT_FUTURA_CONDENSED_BOLD = "Futura Condensed Bold"
local FONT_FUTURA_CONDENSED_LIGHT = "Futura Condensed Light"
local FONT_FUTURA_CONDENSED = "Futura Condensed"
local FONT_GINKO = "Ginko"
local FONT_HEROIC = "Heroic"
local FONT_METAMORPHOUS = "Metamorphous"
local FONT_MONTSERRAT_BOLD = "Montserrat Bold"
local FONT_MONTSERRAT_EXTRABOLD = "Montserrat ExtraBold"
local FONT_MONTSERRAT_SEMIBOLD = "Montserrat SemiBold"
local FONT_PORKY = "Porky"
local FONT_PROFONTWINDOWS = "ProFontWindows"
local FONT_ROBOTO_BOLD_ITALIC = "Roboto Bold Italic"
local FONT_ROBOTO_BOLD = "Roboto Bold"
local FONT_TALISMAN = "Talisman"
local FONT_TRAJAN_PRO_BOLD = "Trajan Pro Bold"
local FONT_TRANSFORMERS = "Transformers"
local FONT_UNIVERS_55 = "Univers 55"
local FONT_YELLOWJACKET = "Yellowjacket"
local FONT_PROSE_ANTIQUE = "ProseAntique"
local FONT_SKYRIM_HANDWRITTEN = "Skyrim Handwritten"
local FONT_TRAJAN_PRO = "Trajan Pro"
local FONT_UNIVERS_57 = "Univers 57"
local FONT_UNIVERS_67 = "Univers 67"
local FONT_LUIE_DEFAULT = "LUIE Default Font"

-- -----------------------------------------------------------------------------
-- Sound Name Constants
-- -----------------------------------------------------------------------------
local SOUND_DEATH_RECAP_KILLING_BLOW = "Death Recap Killing Blow"
local SOUND_LFG_FIND_REPLACEMENT = "LFG Find Replacement"
local SOUND_LFG_SEARCH_STARTED = "LFG Search Started"
local SOUND_GROUP_ELECTION_REQUESTED = "Group Election Requested"
local SOUND_GROUP_LEAVE = "Group Leave"
local SOUND_DUEL_ACCEPTED = "Duel Accepted"
local SOUND_DUEL_BOUNDARY_WARNING = "Duel Boundary Warning"
local SOUND_DUEL_FORFEIT = "Duel Forfeit"
local SOUND_DUEL_INVITE_RECEIVED = "Duel Invite Received"
local SOUND_DUEL_START = "Duel Start"
local SOUND_DUEL_WON = "Duel Won"
local SOUND_TRIAL_SCORE_ADDED_HIGH = "Trial - Scored Added High"
local SOUND_TRIAL_SCORE_ADDED_LOW = "Trial - Scored Added Low"
local SOUND_TRIAL_SCORE_ADDED_NORMAL = "Trial - Scored Added Normal"
local SOUND_TRIAL_SCORE_ADDED_VERY_HIGH = "Trial - Scored Added Very High"
local SOUND_TRIAL_SCORE_ADDED_VERY_LOW = "Trial - Scored Added Very Low"
local SOUND_DISPLAY_ANNOUNCEMENT = "Display Announcement"
local SOUND_TELVAR_MULTIPLIER_UP = "Tel Var Multiplier Up"
local SOUND_BOOK_COLLECTION_COMPLETED = "Book Collection Completed"
local SOUND_COLLECTIBLE_UNLOCKED = "Collectible Unlocked"
local SOUND_VOICE_CHAT_CHANNEL_MADE_ACTIVE = "Voice Chat Channel Made Active"
local SOUND_CONSOLE_GAME_ENTER = "Console Game Enter"
local SOUND_QUEST_SHARED = "Quest Shared"
local SOUND_ULTIMATE_READY = "Ultimate Ready"
local SOUND_CHAMPION_POINTS_COMMITTED = "Champion Points Committed"
local SOUND_CHAMPION_DAMAGE_TAKEN = "Champion Damage Taken"
local SOUND_CHAMPION_RESPEC_ACCEPT = "Champion Respec Accept"
local SOUND_CHAMPION_STAR_LOCKED = "Champion Star Locked"
local SOUND_CHAMPION_CYCLED = "Champion Cycled"

-- -----------------------------------------------------------------------------
-- Statusbar Texture Name Constants
-- -----------------------------------------------------------------------------
local TEXTURE_ALUMINIUM = "Aluminium"
local TEXTURE_ARMORY = "Armory"
local TEXTURE_BANTOBAR = "BantoBar"
local TEXTURE_BARS = "Bars"
local TEXTURE_BUMPS = "Bumps"
local TEXTURE_BUTTON = "Button"
local TEXTURE_CHARCOAL = "Charcoal"
local TEXTURE_CILO = "Cilo"
local TEXTURE_CLOUD = "Cloud"
local TEXTURE_COMET = "Comet"
local TEXTURE_DABS = "Dabs"
local TEXTURE_DARK_BOTTOM = "DarkBottom"
local TEXTURE_DIAGONAL = "Diagonal"
local TEXTURE_ELDER_SCROLLS_GRADIENT = "Elder Scrolls Gradient"
local TEXTURE_EMPTY = "Empty"
local TEXTURE_FALUMN = "Falumn"
local TEXTURE_FIFTHS = "Fifths"
local TEXTURE_FLAT = "Flat"
local TEXTURE_FOURTHS = "Fourths"
local TEXTURE_FROST = "Frost"
local TEXTURE_GLAMOUR = "Glamour"
local TEXTURE_GLAMOUR2 = "Glamour2"
local TEXTURE_GLAMOUR3 = "Glamour3"
local TEXTURE_GLAMOUR4 = "Glamour4"
local TEXTURE_GLAMOUR5 = "Glamour5"
local TEXTURE_GLAMOUR6 = "Glamour6"
local TEXTURE_GLAMOUR7 = "Glamour7"
local TEXTURE_GLASS = "Glass"
local TEXTURE_GLAZE = "Glaze"
local TEXTURE_GLOSS = "Gloss"
local TEXTURE_GRAINY = "Grainy"
local TEXTURE_GRAPHITE = "Graphite"
local TEXTURE_GRID = "Grid"
local TEXTURE_HATCHED = "Hatched"
local TEXTURE_HEALBOT = "Healbot"
local TEXTURE_HORIZONTAL_GRADIENT_1 = "Horizontal Gradient 1"
local TEXTURE_HORIZONTAL_GRADIENT_2 = "Horizontal Gradient 2"
local TEXTURE_INNER_GLOW = "Inner Glow"
local TEXTURE_INNER_SHADOW_GLOSSY = "Inner Shadow Glossy"
local TEXTURE_INNER_SHADOW = "Inner Shadow"
local TEXTURE_LITESTEP = "LiteStep"
local TEXTURE_LITESTEP_LITE = "LiteStepLite"
local TEXTURE_LYFE = "Lyfe"
local TEXTURE_MELLI_DARK_ROUGH = "Melli Dark Rough"
local TEXTURE_MELLI_DARK = "Melli Dark"
local TEXTURE_MELLI = "Melli"
local TEXTURE_MINIMALIST = "Minimalist"
local TEXTURE_MINIMALISTIC = "Minimalistic"
local TEXTURE_OTRAVI = "Otravi"
local TEXTURE_OUTLINE = "Outline"
local TEXTURE_PERL_V2 = "Perl v2"
local TEXTURE_PERL = "Perl"
local TEXTURE_PLAIN = "Plain"
local TEXTURE_RAIN = "Rain"
local TEXTURE_ROCKS = "Rocks"
local TEXTURE_ROUND = "Round"
local TEXTURE_RUBEN = "Ruben"
local TEXTURE_RUNES = "Runes"
local TEXTURE_SAND_PAPER_1 = "Sand Paper 1"
local TEXTURE_SAND_PAPER_2 = "Sand Paper 2"
local TEXTURE_SHADOW = "Shadow"
local TEXTURE_SKEWED = "Skewed"
local TEXTURE_SMOOTH_V2 = "Smooth v2"
local TEXTURE_SMOOTH = "Smooth"
local TEXTURE_SMUDGE = "Smudge"
local TEXTURE_STEEL = "Steel"
local TEXTURE_STRIPED = "Striped"
local TEXTURE_TUBE = "Tube"
local TEXTURE_WATER = "Water"
local TEXTURE_WGLASS = "Wglass"
local TEXTURE_WISPS = "Wisps"
local TEXTURE_XEON = "Xeon"

-- -----------------------------------------------------------------------------
-- Fonts
-- -----------------------------------------------------------------------------
LuiMedia.Fonts =
{
    [FONT_ADVENTURE] = LUIE_MEDIA_FONTS_ADVENTURE_ADVENTURE_SLUG,
    [FONT_ARCHIVONARROW_BOLD] = LUIE_MEDIA_FONTS_ARCHIVONARROW_ARCHIVONARROW_BOLD_SLUG,
    [FONT_ARCHIVONARROW_BOLDITALIC] = LUIE_MEDIA_FONTS_ARCHIVONARROW_ARCHIVONARROW_BOLDITALIC_SLUG,
    [FONT_ARCHIVONARROW_ITALIC] = LUIE_MEDIA_FONTS_ARCHIVONARROW_ARCHIVONARROW_ITALIC_SLUG,
    [FONT_ARCHIVONARROW_MEDIUM] = LUIE_MEDIA_FONTS_ARCHIVONARROW_ARCHIVONARROW_MEDIUM_SLUG,
    [FONT_ARCHIVONARROW_MEDIUMITALIC] = LUIE_MEDIA_FONTS_ARCHIVONARROW_ARCHIVONARROW_MEDIUMITALIC_SLUG,
    [FONT_ARCHIVONARROW_REGULAR] = LUIE_MEDIA_FONTS_ARCHIVONARROW_ARCHIVONARROW_REGULAR_SLUG,
    [FONT_ARCHIVONARROW_SEMIBOLD] = LUIE_MEDIA_FONTS_ARCHIVONARROW_ARCHIVONARROW_SEMIBOLD_SLUG,
    [FONT_ARCHIVONARROW_SEMIBOLDITALIC] = LUIE_MEDIA_FONTS_ARCHIVONARROW_ARCHIVONARROW_SEMIBOLDITALIC_SLUG,
    [FONT_BAZOOKA] = LUIE_MEDIA_FONTS_BAZOOKA_BAZOOKA_SLUG,
    [FONT_CONSOLAS] = "/EsoUI/Common/Fonts/consola.slug",
    [FONT_COOLINE] = LUIE_MEDIA_FONTS_COOLINE_COOLINE_SLUG,
    [FONT_DIOGENES] = LUIE_MEDIA_FONTS_DIOGENES_DIOGENES_SLUG,
    [FONT_ENIGMA_BOLD] = LUIE_MEDIA_FONTS_ENIGMA_ENIGMABOLD_SLUG,
    [FONT_ENIGMA_REG] = LUIE_MEDIA_FONTS_ENIGMA_ENIGMAREG_SLUG,
    [FONT_FORCED_SQUARE] = LUIE_MEDIA_FONTS_FORCEDSQUARE_FORCED_SQUARE_SLUG,
    [FONT_FONTIN_BOLD] = LUIE_MEDIA_FONTS_FONTIN_FONTIN_SANS_B_SLUG,
    [FONT_FONTIN_ITALIC] = LUIE_MEDIA_FONTS_FONTIN_FONTIN_SANS_I_SLUG,
    [FONT_FONTIN_REGULAR] = LUIE_MEDIA_FONTS_FONTIN_FONTIN_SANS_R_SLUG,
    [FONT_FONTIN_SMALLCAPS] = LUIE_MEDIA_FONTS_FONTIN_FONTIN_SANS_SC_SLUG,
    [FONT_FUTURA_CONDENSED_BOLD] = "/EsoUI/Common/Fonts/FTN87.slug",
    [FONT_FUTURA_CONDENSED_LIGHT] = "/EsoUI/Common/Fonts/FTN47.slug",
    [FONT_FUTURA_CONDENSED] = "/EsoUI/Common/Fonts/FTN57.slug",
    [FONT_GINKO] = LUIE_MEDIA_FONTS_GINKO_GINKO_SLUG,
    [FONT_HEROIC] = LUIE_MEDIA_FONTS_HEROIC_HEROIC_SLUG,
    [FONT_METAMORPHOUS] = LUIE_MEDIA_FONTS_METAMORPHOUS_METAMORPHOUS_SLUG,
    [FONT_MONTSERRAT_BOLD] = LUIE_MEDIA_FONTS_MONTSERRAT_MONTSERRAT_BOLD_SLUG,
    [FONT_MONTSERRAT_EXTRABOLD] = LUIE_MEDIA_FONTS_MONTSERRAT_MONTSERRAT_EXTRABOLD_SLUG,
    [FONT_MONTSERRAT_SEMIBOLD] = LUIE_MEDIA_FONTS_MONTSERRAT_MONTSERRAT_SEMIBOLD_SLUG,
    [FONT_PORKY] = LUIE_MEDIA_FONTS_PORKY_PORKY_SLUG,
    [FONT_PROFONTWINDOWS] = LUIE_MEDIA_FONTS_PROFONTWINDOWS_PROFONTWINDOWS_SLUG,
    [FONT_ROBOTO_BOLD_ITALIC] = LUIE_MEDIA_FONTS_ROBOTO_ROBOTO_BOLDITALIC_SLUG,
    [FONT_ROBOTO_BOLD] = LUIE_MEDIA_FONTS_ROBOTO_ROBOTO_BOLD_SLUG,
    [FONT_TALISMAN] = LUIE_MEDIA_FONTS_TALISMAN_TALISMAN_SLUG,
    [FONT_TRAJAN_PRO_BOLD] = LUIE_MEDIA_FONTS_TRAJANPRO_TRAJANPROBOLD_SLUG,
    [FONT_TRANSFORMERS] = LUIE_MEDIA_FONTS_TRANSFORMERS_TRANSFORMERS_SLUG,
    [FONT_UNIVERS_55] = "/EsoUI/Common/Fonts/univers55.slug",
    [FONT_YELLOWJACKET] = LUIE_MEDIA_FONTS_YELLOWJACKET_YELLOWJACKET_SLUG,
}

-- -----------------------------------------------------------------------------
-- Sounds
-- -----------------------------------------------------------------------------
LuiMedia.Sounds =
{
    [SOUND_DEATH_RECAP_KILLING_BLOW] = SOUNDS.DEATH_RECAP_KILLING_BLOW_SHOWN,
    [SOUND_LFG_FIND_REPLACEMENT] = SOUNDS.LFG_FIND_REPLACEMENT,
    [SOUND_LFG_SEARCH_STARTED] = SOUNDS.LFG_SEARCH_STARTED,
    [SOUND_GROUP_ELECTION_REQUESTED] = SOUNDS.GROUP_ELECTION_REQUESTED,
    [SOUND_GROUP_LEAVE] = SOUNDS.GROUP_LEAVE,
    [SOUND_DUEL_ACCEPTED] = SOUNDS.DUEL_ACCEPTED,
    [SOUND_DUEL_BOUNDARY_WARNING] = SOUNDS.DUEL_BOUNDARY_WARNING,
    [SOUND_DUEL_FORFEIT] = SOUNDS.DUEL_FORFEIT,
    [SOUND_DUEL_INVITE_RECEIVED] = SOUNDS.DUEL_INVITE_RECEIVED,
    [SOUND_DUEL_START] = SOUNDS.DUEL_START,
    [SOUND_DUEL_WON] = SOUNDS.DUEL_WON,
    [SOUND_TRIAL_SCORE_ADDED_HIGH] = SOUNDS.RAID_TRIAL_SCORE_ADDED_HIGH,
    [SOUND_TRIAL_SCORE_ADDED_LOW] = SOUNDS.RAID_TRIAL_SCORE_ADDED_LOW,
    [SOUND_TRIAL_SCORE_ADDED_NORMAL] = SOUNDS.RAID_TRIAL_SCORE_ADDED_NORMAL,
    [SOUND_TRIAL_SCORE_ADDED_VERY_HIGH] = SOUNDS.RAID_TRIAL_SCORE_ADDED_VERY_HIGH,
    [SOUND_TRIAL_SCORE_ADDED_VERY_LOW] = SOUNDS.RAID_TRIAL_SCORE_ADDED_VERY_LOW,
    [SOUND_DISPLAY_ANNOUNCEMENT] = SOUNDS.DISPLAY_ANNOUNCEMENT,
    [SOUND_TELVAR_MULTIPLIER_UP] = SOUNDS.TELVAR_MULTIPLIERUP,
    [SOUND_BOOK_COLLECTION_COMPLETED] = SOUNDS.BOOK_COLLECTION_COMPLETED,
    [SOUND_COLLECTIBLE_UNLOCKED] = SOUNDS.COLLECTIBLE_UNLOCKED,
    [SOUND_VOICE_CHAT_CHANNEL_MADE_ACTIVE] = SOUNDS.VOICE_CHAT_ALERT_CHANNEL_MADE_ACTIVE,
    [SOUND_CONSOLE_GAME_ENTER] = SOUNDS.CONSOLE_GAME_ENTER,
    [SOUND_QUEST_SHARED] = SOUNDS.QUEST_SHARED,
    [SOUND_ULTIMATE_READY] = SOUNDS.ABILITY_ULTIMATE_READY,
    [SOUND_CHAMPION_POINTS_COMMITTED] = SOUNDS.CHAMPION_POINTS_COMMITTED,
    [SOUND_CHAMPION_DAMAGE_TAKEN] = SOUNDS.CHAMPION_DAMAGE_TAKEN,
    [SOUND_CHAMPION_RESPEC_ACCEPT] = SOUNDS.CHAMPION_RESPEC_ACCEPT,
    [SOUND_CHAMPION_STAR_LOCKED] = SOUNDS.CHAMPION_STAR_LOCKED,
    [SOUND_CHAMPION_CYCLED] = SOUNDS.CHAMPION_CYCLED_TO_WARRIOR,
}

-- -----------------------------------------------------------------------------
-- Statusbar Textures
-- -----------------------------------------------------------------------------
LuiMedia.StatusbarTextures =
{
    [TEXTURE_ALUMINIUM] = LUIE_MEDIA_UNITFRAMES_TEXTURES_ALUMINIUM_DDS,
    [TEXTURE_ARMORY] = LUIE_MEDIA_UNITFRAMES_TEXTURES_ARMORY_DDS,
    [TEXTURE_BANTOBAR] = LUIE_MEDIA_UNITFRAMES_TEXTURES_BANTOBAR_DDS,
    [TEXTURE_BARS] = LUIE_MEDIA_UNITFRAMES_TEXTURES_BARS_DDS,
    [TEXTURE_BUMPS] = LUIE_MEDIA_UNITFRAMES_TEXTURES_BUMPS_DDS,
    [TEXTURE_BUTTON] = LUIE_MEDIA_UNITFRAMES_TEXTURES_BUTTON_DDS,
    [TEXTURE_CHARCOAL] = LUIE_MEDIA_UNITFRAMES_TEXTURES_CHARCOAL_DDS,
    [TEXTURE_CILO] = LUIE_MEDIA_UNITFRAMES_TEXTURES_CILO_DDS,
    [TEXTURE_CLOUD] = LUIE_MEDIA_UNITFRAMES_TEXTURES_CLOUD_DDS,
    [TEXTURE_COMET] = LUIE_MEDIA_UNITFRAMES_TEXTURES_COMET_DDS,
    [TEXTURE_DABS] = LUIE_MEDIA_UNITFRAMES_TEXTURES_DABS_DDS,
    [TEXTURE_DARK_BOTTOM] = LUIE_MEDIA_UNITFRAMES_TEXTURES_DARKBOTTOM_DDS,
    [TEXTURE_DIAGONAL] = LUIE_MEDIA_UNITFRAMES_TEXTURES_DIAGONAL_DDS,
    [TEXTURE_ELDER_SCROLLS_GRADIENT] = LUIE_MEDIA_UNITFRAMES_TEXTURES_ELDERSCROLLSGRAD_DDS,
    [TEXTURE_EMPTY] = LUIE_MEDIA_UNITFRAMES_TEXTURES_EMPTY_DDS,
    [TEXTURE_FALUMN] = LUIE_MEDIA_UNITFRAMES_TEXTURES_FALUMN_DDS,
    [TEXTURE_FIFTHS] = LUIE_MEDIA_UNITFRAMES_TEXTURES_FIFTHS_DDS,
    [TEXTURE_FLAT] = LUIE_MEDIA_UNITFRAMES_TEXTURES_FLAT_DDS,
    [TEXTURE_FOURTHS] = LUIE_MEDIA_UNITFRAMES_TEXTURES_FOURTHS_DDS,
    [TEXTURE_FROST] = LUIE_MEDIA_UNITFRAMES_TEXTURES_FROST_DDS,
    [TEXTURE_GLAMOUR] = LUIE_MEDIA_UNITFRAMES_TEXTURES_GLAMOUR_DDS,
    [TEXTURE_GLAMOUR2] = LUIE_MEDIA_UNITFRAMES_TEXTURES_GLAMOUR2_DDS,
    [TEXTURE_GLAMOUR3] = LUIE_MEDIA_UNITFRAMES_TEXTURES_GLAMOUR3_DDS,
    [TEXTURE_GLAMOUR4] = LUIE_MEDIA_UNITFRAMES_TEXTURES_GLAMOUR4_DDS,
    [TEXTURE_GLAMOUR5] = LUIE_MEDIA_UNITFRAMES_TEXTURES_GLAMOUR5_DDS,
    [TEXTURE_GLAMOUR6] = LUIE_MEDIA_UNITFRAMES_TEXTURES_GLAMOUR6_DDS,
    [TEXTURE_GLAMOUR7] = LUIE_MEDIA_UNITFRAMES_TEXTURES_GLAMOUR7_DDS,
    [TEXTURE_GLASS] = LUIE_MEDIA_UNITFRAMES_TEXTURES_GLASS_DDS,
    [TEXTURE_GLAZE] = LUIE_MEDIA_UNITFRAMES_TEXTURES_GLAZE_DDS,
    [TEXTURE_GLOSS] = LUIE_MEDIA_UNITFRAMES_TEXTURES_GLOSS_DDS,
    [TEXTURE_GRAINY] = LUIE_MEDIA_UNITFRAMES_TEXTURES_GRAINY_DDS,
    [TEXTURE_GRAPHITE] = LUIE_MEDIA_UNITFRAMES_TEXTURES_GRAPHITE_DDS,
    [TEXTURE_GRID] = LUIE_MEDIA_UNITFRAMES_TEXTURES_GRID_DDS,
    [TEXTURE_HATCHED] = LUIE_MEDIA_UNITFRAMES_TEXTURES_HATCHED_DDS,
    [TEXTURE_HEALBOT] = LUIE_MEDIA_UNITFRAMES_TEXTURES_HEALBOT_DDS,
    [TEXTURE_HORIZONTAL_GRADIENT_1] = LUIE_MEDIA_UNITFRAMES_TEXTURES_HORIZONTALGRAD_DDS,
    [TEXTURE_HORIZONTAL_GRADIENT_2] = LUIE_MEDIA_UNITFRAMES_TEXTURES_HORIZONTALGRADV2_DDS,
    [TEXTURE_INNER_GLOW] = LUIE_MEDIA_UNITFRAMES_TEXTURES_INNERGLOW_DDS,
    [TEXTURE_INNER_SHADOW_GLOSSY] = LUIE_MEDIA_UNITFRAMES_TEXTURES_INNERSHADOWGLOSS_DDS,
    [TEXTURE_INNER_SHADOW] = LUIE_MEDIA_UNITFRAMES_TEXTURES_INNERSHADOW_DDS,
    [TEXTURE_LITESTEP] = LUIE_MEDIA_UNITFRAMES_TEXTURES_LITESTEP_DDS,
    [TEXTURE_LITESTEP_LITE] = LUIE_MEDIA_UNITFRAMES_TEXTURES_LITESTEPLITE_DDS,
    [TEXTURE_LYFE] = LUIE_MEDIA_UNITFRAMES_TEXTURES_LYFE_DDS,
    [TEXTURE_MELLI_DARK_ROUGH] = LUIE_MEDIA_UNITFRAMES_TEXTURES_MELLIDARKROUGH_DDS,
    [TEXTURE_MELLI_DARK] = LUIE_MEDIA_UNITFRAMES_TEXTURES_MELLIDARK_DDS,
    [TEXTURE_MELLI] = LUIE_MEDIA_UNITFRAMES_TEXTURES_MELLI_DDS,
    [TEXTURE_MINIMALIST] = LUIE_MEDIA_UNITFRAMES_TEXTURES_MINIMALIST_DDS,
    [TEXTURE_MINIMALISTIC] = LUIE_MEDIA_UNITFRAMES_TEXTURES_MINIMALISTIC_DDS,
    [TEXTURE_OTRAVI] = LUIE_MEDIA_UNITFRAMES_TEXTURES_OTRAVI_DDS,
    [TEXTURE_OUTLINE] = LUIE_MEDIA_UNITFRAMES_TEXTURES_OUTLINE_DDS,
    [TEXTURE_PERL_V2] = LUIE_MEDIA_UNITFRAMES_TEXTURES_PERL2_DDS,
    [TEXTURE_PERL] = LUIE_MEDIA_UNITFRAMES_TEXTURES_PERL_DDS,
    [TEXTURE_PLAIN] = LUIE_MEDIA_UNITFRAMES_TEXTURES_PLAIN_DDS,
    [TEXTURE_RAIN] = LUIE_MEDIA_UNITFRAMES_TEXTURES_RAIN_DDS,
    [TEXTURE_ROCKS] = LUIE_MEDIA_UNITFRAMES_TEXTURES_ROCKS_DDS,
    [TEXTURE_ROUND] = LUIE_MEDIA_UNITFRAMES_TEXTURES_ROUND_DDS,
    [TEXTURE_RUBEN] = LUIE_MEDIA_UNITFRAMES_TEXTURES_RUBEN_DDS,
    [TEXTURE_RUNES] = LUIE_MEDIA_UNITFRAMES_TEXTURES_RUNES_DDS,
    [TEXTURE_SAND_PAPER_1] = LUIE_MEDIA_UNITFRAMES_TEXTURES_SANDPAPER_DDS,
    [TEXTURE_SAND_PAPER_2] = LUIE_MEDIA_UNITFRAMES_TEXTURES_SANDPAPERV2_DDS,
    [TEXTURE_SHADOW] = LUIE_MEDIA_UNITFRAMES_TEXTURES_SHADOW_DDS,
    [TEXTURE_SKEWED] = LUIE_MEDIA_UNITFRAMES_TEXTURES_SKEWED_DDS,
    [TEXTURE_SMOOTH_V2] = LUIE_MEDIA_UNITFRAMES_TEXTURES_SMOOTHV2_DDS,
    [TEXTURE_SMOOTH] = LUIE_MEDIA_UNITFRAMES_TEXTURES_SMOOTH_DDS,
    [TEXTURE_SMUDGE] = LUIE_MEDIA_UNITFRAMES_TEXTURES_SMUDGE_DDS,
    [TEXTURE_STEEL] = LUIE_MEDIA_UNITFRAMES_TEXTURES_STEEL_DDS,
    [TEXTURE_STRIPED] = LUIE_MEDIA_UNITFRAMES_TEXTURES_STRIPED_DDS,
    [TEXTURE_TUBE] = LUIE_MEDIA_UNITFRAMES_TEXTURES_TUBE_DDS,
    [TEXTURE_WATER] = LUIE_MEDIA_UNITFRAMES_TEXTURES_WATER_DDS,
    [TEXTURE_WGLASS] = LUIE_MEDIA_UNITFRAMES_TEXTURES_WGLASS_DDS,
    [TEXTURE_WISPS] = LUIE_MEDIA_UNITFRAMES_TEXTURES_WISPS_DDS,
    [TEXTURE_XEON] = LUIE_MEDIA_UNITFRAMES_TEXTURES_XEON_DDS,
}

-- -----------------------------------------------------------------------------
-- Initialization
-- -----------------------------------------------------------------------------
local function AddConsoleFonts()
    if not ZO_IsConsoleOrGameCoreUI() then
        LuiMedia.Fonts[FONT_PROSE_ANTIQUE] = ZoFontBookPaper:GetFontInfo()
        LuiMedia.Fonts[FONT_SKYRIM_HANDWRITTEN] = ZoFontBookLetter:GetFontInfo()
        LuiMedia.Fonts[FONT_TRAJAN_PRO] = ZoFontBookTablet:GetFontInfo()
        LuiMedia.Fonts[FONT_UNIVERS_57] = ZoFontGame:GetFontInfo()
        LuiMedia.Fonts[FONT_UNIVERS_67] = ZoFontWinH1:GetFontInfo()
    end
end

local CONSOLE_FONT_STRING = "$(GAMEPAD_BOLD_FONT)|$(GP_18)|soft-shadow-thick"
local PC_FONT_STRING = "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick"
local LUIE_FONT_NAME = "LUIE_SystemFont"
local function AddDefaultFont()
    if not LuiMedia.Fonts[FONT_LUIE_DEFAULT] then
        local font = ""
        if IsInGamepadPreferredMode() or ZO_IsConsoleOrGameCoreUI() then
            font = CONSOLE_FONT_STRING
        else
            font = PC_FONT_STRING
        end
        local LUIE_SystemFont = CreateFont(LUIE_FONT_NAME, font)
        LuiMedia.Fonts[FONT_LUIE_DEFAULT] = LUIE_SystemFont:GetFontInfo()
    end
end

local function RegisterWithLMP()
    -- Register fonts
    for mediaName, mediaPath in pairs(LuiMedia.Fonts) do
        LMP:Register(LMP.MediaType.FONT, mediaName, mediaPath)
    end

    -- Register sounds
    for mediaName, mediaPath in pairs(LuiMedia.Sounds) do
        LMP:Register(LMP.MediaType.SOUND, mediaName, mediaPath)
    end

    -- Register statusbar textures
    for mediaName, mediaPath in pairs(LuiMedia.StatusbarTextures) do
        LMP:Register(LMP.MediaType.STATUSBAR, mediaName, mediaPath)
    end
end

--- Handle media registered by external addons
--- @param mediaType string The media type that was registered
--- @param mediaName string The name of the media that was registered
local function OnMediaRegistered(mediaType, mediaName)
    -- Update our tables with media from external addons
    if mediaType == LMP.MediaType.FONT then
        if not LuiMedia.Fonts[mediaName] then
            LuiMedia.Fonts[mediaName] = LMP:Fetch(mediaType, mediaName)
        end
    elseif mediaType == LMP.MediaType.SOUND then
        if not LuiMedia.Sounds[mediaName] then
            LuiMedia.Sounds[mediaName] = LMP:Fetch(mediaType, mediaName)
        end
    elseif mediaType == LMP.MediaType.STATUSBAR then
        if not LuiMedia.StatusbarTextures[mediaName] then
            LuiMedia.StatusbarTextures[mediaName] = LMP:Fetch(mediaType, mediaName)
        end
    end
end

--- Fetch any media already registered by other addons before LuiMedia loaded
local function FetchExistingExternalMedia()
    -- Fetch fonts
    for _, mediaName in ipairs(LMP:List(LMP.MediaType.FONT)) do
        if not LuiMedia.Fonts[mediaName] then
            LuiMedia.Fonts[mediaName] = LMP:Fetch(LMP.MediaType.FONT, mediaName)
        end
    end

    -- Fetch sounds
    for _, mediaName in ipairs(LMP:List(LMP.MediaType.SOUND)) do
        if not LuiMedia.Sounds[mediaName] then
            LuiMedia.Sounds[mediaName] = LMP:Fetch(LMP.MediaType.SOUND, mediaName)
        end
    end

    -- Fetch statusbar textures
    for _, mediaName in ipairs(LMP:List(LMP.MediaType.STATUSBAR)) do
        if not LuiMedia.StatusbarTextures[mediaName] then
            LuiMedia.StatusbarTextures[mediaName] = LMP:Fetch(LMP.MediaType.STATUSBAR, mediaName)
        end
    end
end

function LuiMedia:Initialize()
    AddConsoleFonts()
    AddDefaultFont()
    RegisterWithLMP()

    -- Fetch any media already registered by other addons
    FetchExistingExternalMedia()

    -- Register callback to automatically add future media from other addons
    CALLBACK_MANAGER:RegisterCallback("LibMediaProvider_Registered", OnMediaRegistered)
end

-- -----------------------------------------------------------------------------
-- Public Getters
-- -----------------------------------------------------------------------------
function LuiMedia.GetFonts()
    return LuiMedia.Fonts
end

function LuiMedia.GetSounds()
    return LuiMedia.Sounds
end

function LuiMedia.GetStatusbarTextures()
    return LuiMedia.StatusbarTextures
end

-- -----------------------------------------------------------------------------
local function OnAddOnLoaded(event, addonName)
    if addonName == "LuiMedia" then
        eventManager:UnregisterForEvent("LuiMedia_OnAddOnLoaded", EVENT_ADD_ON_LOADED)
        LuiMedia:Initialize()
    end
end

local DO_ONCE = false
eventManager:RegisterForEvent("LuiMedia_OnAddOnLoaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded, DO_ONCE)
-- -----------------------------------------------------------------------------
