-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- Assistant unit names. Other LuiData strings stay on the English defaults.
local strings =
{
    LUIE_STRING_PET_NAME_ASSISTANT_EZABI = "依扎比",
    LUIE_STRING_PET_NAME_ASSISTANT_FEZEZ = "费泽兹",
    LUIE_STRING_PET_NAME_ASSISTANT_PIRHARRI = "走私者皮尔哈利",
    LUIE_STRING_PET_NAME_ASSISTANT_GHRASHAROG = "戈拉斯瑞格",
    LUIE_STRING_PET_NAME_ASSISTANT_GILADIL = "拾荒者吉拉迪尔",
    LUIE_STRING_PET_NAME_ASSISTANT_NUZHIMEH = "努兹梅",
    LUIE_STRING_PET_NAME_ASSISTANT_TYTHIS = "泰迪斯·安卓莫",
    LUIE_STRING_PET_NAME_ASSISTANT_BARON = "詹格勒男爵",
    LUIE_STRING_PET_NAME_ASSISTANT_PEDDLER = "奖品贩子",
    LUIE_STRING_PET_NAME_ASSISTANT_FACTOTUMB = "机械人财产总管",
    LUIE_STRING_PET_NAME_ASSISTANT_FACTOTUMM = "机械人商务代表",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
