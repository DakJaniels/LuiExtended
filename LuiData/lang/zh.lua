-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- Assistant unit names, plus LuiData strings whose English text changed.
-- Every other LuiData string stays on the English default.
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

    LUIE_STRING_SKILL_MUNDUS_BASIC_WARRIOR = "使武器和法术伤害提高|cFFFFFF238|r。",
    LUIE_STRING_SKILL_MUNDUS_BASIC_APPRENTICE = "提高经验和灵感获取。",
    LUIE_STRING_SKILL_BATTLE_SPIRIT_TP = "• 受到的伤害、护盾强度和生命恢复降低|cFFFFFF50|r%\n• 伤害护盾强度上限为|cFFFFFF300%|r，基于你最大生命值的|cFFFFFF300|r%。超过4名小队成员后，每增加一名成员都会降低\n• 受到的治疗降低|cFFFFFF55|r%\n• 当|cFFFFFF8|r个或更多持续治疗效果处于激活状态时，受到的治疗再降低|cFFFFFF33|r%\n• 技能范围在|cFFFFFF28|r米或以上时，该范围扩大|cFFFFFF8|r",
    LUIE_STRING_SKILL_BATTLE_SPIRIT_IMPERIAL_CITY_TP = "• 受到的伤害、护盾强度和生命恢复降低|cFFFFFF50|r%\n• 伤害护盾强度上限为|cFFFFFF300%|r，基于你最大生命值的|cFFFFFF300|r%。超过4名小队成员后，每增加一名成员都会降低。\n• 受到的治疗降低|cFFFFFF55|r%\n• 当|cFFFFFF8|r个或更多持续治疗效果处于激活状态时，受到的治疗再降低|cFFFFFF33|r%",
    LUIE_STRING_SKILL_MINOR_BRUTALITY_TP = "使武器和法术伤害提高|cFFFFFF10|r%。",
    LUIE_STRING_SKILL_MAJOR_BRUTALITY_TP = "使武器和法术伤害提高|cFFFFFF20|r%。",
    LUIE_STRING_SKILL_MINOR_SAVAGERY_TP = "使暴击等级提高|cFFFFFF1314|r，使暴击率提高|cFFFFFF6|r%。",
    LUIE_STRING_SKILL_MAJOR_SAVAGERY_TP = "使暴击等级提高|cFFFFFF2629|r，使暴击率提高|cFFFFFF12|r%。",
    LUIE_STRING_SKILL_MINOR_FORCE_TP = "使造成的暴击伤害提高|cFFFFFF10|r%。",
    LUIE_STRING_SKILL_MAJOR_FORCE_TP = "使造成的暴击伤害提高|cFFFFFF20|r%。",
    LUIE_STRING_Skill_Gallop_TP = "使坐骑速度提高|cFFFFFF15|r%。",
    LUIE_STRING_SKILL_MINOR_HEROISM_TP = "战斗中每|cFFFFFF1.5|r秒获得|cFFFFFF1|r终极点。",
    LUIE_STRING_SKILL_MAJOR_HEROISM_TP = "战斗中每|cFFFFFF1.5|r秒获得|cFFFFFF3|r终极点。",
    LUIE_STRING_SKILL_MINOR_MAGICKASTEAL_TP = "攻击你的敌人将回复魔力。",
    LUIE_STRING_SKILL_MINOR_MAGICKASTEAL_OTHER_TP = "受到伤害时回复魔力。",
    LUIE_STRING_SKILL_MINOR_LIFESTEAL_TP = "攻击你的敌人将被治疗。",
    LUIE_STRING_SKILL_MINOR_LIFESTEAL_OTHER_TP = "受到伤害时被治疗。",
    LUIE_STRING_SKILL_MINOR_TIMIDITY_TP = "战斗中每|cFFFFFF1.5|r秒消耗|cFFFFFF1|r终极点。",
    LUIE_STRING_SKILL_EMPOWER_TP = "重攻击造成的伤害提高|cFFFFFF70|r%。已激活战斗意志时不会生效。",
    LUIE_STRING_SKILL_MINOR_VITALITY_TP = "使受到的治疗和伤害护盾强度提高|cFFFFFF6|r%。",
    LUIE_STRING_SKILL_MAJOR_VITALITY_TP = "使受到的治疗和伤害护盾强度提高|cFFFFFF12|r%。",
    LUIE_STRING_SKILL_MINOR_DEFILE_TP = "使受到的治疗和伤害护盾强度降低|cFFFFFF6|r%。",
    LUIE_STRING_SKILL_MAJOR_DEFILE_TP = "使受到的治疗和伤害护盾强度降低|cFFFFFF12|r%。",
    LUIE_STRING_SKILL_MINOR_UNCERTAINTY_TP = "使武器和法术暴击等级降低|cFFFFFF1314|r，使武器和法术暴击率降低|cFFFFFF6|r%。",
    LUIE_STRING_SKILL_EARTHSPIKE_MANTLE_TP = "对怪物造成的伤害提高，并获得Major Resolve，持续|cFFFFFF<<1>>|r<<1[秒/秒]>>。",
    LUIE_STRING_SKILL_EARTHSHIELD_MANTLE_TP = "对怪物造成的伤害提高，并获得Major Resolve，持续|cFFFFFF<<1>>|r<<1[秒/秒]>>。\n\n伤害护盾吸收伤害，持续|cFFFFFF6|r秒，并基于你的最大生命值。",
    LUIE_STRING_SKILL_SHATTERSPIKE_MANTLE_TP = "对怪物造成的伤害提高，并获得Major Resolve，持续|cFFFFFF<<1>>|r<<1[秒/秒]>>。\n\n以碎裂黑曜石轰击附近敌人，在|cFFFFFF20|r秒内造成火焰伤害。",
    LUIE_STRING_SKILL_CRYSTAL_WEAPON_TP = "接下来|cFFFFFF3|r次轻击或重击在|cFFFFFF<<1>>|r<<1[秒/秒]>>内造成额外物理伤害，并使目标护甲降低|cFFFFFF1000|r，持续|cFFFFFF5|r秒。第一次命中的伤害更高。\n\n效果激活时你无法隐藏自己。\n\n施放后，你的下一个非终极技能消耗更低。",
    LUIE_STRING_SKILL_FETCHER_INFECTION_BONUS_DAMAGE_TP = "你的下一次Fetcher Infection造成的伤害提高|cFFFFFF75|r%。",
    LUIE_STRING_SKILL_RALLY_TP = "Rally结束时你会受到治疗。最终治疗量每|cFFFFFF1|r秒提高|cFFFFFF15|r%，最高|cFFFFFF200|r%。",
    LUIE_STRING_SKILL_HEALING_SPRINGS = "每|cFFFFFF1|r秒治疗你和|cFFFFFF<<2>>|r米范围内的盟友。\n\n每有一个受影响的目标，你的法力恢复就会提高，最多叠加|cFFFFFF20|r次。",
    LUIE_STRING_SKILL_MIST_FORM_TP = "向前冲刺时，接下来的|cFFFFFF3|r个投射物不会对你造成伤害。\n\n不久后再次施放会消耗更多法力。",
    LUIE_STRING_SKILL_BLOOD_MIST_TP = "向前冲刺时，接下来的|cFFFFFF3|r个投射物不会对你造成伤害。\n\n你汲取附近敌人的鲜血，造成持续伤害，并按造成伤害的一部分治疗自己。",
    LUIE_STRING_SKILL_LYCANTHROPHY_TP = "你可以变身为野蛮的狼人。\n\n变身期间受到的毒素伤害提高|cFFFFFF15|r%。",
    LUIE_STRING_SKILL_PROPELLING_SHIELD_TP = "使攻城器械伤害降低|cFFFFFF50|r%，并使射程大于|cFFFFFF28|r米的技能射程提高|cFFFFFF7|r米。\n\n不影响跳跃、位移和拉拽技能。",
    LUIE_STRING_SKILL_PROPELLING_SHIELD_GROUND_TP = "防护球体使你和盟友在|cFFFFFF10|r米内受到的攻城器械伤害降低|cFFFFFF50|r%。\n\n球体内射程大于|cFFFFFF28|r米的技能射程提高|cFFFFFF7|r米。\n\n不影响跳跃、位移和拉拽技能。",
    LUIE_STRING_SKILL_SET_BLACKROSE_DESTRO_TP = "Impulse的伤害为每个不同的燃烧、震击和冰冻层数提高|cFFFFFF10|r%。",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
