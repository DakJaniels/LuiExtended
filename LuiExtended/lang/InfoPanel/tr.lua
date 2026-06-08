-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- InfoPanel localization (tr)
-- Translation locale: tr
local strings =
{
    LUIE_STRING_PNL_TRAINNOW = "Şimdi Eğitin",
    LUIE_STRING_PNL_MAXED = "Limite Ulaştı",
    LUIE_STRING_PNL_SHOWGOLD = "Altın Miktarını Göster",
    LUIE_STRING_LAM_PNL_ENABLE = "Bilgi Paneli Modülü",
    LUIE_STRING_LAM_PNL_DESCRIPTION = "Gecikme, saat, FPS, dayanıklılık, silah yükü gibi yararlı bilgileri gösteren bir panel sunar.",
    LUIE_STRING_LAM_PNL_DISABLECOLORSRO = "Salt okunur değerlerde renkleri devre dışı bırak",
    LUIE_STRING_LAM_PNL_DISABLECOLORSRO_TP = "Doğrudan kontrol edemediğiniz bilgi etiketlerinde değere bağlı rengi kapatır: şu an FPS, gecikme ve eklenti bellek havuzu kullanımı (konsol) etiketlerini kapsar.",
    LUIE_STRING_LAM_PNL_ELEMENTS_HEADER = "Bilgi paneli öğeleri",
    LUIE_STRING_LAM_PNL_HEADER = "Bilgi Paneli Seçenekleri",
    LUIE_STRING_LAM_PNL_PANELSCALE = "Bilgi Paneli Ölçeği, %",
    LUIE_STRING_LAM_PNL_PANELSCALE_TP = "Yüksek çözünürlüklü ekranlarda bilgi panelinin boyutunu büyütmek için kullanılır.",
    LUIE_STRING_LAM_PNL_TRANSPARENCY = "Bilgi Paneli Şeffaflığı, %",
    LUIE_STRING_LAM_PNL_TRANSPARENCY_TP = "Bilgi panelinin şeffaflığını ayarlar. %100 = tam opak, %0 = tam şeffaf.",
    LUIE_STRING_LAM_PNL_HIDEINCOMBAT = "Savaşta bilgi panelini gizle",
    LUIE_STRING_LAM_PNL_HIDEINCOMBAT_TP = "Savaşa girdiğinizde bilgi panelini gizler. Savaş bitince tekrar görünür.",
    LUIE_STRING_LAM_PNL_RESETPOSITION_TP = "Bilgi panelinin konumunu ekranın sağ üst köşesine sıfırlar.",
    LUIE_STRING_LAM_PNL_SHOWARMORDURABILITY = "Zırh dayanıklılığını göster",
    LUIE_STRING_LAM_PNL_SHOWBAGSPACE = "Çanta alanını göster",
    LUIE_STRING_LAM_PNL_SHOWCLOCK = "Saati göster",
    LUIE_STRING_LAM_PNL_CLOCKFORMAT = "Saat biçimi",
    LUIE_STRING_LAM_PNL_SHOWEAPONCHARGES = "Silah yüklerini göster",
    LUIE_STRING_LAM_PNL_SHOWFPS = "FPS göster",
    LUIE_STRING_LAM_PNL_SHOWMEMORY = "Bellek kullanımını göster",
    LUIE_STRING_LAM_PNL_SHOWMEMORY_TP = "Konsol: eklenti bellek havuzu kullanılan/kapasite (MB). PC: collectgarbage Lua yığın boyutu (yaklaşık, zorunlu GC yok).",
    LUIE_STRING_LAM_PNL_SHOWLATENCY = "Gecikmeyi göster",
    LUIE_STRING_LAM_PNL_SHOWMOUNTTIMER = "Binek besleme zamanlayıcısını göster |c00FFFF*|r",
    LUIE_STRING_LAM_PNL_SHOWMOUNTTIMER_TP = "(*) Bineğinizi en üst seviyeye eğittiğinizde bu alan geçerli karakter için otomatik gizlenir.",
    LUIE_STRING_LAM_PNL_SHOWSOULGEMS = "Ruh taşlarını göster",
    LUIE_STRING_LAM_PNL_UNLOCKPANEL = "Paneli kilidi aç",
    LUIE_STRING_LAM_PNL_UNLOCKPANEL_TP = "Bilgi panelinin fare ile sürüklenmesine izin verir.",
    LUIE_STRING_LAM_PNL_DISPLAYONWORLDMAP = "Dünya haritasında bilgi panelini göster",
    LUIE_STRING_LAM_PNL_DISPLAYONWORLDMAP_TP = "Dünya haritasına bakarken bilgi panelini gösterir. Konum önemli öğelerle çakışıyorsa kapatılabilir.",

}

LUIE_RegisterStrings(strings, true)
