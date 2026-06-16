-- -----------------------------------------------------------------------------
--  LuiExtended — MiniMap localization (zh)
-- -----------------------------------------------------------------------------

local strings =
{
    LUIE_STRING_LAM_MINIMAP = "MiniMap (BETA)",
    LUIE_STRING_LAM_MINIMAP_DESCRIPTION = "启用并配置小地图模块。",
    LUIE_STRING_LAM_MINIMAP_ENABLE = "启用小地图",
    LUIE_STRING_LAM_MINIMAP_ENABLE_TP = "开关小地图模块。需要重新加载界面。",
    LUIE_STRING_LAM_MINIMAP_ZOOM = "默认缩放 (%)",
    LUIE_STRING_LAM_MINIMAP_ZOOM_TP = "重置时的默认缩放。不能低于将整个区域放入框内的级别（随地图与小地图尺寸变化）。",
    LUIE_STRING_LAM_MINIMAP_PINSCALE = "默认图钉缩放 (%)",
    LUIE_STRING_LAM_MINIMAP_PINSCALE_TP = "缩放地图图标（POI、队伍、世界事件等）。不改变任务区域圆环大小。",
    LUIE_STRING_LAM_MINIMAP_PLAYERPINSCALE = "玩家图钉大小 (%)",
    LUIE_STRING_LAM_MINIMAP_PLAYERPINSCALE_TP = "居中玩家图钉（跟随开）与地图上的玩家图钉（跟随关）的大小。以世界地图 16 像素为基准。",
    LUIE_STRING_LAM_MINIMAP_RESETPOSITION_TP = "将小地图位置重置为默认。",
    LUIE_STRING_LAM_MINIMAP_FOLLOW_PLAYER = "跟随玩家",
    LUIE_STRING_LAM_MINIMAP_FOLLOW_PLAYER_TP = "默认将地图以玩家为中心。拖动平移地图不会更改此设置（直至重新居中或在此切换）。",
    LUIE_STRING_LAM_MINIMAP_LOCK_POSITION = "锁定位置",
    LUIE_STRING_LAM_MINIMAP_LOCK_POSITION_TP = "禁止拖动小地图框体。",
    LUIE_STRING_LAM_MINIMAP_LOCK_SIZE = "锁定大小",
    LUIE_STRING_LAM_MINIMAP_LOCK_SIZE_TP = "禁止调整小地图大小。",
    LUIE_STRING_LAM_MINIMAP_WAYPOINT_SHIFT = "路径点需按住 Shift",
    LUIE_STRING_LAM_MINIMAP_WAYPOINT_SHIFT_TP = "启用时：Shift+点击设置路径点。禁用时：未拖动时的点击设置路径点。",
    LUIE_STRING_LAM_MINIMAP_SHOW_ZOOM_BUTTONS = "显示缩放按钮",
    LUIE_STRING_LAM_MINIMAP_SHOW_ZOOM_BUTTONS_TP = "在地图上显示放大/缩小按钮。",
    LUIE_STRING_LAM_MINIMAP_ADVANCED_HEADER = "高级选项",
    LUIE_STRING_LAM_MINIMAP_ADVANCED_DESC = "更多小地图高级选项将在后续更新中提供。",
    LUIE_STRING_LAM_MINIMAP_PIN_MIRROR_STATE_MACHINE_DEBUG = "图钉镜像状态机调试",
    LUIE_STRING_LAM_MINIMAP_PIN_MIRROR_STATE_MACHINE_DEBUG_TP = "在聊天中记录 ZO_StateMachine 的图钉镜像、地图重载与快速旅行过渡。",
    LUIE_STRING_LAM_MINIMAP_ANCHOR_INFOPANEL = "将信息面板锚定到小地图",
    LUIE_STRING_LAM_MINIMAP_ANCHOR_INFOPANEL_TP = "将信息面板放在地图下方（原区域名位置），并把区域名移到地图上方。启用后由小地图控制位置。需要信息面板模块。",
    LUIE_STRING_LAM_MINIMAP_SHOW_ZONE_NAME = "显示区域名称",
    LUIE_STRING_LAM_MINIMAP_SHOW_ZONE_NAME_TP = "显示当前地图区域名。悬停小地图时使用左下角控件拖动框架。",
    LUIE_STRING_MINIMAP_FRAME_MOVE_TP = "拖动以移动小地图。",
    LUIE_STRING_MINIMAP_FRAME_LOCK_TP = "锁定或解锁小地图位置。",
    LUIE_STRING_LAM_MINIMAP_COMPASS_OVERRIDE_DEFAULT = "使用游戏默认",
    LUIE_STRING_LAM_MINIMAP_COMPASS_OVERRIDE_HIDE = "在 HUD 上隐藏罗盘",
    LUIE_STRING_LAM_MINIMAP_COMPASS_OVERRIDE_SHOW = "在 HUD 上显示罗盘",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
SafeAddVersion("LUIE_STRING_LAM_MINIMAP_PINSCALE_TP", 2)
