-- -----------------------------------------------------------------------------
--  LuiExtended — MiniMap localization (ru)
-- -----------------------------------------------------------------------------

local strings =
{
    LUIE_STRING_LAM_MINIMAP = "MiniMap (BETA)",
    LUIE_STRING_LAM_MINIMAP_DESCRIPTION = "Включить и настроить модуль мини-карты.",
    LUIE_STRING_LAM_MINIMAP_ENABLE = "Включить мини-карту",
    LUIE_STRING_LAM_MINIMAP_ENABLE_TP = "Включает или отключает модуль. Требуется перезагрузка интерфейса.",
    LUIE_STRING_LAM_MINIMAP_ZOOM = "Масштаб по умолчанию (%)",
    LUIE_STRING_LAM_MINIMAP_ZOOM_TP = "Масштаб по умолчанию при сбросе. Не ниже уровня, при котором вся зона помещается в рамку (зависит от карты и размера миникарты).",
    LUIE_STRING_LAM_MINIMAP_PINSCALE = "Размер меток по умолчанию (%)",
    LUIE_STRING_LAM_MINIMAP_PINSCALE_TP = "Масштаб значков (POI, группа, мировые события и т.д.). Круги зон квестов не меняются.",
    LUIE_STRING_LAM_MINIMAP_PLAYERPINSCALE = "Размер метки игрока (%)",
    LUIE_STRING_LAM_MINIMAP_PLAYERPINSCALE_TP = "Размер центральной метки (следование вкл.) и метки на карте (следование выкл.). База: 16 px, как на карте мира.",
    LUIE_STRING_LAM_MINIMAP_RESETPOSITION_TP = "Сбросить положение мини-карты.",
    LUIE_STRING_LAM_MINIMAP_FOLLOW_PLAYER = "Следовать за игроком",
    LUIE_STRING_LAM_MINIMAP_FOLLOW_PLAYER_TP = "По умолчанию центрировать карту на игроке. Перетаскивание смещает карту, не меняя эту настройку (до повторного центрирования или переключения здесь).",
    LUIE_STRING_LAM_MINIMAP_LOCK_POSITION = "Заблокировать позицию",
    LUIE_STRING_LAM_MINIMAP_LOCK_POSITION_TP = "Запретить перемещение рамки мини-карты.",
    LUIE_STRING_LAM_MINIMAP_LOCK_SIZE = "Заблокировать размер",
    LUIE_STRING_LAM_MINIMAP_LOCK_SIZE_TP = "Запретить изменение размера мини-карты.",
    LUIE_STRING_LAM_MINIMAP_WAYPOINT_SHIFT = "Метка с Shift",
    LUIE_STRING_LAM_MINIMAP_WAYPOINT_SHIFT_TP = "Если включено: Shift+клик ставит метку. Иначе: клик без перетаскивания ставит метку.",
    LUIE_STRING_LAM_MINIMAP_SHOW_ZOOM_BUTTONS = "Кнопки масштаба",
    LUIE_STRING_LAM_MINIMAP_SHOW_ZOOM_BUTTONS_TP = "Показывать кнопки «+» и «−» на карте.",
    LUIE_STRING_LAM_MINIMAP_ADVANCED_HEADER = "Дополнительные параметры",
    LUIE_STRING_LAM_MINIMAP_ADVANCED_DESC = "Дополнительные параметры мини-карты появятся в будущих обновлениях.",
    LUIE_STRING_LAM_MINIMAP_PIN_MIRROR_STATE_MACHINE_DEBUG = "Отладка конечного автомата меток",
    LUIE_STRING_LAM_MINIMAP_PIN_MIRROR_STATE_MACHINE_DEBUG_TP = "Выводить в чат переходы ZO_StateMachine для зеркалирования меток, перезагрузки карты и быстрого перемещения.",
    LUIE_STRING_LAM_MINIMAP_SHOW_COMPASS_PARITY_PINS = "Метки квестов (как на компасе)",
    LUIE_STRING_LAM_MINIMAP_SHOW_COMPASS_PARITY_PINS_TP = "Рисует метки квестов на миникарте, если нативные метки отсутствуют, по тем же данным, что и компас.",
    LUIE_STRING_LAM_MINIMAP_FORCE_QUEST_PINS = "Принудительно показывать квесты",
    LUIE_STRING_LAM_MINIMAP_FORCE_QUEST_PINS_TP = "Показывать метки квестов на миникарте, даже если фильтр квестов на карте мира выключен.",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
SafeAddVersion("LUIE_STRING_LAM_MINIMAP_PINSCALE_TP", 2)
