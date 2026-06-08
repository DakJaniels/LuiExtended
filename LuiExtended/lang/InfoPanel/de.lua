-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- InfoPanel localization (de)
-- Translation locale: de
local strings =
{
    LUIE_STRING_PNL_TRAINNOW = "Jetzt lernen",
    LUIE_STRING_PNL_MAXED = "Am Limit",
    LUIE_STRING_PNL_SHOWGOLD = "Goldmenge anzeigen",
    LUIE_STRING_LAM_PNL_ENABLE = "Info-Panel-Modul",
    LUIE_STRING_LAM_PNL_DESCRIPTION = "Zeigt ein Panel mit nützlichen Informationen wie Latenz, Uhrzeit, FPS, Haltbarkeit und Waffenaufladung usw. an.",
    LUIE_STRING_LAM_PNL_DISABLECOLORSRO = "Farben für schreibgeschützte Werte deaktivieren",
    LUIE_STRING_LAM_PNL_DISABLECOLORSRO_TP = "Deaktiviert die werteabhängige Farbe der Informationsanzeige für Elemente, die du nicht direkt kontrollieren kannst: Derzeit betrifft dies FPS-, Latenz- und Add-on-Speicherpool-Anzeigen (Konsole).",
    LUIE_STRING_LAM_PNL_ELEMENTS_HEADER = "Info-Panel-Elemente",
    LUIE_STRING_LAM_PNL_HEADER = "Info-Panel-Optionen",
    LUIE_STRING_LAM_PNL_PANELSCALE = "Info-Panel-Größe, %",
    LUIE_STRING_LAM_PNL_PANELSCALE_TP = "Wird verwendet, um die Größe des Info-Panels auf Bildschirmen mit hoher Auflösung zu vergrößern.",
    LUIE_STRING_LAM_PNL_TRANSPARENCY = "Info-Panel-Transparenz, %",
    LUIE_STRING_LAM_PNL_TRANSPARENCY_TP = "Passt die Transparenz des Info-Panels an. 100 % = vollständig deckend, 0 % = vollständig transparent.",
    LUIE_STRING_LAM_PNL_HIDEINCOMBAT = "Info-Panel im Kampf ausblenden",
    LUIE_STRING_LAM_PNL_HIDEINCOMBAT_TP = "Blendet das Info-Panel aus, wenn du in den Kampf gehst. Es wird wieder angezeigt, wenn der Kampf endet.",
    LUIE_STRING_LAM_PNL_RESETPOSITION_TP = "Setzt die Position des Info-Panels in die obere rechte Bildschirmecke zurück.",
    LUIE_STRING_LAM_PNL_SHOWARMORDURABILITY = "Rüstungshaltbarkeit anzeigen",
    LUIE_STRING_LAM_PNL_SHOWBAGSPACE = "Taschenplatz anzeigen",
    LUIE_STRING_LAM_PNL_SHOWCLOCK = "Uhr anzeigen",
    LUIE_STRING_LAM_PNL_CLOCKFORMAT = "Uhrzeitformat",
    LUIE_STRING_LAM_PNL_SHOWEAPONCHARGES = "Waffenaufladungen anzeigen",
    LUIE_STRING_LAM_PNL_SHOWFPS = "FPS anzeigen",
    LUIE_STRING_LAM_PNL_SHOWMEMORY = "Speichernutzung anzeigen",
    LUIE_STRING_LAM_PNL_SHOWMEMORY_TP = "Konsole: Add-on-Speicherpool genutzt/Kapazität (MB). PC: Lua-Heap via collectgarbage (näherungsweise, ohne erzwungenes GC).",
    LUIE_STRING_LAM_PNL_SHOWLATENCY = "Latenz anzeigen",
    LUIE_STRING_LAM_PNL_SHOWMOUNTTIMER = "Reittier-Fütterungstimer anzeigen |c00FFFF*|r",
    LUIE_STRING_LAM_PNL_SHOWMOUNTTIMER_TP = "(*) Sobald du dein Reittier auf die maximale Stufe trainiert hast, wird dieses Feld für den aktuellen Charakter automatisch ausgeblendet.",
    LUIE_STRING_LAM_PNL_SHOWSOULGEMS = "Seelensteine anzeigen",
    LUIE_STRING_LAM_PNL_UNLOCKPANEL = "Panel entsperren",
    LUIE_STRING_LAM_PNL_UNLOCKPANEL_TP = "Ermöglicht das Verschieben des Info-Panels mit der Maus.",
    LUIE_STRING_LAM_PNL_DISPLAYONWORLDMAP = "Info-Panel auf der Weltkarte anzeigen",
    LUIE_STRING_LAM_PNL_DISPLAYONWORLDMAP_TP = "Zeigt das Info-Panel an, während du die Weltkarte betrachtest. Diese Option kann deaktiviert werden, wenn dein Info-Panel wichtige Elemente auf der Weltkarte überdeckt.",
    LUIE_STRING_PNL_FPS_FORMAT = "<<1>> FPS",
    LUIE_STRING_PNL_LATENCY_MS_FORMAT = "<<1>> ms",


}

LUIE_RegisterStrings(strings, true)
