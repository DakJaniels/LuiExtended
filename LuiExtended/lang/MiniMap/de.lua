-- -----------------------------------------------------------------------------
--  LuiExtended — MiniMap localization (de)
-- -----------------------------------------------------------------------------

local strings =
{
    LUIE_STRING_LAM_MINIMAP = "MiniMap (BETA)",
    LUIE_STRING_LAM_MINIMAP_DESCRIPTION = "MiniMap-Modul aktivieren und konfigurieren.",
    LUIE_STRING_LAM_MINIMAP_ENABLE = "MiniMap aktivieren",
    LUIE_STRING_LAM_MINIMAP_ENABLE_TP = "MiniMap-Modul ein- oder ausschalten. Erfordert UI-Neuladen.",
    LUIE_STRING_LAM_MINIMAP_ZOOM = "Standard-Zoom (%)",
    LUIE_STRING_LAM_MINIMAP_ZOOM_TP = "Standard-Zoom beim Zurücksetzen. Nicht unter den Wert, der die ganze Zone in den Rahmen legt (abhängig von Karte und Minimap-Größe).",
    LUIE_STRING_LAM_MINIMAP_PINSCALE = "Standard-Pin-Skalierung (%)",
    LUIE_STRING_LAM_MINIMAP_PINSCALE_TP = "Skaliert Karten-Symbole (POI, Gruppe, Weltereignisse usw.). Quest-Bereichskreise bleiben kartenproportional.",
    LUIE_STRING_LAM_MINIMAP_PLAYERPINSCALE = "Spieler-Pip-Größe (%)",
    LUIE_STRING_LAM_MINIMAP_PLAYERPINSCALE_TP = "Größe des zentrierten Spieler-Pips (Folgen an) und Karten-Pins (Folgen aus). Basis: 16 px wie Weltkarte.",
    LUIE_STRING_LAM_MINIMAP_RESETPOSITION_TP = "MiniMap-Position auf Standard zurücksetzen.",
    LUIE_STRING_LAM_MINIMAP_FOLLOW_PLAYER = "Spieler folgen",
    LUIE_STRING_LAM_MINIMAP_FOLLOW_PLAYER_TP = "Standard: Karte auf Spieler zentrieren. Ziehen schwenkt die Karte, ohne diese Einstellung zu ändern (bis Neuzentrierung oder hier umschalten).",
    LUIE_STRING_LAM_MINIMAP_LOCK_POSITION = "Position sperren",
    LUIE_STRING_LAM_MINIMAP_LOCK_POSITION_TP = "Verschieben des MiniMap-Fensters verhindern.",
    LUIE_STRING_LAM_MINIMAP_LOCK_SIZE = "Größe sperren",
    LUIE_STRING_LAM_MINIMAP_LOCK_SIZE_TP = "Größenänderung des MiniMap-Fensters verhindern.",
    LUIE_STRING_LAM_MINIMAP_WAYPOINT_SHIFT = "Wegpunkt mit Umschalt",
    LUIE_STRING_LAM_MINIMAP_WAYPOINT_SHIFT_TP = "Wenn aktiv: Umschalt+Linksklick setzt einen Wegpunkt, Umschalt+Rechtsklick entfernt ihn. Wenn inaktiv: Klick ohne Ziehen setzt einen Wegpunkt.",
    LUIE_STRING_LAM_MINIMAP_SHOW_ZOOM_BUTTONS = "Zoom-Tasten anzeigen",
    LUIE_STRING_LAM_MINIMAP_SHOW_ZOOM_BUTTONS_TP = "Zoom-Plus/Minus-Tasten auf der Karte anzeigen.",
    LUIE_STRING_LAM_MINIMAP_ADVANCED_HEADER = "Erweiterte Optionen",
    LUIE_STRING_LAM_MINIMAP_ADVANCED_DESC = "Weitere erweiterte MiniMap-Optionen folgen in künftigen Updates.",
    LUIE_STRING_LAM_MINIMAP_PIN_MIRROR_STATE_MACHINE_DEBUG = "Pin-Mirror-Zustandsautomat (Debug)",
    LUIE_STRING_LAM_MINIMAP_PIN_MIRROR_STATE_MACHINE_DEBUG_TP = "ZO_StateMachine-Übergänge für Pin-Spiegel, Karten-Neuladen und Schnellreise im Chat protokollieren.",
    LUIE_STRING_LAM_MINIMAP_ANCHOR_INFOPANEL = "InfoPanel an Minimap verankern",
    LUIE_STRING_LAM_MINIMAP_ANCHOR_INFOPANEL_TP = "InfoPanel unter der Karte (Zonenname-Position) platzieren und den Zonentitel über die Karte legen. Position wird von der Minimap gesteuert. Erfordert das InfoPanel-Modul.",
    LUIE_STRING_LAM_MINIMAP_SHOW_ZONE_NAME = "Zonennamen anzeigen",
    LUIE_STRING_LAM_MINIMAP_SHOW_ZONE_NAME_TP = "Aktuellen Zonennamen an der Minimap anzeigen. Zum Verschieben beim Darüberfahren die Steuerung unten links nutzen.",
    LUIE_STRING_MINIMAP_FRAME_MOVE_TP = "Ziehen, um die Minimap zu verschieben.",
    LUIE_STRING_MINIMAP_FRAME_LOCK_TP = "Lock or unlock minimap position.",
    LUIE_STRING_LAM_MINIMAP_COMPASS_OVERRIDE_DEFAULT = "Spielstandard",
    LUIE_STRING_LAM_MINIMAP_COMPASS_OVERRIDE_HIDE = "Kompass am HUD ausblenden",
    LUIE_STRING_LAM_MINIMAP_COMPASS_OVERRIDE_SHOW = "Kompass am HUD anzeigen",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
SafeAddVersion("LUIE_STRING_LAM_MINIMAP_PINSCALE_TP", 2)
