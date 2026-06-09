-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- InfoPanel localization (ru)
-- Translation locale: ru
local strings =
{
    LUIE_STRING_PNL_TRAINNOW = "Покормить",
    LUIE_STRING_PNL_MAXED = "Макс.",
    LUIE_STRING_PNL_SHOWGOLD = "Показывать золото",
    LUIE_STRING_LAM_PNL_ENABLE = "Инфо-панель",
    LUIE_STRING_LAM_PNL_DESCRIPTION = "Показывает панель с потенциально полезной информацией, такой как: задержка, время, FPS, прочность брони, заряд оружия и прочее...",
    LUIE_STRING_LAM_PNL_DISABLECOLORSRO = "Отключить цвет значений только для чтения",
    LUIE_STRING_LAM_PNL_DISABLECOLORSRO_TP = "Отключает цвет в зависимости от значения для таких вещей, которые игрок не может контролировать: На текущий момент это включает FPS, задержку (пинг) и использование пула памяти модификаций (консоль).",
    LUIE_STRING_LAM_PNL_ELEMENTS_HEADER = "Элементы Инфо-панели",
    LUIE_STRING_LAM_PNL_HEADER = "Настройки Инфо-панели",
    LUIE_STRING_LAM_PNL_PANELSCALE = "Масштаб, %",
    LUIE_STRING_LAM_PNL_PANELSCALE_TP = "Используется для изменения масштаба инфо-панели на экранах с большим разрешением.",
    LUIE_STRING_LAM_PNL_TRANSPARENCY = "Прозрачность инфо-панели, %",
    LUIE_STRING_LAM_PNL_TRANSPARENCY_TP = "Настройка прозрачности инфо-панели. 100 % = непрозрачно, 0 % = полностью прозрачно.",
    LUIE_STRING_LAM_PNL_HIDEINCOMBAT = "Скрывать инфо-панель в бою",
    LUIE_STRING_LAM_PNL_HIDEINCOMBAT_TP = "Скрывает инфо-панель при входе в бой. Снова появляется после окончания боя.",
    LUIE_STRING_LAM_PNL_RESETPOSITION_TP = "Это сбросит положение Инфо-панели в верхний правый угол.",
    LUIE_STRING_LAM_PNL_SHOWARMORDURABILITY = "Прочность брони",
    LUIE_STRING_LAM_PNL_SHOWBAGSPACE = "Сумка",
    LUIE_STRING_LAM_PNL_SHOWCLOCK = "Часы",
    LUIE_STRING_LAM_PNL_CLOCKFORMAT = "Формат часов",
    LUIE_STRING_LAM_PNL_SHOWEAPONCHARGES = "Заряд оружия",
    LUIE_STRING_LAM_PNL_SHOWFPS = "FPS",
    LUIE_STRING_LAM_PNL_SHOWMEMORY = "Использование памяти",
    LUIE_STRING_LAM_PNL_SHOWMEMORY_TP = "Консоль: пул памяти модификаций использовано/лимит (МБ). PC: куча Lua через collectgarbage (приблизительно, без принудительного GC).",
    LUIE_STRING_LAM_PNL_SHOWLATENCY = "Задержка",
    LUIE_STRING_LAM_PNL_SHOWMOUNTTIMER = "Таймер уроков верховой езды |c00FFFF*|r",
    LUIE_STRING_LAM_PNL_SHOWMOUNTTIMER_TP = "(*)Как только вы достигнете максимальных значений, эта настройка окажется автоматически скрыта.",
    LUIE_STRING_LAM_PNL_SHOWSOULGEMS = "Камни душ",
    LUIE_STRING_LAM_PNL_UNLOCKPANEL = "Разблокировать панель",
    LUIE_STRING_LAM_PNL_UNLOCKPANEL_TP = "Позволяет мышью перемещать Инфо-панель.",
    LUIE_STRING_LAM_PNL_DISPLAYONWORLDMAP = "Отображение Инфо-панели на экране карты мира",
    LUIE_STRING_LAM_PNL_DISPLAYONWORLDMAP_TP = "Отображение Инфо-панели при просмотре карты мира. Эта опция может быть выключена, если ваша Инфо-панель обрезает какие-либо важные элементы на экране карты мира.",
    LUIE_STRING_PNL_FPS_FORMAT = "<<1>> кадров в секунду",
    LUIE_STRING_PNL_LATENCY_MS_FORMAT = "<<1>> мс",


}

LUIE_RegisterStrings(strings, true)
