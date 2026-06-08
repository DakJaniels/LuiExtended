-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- Shared localization (de)
-- Translation locale: de
local strings =
{
    LUIE_STRING_CUSTOM_LIST_AURA_BLACKLIST = "Aura-Blacklist",
    LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST = "Zauberleisten-Blacklist",
    LUIE_STRING_CUSTOM_LIST_PRIORITY_BUFFS = "Prioritäts-Stärkungen",
    LUIE_STRING_CUSTOM_LIST_PRIORITY_DEBUFFS = "Prioritäts-Schwächungen",
    LUIE_STRING_CUSTOM_LIST_CT_BLACKLIST = "Kampftext-Blacklist",
    LUIE_STRING_CUSTOM_LIST_UF_WHITELIST = "Begleiter-Namen-Whitelist",
    LUIE_STRING_CUSTOM_LIST_ADDED_ID = "<<1>> [<<2>>] <<3>> zu <<4>> hinzugefügt.",
    LUIE_STRING_CUSTOM_LIST_ADDED_FAILED = "Konnte [<<1>>] nicht zu <<2>> hinzufügen. Diese abilityId existiert nicht.",
    LUIE_STRING_CUSTOM_LIST_ADDED_NAME = "<<1>> zu <<2>> hinzugefügt.",
    LUIE_STRING_CUSTOM_LIST_CLEARED = "Alle Einträge von <<1>> gelöscht.",
    LUIE_STRING_CUSTOM_LIST_REMOVED_ID = "<<1>> [<<2>>] <<3>> aus <<4>> entfernt.",
    LUIE_STRING_CUSTOM_LIST_REMOVED_NAME = "<<1>> aus <<2>> entfernt.",
    LUIE_STRING_DEFAULT_FRAME_QUEST_LOG = "Questlog",
    LUIE_STRING_DEFAULT_FRAME_BATTLEGROUND_SCORE = "Schlachtfeld Wertung",
    LUIE_STRING_DEFAULT_FRAME_LOOT_HISTORY = "Loot Historie",
    LUIE_STRING_DEFAULT_FRAME_EQUIPMENT_STATUS = "Ausrüstungsstatus",
    LUIE_STRING_DEFAULT_FRAME_INFAMY_METER = "Kopfgeld Anzeige",
    LUIE_STRING_DEFAULT_FRAME_TEL_VAR_METER = "Tel Var Anzeige",
    LUIE_STRING_DEFAULT_FRAME_VOLENDRUNG_METER = "Volendrung-Anzeige",
    LUIE_STRING_DEFAULT_FRAME_ACTION_BAR = "Aktionsleiste",
    LUIE_STRING_DEFAULT_FRAME_SUBTITLES = "Untertitel",
    LUIE_STRING_DEFAULT_FRAME_TUTORIALS = "Anleitungen",
    LUIE_STRING_DEFAULT_FRAME_OBJECTIVE_METER = "Ziel- &\\nWiederbelebungs-\\nAnzeige",
    LUIE_STRING_DEFAULT_FRAME_PLAYER_INTERACTION = "Spieler-Interaktion",
    LUIE_STRING_DEFAULT_FRAME_ACTIVE_COMBAT_TIPS = "Kampftipps",
    LUIE_STRING_DEFAULT_FRAME_SYNERGY = "Synergie",
    LUIE_STRING_DEFAULT_FRAME_ALERTS = "Warnungstext",
    LUIE_STRING_DEFAULT_FRAME_COMPASS = "Kompass",
    LUIE_STRING_DEFAULT_FRAME_PLAYER_PROGRESS = "Erfahrungsleiste",
    LUIE_STRING_DEFAULT_FRAME_ENDLESS_DUNGEON_TRACKER = "Endlos-Archiv-Tracker",
    LUIE_STRING_DEFAULT_FRAME_CSA = "Bildschirm-Benachrichtigungen",
    LUIE_STRING_DEFAULT_FRAME_RETICLE_CONTAINER_INTERACT = "Interaktionstext",
    LUIE_STRING_DISMISS_PET = "|cBFBFBFDu verabschiedest |r<<1>>|cBFBFBF.|r",
    LUIE_STRING_CUSTOM_LIST_GROUP_BUFFS = "Eigene Gruppen-Stärkungen",
    LUIE_STRING_CUSTOM_LIST_GROUP_DEBUFFS = "Eigene Gruppen-Schwächungen",

    LUIE_STRING_SHARED_ALIGN_LEFT = "Links",
    LUIE_STRING_SHARED_ALIGN_CENTERED = "Zentriert",
    LUIE_STRING_SHARED_ALIGN_RIGHT = "Rechts",
    LUIE_STRING_SHARED_ALIGN_TOP = "Oben",
    LUIE_STRING_SHARED_ALIGN_BOTTOM = "Unten",
    LUIE_STRING_SHARED_SORT_LEFT_TO_RIGHT = "Links nach rechts",
    LUIE_STRING_SHARED_SORT_RIGHT_TO_LEFT = "Rechts nach links",
    LUIE_STRING_SHARED_SORT_BOTTOM_TO_TOP = "Unten nach oben",
    LUIE_STRING_SHARED_SORT_TOP_TO_BOTTOM = "Oben nach unten",
    LUIE_STRING_SHARED_STACK_DOWN = "Nach unten",
    LUIE_STRING_SHARED_STACK_UP = "Nach oben",
    LUIE_STRING_SHARED_ORIENTATION_HORIZONTAL = "Waagerecht",
    LUIE_STRING_SHARED_ORIENTATION_VERTICAL = "Vertikal",
    LUIE_STRING_SHARED_CC_ALL = "Alle Massenkontrolle",
    LUIE_STRING_SHARED_CC_NPC_ONLY = "Nur NSC-Massenkontrolle",
    LUIE_STRING_SHARED_CC_PLAYER_ONLY = "Nur Spieler-Massenkontrolle",

    LUIE_STRING_SHARED_GRID_SNAP_ENABLE = "Raster einrasten aktivieren (<<1>>)",
    LUIE_STRING_SHARED_GRID_SNAP_ENABLE_TP = "Beim Verschieben von <<1>> am Raster einrasten.",
    LUIE_STRING_SHARED_GRID_SNAP_SIZE = "Rastergröße (<<1>>)",
    LUIE_STRING_SHARED_GRID_SNAP_SIZE_TP = "Rastergröße zum Einrasten von <<1>> festlegen.",
    LUIE_STRING_SHARED_MODULE_DEFAULT_UI = "Standard-UI-Elemente",
    LUIE_STRING_SHARED_OOC_OPACITY = "Deckkraft außerhalb des Kampfs",
    LUIE_STRING_SHARED_IC_OPACITY = "Deckkraft im Kampf",

}

LUIE_RegisterStrings(strings, true)
