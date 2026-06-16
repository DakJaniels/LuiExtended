-- -----------------------------------------------------------------------------
--  LuiExtended — MiniMap localization (fr)
-- -----------------------------------------------------------------------------

local strings =
{
    LUIE_STRING_LAM_MINIMAP = "MiniMap (BETA)",
    LUIE_STRING_LAM_MINIMAP_DESCRIPTION = "Activer et configurer le module Mini-carte.",
    LUIE_STRING_LAM_MINIMAP_ENABLE = "Activer la mini-carte",
    LUIE_STRING_LAM_MINIMAP_ENABLE_TP = "Active ou désactive le module. Nécessite un rechargement de l'interface.",
    LUIE_STRING_LAM_MINIMAP_ZOOM = "Zoom par défaut (%)",
    LUIE_STRING_LAM_MINIMAP_ZOOM_TP = "Zoom par défaut au reset. Ne peut pas être inférieur au niveau qui affiche toute la zone dans le cadre (selon la carte et la taille de la mini-carte).",
    LUIE_STRING_LAM_MINIMAP_PINSCALE = "Échelle des pins par défaut (%)",
    LUIE_STRING_LAM_MINIMAP_PINSCALE_TP = "Échelle des icônes (POI, groupe, événements mondiaux, etc.). N'affecte pas les cercles de zone de quête.",
    LUIE_STRING_LAM_MINIMAP_PLAYERPINSCALE = "Taille du pip joueur (%)",
    LUIE_STRING_LAM_MINIMAP_PLAYERPINSCALE_TP = "Taille du pip joueur centré (suivi activé) et du pin sur la carte (suivi désactivé). Base : 16 px comme la carte du monde.",
    LUIE_STRING_LAM_MINIMAP_RESETPOSITION_TP = "Réinitialiser la position de la mini-carte.",
    LUIE_STRING_LAM_MINIMAP_FOLLOW_PLAYER = "Suivre le joueur",
    LUIE_STRING_LAM_MINIMAP_FOLLOW_PLAYER_TP = "Par défaut : centrer la carte sur vous. Glisser pour déplacer la carte sans modifier ce réglage (jusqu'au recentrage ou à ce bouton).",
    LUIE_STRING_LAM_MINIMAP_LOCK_POSITION = "Verrouiller la position",
    LUIE_STRING_LAM_MINIMAP_LOCK_POSITION_TP = "Empêche de déplacer le cadre de la mini-carte.",
    LUIE_STRING_LAM_MINIMAP_LOCK_SIZE = "Verrouiller la taille",
    LUIE_STRING_LAM_MINIMAP_LOCK_SIZE_TP = "Empêche de redimensionner la mini-carte.",
    LUIE_STRING_LAM_MINIMAP_WAYPOINT_SHIFT = "Point de passage avec Maj",
    LUIE_STRING_LAM_MINIMAP_WAYPOINT_SHIFT_TP = "Si activé : Maj+clic place un point de passage. Sinon : un clic sans glisser en place un.",
    LUIE_STRING_LAM_MINIMAP_SHOW_ZOOM_BUTTONS = "Afficher les boutons zoom",
    LUIE_STRING_LAM_MINIMAP_SHOW_ZOOM_BUTTONS_TP = "Affiche les boutons zoom + et − sur la carte.",
    LUIE_STRING_LAM_MINIMAP_ADVANCED_HEADER = "Options avancées",
    LUIE_STRING_LAM_MINIMAP_ADVANCED_DESC = "D'autres options avancées seront ajoutées ultérieurement.",
    LUIE_STRING_LAM_MINIMAP_PIN_MIRROR_STATE_MACHINE_DEBUG = "Débogage machine à états (pins)",
    LUIE_STRING_LAM_MINIMAP_PIN_MIRROR_STATE_MACHINE_DEBUG_TP = "Journalise les transitions ZO_StateMachine pour le miroir des pins, le rechargement de carte et le voyage rapide.",
    LUIE_STRING_LAM_MINIMAP_ANCHOR_INFOPANEL = "Ancrer le panneau d'info à la mini-carte",
    LUIE_STRING_LAM_MINIMAP_ANCHOR_INFOPANEL_TP = "Place le panneau d'info sous la carte (emplacement du nom de zone) et le titre de zone au-dessus de la carte. Position contrôlée par la mini-carte. Nécessite le module InfoPanel.",
    LUIE_STRING_LAM_MINIMAP_SHOW_ZONE_NAME = "Afficher le nom de zone",
    LUIE_STRING_LAM_MINIMAP_SHOW_ZONE_NAME_TP = "Affiche le nom de la carte actuelle. Déplacez le cadre avec le contrôle en bas à gauche au survol.",
    LUIE_STRING_MINIMAP_FRAME_MOVE_TP = "Glisser pour déplacer la mini-carte.",
    LUIE_STRING_MINIMAP_FRAME_LOCK_TP = "Verrouiller ou déverrouiller la position de la mini-carte.",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
SafeAddVersion("LUIE_STRING_LAM_MINIMAP_PINSCALE_TP", 2)
