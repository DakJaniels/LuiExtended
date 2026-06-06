-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- InfoPanel localization (default)
-- Translation by: <default>
local strings =
{
    LUIE_STRING_PNL_TRAINNOW = "Train Now",
    LUIE_STRING_PNL_MAXED = "Maxed",
    LUIE_STRING_PNL_SHOWGOLD = "Show Gold Amount",
    LUIE_STRING_LAM_PNL_ENABLE = "Info Panel Module",
    LUIE_STRING_LAM_PNL_DESCRIPTION = "Displays a panel with potentially useful information on it such as Latency, Time, FPS, Durability and Weapon Charge, etc...",
    LUIE_STRING_LAM_PNL_DISABLECOLORSRO = "Disable colors on read-only values",
    LUIE_STRING_LAM_PNL_DISABLECOLORSRO_TP = "Disable value-dependent color of the information label for items that you don't have direct control: Currently this includes FPS, Latency, and add-on memory pool usage (console) labels.",
    LUIE_STRING_LAM_PNL_ELEMENTS_HEADER = "Info Panel elements",
    LUIE_STRING_LAM_PNL_HEADER = "Info Panel Options",
    LUIE_STRING_LAM_PNL_PANELSCALE = "Info Panel Scale, %",
    LUIE_STRING_LAM_PNL_PANELSCALE_TP = "Used to magnify size of Info Panel on large resolution displays.",
    LUIE_STRING_LAM_PNL_TRANSPARENCY = "Info Panel Transparency, %",
    LUIE_STRING_LAM_PNL_TRANSPARENCY_TP = "Adjust the transparency of the Info Panel. 100% = fully opaque, 0% = fully transparent.",
    LUIE_STRING_LAM_PNL_RESETPOSITION_TP = "This will reset position of Info Panel into screen top right corner.",
    LUIE_STRING_LAM_PNL_SHOWARMORDURABILITY = "Show Armour Durability",
    LUIE_STRING_LAM_PNL_SHOWBAGSPACE = "Show Bags Space",
    LUIE_STRING_LAM_PNL_SHOWCLOCK = "Show Clock",
    LUIE_STRING_LAM_PNL_CLOCKFORMAT = "Clock Format",
    LUIE_STRING_LAM_PNL_SHOWEAPONCHARGES = "Show Weapons Charges",
    LUIE_STRING_LAM_PNL_SHOWFPS = "Show FPS",
    LUIE_STRING_LAM_PNL_SHOWMEMORY = "Show Memory Usage",
    LUIE_STRING_LAM_PNL_SHOWMEMORY_TP = "Console: add-on memory pool used/capacity (MB). PC: Lua heap size from collectgarbage (approximate, no forced GC).",
    LUIE_STRING_LAM_PNL_SHOWLATENCY = "Show Latency",
    LUIE_STRING_LAM_PNL_SHOWMOUNTTIMER = "Show Mount Feed Timer |c00FFFF*|r",
    LUIE_STRING_LAM_PNL_SHOWMOUNTTIMER_TP = "(*) Once you have trained your mount to maximum level this field will be automatically hidden for current character.",
    LUIE_STRING_LAM_PNL_SHOWSOULGEMS = "Show Soul Gems",
    LUIE_STRING_LAM_PNL_UNLOCKPANEL = "Unlock panel",
    LUIE_STRING_LAM_PNL_UNLOCKPANEL_TP = "Allow mouse dragging for Info Panel.",
    LUIE_STRING_LAM_PNL_DISPLAYONWORLDMAP = "Display Info Panel on World Map Screen",
    LUIE_STRING_LAM_PNL_DISPLAYONWORLDMAP_TP = "Display the Info Panel when you are viewing the world map. This option can be toggled if your Info Panel position clips with any important elements on the World Map screen.",
    LUIE_STRING_LAM_PNL_HIDEINCOMBAT = "Hide Info Panel in combat",
    LUIE_STRING_LAM_PNL_HIDEINCOMBAT_TP = "Hide the Info Panel when you enter combat. It becomes visible again when combat ends.",
    LUIE_STRING_PNL_FPS_FORMAT = "<<1>> fps",
    LUIE_STRING_PNL_LATENCY_MS_FORMAT = "<<1>> ms",

}

LUIE_RegisterStrings(strings, false)
