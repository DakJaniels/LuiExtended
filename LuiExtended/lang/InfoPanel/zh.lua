-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- InfoPanel localization (zh)
-- Translation locale: zh
local strings =
{
    LUIE_STRING_PNL_TRAINNOW = "立即训练",
    LUIE_STRING_PNL_MAXED = "已满",
    LUIE_STRING_PNL_SHOWGOLD = "显示金币数量",
    LUIE_STRING_LAM_PNL_ENABLE = "信息面板模块",
    LUIE_STRING_LAM_PNL_DESCRIPTION = "在面板上展示延迟、时间、FPS、耐久度和武器充能等数值",
    LUIE_STRING_LAM_PNL_DISABLECOLORSRO = "禁用只读数值的颜色",
    LUIE_STRING_LAM_PNL_DISABLECOLORSRO_TP = "禁用无法直接控制的信息标签的数值相关颜色设置，目前包括FPS、延迟以及插件内存池占用（主机）。",
    LUIE_STRING_LAM_PNL_ELEMENTS_HEADER = "信息面板元素",
    LUIE_STRING_LAM_PNL_HEADER = "信息面板选项",
    LUIE_STRING_LAM_PNL_PANELSCALE = "信息面板缩放，%",
    LUIE_STRING_LAM_PNL_PANELSCALE_TP = "用于在大分辨率显示器上放大信息面板的大小。",
    LUIE_STRING_LAM_PNL_TRANSPARENCY = "信息面板透明度，%",
    LUIE_STRING_LAM_PNL_TRANSPARENCY_TP = "调整信息面板透明度。100% = 完全不透明，0% = 完全透明。",
    LUIE_STRING_LAM_PNL_HIDEINCOMBAT = "战斗中隐藏信息面板",
    LUIE_STRING_LAM_PNL_HIDEINCOMBAT_TP = "进入战斗时隐藏信息面板，战斗结束后再次显示。",
    LUIE_STRING_LAM_PNL_RESETPOSITION_TP = "这将把信息面板重置到屏幕右上角。",
    LUIE_STRING_LAM_PNL_SHOWARMORDURABILITY = "显示护甲耐久度",
    LUIE_STRING_LAM_PNL_SHOWBAGSPACE = "显示背包空间",
    LUIE_STRING_LAM_PNL_SHOWCLOCK = "显示时钟",
    LUIE_STRING_LAM_PNL_CLOCKFORMAT = "时钟格式",
    LUIE_STRING_LAM_PNL_SHOWEAPONCHARGES = "显示武器充能",
    LUIE_STRING_LAM_PNL_SHOWFPS = "显示FPS",
    LUIE_STRING_LAM_PNL_SHOWMEMORY = "显示内存占用",
    LUIE_STRING_LAM_PNL_SHOWMEMORY_TP = "主机：插件内存池已用/上限（MB）。PC：collectgarbage 的 Lua 堆大小（近似值，不强制 GC）。",
    LUIE_STRING_LAM_PNL_SHOWLATENCY = "显示延迟",
    LUIE_STRING_LAM_PNL_SHOWMOUNTTIMER = "显示坐骑喂养计时器 |c00FFFF*|r",
    LUIE_STRING_LAM_PNL_SHOWMOUNTTIMER_TP = "(*) 当前角色坐骑训练到最高级别后，这个字段将自动隐藏。",
    LUIE_STRING_LAM_PNL_SHOWSOULGEMS = "显示灵魂宝石",
    LUIE_STRING_LAM_PNL_UNLOCKPANEL = "解锁面板",
    LUIE_STRING_LAM_PNL_UNLOCKPANEL_TP = "允许鼠标拖动信息面板。",
    LUIE_STRING_LAM_PNL_DISPLAYONWORLDMAP = "在世界地图屏幕上显示信息面板",
    LUIE_STRING_LAM_PNL_DISPLAYONWORLDMAP_TP = "在查看世界地图时显示信息面板。如果信息面板位置与世界地图屏幕上的任何重要元素重叠，可以切换此选项。",
    LUIE_STRING_PNL_FPS_FORMAT = "<<1>> 帧率",
    LUIE_STRING_PNL_LATENCY_MS_FORMAT = "<<1>> 毫秒",


}

LUIE_RegisterStrings(strings, true)
