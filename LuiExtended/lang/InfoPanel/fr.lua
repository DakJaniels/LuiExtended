-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- InfoPanel localization (fr)
-- Translation locale: fr
local strings =
{
    LUIE_STRING_PNL_TRAINNOW = "Entraîner",
    LUIE_STRING_PNL_MAXED = "Au Max",
    LUIE_STRING_PNL_SHOWGOLD = "Afficher l'or",
    LUIE_STRING_LAM_PNL_ENABLE = "Module du panneau d'informations",
    LUIE_STRING_LAM_PNL_DESCRIPTION = "Affiche un panneau avec des informations utiles comme la latence, les FPS, l'usage de l'armure et les charges des armes, etc...",
    LUIE_STRING_LAM_PNL_DISABLECOLORSRO = "Désactiver les couleurs des données en lecture seule",
    LUIE_STRING_LAM_PNL_DISABLECOLORSRO_TP = "Désactivez la couleur dépendante de la valeur de l'étiquette d'information pour les éléments sur lesquels vous n'avez pas de contrôle direct : actuellement, cela inclut les étiquettes FPS, Latence et utilisation du pool de mémoire supplémentaire (console).",
    LUIE_STRING_LAM_PNL_ELEMENTS_HEADER = "Elements du panneau d'informations",
    LUIE_STRING_LAM_PNL_HEADER = "Paramètres du panneau d'informations",
    LUIE_STRING_LAM_PNL_PANELSCALE = "Échelle du panneau d'information, %",
    LUIE_STRING_LAM_PNL_PANELSCALE_TP = "Agrandit le panneau d'informations sur les écrans haute résolution.",
    LUIE_STRING_LAM_PNL_TRANSPARENCY = "Transparence du panneau, %",
    LUIE_STRING_LAM_PNL_TRANSPARENCY_TP = "Ajuste la transparence du panneau. 100 % = opaque, 0 % = transparent.",
    LUIE_STRING_LAM_PNL_HIDEINCOMBAT = "Masquer le panneau en combat",
    LUIE_STRING_LAM_PNL_HIDEINCOMBAT_TP = "Masque le panneau d'informations en combat. Il réapparaît à la fin du combat.",
    LUIE_STRING_LAM_PNL_RESETPOSITION_TP = "Réinitialisation de la position du panneau d'information dans le coin haut/droit de l'écran.",
    LUIE_STRING_LAM_PNL_SHOWARMORDURABILITY = "Afficher l'usage de l'armure",
    LUIE_STRING_LAM_PNL_SHOWBAGSPACE = "Afficher le remplissage des sacs",
    LUIE_STRING_LAM_PNL_SHOWCLOCK = "Afficher l'heure",
    LUIE_STRING_LAM_PNL_CLOCKFORMAT = "Format de l'horloge",
    LUIE_STRING_LAM_PNL_SHOWEAPONCHARGES = "Afficher les charges des armes",
    LUIE_STRING_LAM_PNL_SHOWFPS = "Afficher les FPS",
    LUIE_STRING_LAM_PNL_SHOWMEMORY = "Afficher l'utilisation mémoire",
    LUIE_STRING_LAM_PNL_SHOWMEMORY_TP = "Console : pool mémoire des extensions utilisé/capacité (Mo). PC : tas Lua via collectgarbage (approximatif, sans GC forcé).",
    LUIE_STRING_LAM_PNL_SHOWLATENCY = "Afficher la latence",
    LUIE_STRING_LAM_PNL_SHOWMOUNTTIMER = "Afficher l'état d'entrainement de la monture |c00FFFF*|r",
    LUIE_STRING_LAM_PNL_SHOWMOUNTTIMER_TP = "(*) Cette informations sera automatiquement masquée si la monture est entrainée au maximum de ses capacités.",
    LUIE_STRING_LAM_PNL_SHOWSOULGEMS = "Afficher le nombre de pierres d'âmes",
    LUIE_STRING_LAM_PNL_UNLOCKPANEL = "Déverrouiller le panneau d'informations",
    LUIE_STRING_LAM_PNL_UNLOCKPANEL_TP = "Permet le déplacement du panneau d'informations avec la souris.",
    LUIE_STRING_LAM_PNL_DISPLAYONWORLDMAP = "Afficher le panneau d'informations dans la fenêtre de la carte du monde",
    LUIE_STRING_LAM_PNL_DISPLAYONWORLDMAP_TP = "Affichez le panneau d'informations lorsque vous consultez la carte du monde. Cette option peut être activée si la position de votre panneau d'informations correspond à des éléments importants sur l'écran de la carte du monde.",
    LUIE_STRING_PNL_FPS_FORMAT = "<<1>> fps",
    LUIE_STRING_PNL_LATENCY_MS_FORMAT = "<<1>> ms",


}

LUIE_RegisterStrings(strings, true)
