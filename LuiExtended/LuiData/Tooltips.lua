-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData
local Data = LuiData.Data

local GetAbilityDescription = GetAbilityDescription
local GetAbilityDuration = GetAbilityDuration
local GetAbilityName = GetAbilityName
local GetCollectibleDescription = GetCollectibleDescription
local GetItemLinkOnUseAbilityDescription = GetItemLinkOnUseAbilityDescription
local GetNumPassiveSkillRanks = GetNumPassiveSkillRanks
local GetSkillLineIndicesFromSkillLineId = GetSkillLineIndicesFromSkillLineId
local GetString = GetString
local zo_strformat = zo_strformat
local zo_strgsub = zo_strgsub

-- From /esoui/lang/en_client.lua
-- SI_DAMAGETYPE0 = "None"
-- SI_DAMAGETYPE1 = "Generic"
-- SI_DAMAGETYPE2 = "Physical"
-- SI_DAMAGETYPE3 = "Flame"
-- SI_DAMAGETYPE4 = "Shock"
-- SI_DAMAGETYPE5 = "Daedric"
-- SI_DAMAGETYPE6 = "Frost"
-- SI_DAMAGETYPE7 = "Earth"
-- SI_DAMAGETYPE8 = "Magic"
-- SI_DAMAGETYPE9 = "Drowning"
-- SI_DAMAGETYPE10 = "Disease"
-- SI_DAMAGETYPE11 = "Poison"
-- SI_DAMAGETYPE12 = "Bleed"

-- Local Damagetypes for easy use
local PhysicalDamage = GetString(SI_DAMAGETYPE2) .. " Damage" -- TODO: Localize
local FlameDamage = GetString(SI_DAMAGETYPE3) .. " Damage"    -- TODO: Localize
local ShockDamage = GetString(SI_DAMAGETYPE4) .. " Damage"    -- TODO: Localize
local FrostDamage = GetString(SI_DAMAGETYPE6) .. " Damage"    -- TODO: Localize
local MagicDamage = GetString(SI_DAMAGETYPE8) .. " Damage"    -- TODO: Localize
local DiseaseDamage = GetString(SI_DAMAGETYPE10) .. " Damage" -- TODO: Localize
local PoisonDamage = GetString(SI_DAMAGETYPE11) .. " Damage"  -- TODO: Localize
local BleedDamage = GetString(SI_DAMAGETYPE12) .. " Damage"   -- TODO: Localize
local OblivionDamage = "Oblivion Damage"                      -- TODO: Localize

--- @class (partial) Tooltips
local tooltips =
{
    ----------------------------------------------------------------
    -- MAJOR / MINOR BUFFS & DEBUFFS -------------------------------
    ----------------------------------------------------------------

    -- Major/Minor Buffs
    Skill_Minor_Resolve = GetString(LUIE_STRING_SKILL_MINOR_RESOLVE_TP),
    Skill_Major_Resolve = GetString(LUIE_STRING_SKILL_MAJOR_RESOLVE_TP),
    Skill_Minor_Fortitude = GetString(LUIE_STRING_SKILL_MINOR_FORTITUDE_TP),
    Skill_Major_Fortitude = GetString(LUIE_STRING_SKILL_MAJOR_FORTITUDE_TP),
    Skill_Minor_Endurance = GetString(LUIE_STRING_SKILL_MINOR_ENDURANCE_TP),
    Skill_Major_Endurance = GetString(LUIE_STRING_SKILL_MAJOR_ENDURANCE_TP),
    Skill_Minor_Intellect = GetString(LUIE_STRING_SKILL_MINOR_INTELLECT_TP),
    Skill_Major_Intellect = GetString(LUIE_STRING_SKILL_MAJOR_INTELLECT_TP),
    Skill_Minor_Sorcery = GetString(LUIE_STRING_SKILL_MINOR_SORCERY_TP),
    Skill_Major_Sorcery = GetString(LUIE_STRING_SKILL_MAJOR_SORCERY_TP),
    Skill_Minor_Prophecy = GetString(LUIE_STRING_SKILL_MINOR_PROPHECY_TP),
    Skill_Major_Prophecy = GetString(LUIE_STRING_SKILL_MAJOR_PROPHECY_TP),
    Skill_Minor_Brutality = GetString(LUIE_STRING_SKILL_MINOR_BRUTALITY_TP),
    Skill_Major_Brutality = GetString(LUIE_STRING_SKILL_MAJOR_BRUTALITY_TP),
    Skill_Minor_Savagery = GetString(LUIE_STRING_SKILL_MINOR_SAVAGERY_TP),
    Skill_Major_Savagery = GetString(LUIE_STRING_SKILL_MAJOR_SAVAGERY_TP),
    Skill_Minor_Berserk = GetString(LUIE_STRING_SKILL_MINOR_BERSERK_TP),
    Skill_Major_Berserk = GetString(LUIE_STRING_SKILL_MAJOR_BERSERK_TP),
    Skill_Minor_Force = GetString(LUIE_STRING_SKILL_MINOR_FORCE_TP),
    Skill_Major_Force = GetString(LUIE_STRING_SKILL_MAJOR_FORCE_TP),
    Skill_Minor_Vitality = GetString(LUIE_STRING_SKILL_MINOR_VITALITY_TP),
    Skill_Major_Vitality = GetString(LUIE_STRING_SKILL_MAJOR_VITALITY_TP),
    Skill_Minor_Mending = GetString(LUIE_STRING_SKILL_MINOR_MENDING_TP),
    Skill_Major_Mending = GetString(LUIE_STRING_SKILL_MAJOR_MENDING_TP),
    Skill_Minor_Protection = GetString(LUIE_STRING_SKILL_MINOR_PROTECTION_TP),
    Skill_Major_Protection = GetString(LUIE_STRING_SKILL_MAJOR_PROTECTION_TP),
    Skill_Minor_Evasion = GetString(LUIE_STRING_SKILL_MINOR_EVASION_TP),
    Skill_Major_Evasion = GetString(LUIE_STRING_SKILL_MAJOR_EVASION_TP),
    Skill_Minor_Expedition = GetString(LUIE_STRING_SKILL_MINOR_EXPEDITION_TP),
    Skill_Major_Expedition = GetString(LUIE_STRING_SKILL_MAJOR_EXPEDITION_TP),
    Skill_Gallop = GetString(LUIE_STRING_Skill_Gallop_TP),
    Skill_Minor_Heroism = GetString(LUIE_STRING_SKILL_MINOR_HEROISM_TP),
    Skill_Major_Heroism = GetString(LUIE_STRING_SKILL_MAJOR_HEROISM_TP),
    Skill_Minor_Toughness = GetString(LUIE_STRING_SKILL_MINOR_TOUGHNESS_TP),
    Skill_Minor_Courage = GetString(LUIE_STRING_SKILL_MINOR_COURAGE_TP),
    Skill_Major_Courage = GetString(LUIE_STRING_SKILL_MAJOR_COURAGE_TP),

    -- Major/Minor Debuffs
    Skill_Minor_Breach = GetString(LUIE_STRING_SKILL_MINOR_BREACH_TP),
    Skill_Major_Breach = GetString(LUIE_STRING_SKILL_MAJOR_BREACH_TP),
    Skill_Major_Fracture_NPC = GetString(LUIE_STRING_SKILL_MAJOR_FRACTURE_NPC_TP),
    Skill_Minor_Vulnerability = GetString(LUIE_STRING_SKILL_MINOR_VULNERABILITY_TP),
    Skill_Major_Vulnerability = GetString(LUIE_STRING_SKILL_MAJOR_VULNERABILITY_TP),
    Skill_Minor_Maim = GetString(LUIE_STRING_SKILL_MINOR_MAIM_TP),
    Skill_Major_Maim = GetString(LUIE_STRING_SKILL_MAJOR_MAIM_TP),
    Skill_Minor_Defile = GetString(LUIE_STRING_SKILL_MINOR_DEFILE_TP),
    Skill_Major_Defile = GetString(LUIE_STRING_SKILL_MAJOR_DEFILE_TP),
    Skill_Minor_Magickasteal = GetString(LUIE_STRING_SKILL_MINOR_MAGICKASTEAL_TP),
    Skill_Minor_Magickasteal_Other = GetString(LUIE_STRING_SKILL_MINOR_MAGICKASTEAL_OTHER_TP),
    Skill_Minor_Lifesteal = GetString(LUIE_STRING_SKILL_MINOR_LIFESTEAL_TP),
    Skill_Minor_Lifesteal_Other = GetString(LUIE_STRING_SKILL_MINOR_LIFESTEAL_OTHER_TP),
    Skill_Minor_Enveration = GetString(LUIE_STRING_SKILL_MINOR_ENERVATION_TP),
    Skill_Minor_Uncertainty = GetString(LUIE_STRING_SKILL_MINOR_UNCERTAINTY_TP),
    Skill_Minor_Cowardice = GetString(LUIE_STRING_SKILL_MINOR_COWARDICE_TP),
    Skill_Major_Cowardice = GetString(LUIE_STRING_SKILL_MAJOR_COWARDICE_TP),
    Skill_Minor_Mangle = GetString(LUIE_STRING_SKILL_MINOR_MANGLE_TP),
    Skill_Minor_Timidity = GetString(LUIE_STRING_SKILL_MINOR_TIMIDITY_TP),
    Skill_Minor_Brittle = GetString(LUIE_STRING_SKILL_MINOR_BRITTLE_TP),
    Skill_Major_Brittle = GetString(LUIE_STRING_SKILL_MAJOR_BRITTLE_TP),

    -- Aegis/Slayer
    Skill_Minor_Aegis = GetString(LUIE_STRING_SKILL_MINOR_AEGIS_TP),
    Skill_Major_Aegis = GetString(LUIE_STRING_SKILL_MAJOR_AEGIS_TP),
    Skill_Minor_Slayer = GetString(LUIE_STRING_SKILL_MINOR_SLAYER_TP),
    Skill_Major_Slayer = GetString(LUIE_STRING_SKILL_MAJOR_SLAYER_TP),

    -- Empower / Hindrance
    Skill_Empower = GetString(LUIE_STRING_SKILL_EMPOWER_TP),

    ----------------------------------------------------------------
    -- GENERIC SKILLS ----------------------------------------------
    ----------------------------------------------------------------

    Generic_Immunity = GetString(LUIE_STRING_SKILL_SET_GENERIC_IMMUNITY_TP),
    Generic_Immunity_Permanent = GetString(LUIE_STRING_SKILL_GENERIC_IMMUNITY_PERMANENT_TP),
    Generic_Damage_Immunity_Permanent = GetString(LUIE_STRING_SKILL_GENERIC_DAMAGE_IMMUNITY_PERMANENT_TP),

    Generic_Snare = GetString(LUIE_STRING_SKILL_GENERIC_SNARE_TP),
    Generic_Snare_No_Dur = GetString(LUIE_STRING_SKILL_GENERIC_SNARE_NO_DUR_TP),

    Generic_Damage_Shield_No_Duration = GetString(LUIE_STRING_SKILL_GENERIC_DAMAGE_SHIELD_NO_DUR_TP),
    Generic_Damage_Shield_Duration = GetString(LUIE_STRING_SKILL_GENERIC_DAMAGE_SHIELD_TP),
    Generic_Damage_Shield_Percent_Duration = GetString(LUIE_STRING_SKILL_GENERIC_DAMAGE_SHIELD_PERCENT_TP),
    Generic_Weapon_Damage_Duration = GetString(LUIE_STRING_SKILL_SET_GENERIC_WEP_DAMAGE_TIME_TP),
    Generic_Weapon_Damage_Duration_Value = GetString(LUIE_STRING_SKILL_SET_GENERIC_WEP_DAMAGE_VALUE_TIME_TP),
    Generic_Spell_Damage_Duration = GetString(LUIE_STRING_SKILL_SET_GENERIC_SPELL_DAMAGE_TIME_TP),
    Generic_Spell_Damage_Duration_Value = GetString(LUIE_STRING_SKILL_SET_GENERIC_SPELL_DAMAGE_TIME_VALUE_TP),
    Generic_LA_HA_Damage_Duration = GetString(LUIE_STRING_SKILL_SET_GENERIC_LA_HA_DAMAGE_TP),
    Generic_LA_HA_Damage_Duration_Value = GetString(LUIE_STRING_SKILL_SET_GENERIC_LA_HA_DAMAGE_VALUE_TP),
    Generic_Magicka_Recovery_Duration = GetString(LUIE_STRING_SKILL_SET_GENERIC_MAG_RECOVERY_TIME_TP),
    Generic_Magicka_Recovery_Duration_Value = GetString(LUIE_STRING_SKILL_SET_GENERIC_MAG_RECOVERY_TIME_VALUE_TP),
    Generic_Weapon_Spell_Damage_Duration = GetString(LUIE_STRING_SKILL_SET_GENERIC_WEP_SPELL_DAMAGE_TIME_TP),
    Generic_Weapon_Spell_Damage_Duration_Value = GetString(LUIE_STRING_SKILL_SET_GENERIC_WEP_SPELL_DAMAGE_TIME_VALUE_TP),

    Generic_Reduce_Weapon_Damage_Duration_Value = GetString(LUIE_STRING_SKILL_SET_GENERIC_REDUCE_WEAPON_DAMAGE_TIME_VALUE_TP),

    Generic_Increase_Max_Magicka_Duration_Percentage = GetString(LUIE_STRING_SKILL_INCREASE_MAX_MAGICKA_DURATION_PERCENTAGE_TP),

    Generic_Magicka_Regen = GetString(LUIE_STRING_SKILL_GENERIC_MGK_REGEN_TP),
    Generic_Magicka_Regen_Value = GetString(LUIE_STRING_SKILL_GENERIC_MGK_REGEN_VALUE_TP),
    Generic_Stamina_Regen = GetString(LUIE_STRING_SKILL_GENERIC_STAM_REGEN_TP),
    Generic_Stamina_Regen_Value = GetString(LUIE_STRING_SKILL_GENERIC_STAM_REGEN_VALUE_TP),
    Generic_Health_Recovery = GetString(LUIE_STRING_SKILL_GENERIC_HEALTH_RECOVERY_TP),

    Generic_Enrage = GetString(LUIE_STRING_SKILL_GENERIC_ENRAGE),
    Generic_Enrage_No_Dur = GetString(LUIE_STRING_SKILL_GENERIC_ENRAGE_NO_DUR),
    Generic_Enrage_Damage_Taken_No_Dur = GetString(LUIE_STRING_SKILL_GENERIC_ENRAGE_DAMAGE_TAKEN_NO_DUR),
    Generic_Enrage_Damage_Reduce_No_Dur = GetString(LUIE_STRING_SKILL_GENERIC_ENRAGE_DAMAGE_REDUCE_NO_DUR),
    Generic_Enrage_Stack_Permanent = GetString(LUIE_STRING_SKILL_GENERIC_ENRAGE_STACK_PERMANENT_TP),

    Generic_Increase_Damage_Taken = GetString(LUIE_STRING_SKILL_GENERIC_INCREASE_DAMAGE_TAKEN_TP),
    Generic_Reduce_Damage_Taken = GetString(LUIE_STRING_SKILL_GENERIC_REDUCE_DAMAGE_TAKEN_TP),
    Generic_Critical_Damage = GetString(LUIE_STRING_SKILL_SET_GENERIC_CRITICAL_DAMAGE_TP),

    Generic_Movement_Speed = GetString(LUIE_STRING_SKILL_GENERIC_MOVEMENT_SPEED_TP),

    Generic_Increase_Physical_Spell_Pen = GetString(LUIE_STRING_SKILL_GENERIC_PHYSICAL_SPELL_PEN_TP),

    Generic_Set_ICD = GetString(LUIE_STRING_SKILL_SET_GENERIC_ICD_TP),
    Generic_Set_ICD_Minutes = GetString(LUIE_STRING_SKILL_SET_GENERIC_ICD_MINUTES_TP),

    -- Resistances
    Generic_Physical_Resist = GetString(LUIE_STRING_SKILL_GENERIC_PHYSICAL_RESIST_TP),
    Generic_Spell_Resist_No_Dur = GetString(LUIE_STRING_SKILL_GENERIC_SPELL_RESIST_NO_DUR_TP),
    Generic_Physical_Spell_Resist = GetString(LUIE_STRING_SKILL_GENERIC_PHY_SPELL_RESIST),
    Generic_Physical_Spell_Resist_Value = GetString(LUIE_STRING_SKILL_GENERIC_PHY_SPELL_RESIST_VALUE_TP),
    Generic_Physical_Spell_Resist_No_Dur = GetString(LUIE_STRING_SKILL_GENERIC_PHY_SPELL_RESIST_NO_DUR_TP),
    Generic_Physical_Spell_Resist_No_Dur_Value = GetString(LUIE_STRING_SKILL_GENERIC_PHY_SPELL_RESIST_NO_DUR_VALUE_TP),

    Generic_Reduce_Physical_Spell_Resist = GetString(LUIE_STRING_SKILL_GENERIC_REDUCE_PHY_SPELL_RESIST_TP),
    Generic_Reduce_Physical_Spell_Resist_Value = GetString(LUIE_STRING_SKILL_GENERIC_REDUCE_PHY_SPELL_RESIST_VALUE_TP),
    Generic_Reduce_Physical_Spell_Resist_No_Dur = GetString(LUIE_STRING_SKILL_GENERIC_REDUCE_PHY_SPELL_RESIST_NO_DUR_TP),
    Generic_Reduce_Physical_Spell_Resist_No_Dur_Value = GetString(LUIE_STRING_SKILL_GENERIC_REDUCE_PHY_SPELL_RESIST_NO_DUR_VALUE_TP),
    Generic_Reduce_Physical_Spell_Damage_Percentage = GetString(LUIE_STRING_SKILL_GENERIC_REDUCE_WEP_SPELL_DMG_PERCENTAGE_TP), -- TODO: Unused
    Generic_Reduce_Physical_Spell_Damage_Value = GetString(LUIE_STRING_SKILL_GENERIC_REDUCE_WEP_SPELL_DMG_VALUE_TP),           -- TODO: Unused

    Generic_Reduce_Physical_Resist_Value = GetString(LUIE_STRING_SKILL_GENERIC_REDUCE_PHYSICAL_RESIST_VALUE_TP),

    Generic_Reduce_Healing_Received = GetString(LUIE_STRING_SKILL_GENERIC_REDUCE_HEALING_RECEIVED_TP),

    Generic_Lower_Max_HP = GetString(LUIE_STRING_SKILL_GENERIC_LOWER_MAX_HP_TP),

    Generic_Reduce_Damage_Done = GetString(LUIE_STRING_SKILL_GENERIC_REDUCE_DAMAGE_DONE_TP),

    Generic_Test = GetString(LUIE_STRING_SKILL_TEST_TP),

    Generic_Increase_Stamina_Recovery_No_Dur = GetString(LUIE_STRING_SKILL_GENERIC_STAMINA_RECOVERY_NO_DUR_TP),
    Generic_Increase_Magicka_Recovery_No_Dur = GetString(LUIE_STRING_SKILL_GENERIC_MAGICKA_RECOVERY_NO_DUR_TP),

    Generic_Increase_Healing_Received_No_Dur = GetString(LUIE_STRING_SKILL_GENERIC_INCREASE_HEALING_RECEIVED_NO_DUR_TP),

    Generic_Bleed = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_DOT_TP), "SUBSTRING", BleedDamage),
    Generic_Physical = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_DOT_TP), "SUBSTRING", PhysicalDamage),
    Generic_Disease = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_DOT_TP), "SUBSTRING", DiseaseDamage),
    Generic_Poison = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_DOT_TP), "SUBSTRING", PoisonDamage),
    Generic_Burn = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_DOT_TP), "SUBSTRING", FlameDamage),
    Generic_Freeze = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_DOT_TP), "SUBSTRING", FrostDamage),
    Generic_Shock = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_DOT_TP), "SUBSTRING", ShockDamage),
    Generic_Oblivion = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_DOT_TP), "SUBSTRING", OblivionDamage),
    Generic_Magic_No_Tick = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_DOT_NO_TICK_TP), "SUBSTRING", MagicDamage),
    Generic_Magic = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_DOT_TP), "SUBSTRING", MagicDamage),
    Generic_HoT = GetString(LUIE_STRING_SKILL_GENERIC_HOT_TP),
    Generic_HoT_Channel = GetString(LUIE_STRING_SKILL_GENERIC_HOT_CHANNEL_TP),

    Generic_Shock_Snare = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_DOT_SNARE_TP), "SUBSTRING", ShockDamage),
    Generic_Oblivion_Snare = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_DOT_SNARE_TP), "SUBSTRING", OblivionDamage),

    Generic_AOE_Physical = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_GROUND_AOE_TP), "SUBSTRING", PhysicalDamage),
    Generic_AOE_Bleed = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_GROUND_AOE_TP), "SUBSTRING", BleedDamage),
    Generic_AOE_Poison = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_GROUND_AOE_TP), "SUBSTRING", PoisonDamage),
    Generic_AOE_Disease = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_GROUND_AOE_TP), "SUBSTRING", DiseaseDamage),
    Generic_AOE_Fire = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_GROUND_AOE_TP), "SUBSTRING", FlameDamage),
    Generic_AOE_Frost = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_GROUND_AOE_TP), "SUBSTRING", FrostDamage),
    Generic_AOE_Shock = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_GROUND_AOE_TP), "SUBSTRING", ShockDamage),
    Generic_AOE_Magic = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_GROUND_AOE_TP), "SUBSTRING", MagicDamage),
    Generic_AOE_Oblivion = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_GROUND_AOE_TP), "SUBSTRING", OblivionDamage),

    Generic_AOE_Fire_Stacking = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_GROUND_AOE_STACK_TP), "SUBSTRING", FlameDamage),
    Generic_AOE_Shock_Stacking = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_GROUND_AOE_STACK_TP), "SUBSTRING", ShockDamage),

    Generic_AOE_Snare_Physical = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_GROUND_AOE_SNARE_TP), "SUBSTRING", PhysicalDamage),
    Generic_AOE_Snare_Poison = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_GROUND_AOE_SNARE_TP), "SUBSTRING", PoisonDamage),
    Generic_AOE_Snare_Disease = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_GROUND_AOE_SNARE_TP), "SUBSTRING", DiseaseDamage),
    Generic_AOE_Snare_Fire = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_GROUND_AOE_SNARE_TP), "SUBSTRING", FlameDamage),
    Generic_AOE_Snare_Frost = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_GROUND_AOE_SNARE_TP), "SUBSTRING", FrostDamage),
    Generic_AOE_Snare_Shock = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_GROUND_AOE_SNARE_TP), "SUBSTRING", ShockDamage),
    Generic_AOE_Snare_Magic = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_GROUND_AOE_SNARE_TP), "SUBSTRING", MagicDamage),

    Generic_AOE_Heal = GetString(LUIE_STRING_SKILL_GENERIC_GROUND_HEAL_TP),

    Generic_Off_Balance = GetString(LUIE_STRING_SKILL_GENERIC_OFF_BALANCE_TP),
    -- Generic_Off_Balance_No_Dur                      = GetString(LUIE_STRING_SKILL_GENERIC_OFF_BALANCE_NO_DUR_TP),
    Generic_Off_Balance_Immunity = GetString(LUIE_STRING_SKILL_GENERIC_OFF_BALANCE_IMMUNITY_TP),
    Generic_Major_Vulnerability_Immunity = GetString(LUIE_STRING_SKILL_GENERIC_MAJOR_VULNERABILITY_IMMUNITY_TP),
    Generic_Immobilize = GetString(LUIE_STRING_SKILL_GENERIC_IMMOBILIZE_TP),
    Generic_Immobilize_No_Dur = GetString(LUIE_STRING_SKILL_GENERIC_IMMOBILIZE_NO_DUR_TP),
    Generic_Stagger = GetString(LUIE_STRING_SKILL_GENERIC_STAGGER_TP),
    Generic_Stun = GetString(LUIE_STRING_SKILL_GENERIC_STUN_TP),
    Generic_Stun_No_Dur = GetString(LUIE_STRING_SKILL_GENERIC_STUN_NO_DUR_TP),
    Generic_Levitate = GetString(LUIE_STRING_SKILL_GENERIC_LEVITATE_TP),
    Generic_Knockback = GetString(LUIE_STRING_SKILL_GENERIC_KNOCKBACK_TP),
    Generic_Knockdown = GetString(LUIE_STRING_SKILL_GENERIC_KNOCKDOWN_TP),
    Generic_Knockdown_No_Dur = GetString(LUIE_STRING_SKILL_GENERIC_KNOCKDOWN_NO_DUR_TP),
    Generic_Fear = GetString(LUIE_STRING_SKILL_GENERIC_FEAR_TP),
    Generic_Fear_No_Dur = GetString(LUIE_STRING_SKILL_GENERIC_FEAR_NO_DUR_TP),
    Generic_Silence = GetString(LUIE_STRING_SKILL_GENERIC_SILENCE_TP),
    Generic_Silence_No_Dur = GetString(LUIE_STRING_SKILL_GENERIC_SILENCE_NO_DUR_TP),
    Generic_Disorient = GetString(LUIE_STRING_SKILL_GENERIC_DISORIENT_TP),
    -- Generic_Disorient_No_Dur                        = GetString(LUIE_STRING_SKILL_GENERIC_DISORIENT_NO_DUR_TP),

    Generic_CC_Immunity = GetString(LUIE_STRING_SKILL_GENERIC_CC_IMMUNITY_TP),
    Generic_Scary_Immunities = GetString(LUIE_STRING_SKILL_GENERIC_SCARY_IMMUNITIES_TP),
    Generic_Scary_Immunities_Duration = GetString(LUIE_STRING_SKILL_GENERIC_SCARY_IMMUNITIES_DUR_TP),
    Generic_Flying_Immunities = GetString(LUIE_STRING_SKILL_GENERIC_FLYING_IMMUNITIES_TP),
    Generic_Invisibility = GetString(LUIE_STRING_SKILL_GENERIC_INVISIBILITY_TP),
    Generic_Detection = GetString(LUIE_STRING_SKILL_GENERIC_DETECTION_TP),
    Generic_Detection_NPC = GetString(LUIE_STRING_SKILL_GENERIC_DETECTION_NPC_TP),

    Generic_Ravage_Health_Potion = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_RAVAGE_HEALTH_POTION_TP), "SUBSTRING", PoisonDamage),
    Generic_Gradual_Ravage_Health_Potion = zo_strgsub(GetString(LUIE_STRING_SKILL_GENERIC_RAVAGE_HEALTH_POTION_TP), "SUBSTRING", BleedDamage),
    -- Generic_Ravage_Magicka_Potion                   = GetString(LUIE_STRING_SKILL_GENERIC_RAVAGE_MAGICKA_POTION_TP),
    -- Generic_Ravage_Stamina_Potion                   = GetString(LUIE_STRING_SKILL_GENERIC_RAVAGE_STAMINA_POTION_TP),
    Generic_Ravage_Magicka_Poison = GetString(LUIE_STRING_SKILL_GENERIC_RAVAGE_MAGICKA_POISON_TP),
    Generic_Ravage_Stamina_Poison = GetString(LUIE_STRING_SKILL_GENERIC_RAVAGE_STAMINA_POISON_TP),

    Generic_Marked = GetString(LUIE_STRING_SKILL_GENERIC_MARKED_TP),
    Generic_Trauma = GetString(LUIE_STRING_SKILL_GENERIC_TRAUMA_TP),
    Generic_Reveal = GetString(LUIE_STRING_SKILL_GENERIC_REVEAL_TP),
    Generic_Reveal_No_Dur = GetString(LUIE_STRING_SKILL_GENERIC_REVEAL_NO_DUR_TP),
    Generic_Blind = GetString(LUIE_STRING_SKILL_GENERIC_BLIND_TP),

    Skill_Spell_Resistance_Potion = GetString(LUIE_STRING_SKILL_SPELL_RESISTANCE_POTION_TP),
    Skill_Physical_Resistance_Potion = GetString(LUIE_STRING_SKILL_PHYSICAL_RESISTANCE_POTION_TP),
    Skill_Ravage_Armor_Potion = GetString(LUIE_STRING_SKILL_RAVAGE_ARMOR_TP),
    Skill_Ravage_Spell_Protection_Potion = GetString(LUIE_STRING_SKILL_RAVAGE_SPELL_PROTECTION_TP),
    Skill_Spell_Resistance_Poison = GetString(LUIE_STRING_SKILL_SPELL_RESISTANCE_POISON_TP),
    Skill_Physical_Resistance_Poison = GetString(LUIE_STRING_SKILL_PHYSICAL_RESISTANCE_POISON_TP),

    ----------------------------------------------------------------
    -- INNATE SKILLS ----------------------------------------------
    ----------------------------------------------------------------

    -- Player Basic

    Innate_Mounted = GetString(LUIE_STRING_SKILL_MOUNTED_TP),
    Innate_Mounted_Passenger = GetString(LUIE_STRING_SKILL_MOUNTED_PASSENGER_TP),
    Innate_Vanity_Pet = GetString(LUIE_STRING_SKILL_COLLECTIBLE_VANITY_PET_TP),
    Innate_Immobilize_Immunity = GetString(LUIE_STRING_SKILL_IMMOBILIZE_IMMUNITY_TP),
    Innate_Snare_Immobilize_Immunity = GetString(LUIE_STRING_SKILL_SNARE_IMMOBILIZE_IMMUNITY_TP),
    Innate_Dodge_Fatigue = GetString(LUIE_STRING_SKILL_DODGE_FATIGUE_TP),
    Innate_Invisible = GetString(LUIE_STRING_SKILL_INVISIBLE_TP),
    -- Innate_Sprint                                   = GetString(LUIE_STRING_SKILL_SPRINT_TP),
    -- Innate_Gallop                                   = GetString(LUIE_STRING_SKILL_GALLOP_TP),
    Innate_Resurrection_Immunity = GetString(LUIE_STRING_SKILL_RESURRECTION_IMMUNITY_TP),
    Innate_Taunt = GetString(LUIE_STRING_SKILL_TAUNT_TP),
    Innate_Taunt_Other = GetString(LUIE_STRING_SKILL_TAUNT_OTHER_TP),
    Innate_Disguised = GetString(LUIE_STRING_SKILL_DISGUISE_TP),
    Innate_Battle_Spirit = GetString(LUIE_STRING_SKILL_BATTLE_SPIRIT_TP),
    Innate_Battle_Spirit_Imperial_City = GetString(LUIE_STRING_SKILL_BATTLE_SPIRIT_IMPERIAL_CITY_TP),
    Innate_Recall_Penalty = GetString(LUIE_STRING_SKILL_RECALL_PENALTY_TP),
    Innate_Battleground_Deserter = GetString(LUIE_STRING_SKILL_BATTLEGROUND_DESERTER_TP),
    Innate_Looking_for_Group = GetString(LUIE_STRING_SKILL_LOOKING_FOR_GROUP_TP),
    Innate_Ayleid_Well = GetString(LUIE_STRING_SKILL_AYLEID_WELL_TP),
    Innate_Ayleid_Well_Fortified = GetString(LUIE_STRING_SKILL_AYLEID_WELL_FORTIFIED_TP),
    Innate_Firelight = GetString(LUIE_STRING_SKILL_FIRELIGHT_TP),
    Innate_ESO_Plus = GetString(LUIE_STRING_SKILL_ESO_PLUS_TP),

    -- Mundus Stones
    Boon_Lady = GetString(LUIE_STRING_SKILL_MUNDUS_BASIC_LADY),
    Boon_Lover = GetString(LUIE_STRING_SKILL_MUNDUS_BASIC_LOVER),
    Boon_Lord = GetString(LUIE_STRING_SKILL_MUNDUS_BASIC_LORD),
    Boon_Mage = GetString(LUIE_STRING_SKILL_MUNDUS_BASIC_MAGE),
    Boon_Tower = GetString(LUIE_STRING_SKILL_MUNDUS_BASIC_TOWER),
    Boon_Atronach = GetString(LUIE_STRING_SKILL_MUNDUS_BASIC_ATRONACH),
    Boon_Serpent = GetString(LUIE_STRING_SKILL_MUNDUS_BASIC_SERPENT),
    Boon_Shadow = GetString(LUIE_STRING_SKILL_MUNDUS_BASIC_SHADOW),
    Boon_Ritual = GetString(LUIE_STRING_SKILL_MUNDUS_BASIC_RITUAL),
    Boon_Thief = GetString(LUIE_STRING_SKILL_MUNDUS_BASIC_THIEF),
    Boon_Warrior = GetString(LUIE_STRING_SKILL_MUNDUS_BASIC_WARRIOR),
    Boon_Apprentice = GetString(LUIE_STRING_SKILL_MUNDUS_BASIC_APPRENTICE),
    Boon_Steed = GetString(LUIE_STRING_SKILL_MUNDUS_BASIC_STEED),

    ----------------------------------------------------------------
    -- EVENT SKILLS ------------------------------------------------
    ----------------------------------------------------------------

    Event_Freezing = GetString(LUIE_STRING_SKILL_EVENT_FREEZING),
    Event_Warm = GetString(LUIE_STRING_SKILL_EVENT_WARM),
    Event_Festival_Grog = GetString(LUIE_STRING_SKILL_EVENT_FESTIVAL_GROG),
    Event_Festival_Mints = GetString(LUIE_STRING_SKILL_EVENT_FESTIVAL_MINTS),
    Event_Revelry_Pie = GetString(LUIE_STRING_SKILL_REVELRY_PIE_TP),

    ----------------------------------------------------------------
    -- CHAMPION POINT SKILLS ---------------------------------------
    ----------------------------------------------------------------

    -- Craft
    Champion_Shadowstrike = GetString(LUIE_STRING_SKILL_SHADOWSTRIKE_TP),

    -- Warfare
    Champion_Enlivening_Overflow = GetString(LUIE_STRING_SKILL_ENLIVENING_OVERFLOW_TP),
    Champion_Foresight = GetString(LUIE_STRING_SKILL_FORESIGHT_TP),
    Champion_Riposte = GetString(LUIE_STRING_SKILL_RIPOSTE_TP),

    -- Fitness
    Champion_Expert_Evasion = GetString(LUIE_STRING_SKILL_EXPERT_EVASION_TP),
    Champion_Winded = GetString(LUIE_STRING_SKILL_WINDED_TP),
    Champion_Unchained = GetString(LUIE_STRING_SKILL_UNCHAINED_TP),

    ----------------------------------------------------------------
    -- CONSUMABLES & ITEMS -----------------------------------------
    ----------------------------------------------------------------

    -- Glyphs
    Item_Glyph_of_Weakening = GetString(LUIE_STRING_SKILL_GLYPH_WEAKENING_TP),

    -- Crafted Food
    Food_Crafted_Health = GetItemLinkOnUseAbilityDescription("|H1:item:68235:309:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"),
    Food_Crafted_Magicka = GetItemLinkOnUseAbilityDescription("|H1:item:68238:309:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"),
    Food_Crafted_Stamina = GetItemLinkOnUseAbilityDescription("|H1:item:68241:309:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"),
    Food_Crafted_Health_Magicka = GetItemLinkOnUseAbilityDescription("|H1:item:68244:310:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"),
    Food_Crafted_Health_Stamina = GetItemLinkOnUseAbilityDescription("|H1:item:68247:310:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"),
    Food_Crafted_Magicka_Stamina = GetItemLinkOnUseAbilityDescription("|H1:item:68250:310:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"),
    Food_Crafted_Triple = GetItemLinkOnUseAbilityDescription("|H1:item:68254:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"),
    Food_Crafted_Orzorgas_Tripe = GetItemLinkOnUseAbilityDescription("|H1:item:71057:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"),
    Food_Crafted_Orzorgas_Blood_Price = GetItemLinkOnUseAbilityDescription("|H1:item:71058:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"),
    Food_Crafted_Orzorgas_Smoked_Bear = GetItemLinkOnUseAbilityDescription("|H1:item:71059:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"),
    Food_Crafted_Deregulated_Mushroom_Stew = GetItemLinkOnUseAbilityDescription("|H1:item:133554:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"),
    Food_Crafted_Clockwork_Citrus_Filet = GetItemLinkOnUseAbilityDescription("|H1:item:133556:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"),
    Food_Crafted_Artaeum_Takeaway_Broth = GetItemLinkOnUseAbilityDescription("|H1:item:139018:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"),
    Food_Crafted_Artaeum_Pickled_Fish_Bowl = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:139016:6:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_ARTAEUM_BOWL), GetString(LUIE_STRING_SKILL_ADD_TOOLTIP_ARTAEUM_BOWL)),
    Food_Crafted_Candied_Jesters_Coins = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:120762:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),
    Food_Crafted_Lava_Foot_Soup = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:112425:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),
    Food_Crafted_Alcaire_Festival_Sword_Pie = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:112439:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),
    Food_Crafted_Pumpkin_Snack_Skewer = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:87686:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),
    Food_Crafted_Crunchy_Spider_Skewer = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:87691:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),
    Food_Crafted_Frosted_Brains = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:87696:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),
    Food_Crafted_Jagga_Drenched_Mud_Ball = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:112434:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),
    Food_Crafted_Jewels_of_Misrule = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:120764:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),
    Food_Crafted_Rajhins_Sugar_Claws = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:112438:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),
    Food_Crafted_Sweet_Sanguine_Apples = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:87685:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),
    Food_Crafted_Bewitched_Sugar_Skulls = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:153629:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),

    -- Vendor / Cyrodiil Food
    Food_Vendor_Health = GetItemLinkOnUseAbilityDescription("|H1:item:57637:308:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Food_Vendor_Magicka = GetItemLinkOnUseAbilityDescription("|H1:item:57631:134:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Food_Vendor_Stamina = GetItemLinkOnUseAbilityDescription("|H1:item:71252:308:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Food_Cyrodilic_Field_Bar = GetItemLinkOnUseAbilityDescription("|H1:item:71076:368:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Food_Cyrodilic_Field_Tack = GetItemLinkOnUseAbilityDescription("|H1:item:71074:368:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Food_Cyrodilic_Field_Treat = GetItemLinkOnUseAbilityDescription("|H1:item:71075:368:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),

    -- Crown Food
    Food_Crown_Crate_Meal = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:94437:123:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),
    Food_Crown_Meal = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:64711:123:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),
    Food_Crown_Vigorous_Ragout = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:124676:123:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),
    Food_Crown_Combat_Mystics_Stew = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:124675:123:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),

    -- Crafted Drink
    Drink_Crafted_Health = GetItemLinkOnUseAbilityDescription("|H1:item:68257:309:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"),
    Drink_Crafted_Magicka = GetItemLinkOnUseAbilityDescription("|H1:item:68260:309:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"),
    Drink_Crafted_Stamina = GetItemLinkOnUseAbilityDescription("|H1:item:68263:309:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"),
    Drink_Crafted_Health_Magicka = GetItemLinkOnUseAbilityDescription("|H1:item:68266:310:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"),
    Drink_Crafted_Health_Stamina = GetItemLinkOnUseAbilityDescription("|H1:item:68269:310:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"),
    Drink_Crafted_Magicka_Stamina = GetItemLinkOnUseAbilityDescription("|H1:item:68272:310:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"),
    Drink_Crafted_Triple = GetItemLinkOnUseAbilityDescription("|H1:item:68276:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"),
    Drink_Crafted_Orzorgas_Red_Frothgar = GetItemLinkOnUseAbilityDescription("|H1:item:71056:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"),
    Drink_Crafted_Spring_Loaded_Infusion = GetItemLinkOnUseAbilityDescription("|H1:item:133555:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"),
    Drink_Crafted_Dubious_Camoran_Throne = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:120763:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),
    Drink_Crafted_Witchmothers_Potent_Brew = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:87697:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),
    Drink_Crafted_Bowl_of_Peeled_Eyeballs = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:87687:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),
    Drink_Crafted_Witchmothers_Party_Punch = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:87690:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),
    Drink_Crafted_Ghastly_Eye_Bowl = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:87695:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),
    Drink_Crafted_Bergama_Warning_Fire = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:112426:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),
    Drink_Crafted_Betnikh_Twice_Spiked_Ale = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:112433:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_TWICE_SPIKED_ALE), ""),
    Drink_Crafted_Snow_Bear_Glow_Wine = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:112440:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),
    Drink_Double_Bloody_Mara = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:87699:6:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_DOUBLE_BLOODY_MARA), ""),
    Drink_Hissmir = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:101879:6:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_HISSMIR), GetString(LUIE_STRING_SKILL_ADD_TOOLTIP_HISSMIR)),
    Drink_Crafted_Disastrously_Bloody_Mara = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:153625:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_DISASTROUSLY_BLOODY), ""),
    Drink_Crafted_Pack_Leaders_Bone_Broth = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:153627:311:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_PACK_LEADERS_BROTH), GetString(LUIE_STRING_SKILL_ADD_TOOLTIP_PACK_LEADERS_BROTH)),

    -- Vendor / Cyrodiil Drink
    Drink_Vendor_Health = GetItemLinkOnUseAbilityDescription("|H1:item:71249:134:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Drink_Vendor_Magicka = GetItemLinkOnUseAbilityDescription("|H1:item:71250:308:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Drink_Vendor_Stamina = GetItemLinkOnUseAbilityDescription("|H1:item:71251:134:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Drink_Cyrodilic_Field_Tonic = GetItemLinkOnUseAbilityDescription("|H1:item:71079:368:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Drink_Cyrodilic_Field_Brew = GetItemLinkOnUseAbilityDescription("|H1:item:71077:368:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Drink_Cyrodilic_Field_Tea = GetItemLinkOnUseAbilityDescription("|H1:item:71078:368:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),

    -- Crown Drink
    Drink_Crown_Crate_Drink = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:94438:123:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),
    Drink_Crown_Drink = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:64712:123:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),
    Drink_Crown_Stout_Magic_Liqueur = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:124677:123:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),
    Drink_Crown_Vigorous_Tincture = zo_strgsub(GetItemLinkOnUseAbilityDescription("|H1:item:124678:123:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"), GetString(LUIE_STRING_SKILL_REMOVE_TOOLTIP_SCALED_LEVEL), ""),

    -- Experience
    Experience_Psijic_Ambrosia = zo_strformat(GetString(LUIE_STRING_SKILL_EXPERIENCE_HALF_HOUR_TP), "50"),
    Experience_Aetherial_Ambrosia = zo_strformat(GetString(LUIE_STRING_SKILL_EXPERIENCE_HALF_HOUR_TP), "100"),
    Experience_Mythic_Aetherial_Ambrosia = zo_strformat(GetString(LUIE_STRING_SKILL_EXPERIENCE_HALF_HOUR_TP), "150"),
    Experience_Crown = zo_strformat(GetString(LUIE_STRING_SKILL_EXPERIENCE_HOUR_TP), "50", "2"),
    Experience_Gold_Coast = zo_strformat(GetString(LUIE_STRING_SKILL_EXPERIENCE_HOUR_TP), "50", "1"),
    Experience_Major_Gold_Coast = zo_strformat(GetString(LUIE_STRING_SKILL_EXPERIENCE_HOUR_TP), "100", "1"),
    Experience_Grand_Gold_Coast = zo_strformat(GetString(LUIE_STRING_SKILL_EXPERIENCE_HOUR_TP), "150", "1"),
    Experience_Seasonal_Event = zo_strformat(GetString(LUIE_STRING_SKILL_EXPERIENCE_HOUR_TP), "100", "2"),
    Experience_Seasonal_Pelinal = zo_strformat(GetString(LUIE_STRING_SKILL_EXPERIENCE_PELINAL), "2"),

    -- Alliance War Experience
    Experience_Alliance_War_Skill = zo_strformat(GetString(LUIE_STRING_SKILL_EXPERIENCE_ALLIANCE_HOUR_TP), "50"),
    Experience_Alliance_War_Skill_Major = zo_strformat(GetString(LUIE_STRING_SKILL_EXPERIENCE_ALLIANCE_HOUR_TP), "100"),
    Experience_Alliance_War_Skill_Grand = zo_strformat(GetString(LUIE_STRING_SKILL_EXPERIENCE_ALLIANCE_HOUR_TP), "150"),

    Experience_Colovian_War_Torte = zo_strformat(GetString(LUIE_STRING_SKILL_EXPERIENCE_ALLIANCE_HALF_HOUR_TP), "50"),    -- Colovian War Torte
    Experience_Molten_War_Torte = zo_strformat(GetString(LUIE_STRING_SKILL_EXPERIENCE_ALLIANCE_HALF_HOUR_TP), "100"),     -- Molten War Torte
    Experience_White_Gold_War_Torte = zo_strformat(GetString(LUIE_STRING_SKILL_EXPERIENCE_ALLIANCE_HALF_HOUR_TP), "150"), -- White-Gold War Torte

    -- Mementos
    Memento_Witchmothers_Brew = GetAbilityDescription(84369),
    Memento_Almalexias_Lantern = GetCollectibleDescription(341),
    Memento_Bonesnap_Binding_Talisman = GetCollectibleDescription(348),
    Memento_Discourse_Amaranthine = GetCollectibleDescription(345),
    Memento_Fetish_of_Anger = GetCollectibleDescription(347),
    Memento_Finvirs_Trinket = GetCollectibleDescription(336),
    Memento_Mystery_Meat = GetCollectibleDescription(342),
    Memento_Sanguines_Goblet = GetCollectibleDescription(338),
    Memento_Token_of_Root_Sunder = GetCollectibleDescription(349),

    -- Crown Mementos
    Memento_Storm_Atronach_Aura = GetCollectibleDescription(594),
    Memento_Storm_Atronach_Transform = GetCollectibleDescription(596),
    Memento_Wild_Hunt_Leaf_Dance_Aura = GetCollectibleDescription(760),
    Memento_Wild_Hunt_Transform = GetCollectibleDescription(759),
    Memento_Floral_Swirl_Aura = GetCollectibleDescription(758),
    Memento_Dwarven_Puzzle_Orb = GetCollectibleDescription(1181),
    Memento_Dwarven_Tonal_Forks = GetCollectibleDescription(1182),
    Memento_Dwemervamidium_Mirage = GetCollectibleDescription(1183),
    Memento_Swarm_of_Crows = GetCollectibleDescription(1384),
    Memento_Ghost_Lantern = GetCollectibleDescription(5212),

    ----------------------------------------------------------------
    -- ITEM SETS --------------------------------------------------
    ----------------------------------------------------------------

    -- Weapon Sets
    Set_Asylum_Dual_Wield = GetString(LUIE_STRING_SKILL_SET_ASYLUM_DUAL_WIELD),
    Set_Asylum_Bow = GetString(LUIE_STRING_SKILL_SET_ASYLUM_BOW),
    Set_Asylum_Destruction_Staff = GetString(LUIE_STRING_SKILL_SET_ASYLUM_DESTRUCTION_STAFF),
    Set_Aslyum_Restoration_Staff = GetString(LUIE_STRING_SKILL_SET_ASYLUM_RESTORATION_STAFF),
    Set_Maelstrom_DW = GetString(LUIE_STRING_SKILL_SET_MAELSTROM_DW),
    Set_Maelstrom_1H = GetString(LUIE_STRING_SKILL_SET_MAELSTROM_1H),
    Set_Maelstrom_2H = zo_strgsub(zo_strformat(GetString(LUIE_STRING_SKILL_GENERIC_DOT_TP), 6, 1), "SUBSTRING", BleedDamage),
    Set_Master_1H = GetString(LUIE_STRING_SKILL_SET_MASTER_1H),
    Set_Master_Resto = GetString(LUIE_STRING_SKILL_SET_MASTER_RESTO),
    Set_Blackrose_Dual_Wield = GetString(LUIE_STRING_SKILL_SET_BLACKROSE_DUAL_WIELD),
    Set_Blackrose_1H = GetString(LUIE_STRING_SKILL_SET_BLACKROSE_1H_TP),
    Set_Blackrose_Destro_Staff = GetString(LUIE_STRING_SKILL_SET_BLACKROSE_DESTRO_TP),
    Set_Vateshran_2H = GetString(LUIE_STRING_SKILL_SET_VATESHRAN_2H_TP),
    Set_Vateshran_1H = GetString(LUIE_STRING_SKILL_SET_VATESHRAN_1H_TP),
    Set_Vateshran_Destro_Staff = GetString(LUIE_STRING_SKILL_SET_VATESHRAN_DESTRO_TP),
    Set_Vateshran_Destro_Staff_Buff = GetString(LUIE_STRING_SKILL_SET_VATESHRAN_DESTRO_BUFF_TP),
    Set_Vateshran_Resto_Staff = GetString(LUIE_STRING_SKILL_SET_VATESHRAN_RESTO_TP),

    -- Monster Helms
    Set_Balorgh = GetString(LUIE_STRING_SKILL_SET_BALORGH),
    Set_Bogdan_the_Nightflame = GetString(LUIE_STRING_SKILL_SET_BOGDAN),
    Set_Domihaus_Buff = GetString(LUIE_STRING_SKILL_SET_DOMIHAUS_BUFF),
    Set_Domihaus_Damage = GetString(LUIE_STRING_SKILL_SET_DOMIHAUS_DAMAGE),
    Set_Earthgore = GetString(LUIE_STRING_SKILL_SET_EARTHGORE),
    Set_Grothdarr = GetString(LUIE_STRING_SKILL_SET_GROTHDARR),
    Set_Iceheart = GetString(LUIE_STRING_SKILL_SET_ICEHEART),
    Set_Ilambris = GetString(LUIE_STRING_SKILL_SET_ILAMBRIS),
    Set_Ilambris_Ground = GetString(LUIE_STRING_SKILL_SET_ILAMBRIS_GROUND),
    Set_Lord_Warden_Buff = GetString(LUIE_STRING_SKILL_SET_LORD_WARDEN_BUFF),
    Set_Malubeth_Damage = GetString(LUIE_STRING_SKILL_SET_MALUBETH_DAMAGE),
    Set_Malubeth_Heal = GetString(LUIE_STRING_SKILL_SET_MALUBETH_HEAL),
    Set_Maw_of_the_Infernal = GetString(LUIE_STRING_SKILL_SET_MAW_OF_THE_INFERNAL),
    Set_Molag_Kena_Overkill = GetString(LUIE_STRING_SKILL_SET_MOLAG_KENA_OVERKILL_TP),
    Set_Molag_Kena = GetString(LUIE_STRING_SKILL_SET_MOLAG_KENA_TP),
    Set_Pirate_Skeleton = GetString(LUIE_STRING_SKILL_SET_PIRATE_SKELETON_TP),
    Set_Sentinel_of_Rkugamz = GetString(LUIE_STRING_SKILL_SET_SENTINEL_OF_REKUGAMZ_TP),
    Set_Sentinel_of_Rkugamz_Ground = GetString(LUIE_STRING_SKILL_SET_SENTINEL_OF_REKUGAMZ_GROUND_TP),
    Set_Shadowrend = GetString(LUIE_STRING_SKILL_SET_SHADOWREND_TP),
    Set_Spawn_of_Mephala = GetString(LUIE_STRING_SKILL_SET_SPAWN_OF_MEPHALA_TP),
    Set_Stormfist = GetString(LUIE_STRING_SKILL_SET_STORMFIST_TP),
    Skill_Stormfist_Ground = GetString(LUIE_STRING_SKILL_STORMFIST_GROUND_TP),
    Set_Engine_Guardian_Stamina = zo_strformat(GetString(LUIE_STRING_SKILL_SET_ENGINE_GUARDIAN), GetString(SI_COMBATMECHANICFLAGS4)),
    Set_Engine_Guardian_Magicka = zo_strformat(GetString(LUIE_STRING_SKILL_SET_ENGINE_GUARDIAN), GetString(SI_COMBATMECHANICFLAGS1)),
    Set_Engine_Guardian_Health = zo_strformat(GetString(LUIE_STRING_SKILL_SET_ENGINE_GUARDIAN), GetString(SI_COMBATMECHANICFLAGS32)),
    Set_The_Troll_King = GetString(LUIE_STRING_SKILL_SET_THE_TROLL_KING_TP),
    Set_Thurvokun = GetString(LUIE_STRING_SKILL_SET_THURVOKUN_TP),
    Set_Thurvokun_Ground = GetString(LUIE_STRING_SKILL_SET_THURVOKUN_GROUND_TP),
    Set_Zaan = GetString(LUIE_STRING_SKILL_SET_ZAAN_TP),
    Set_Energy_Charge = GetString(LUIE_STRING_SKILL_SET_ENERGY_CHARGE_TP),
    Set_Meridias_Favor = GetString(LUIE_STRING_SKILL_SET_MERIDIAS_FAVOR_TP),
    Set_Aurorans_Thunder = GetString(LUIE_STRING_SKILL_SET_AURORANS_THUNDER_TP),
    Set_Tzogvins_Warband = GetString(LUIE_STRING_SKILL_SET_TZOGVINS_WARBAND_TP),
    Set_Frozen_Watcher = GetString(LUIE_STRING_SKILL_SET_FROZEN_WATCHER_TP),
    Set_Maarselok = GetString(LUIE_STRING_SKILL_MAARSELOK_TP),
    Set_Nerieneth = GetString(LUIE_STRING_SKILL_NERIENETH_TP),
    Set_Sellistrix = GetString(LUIE_STRING_SKILL_SELLISTRIX_TP),
    Set_Kjalnars_Nightmare = GetString(LUIE_STRING_SKILL_KJALNARS_NIGHTMARE_TP),
    Set_Meridias_Blessed_Armor = GetString(LUIE_STRING_SKILL_SET_MERIDIAS_BLESSED_ARMOR_TP),

    Set_Stone_Husk_DOT = GetString(LUIE_STRING_SET_STONE_HUSK_DOT_TP),
    Set_Stone_Husk_Drain = GetString(LUIE_STRING_SET_STONE_HUSK_HUSK_DRAIN_TP),
    Set_Stone_Husk_Buff = GetString(LUIE_STRING_SET_STONE_HUSK_BUFF_TP),

    -- Mythic Items
    Set_Snow_Treaders = GetString(LUIE_STRING_SKILL_SET_SNOW_TREADERS_TP),
    Set_Bloodlords_Embrace = GetString(LUIE_STRING_SKILL_SET_BLOODLORDS_EMBRACE_TP),
    Set_Thrassian_Stranglers = GetString(LUIE_STRING_SKILL_SET_THRASSIAN_STANGLERS_TP),

    -- Crafted Sets
    Set_Eternal_Hunt = GetString(LUIE_STRING_SKILL_SET_ETERNAL_HUNT),
    Set_Morkuldin = GetString(LUIE_STRING_SKILL_SET_MORKULDIN),
    Set_Tavas_Favor = GetString(LUIE_STRING_SKILL_SET_TAVAS_FAVOR),
    Set_Varens_Legacy = GetString(LUIE_STRING_SKILL_SET_VARENS_LEGACY),
    Set_Mechanical_Acuity = GetString(LUIE_STRING_SKILL_SET_MECHANICAL_ACUITY),
    Set_Senche_Rahts_Grit = GetString(LUIE_STRING_SKILL_SET_SENCHE_RAHTS_GRIT),
    Set_Vastaries_Tutelage = GetString(LUIE_STRING_SKILL_SET_VASTARIES_TUTELAGE),
    Set_Eye_of_Nahviintaas = GetString(LUIE_STRING_SKILL_SET_EYE_OF_NAHVIINTAAS),
    Set_Seventh_Legion = GetString(LUIE_STRING_SKILL_SET_SEVENTH_LEGION_TP),
    Set_Sloads = GetString(LUIE_STRING_SKILL_SET_SLOADS_TP),
    Set_Grave_Stake_Collector = GetString(LUIE_STRING_SKILL_SET_GRAVE_STAKE_COLLECTOR_TP),
    Set_Coldharbours_Favorite_Heal = GetString(LUIE_STRING_SKILL_SET_COLDHARBOURS_FAVORITE_HEAL_TP),
    Set_Coldharbours_Favorite_Damage = GetString(LUIE_STRING_SKILL_SET_COLDHARBOURS_FAVORITE_DAMAGE_TP),
    Set_Stuhns_Favor = GetString(LUIE_STRING_SKILL_SET_STUHNS_FAVOR_TP),
    Set_Dragons_Appetite = GetString(LUIE_STRING_SKILL_SET_DRAGONS_APPETITE_TP),
    Set_Voidcaller = GetString(LUIE_STRING_SET_VOIDCALLER_TP),

    -- Light / Medium / Heavy Sets
    Set_Queens_Elegance_LA = GetString(LUIE_STRING_SKILL_SET_ELEGANCE_LA_TP),
    Set_Queens_Elegance_HA = GetString(LUIE_STRING_SKILL_SET_ELEGANCE_HA_TP),
    Set_Bahrahas_Curse = GetString(LUIE_STRING_SKILL_SET_BAHRAHAS_CURSE_TP),
    Skill_Bahrahas_Curse_Ground = GetString(LUIE_STRING_SKILL_BAHRAHAS_CURSE_GROUND_TP),
    Set_Briarheart = GetString(LUIE_STRING_SKILL_SET_BRIARHEART_TP),
    Set_Unfathomable_Darknesss = GetString(LUIE_STRING_SKILL_SET_UNFATHOMABLE_DARKNESS_TP),
    Set_Storm_Knight = GetString(LUIE_STRING_SKILL_SET_STORM_KNIGHT_TP),
    Set_Draugrs_Rest = GetString(LUIE_STRING_SKILL_SET_DRAUGRS_REST_TP),
    Set_Overwhelming_Surge = GetString(LUIE_STRING_SKILL_SET_OVERWHELMING_SURGE_TP),
    Set_Plague_Slinger = GetString(LUIE_STRING_SKILL_PLAGUE_SLINGER_TP),
    Set_Blood_Moon_Scent = GetString(LUIE_STRING_SKILL_SET_BLOOD_SCENT),
    Set_Blood_Moon_Frenzied = GetString(LUIE_STRING_SKILL_SET_FRENIZED),
    Set_Ebon_Armory = GetString(LUIE_STRING_SKILL_SET_EBON_ARMORY),
    Set_Embershield = GetString(LUIE_STRING_SKILL_SET_EMBERSHIELD),
    Set_Hagravens_Garden = GetString(LUIE_STRING_SKILL_SET_HAGRAVENS_GARDEN),
    Set_Jolting_Arms = GetString(LUIE_STRING_SKILL_SET_JOLTING_ARMS),
    Set_Leeching_Plate = GetString(LUIE_STRING_SKILL_SET_LEECHING_PLATE_TP),
    Skill_Leeching_Plate_Ground = GetString(LUIE_STRING_SKILL_LEECHING_PLATE_GROUND_TP),
    Set_Hand_of_Mephala = GetString(LUIE_STRING_SKILL_SET_HAND_OF_MEPHALA_TP),
    Skill_Hand_of_Mephala_Ground = GetString(LUIE_STRING_SKILL_HAND_OF_MEPHALA_GROUND_TP),
    Set_Hollowfang_Thirst = GetString(LUIE_STRING_SKILL_HOLLOWFANG_THIRST_TP),
    Set_Touch_of_Zen = GetString(LUIE_STRING_SKILL_TOUCH_OF_ZEN_TP),
    Set_Blight_Seed = GetString(LUIE_STRING_SKILL_SET_BLIGHT_SEED_TP),
    Set_Renalds_Resolve = GetString(LUIE_STRING_SKILL_RENALDS_RESOLVE_TP),
    Set_Dragons_Defilement = GetString(LUIE_STRING_SKILL_DRAGONS_DEFILEMENT_TP),
    Set_Dragonguard_Tactics = GetString(LUIE_STRING_SKILL_DRAGONGUARD_TACTICS_TP),
    Set_Senchals_Duty = GetString(LUIE_STRING_SKILL_SENCHALS_DUTY_TP),
    Set_Trinimacs_Valor = GetString(LUIE_STRING_SKILL_TRINIMACS_VALOR_TP),
    Set_Hatchlings_Shell = GetString(LUIE_STRING_SKILL_SET_HATCHLINGS_SHELL_TP),
    Set_Dunerippers_Scales = GetString(LUIE_STRING_SKILL_SET_DUNERIPPERS_SCALES_TP),
    Set_Hitis_Hearth = GetString(LUIE_STRING_SET_HITIS_HEARTH_TP),
    Set_Hitis_Hearth_Ground = GetString(LUIE_STRING_SET_HITIS_HEARTH_GROUND_TP),
    Set_Draugrkin = GetString(LUIE_STRING_SET_DRAUGRKIN_TP),
    Set_Aegis_Caller = GetString(LUIE_STRING_SET_AEGIS_CALLER_TP),
    Set_Grave_Guardian = GetString(LUIE_STRING_SET_GRAVE_GUARDIAN_TP),
    Set_Winters_Respite = GetString(LUIE_STRING_SET_WINTERS_RESPITE_TP),
    Set_Hunters_Venom = GetString(LUIE_STRING_SET_HUNTERS_VENOM_TP),
    Set_Sheer_Venom = GetString(LUIE_STRING_SET_SHEER_VENOM_TP),
    Set_Elemental_Catalyst = GetString(LUIE_STRING_SET_ELEMENTAL_CATALYST_TP),
    Set_Crimson_Twilight = GetString(LUIE_STRING_SET_CRIMSON_TWILIGHT_TP),
    Set_Ironblood = GetString(LUIE_STRING_SKILL_SET_IRONBLOOD_TP),

    -- Trial Sets
    Set_Berserking_Warrior = GetString(LUIE_STRING_SKILL_SET_BERSERKING_WARRIOR_TP),
    Set_Destructive_Mage = GetString(LUIE_STRING_SKILL_SET_DESTRUCTIVE_MAGE_TP),
    Set_Twice_Fanged_Serpent = GetString(LUIE_STRING_SKILL_SET_TWICE_FANGED_SERPENT_TP),
    Set_Lunar_Bastion = GetString(LUIE_STRING_SKILL_SET_LUNAR_BASTION_TP),
    Set_Lunar_Bastion_Ground = GetString(LUIE_STRING_SKILL_SET_LUNAR_BASTION_GROUND_TP),
    Set_Vestment_of_Olorime = GetString(LUIE_STRING_SKILL_SET_VESTMENT_OF_OLORIME_TP),
    Set_Mantle_of_Siroria = GetString(LUIE_STRING_SKILL_SET_MANTLE_OF_SIRORIA_TP),
    Set_Sirorias_Boon = GetString(LUIE_STRING_SKILL_SET_SIRORIAS_BOON_TP),
    Set_Relequen = GetString(LUIE_STRING_SKILL_SET_RELEQUEN_TP),

    Set_Kynes_Blessing = GetString(LUIE_STRING_SKILL_SET_KYNES_BLESSING_TP),
    -- Set_Kynes_Blessing_Ground                     = GetString(LUIE_STRING_SKILL_SET_KYNES_BLESSING_GROUND_TP),
    Set_Giants_Endurance = GetString(LUIE_STRING_SKILL_SET_GIANTS_ENDURANCE_TP),
    Set_Giants_Might = GetString(LUIE_STRING_SKILL_SET_GIANTS_MIGHT_TP),
    Set_Roar_of_Alkosh = GetString(LUIE_STRING_SKILL_ROAR_OF_ALKOSH_TP),

    -- Battleground Sets
    Set_Vanguards_Challenge = GetString(LUIE_STRING_SKILL_SET_VANGUARDS_CHALLENGE_TP),
    -- Set_Cowards_Gear                                = GetString(LUIE_STRING_SKILL_SET_COWARDS_GEAR_TP),

    -- Imperial City Sets
    Set_Galerions_Revenge = GetString(LUIE_STRING_SKILL_SET_GALERIONS_REVENGE_TP),
    Set_Vicecanon_of_Venom = GetString(LUIE_STRING_SKILL_SET_VICECANON_OF_VENOM_TP),

    -- Cyrodiil Sets
    Set_Soldier_of_Anguish = GetString(LUIE_STRING_SKILL_SET_SOLDIER_OF_ANGUISH_TP),
    Set_Spell_Strategist = GetString(LUIE_STRING_SKILL_SET_SPELL_STRATEGIST_TP),
    Set_Glorious_Defender = GetString(LUIE_STRING_SKILL_SET_GLORIOUS_DEFENDER_TP),
    Set_Light_of_Cyrodiil = GetString(LUIE_STRING_SKILL_SET_CYRODIILS_LIGHT_TP),
    Set_Morag_Tong = GetString(LUIE_STRING_SKILL_SET_MORAG_TONG_TP),
    Set_Warriors_Fury = GetString(LUIE_STRING_SKILL_SET_WARRIORS_FURY_TP),
    Set_Robes_of_Transmutation = GetString(LUIE_STRING_SKILL_SET_ROBES_OF_TRANSMUTATION_TP),
    Set_Beckoning_Steel = GetString(LUIE_STRING_SKILL_SET_BECKONING_STEEL_TP),
    Set_Sentry = GetString(LUIE_STRING_SKILL_SET_SENTRY_TP),
    Set_Ravager = GetString(LUIE_STRING_SKILL_SET_RAVAGER_TP),

    -- Arena Sets
    Set_Succession_Flame = zo_strformat(GetString(LUIE_STRING_SKILL_SET_SUCCESSION_TP), FlameDamage),
    Set_Succession_Shock = zo_strformat(GetString(LUIE_STRING_SKILL_SET_SUCCESSION_TP), ShockDamage),
    Set_Succession_Frost = zo_strformat(GetString(LUIE_STRING_SKILL_SET_SUCCESSION_TP), FrostDamage),
    Set_Para_Bellum = GetString(LUIE_STRING_SKILL_SET_PARA_BELLUM_TP),
    Set_Hex_Siphon = GetString(LUIE_STRING_SKILL_SET_HEX_SIPHON_TP),
    Set_Explosive_Rebuke = GetString(LUIE_STRING_SKILL_SET_EXPLOSIVE_REBUKE_TP),

    -- Disguises
    Disguise_Generic = GetString(LUIE_STRING_SKILL_DISGUISE_GENERIC_TP),
    Disguise_Kollopi_Essence = GetString(LUIE_STRING_SKILL_DISGUISE_KOLLOPI_ESSENCE_TP),
    Disguise_Sea_Viper_Armor = GetString(LUIE_STRING_SKILL_DISGUISE_SEA_VIPER_ARMOR_TP),
    Disguise_Vulkhel_Guard = GetString(LUIE_STRING_SKILL_DISGUISE_VULKHEL_GUARD_TP),
    Disguise_Phaer_Mercenary = GetString(LUIE_STRING_SKILL_DISGUISE_PHAER_MERCENARY_TP),
    Disguise_Quendeluun = GetString(LUIE_STRING_SKILL_DISGUISE_QUENDELUUN_TP),
    Disguise_Seadrake = GetString(LUIE_STRING_SKILL_DISGUISE_SEADRAKE_TP),
    Disguise_Servants_Robes = GetString(LUIE_STRING_SKILL_DISGUISE_SERVANTS_ROBES_TP),
    Disguise_Bloodthorn = GetString(LUIE_STRING_SKILL_DISGUISE_BLOODTHORN_DISGUISE_TP),

    ----------------------------------------------------------------
    -- CLASS SKILLS ------------------------------------------------
    ----------------------------------------------------------------

    -- Dragonknight
    Skill_Seething_Fury = GetString(LUIE_STRING_SKILL_SEETHING_FURY_TP),
    Skill_Venomous_Claw = GetString(LUIE_STRING_SKILL_VENOMOUS_CLAW_TP),
    Skill_Burning_Embers = GetString(LUIE_STRING_SKILL_BURNING_EMBERS_TP),
    Skill_Engulfing_Flames = GetString(LUIE_STRING_SKILL_ENGULFING_FLAMES_TP),
    Skill_Engulfing_Flames_Dummy = GetString(LUIE_STRING_SKILL_ENGULFING_FLAMES_DUMMY_TP),
    Skill_Inferno_Active = GetString(LUIE_STRING_SKILL_INFERNO_TP),
    Skill_Flames_of_Oblivion_Active = GetString(LUIE_STRING_SKILL_FLAMES_OF_OBLIVION_TP),
    Skill_Cauterize_Active = GetString(LUIE_STRING_SKILL_CAUTERIZE_TP),
    Skill_Dragonknight_Standard = GetString(LUIE_STRING_SKILL_DRAGONKNIGHT_STANDARD_TP),
    Skill_Dragonknight_Standard_Ground = GetString(LUIE_STRING_SKILL_DRAGONKNIGHT_STANDARD_GROUND_TP),
    Skill_Standard_of_Might_Buff = GetString(LUIE_STRING_SKILL_STANDARD_OF_MIGHT_TP),
    Skill_Shifting_Standard = GetString(LUIE_STRING_SKILL_SHIFTING_STANDARD_TP),
    Skill_Spiked_Armor = GetString(LUIE_STRING_SKILL_SPIKED_ARMOR_TP),
    Skill_Hardened_Armor = GetString(LUIE_STRING_SKILL_HARDENED_ARMOR_TP),
    Skill_Burning_Talons = GetString(LUIE_STRING_SKILL_BURNING_TALONS_TP),
    Skill_Protective_Scale = GetString(LUIE_STRING_SKILL_PROTECTIVE_SCALE_TP),
    Skill_Protective_Plate = GetString(LUIE_STRING_SKILL_PROTECTIVE_PLATE_TP),
    Skill_Dragon_Fire_Scale = GetString(LUIE_STRING_SKILL_DRAGON_FIRE_SCALE_TP),
    Skill_Inhale = GetString(LUIE_STRING_SKILL_INHALE_TP),
    Skill_Draw_Essence = GetString(LUIE_STRING_SKILL_DRAW_ESSENCE_TP),
    Skill_Molten_Armaments = GetString(LUIE_STRING_SKILL_MOLTEN_ARMAMENTS_TP),
    Skill_Petrify_Stun = GetString(LUIE_STRING_SKILL_PETRIFY_STUN_TP),
    Skill_Fossilize_Stun = GetString(LUIE_STRING_SKILL_FOSSILIZE_STUN_TP),
    Skill_Shattering_Rocks_Stun = GetString(LUIE_STRING_SKILL_SHATTERING_ROCKS_STUN_TP),
    Skill_Ash_Cloud = GetString(LUIE_STRING_SKILL_ASH_CLOUD_TP),
    Skill_Eruption = GetString(LUIE_STRING_SKILL_ERUPTION_TP),
    Skill_Magma_Armor = GetString(LUIE_STRING_SKILL_MAGMA_ARMOR_TP),
    Skill_Corrosive_Armor = GetString(LUIE_STRING_SKILL_CORROSIVE_ARMOR_TP),
    Skill_Stonefist = GetString(LUIE_STRING_SKILL_STONEFIST_TP),
    Skill_Stone_Giant = GetString(LUIE_STRING_SKILL_STONE_GIANT_TP),
    Skill_Stagger = GetString(LUIE_STRING_SKILL_STAGGER_TP),

    -- Nightblade
    Skill_Mark_Target = GetString(LUIE_STRING_SKILL_MARK_TARGET_TP),
    Skill_Reapers_Mark = GetString(LUIE_STRING_SKILL_REAPERS_MARK_TP),
    Skill_Death_Stroke_Debuff = GetString(LUIE_STRING_SKILL_DEATH_STROKE_DEBUFF),
    Skill_Incapacitating_Strike = GetString(LUIE_STRING_SKILL_INCAPACITATING_STRIKE),
    Skill_Shadowy_Disguise = GetString(LUIE_STRING_SKILL_SHADOWY_DISGUISE_TP),
    Skill_Grim_Focus = GetString(LUIE_STRING_SKILL_GRIM_FOCUS_TP),
    Skill_Relentless_Focus = GetString(LUIE_STRING_SKILL_RELENTLESS_FOCUS_TP),
    Skill_Merciless_Resolve = GetString(LUIE_STRING_SKILL_MERCILESS_RESOLVE_TP),
    Skill_Grim_Focus_Defense = GetString(LUIE_STRING_SKILL_GRIM_FOCUS_DEFENSE_TP),
    Skill_Path_of_Darkness = GetString(LUIE_STRING_SKILL_PATH_OF_DARKNESS_TP),
    Skill_Twisting_Path = GetString(LUIE_STRING_SKILL_TWISTING_PATH_TP),
    Skill_Refreshing_Path = GetString(LUIE_STRING_SKILL_REFRESHING_PATH_TP),
    Skill_Manifestation_of_Terror = GetString(LUIE_STRING_SKILL_MANIFESTATION_OF_TERROR_TP),
    Skill_Summon_Shade = GetString(LUIE_STRING_SKILL_SUMMON_SHADE_TP),
    Skill_Dark_Shade = GetString(LUIE_STRING_SKILL_DARK_SHADE_TP),
    Skill_Shadow_Image = GetString(LUIE_STRING_SKILL_SHADOW_IMAGE_TP),
    Skill_Hidden_Refresh = GetString(LUIE_STRING_SKILL_HIDDEN_REFRESH_TP),
    Skill_Consuming_Darkness = GetString(LUIE_STRING_SKILL_CONSUMING_DARKNESS_TP),
    Skill_Bolstering_Darkness = GetString(LUIE_STRING_SKILL_BOLSTERING_DARKNESS_TP),
    Skill_Veil_of_Blades = GetString(LUIE_STRING_SKILL_VEIL_OF_BLADES_TP),
    Skill_Malevolent_Offering = GetString(LUIE_STRING_SKILL_MALEVOLENT_OFFERING_TP),
    Skill_Cripple = GetString(LUIE_STRING_SKILL_CRIPPLE_TP),
    Skill_Crippling_Grasp = GetString(LUIE_STRING_SKILL_CRIPPLING_GRASP_TP),
    Skill_Debilitate = GetString(LUIE_STRING_SKILL_DEBILITATE_TP),
    Skill_Siphoning_Strikes = GetString(LUIE_STRING_SKILL_SIPHONING_STRIKES_TP),
    Skill_Leeching_Strikes = GetString(LUIE_STRING_SKILL_LEECHING_STRIKES_TP),
    Skill_Siphoning_Attacks = GetString(LUIE_STRING_SKILL_SIPHONING_ATTACKS_TP),
    Skill_Soul_Tether = GetString(LUIE_STRING_SKILL_SOUL_TETHER_TP),

    -- Sorcerer
    Skill_Persistence_Rank_1 = zo_strformat(GetString(LUIE_STRING_SKILL_PERSISTENCE), 7),
    Skill_Persistence_Rank_2 = zo_strformat(GetString(LUIE_STRING_SKILL_PERSISTENCE), 15),
    Skill_Crystal_Weaver = GetString(LUIE_STRING_SKILL_CRYSTAL_WEAVER_TP),
    Skill_Crystal_Weapon = GetString(LUIE_STRING_SKILL_CRYSTAL_WEAPON_TP),
    Skill_Crystal_Fragments = GetString(LUIE_STRING_SKILL_CRYSTAL_FRAGMENTS_TP),
    Skill_Shattering_Prison = GetString(LUIE_STRING_SKILL_SHATTERING_PRISON_TP),
    Skill_Rune_Cage = GetString(LUIE_STRING_SKILL_RUNE_CAGE_TP),
    Skill_Defensive_Rune = GetString(LUIE_STRING_SKILL_DEFENSIVE_RUNE_TP),
    Skill_Daedric_Mines = GetString(LUIE_STRING_SKILL_DAEDRIC_MINES_TP),
    Skill_Negate_Magic = GetString(LUIE_STRING_SKILL_NEGATE_MAGIC_TP),
    Skill_Suppression_Field = GetString(LUIE_STRING_SKILL_SUPPRESSION_FIELD_TP),
    Skill_Absorption_Field = GetString(LUIE_STRING_SKILL_ABSORPTION_FIELD_TP),
    Skill_Unstable_Familiar = GetString(LUIE_STRING_SKILL_UNSTABLE_FAMILIAR_TP),
    Skill_Unstable_Clannfear = GetString(LUIE_STRING_SKILL_UNSTABLE_CLANNFEAR_TP),
    Skill_Volatile_Familiar = GetString(LUIE_STRING_SKILL_VOLATILE_FAMILIAR_TP),
    Skill_Familiar_Damage_Pulse = GetString(LUIE_STRING_SKILL_FAMILIAR_DAMAGE_PULSE_TP),
    Skill_Familiar_Damage_Pulse_Self = GetString(LUIE_STRING_SKILL_FAMILIAR_DAMAGE_PULSE_SELF_TP),
    Skill_Familiar_Stun_Pulse = GetString(LUIE_STRING_SKILL_FAMILIAR_DAMAGE_PULSE_STUN_TP),
    Skill_Familiar_Stun_Pulse_Self = GetString(LUIE_STRING_SKILL_FAMILIAR_DAMAGE_PULSE_SELF_STUN_TP),
    Skill_Daedric_Curse = GetString(LUIE_STRING_SKILL_DAEDRIC_CURSE_TP),
    Skill_Daedric_Prey = GetString(LUIE_STRING_SKILL_DAEDRIC_PREY_TP),
    Skill_Haunting_Curse = GetString(LUIE_STRING_SKILL_HAUNTING_CURSE_TP),
    Skill_Winged_Twilight = GetString(LUIE_STRING_SKILL_WINGED_TWILIGHT_TP),
    Skill_Twilight_Tormentor = GetString(LUIE_STRING_SKILL_TWILIGHT_TORMENTOR_TP),
    Skill_Twilight_Matriarch = GetString(LUIE_STRING_SKILL_TWILIGHT_MATRIARCH_TP),
    Skill_Tormentor_Damage_Boost = GetString(LUIE_STRING_SKILL_TORMENTOR_DAMAGE_BOOST_TP),
    Skill_Tormentor_Damage_Boost_Self = GetString(LUIE_STRING_SKILL_TORMENTOR_DAMAGE_BOOST_SELF_TP),
    Skill_Bound_Armor = GetString(LUIE_STRING_SKILL_BOUND_ARMOR_TP),
    Skill_Bound_Armaments_Skill = GetString(LUIE_STRING_SKILL_BOUND_ARMAMENTS_SKILL_TP),
    Skill_Bound_Armaments_Stack = GetString(LUIE_STRING_SKILL_BOUND_ARMAMENTS_STACK_TP),
    Skill_Storm_Atronach = GetString(LUIE_STRING_SKILL_STORM_ATRONACH_TP),
    Skill_Charged_Atronach = GetString(LUIE_STRING_SKILL_CHARGED_ATRONACH_TP),
    Skill_Mages_Fury = GetString(LUIE_STRING_SKILL_MAGES_FURY_TP),
    Skill_Endless_Fury = GetString(LUIE_STRING_SKILL_ENDLESS_FURY_TP),
    Skill_Lightning_Form = GetString(LUIE_STRING_SKILL_LIGHTNING_FORM_TP),
    Skill_Hurricane = GetString(LUIE_STRING_SKILL_HURRICANE_TP),
    Skill_Lightning_Splash = GetString(LUIE_STRING_SKILL_LIGHTNING_SPLASH_TP),
    Skill_Surge = GetString(LUIE_STRING_SKILL_SURGE_TP),
    Skill_Power_Surge = GetString(LUIE_STRING_SKILL_POWER_SURGE_TP),
    Skill_Bolt_Escape_Fatigue = GetString(LUIE_STRING_SKILL_BOLT_ESCAPE_FATIGUE_TP),
    Skill_Intercept = GetString(LUIE_STRING_SKILL_INTERCEPT_TP),
    Skill_Overload = GetString(LUIE_STRING_SKILL_OVERLOAD_TP),
    Skill_Energy_Overload = GetString(LUIE_STRING_SKILL_ENERGY_OVERLOAD_TP),
    Skill_Suppression_Field_Stun = GetString(LUIE_STRING_SKILL_SUPPRESSION_FIELD_STUN),
    Skill_Suppression_Field_Silence = GetString(LUIE_STRING_SKILL_SUPPRESSION_FIELD_SILENCE),

    -- Templar
    Skill_Spear_Shards = GetString(LUIE_STRING_SKILL_SPEAR_SHARDS_TP),
    Skill_Luminous_Shards = GetString(LUIE_STRING_SKILL_LUMINOUS_SHARDS_TP),
    Skill_Blazing_Shield = GetString(LUIE_STRING_SKILL_BLAZING_SHIELD_TP),
    Skill_Radial_Sweep = GetString(LUIE_STRING_SKILL_RADIAL_SWEEP_TP),
    Skill_Sun_Fire = GetString(LUIE_STRING_SKILL_SUN_FIRE_TP),
    Skill_Sun_Fire_Snare = GetString(LUIE_STRING_SKILL_SUN_FIRE_SNARE_TP),
    Skill_Solar_Barrage = GetString(LUIE_STRING_SKILL_SOLAR_BARRAGE_TP),
    Skill_Backlash = GetString(LUIE_STRING_SKILL_BACKLASH_TP),
    Skill_Purifying_Light = GetString(LUIE_STRING_SKILL_PURIFYING_LIGHT_TP),
    Skill_Power_of_the_Light = GetString(LUIE_STRING_SKILL_POWER_OF_THE_LIGHT_TP),
    Skill_Eclipse = GetString(LUIE_STRING_SKILL_ECLIPSE_TP),
    Skill_Living_Dark = GetString(LUIE_STRING_SKILL_LIVING_DARK_TP),
    Skill_Unstable_Core = GetString(LUIE_STRING_SKILL_UNSTABLE_CORE_TP),
    Skill_Radiant_Destruction = GetString(LUIE_STRING_SKILL_RADIANT_DESTRUCTION_TP),
    Skill_Nova = GetString(LUIE_STRING_SKILL_NOVA_TP),
    Skill_Nova_Ground = GetString(LUIE_STRING_SKILL_NOVA_GROUND_TP),
    Skill_Solar_Prison = GetString(LUIE_STRING_SKILL_SOLAR_PRISON_TP),
    Skill_Solar_Disturbance = GetString(LUIE_STRING_SKILL_SOLAR_DISTURBANCE_TP),
    Skill_Solar_Disturbance_Ground = GetString(LUIE_STRING_SKILL_SOLAR_DISTURBANCE_GROUND_TP),
    Skill_Cleansing_Ritual = GetString(LUIE_STRING_SKILL_CLEANSING_RITUAL_TP),
    Skill_Ritual_of_Retribution = GetString(LUIE_STRING_SKILL_CLEANSING_RITUAL_RETRIBUTION_TP),
    Skill_Rite_of_Passage = GetString(LUIE_STRING_SKILL_RITE_OF_PASSAGE_TP),
    Skill_Sacred_Ground = GetString(LUIE_STRING_SKILL_SACRED_GROUND_TP),
    Skill_Rune_Focus = GetString(LUIE_STRING_SKILL_RUNE_FOCUS_TP),
    Skill_Channeled_Focus = GetString(LUIE_STRING_SKILL_CHANNELED_FOCUS_TP),
    Skill_Restoring_Focus = GetString(LUIE_STRING_SKILL_RESTORING_FOCUS_TP),

    -- Warden
    Skill_Cutting_Dive = GetString(LUIE_STRING_SKILL_CUTTING_DIVE_TP),
    Skill_Scorch = GetString(LUIE_STRING_SKILL_SCORCH_TP),
    Skill_Subterranean_Assault = GetString(LUIE_STRING_SKILL_SUB_ASSAULT_TP),
    Skill_Subterranean_Assault_Echo = GetString(LUIE_STRING_SKILL_SUB_ASSAULT_ECHO_TP),
    Skill_Deep_Fissure = GetString(LUIE_STRING_SKILL_DEEP_FISSURE_TP),
    Skill_Fetcher_Infection_Bonus = GetString(LUIE_STRING_SKILL_FETCHER_INFECTION_BONUS_DAMAGE_TP),
    Skill_Growing_Swarm = GetString(LUIE_STRING_SKILL_GROWING_SWARM_TP),
    Skill_Betty_Netch = GetString(LUIE_STRING_SKILL_BETTY_NETCH_TP),
    Skill_Blue_Betty = GetString(LUIE_STRING_SKILL_BLUE_BETTY_TP),
    Skill_Bull_Netch = GetString(LUIE_STRING_SKILL_BULL_NETCH_TP),
    Skill_Feral_Guardian = GetString(LUIE_STRING_SKILL_FERAL_GUARDIAN_TP),
    Skill_Eternal_Guardian = GetString(LUIE_STRING_SKILL_ETERNAL_GUARDIAN_TP),
    Skill_Wild_Guardian = GetString(LUIE_STRING_SKILL_WILD_GUARDIAN_TP),
    Skill_Guardians_Wrath = GetString(LUIE_STRING_SKILL_GUARDIANS_WRATH_TP),
    Skill_Guardians_Savagery = GetString(LUIE_STRING_SKILL_GUARDIANS_SAVAGERY_TP),
    Skill_Eternal_Guardian_Cooldown = GetString(LUIE_STRING_SKILL_ETERNAL_GUARDIAN_COOLDOWN_TP),
    Skill_Healing_Seed = GetString(LUIE_STRING_SKILL_HEALING_SEED_TP),
    Skill_Budding_Seeds = GetString(LUIE_STRING_SKILL_BUDDING_SEEDS_TP),
    Skill_Corrupting_Pollen = GetString(LUIE_STRING_SKILL_CORRUPTING_POLLEN_TP),
    Skill_Living_Vines = GetString(LUIE_STRING_SKILL_LIVING_VINES_TP),
    Skill_Leeching_Vines = GetString(LUIE_STRING_SKILL_LEECHING_VINES_TP),
    Skill_Living_Trellis = GetString(LUIE_STRING_SKILL_LIVING_TRELLIS_TP),
    Skill_Lotus_Flower = GetString(LUIE_STRING_SKILL_LOTUS_FLOWER_TP),
    Skill_Natures_Grasp = GetString(LUIE_STRING_SKILL_NATURES_GRASP_TP),
    Skill_Natures_Grasp_Self = GetString(LUIE_STRING_SKILL_NATURES_GRASP_SELF_TP),
    Skill_Secluded_Grove = GetString(LUIE_STRING_SKILL_SECLUDED_GROVE_TP),
    Skill_Healing_Thicket = GetString(LUIE_STRING_SKILL_HEALING_THICKET_TP),
    Skill_Impaling_Shards = GetString(LUIE_STRING_SKILL_IMPALING_SHARDS_TP),
    Skill_Crystallized_Shield = GetString(LUIE_STRING_SKILL_CRYSTALLIZED_SHIELD_TP),
    Skill_Crystallized_Slab = GetString(LUIE_STRING_SKILL_CRYSTALLIZED_SLAB_TP),
    Skill_Shimmering_Shield = GetString(LUIE_STRING_SKILL_SHIMMERING_SHIELD_TP),
    Skill_Frozen_Gate = GetString(LUIE_STRING_SKILL_FROZEN_GATE_TP),
    Skill_Frozen_Device = GetString(LUIE_STRING_SKILL_FROZEN_DEVICE_TP),
    Skill_Frozen_Retreat = GetString(LUIE_STRING_SKILL_FROZEN_RETREAT_TP),
    Skill_Sleet_Storm = GetString(LUIE_STRING_SKILL_SLEET_STORM_TP),
    Skill_Permafrost = GetString(LUIE_STRING_SKILL_PERMAFROST_TP),
    Skill_Permafrost_Ground = GetString(LUIE_STRING_SKILL_PERMAFROST_GROUND_TP),
    Skill_Arctic_Blast = GetString(LUIE_STRING_SKILL_ARCTIC_BLAST_TP),
    Skill_Arctic_Blast_Ground = GetString(LUIE_STRING_SKILL_ARCTIC_BLAST_GROUND_TP),

    -- Necromancer
    Skill_Reusable_Parts_Rank_1 = zo_strformat(GetString(LUIE_STRING_SKILL_REUSABLE_PARTS_TP), 25),
    Skill_Reusable_Parts_Rank_2 = zo_strformat(GetString(LUIE_STRING_SKILL_REUSABLE_PARTS_TP), 50),
    Skill_Flame_Skull = GetString(LUIE_STRING_SKILL_FLAME_SKULL_TP),
    Skill_Ricochet_Skull = GetString(LUIE_STRING_SKILL_RICOCHET_SKULL_TP),
    Skill_Blastbones = GetString(LUIE_STRING_SKILL_BLASTBONES_TP),
    Skill_Blighted_Blastbones = GetString(LUIE_STRING_SKILL_BLIGHTED_BLASTBONES_TP),
    Skill_Stalking_Blastbones = GetString(LUIE_STRING_SKILL_STALKING_BLASTBONES_TP),
    Skill_Boneyard = GetString(LUIE_STRING_SKILL_BONEYARD_TP),
    Skill_Unnerving_Boneyard = GetString(LUIE_STRING_SKILL_UNNERVING_BONEYARD_TP),
    Skill_Unnerving_Boneyard_Ground = GetString(LUIE_STRING_SKILL_UNNERVING_BONEYARD_GROUND_TP),
    Skill_Avid_Boneyard = GetString(LUIE_STRING_SKILL_AVID_BONEYARD_TP),
    Skill_Skeletal_Mage = GetString(LUIE_STRING_SKILL_SKELETAL_MAGE_TP),
    Skill_Skeletal_Archer = GetString(LUIE_STRING_SKILL_SKELETAL_ARCHER_TP),
    Skill_Skeletal_Arcanist = GetString(LUIE_STRING_SKILL_SKELETAL_ARCANIST_TP),
    Skill_Shocking_Siphon = GetString(LUIE_STRING_SKILL_SHOCKING_SIPHON_TP),
    Skill_Shocking_Siphon_Ground = GetString(LUIE_STRING_SKILL_SHOCKING_SIPHON_GROUND_TP),
    Skill_Detonating_Siphon = GetString(LUIE_STRING_SKILL_DETONATING_SIPHON_TP),
    Skill_Detonating_Siphon_Ground = GetString(LUIE_STRING_SKILL_DETONATING_SIPHON_GROUND_TP),
    Skill_Mystic_Siphon = GetString(LUIE_STRING_SKILL_MYSTIC_SIPHON_TP),
    Skill_Frozen_Colossus = GetString(LUIE_STRING_SKILL_FROZEN_COLOSSUS_TP),
    Skill_Frozen_Colossus_Ground = GetString(LUIE_STRING_SKILL_FROZEN_COLOSSUS_GROUND_TP),
    Skill_Pestilent_Colossus = GetString(LUIE_STRING_SKILL_PESTILENT_COLOSSUS_TP),
    Skill_Pestilent_Colossus_Ground = GetString(LUIE_STRING_SKILL_PESTILENT_COLOSSUS_GROUND_TP),
    Skill_Glacial_Colossus = GetString(LUIE_STRING_SKILL_GLACIAL_COLOSSUS_TP),
    Skill_Glacial_Colossus_Ground = GetString(LUIE_STRING_SKILL_GLACIAL_COLOSSUS_GROUND_TP),
    Skill_Bone_Totem = GetString(LUIE_STRING_SKILL_BONE_TOTEM_TP),
    Skill_Agony_Totem = GetString(LUIE_STRING_SKILL_AGONY_TOTEM_TP),
    Skill_Bone_Goliath_Transformation = GetString(LUIE_STRING_SKILL_BONE_GOLIATH_TRANSFORMATION_TP),
    Skill_Pummeling_Goliath = GetString(LUIE_STRING_SKILL_PUMMELING_GOLIATH_TP),
    Skill_Ravenous_Goliath = GetString(LUIE_STRING_SKILL_RAVENOUS_GOLIATH_TP),
    Skill_Ravenous_Goliath_Ground = GetString(LUIE_STRING_SKILL_RAVENOUS_GOLIATH_GROUND_TP),
    Skill_Resistant_Flesh = GetString(LUIE_STRING_SKILL_RESISTANT_FLESH_TP),
    Skill_Life_amid_Death = GetString(LUIE_STRING_SKILL_LIFE_AMID_DEATH_TP),
    Skill_Spirit_Mender = GetString(LUIE_STRING_SKILL_SPIRIT_MENDER_TP),
    Skill_Spirit_Guardian = GetString(LUIE_STRING_SKILL_SPIRIT_GUARDIAN_TP),
    Skill_Restoring_Tether = GetString(LUIE_STRING_SKILL_RESTORING_TETHER_TP),
    Skill_Braided_Tether = GetString(LUIE_STRING_SKILL_BRAIDED_TETHER_TP),
    Skill_Mortal_Coil = GetString(LUIE_STRING_SKILL_MORTAL_COIL_TP),
    Skill_Bone_Armor = GetString(LUIE_STRING_SKILL_BONE_ARMOR_TP),
    Skill_Beckoning_Armor = GetString(LUIE_STRING_SKILL_BECKONING_ARMOR_TP),
    Skill_Summoners_Armor = GetString(LUIE_STRING_SKILL_SUMMONERS_ARMOR_TP),

    ----------------------------------------------------------------
    -- WEAPON SKILLS -----------------------------------------------
    ----------------------------------------------------------------

    -- Two Handed
    Skill_Follow_Up_Rank_1 = zo_strformat(GetString(LUIE_STRING_SKILL_FOLLOW_UP_TP), 5),
    Skill_Follow_Up_Rank_2 = zo_strformat(GetString(LUIE_STRING_SKILL_FOLLOW_UP_TP), 10),
    Skill_Battle_Rush_Rank_1 = zo_strformat(GetString(LUIE_STRING_SKILL_BATTLE_RUSH_TP), 15),
    Skill_Battle_Rush_Rank_2 = zo_strformat(GetString(LUIE_STRING_SKILL_BATTLE_RUSH_TP), 30),
    Skill_Rally = GetString(LUIE_STRING_SKILL_RALLY_TP),
    Skill_Stampede = GetString(LUIE_STRING_SKILL_STAMPEDE_TP),
    Skill_Berserker_Strike = GetString(LUIE_STRING_SKILL_BERSERKER_STRIKE_TP),
    Skill_Onslaught = GetString(LUIE_STRING_SKILL_ONSLAUGHT_TP),
    Skill_Berserker_Rage = GetString(LUIE_STRING_SKILL_BERSERKER_RAGE_TP),

    -- Sword and Shield
    Skill_Defensive_Posture = GetString(LUIE_STRING_SKILL_DEFENSIVE_POSTURE_TP),
    Skill_Absorb_Missile = GetString(LUIE_STRING_SKILL_ABSORB_MISSILE_TP),
    Skill_Reverberating_Bash = GetString(LUIE_STRING_SKILL_REVEBERATING_BASH_TP),
    Skill_Resentment = GetString(LUIE_STRING_SKILL_RESENTMENT_TP),
    Skill_Shield_Wall = GetString(LUIE_STRING_SKILL_SHIELD_WALL_TP),
    Skill_Spell_Wall = GetString(LUIE_STRING_SKILL_SPELL_WALL_TP),
    Skill_Shield_Discipline = GetString(LUIE_STRING_SKILL_SHIELD_DISCIPLINE_TP),

    -- Dual Wield
    Skill_Rending_Slashes = GetString(LUIE_STRING_SKILL_RENDING_SLASHES_TP),
    Skill_Blood_Craze = GetString(LUIE_STRING_SKILL_BLOOD_CRAZE_TP),
    Skill_Blood_Craze_Heal = GetString(LUIE_STRING_SKILL_BLOOD_CRAZE_HEAL_TP),
    Skill_Blade_Cloak = GetString(LUIE_STRING_SKILL_BLADE_CLOAK_TP),
    Skill_Lacerate = GetString(LUIE_STRING_SKILL_LACERATE_TP),
    Skill_Thrive_in_Chaos = GetString(LUIE_STRING_SKILL_THRIVE_IN_CHAOS_TP),
    Skill_Flying_Blade = GetString(LUIE_STRING_SKILL_FLYING_BLADE_TP),

    -- Bow
    Skill_Hawk_Eye_Rank_1 = zo_strformat(GetString(LUIE_STRING_SKILL_HAWK_EYE_TP), 2),
    Skill_Hawk_Eye_Rank_2 = zo_strformat(GetString(LUIE_STRING_SKILL_HAWK_EYE_TP), 5),
    Skill_Volley = GetString(LUIE_STRING_SKILL_VOLLEY_TP),
    Skill_Poison_Injection = GetString(LUIE_STRING_SKILL_POISON_INJECTION_TP),
    Skill_Ballista = GetString(LUIE_STRING_SKILL_BALLISTA_TP),

    -- Destruction Staff
    Skill_Heavy_Attack_Lightning = GetString(LUIE_STRING_HEAVY_ATTACK_LIGHTNING_STAFF_TP),
    Skill_Heavy_Attack_Restoration = GetString(LUIE_STRING_HEAVY_ATTACK_RESTORATION_STAFF_TP),
    Skill_Wall_of_Elements_Fire = GetString(LUIE_STRING_SKILL_WOE_FIRE_TP),
    Skill_Wall_of_Elements_Frost = GetString(LUIE_STRING_SKILL_WOE_FROST_TP),
    Skill_Wall_of_Elements_Shock = GetString(LUIE_STRING_SKILL_WOE_SHOCK_TP),
    Skill_U_Wall_of_Elements_Fire = GetString(LUIE_STRING_SKILL_UWOE_FIRE_TP),
    Skill_U_Wall_of_Elements_Frost = GetString(LUIE_STRING_SKILL_UWOE_FROST_TP),
    Skill_U_Wall_of_Elements_Shock = GetString(LUIE_STRING_SKILL_UWOE_SHOCK_TP),
    Skill_Wall_of_Elements_Ground_Fire = GetString(LUIE_STRING_SKILL_WALL_OF_ELEMENTS_GROUND_FIRE),
    Skill_Wall_of_Elements_Ground_Shock = GetString(LUIE_STRING_SKILL_WALL_OF_ELEMENTS_GROUND_SHOCK),
    Skill_Wall_of_Elements_Ground_Frost = GetString(LUIE_STRING_SKILL_WALL_OF_ELEMENTS_GROUND_FROST),
    Skill_U_Wall_of_Elements_Ground_Fire = GetString(LUIE_STRING_SKILL_U_WALL_OF_ELEMENTS_GROUND_FIRE),
    Skill_U_Wall_of_Elements_Ground_Shock = GetString(LUIE_STRING_SKILL_U_WALL_OF_ELEMENTS_GROUND_SHOCK),
    Skill_U_Wall_of_Elements_Ground_Frost = GetString(LUIE_STRING_SKILL_U_WALL_OF_ELEMENTS_GROUND_FROST),
    Skill_Wall_of_Elements_Frost_Shield = GetString(LUIE_STRING_SKILL_WOE_FROST_SHIELD_TP),
    Skill_Fire_Storm = zo_strformat(GetString(LUIE_STRING_SKILL_ELEMENTAL_STORM_TP), GetString(SI_DAMAGETYPE3)),
    Skill_Thunder_Storm = zo_strformat(GetString(LUIE_STRING_SKILL_ELEMENTAL_STORM_TP), GetString(SI_DAMAGETYPE4)),
    Skill_Ice_Storm = zo_strformat(GetString(LUIE_STRING_SKILL_ELEMENTAL_STORM_TP), GetString(SI_DAMAGETYPE6)),
    Skill_Fiery_Rage = zo_strformat(GetString(LUIE_STRING_SKILL_ELEMENTAL_STORM_TP), GetString(SI_DAMAGETYPE3)),
    Skill_Icy_Rage = GetString(LUIE_STRING_SKILL_ICY_RAGE_TP),
    Skill_Eye_of_Flame = zo_strformat(GetString(LUIE_STRING_SKILL_EYE_OF_THE_STORM_TP), GetString(SI_DAMAGETYPE3)),
    Skill_Eye_of_Lightning = zo_strformat(GetString(LUIE_STRING_SKILL_EYE_OF_THE_STORM_TP), GetString(SI_DAMAGETYPE4)),
    Skill_Eye_of_Frost = zo_strformat(GetString(LUIE_STRING_SKILL_EYE_OF_THE_STORM_TP), GetString(SI_DAMAGETYPE6)),

    -- Restoration Staff
    Skill_Grand_Healing = GetString(LUIE_STRING_SKILL_GRAND_HEALING),
    Skill_Healing_Springs = GetString(LUIE_STRING_SKILL_HEALING_SPRINGS),
    Skill_Healing_Ward = GetString(LUIE_STRING_SKILL_HEALING_WARD),
    Skill_Lights_Champion = GetString(LUIE_STRING_SKILL_LIGHTS_CHAMPION),

    ----------------------------------------------------------------
    -- ARMOR SKILLS ------------------------------------------------
    ----------------------------------------------------------------

    -- Light Armor
    Skill_Harness_Magicka = GetString(LUIE_STRING_SKILL_HARNESS_MAGICKA),

    -- Medium Armor
    Skill_Elude = GetString(LUIE_STRING_SKILL_ELUDE),

    -- Heavy Armor
    Skill_Unstoppable = GetString(LUIE_STRING_SKILL_UNSTOPPABLE),

    ----------------------------------------------------------------
    -- WORLD SKILLS ------------------------------------------------
    ----------------------------------------------------------------

    -- Soul Magic
    Skill_Soul_Summons = GetString(LUIE_STRING_SKILL_SOUL_SUMMONS_TP),
    Skill_Soul_Trap = GetString(LUIE_STRING_SKILL_SOUL_TRAP),
    Skill_Consuming_Trap = GetString(LUIE_STRING_SKILL_CONSUMING_TRAP),

    -- Vampire
    Skill_Noxiphilic_Sanguivoria = GetString(LUIE_STRING_SKILL_NOXIPHILIC_SANGUIVORIA_TP),
    Skill_Vampirism_Stage_1 = GetString(LUIE_STRING_SKILL_VAMPIRISM_STAGE1_TP),
    Skill_Vampirism_Stage_2 = GetString(LUIE_STRING_SKILL_VAMPIRISM_STAGE2_TP),
    Skill_Vampirism_Stage_3 = GetString(LUIE_STRING_SKILL_VAMPIRISM_STAGE3_TP),
    Skill_Vampirism_Stage_4 = GetString(LUIE_STRING_SKILL_VAMPIRISM_STAGE4_TP),
    Skill_Vampirism_Stage_5 = GetString(LUIE_STRING_SKILL_VAMPIRISM_STAGE5_TP),
    Skill_Blood_Ritual = GetString(LUIE_STRING_SKILL_BLOOD_RITUAL_TP),
    Skill_Unnatural_Movement = GetString(LUIE_STRING_SKILL_UNNATURAL_MOVEMENT_TP),
    Skill_Blood_for_Blood = GetString(LUIE_STRING_SKILL_BLOOD_FOR_BLOOD_TP),
    Skill_Blood_Frenzy = GetString(LUIE_STRING_SKILL_BLOOD_FRENZY_TP),
    Skill_Simmering_Frenzy = GetString(LUIE_STRING_SKILL_SIMMERING_FRENZY_TP),
    Skill_Sated_Fury = GetString(LUIE_STRING_SKILL_SATED_FURY_TP),
    Skill_Vampiric_Drain = GetString(LUIE_STRING_SKILL_VAMPIRIC_DRAIN_TP),
    Skill_Drain_Vigor = GetString(LUIE_STRING_SKILL_DRAIN_VIGOR_TP),
    Skill_Exhilarating_Drain = GetString(LUIE_STRING_SKILL_EXHILARATING_DRAIN_TP),
    Skill_Stupefy = GetString(LUIE_STRING_SKILL_STUPEFY_TP),
    Skill_Mist_Form = GetString(LUIE_STRING_SKILL_MIST_FORM_TP),
    Skill_Blood_Mist = GetString(LUIE_STRING_SKILL_BLOOD_MIST_TP),
    Skill_Blood_Scion = GetString(LUIE_STRING_SKILL_BLOOD_SCION_TP),
    Skill_Swarming_Scion = GetString(LUIE_STRING_SKILL_SWARMING_SCION_TP),

    -- Werewolf
    Skill_Sanies_Lupinus = GetString(LUIE_STRING_SKILL_SANIES_LUPINUS_TP),
    Skill_Lycanthrophy = GetString(LUIE_STRING_SKILL_LYCANTHROPHY_TP),
    Skill_Blood_Moon = GetString(LUIE_STRING_SKILL_BLOOD_MOON_TP),
    Skill_Claws_of_Life = GetString(LUIE_STRING_SKILL_CLAWS_OF_LIFE_TP),
    Skill_Werewolf_Transformation = GetString(LUIE_STRING_SKILL_WEREWOLF_TRANSFORMATION_TP),
    Skill_Werewolf_Berserker = GetString(LUIE_STRING_SKILL_WEREWOLF_BERSERKER_TP),
    Skill_Pack_Leader = GetString(LUIE_STRING_SKILL_PACK_LEADER_TP),

    Skill_Carnage_Proc = GetString(LUIE_STRING_SKILL_CARNAGE_PROC_TP),
    Skill_Carnage = GetString(LUIE_STRING_SKILL_CARNAGE_TP),
    Skill_Feral_Carnage = GetString(LUIE_STRING_SKILL_FERAL_CARNAGE_TP),
    Skill_Brutal_Carnage_Buff = GetString(LUIE_STRING_SKILL_BRUTAL_CARNAGE_BUFF_TP),
    Skill_Hircines_Fortitude = GetString(LUIE_STRING_SKILL_HIRCINES_FORTITUDE_TP),
    Skill_Ferocious_Roar = GetString(LUIE_STRING_SKILL_FEROCIOUS_ROAR_TP),

    ----------------------------------------------------------------
    -- GUILDS SKILLS ------------------------------------------------
    ----------------------------------------------------------------

    -- Fighters Guild
    Skill_Circle_of_Protection = GetString(LUIE_STRING_SKILL_CIRCLE_OF_PROTECTION_TP),
    Skill_Ring_of_Preservation = GetString(LUIE_STRING_SKILL_RING_OF_PRESERVATION_TP),
    Skill_Expert_Hunter = GetString(LUIE_STRING_SKILL_EXPERT_HUNTER_TP),
    Skill_Evil_Hunter = GetString(LUIE_STRING_SKILL_EVIL_HUNTER_TP),
    Skill_Trap_Beast = GetString(LUIE_STRING_SKILL_TRAP_BEAST_TP),
    Skill_Trap_Beast_Debuff = GetString(LUIE_STRING_SKILL_TRAP_BEAST_DEBUFF_TP),
    Skill_Barbed_Trap = GetString(LUIE_STRING_SKILL_BARBED_TRAP_TP),
    Skill_Barbed_Trap_Debuff = GetString(LUIE_STRING_SKILL_BARBED_TRAP_DEBUFF_TP),
    Skill_Flawless_Dawnbreaker = GetString(LUIE_STRING_SKILL_FLAWLESS_DAWNBREAKER_TP),
    Skill_Dawnbreaker_of_Smiting = GetString(LUIE_STRING_SKILL_DAWNBREAKER_OF_SMITING_TP),

    -- Mages Guild
    Skill_Radiant_Magelight = GetString(LUIE_STRING_SKILL_RADIANT_MAGELIGHT_TP),
    Skill_Structured_Entropy = GetString(LUIE_STRING_SKILL_STRUCTURED_ENTROPY_TP),
    Skill_Fire_Rune = GetString(LUIE_STRING_SKILL_FIRE_RUNE_TP),
    Skill_Volcanic_Rune = GetString(LUIE_STRING_SKILL_VOLCANIC_RUNE_TP),
    Skill_Scalding_Rune = zo_strformat(GetString(LUIE_STRING_SKILL_SCALDING_RUNE_TP), ((GetAbilityDuration(40468) or 0) / 1000) + GetNumPassiveSkillRanks(GetSkillLineIndicesFromSkillLineId(44), select(2, GetSkillLineIndicesFromSkillLineId(44)), 8)),
    Skill_Equilibrium = GetString(LUIE_STRING_SKILL_EQUILIBRIUM_TP),
    Skill_Spell_Symmetry = GetString(LUIE_STRING_SKILL_SPELL_SYMMETRY_TP),
    Skill_Meteor = GetString(LUIE_STRING_SKILL_METEOR_TP),
    Skill_Ice_Comet = GetString(LUIE_STRING_SKILL_ICE_COMET_TP),

    -- Psijic Order
    Skill_Spell_Orb = GetString(LUIE_STRING_SKILL_SPELL_ORB_TP),
    Skill_Concentrated_Barrier = GetString(LUIE_STRING_SKILL_CONCENTRATED_BARRIER_TP),
    Skill_Time_Stop = GetString(LUIE_STRING_SKILL_TIME_STOP_TP),
    Skill_Borrowed_Time = GetString(LUIE_STRING_SKILL_TIME_BORROWED_TIME_TP),
    Skill_Borrowed_Time_Stun = GetString(LUIE_STRING_SKILL_TIME_BORROWED_TIME_STUN_TP),
    Skill_Time_Freeze = GetString(LUIE_STRING_SKILL_TIME_FREEZE_TP),
    Skill_Time_Freeze_Ground = GetString(LUIE_STRING_SKILL_TIME_FREEZE_GROUND_TP),
    Skill_Imbue_Weapon = GetString(LUIE_STRING_SKILL_IMBUE_WEAPON_TP),
    Skill_Elemental_Weapon = GetString(LUIE_STRING_SKILL_ELEMENTAL_WEAPON_TP),
    Skill_Crushing_Weapon = GetString(LUIE_STRING_SKILL_CRUSHING_WEAPON_TP),
    Skill_Mend_Wounds = GetString(LUIE_STRING_SKILL_MEND_WOUNDS_TP),
    Skill_Mend_Spirit = GetString(LUIE_STRING_SKILL_MEND_SPIRIT_TP),
    Skill_Symbiosis = GetString(LUIE_STRING_SKILL_SYMBIOSIS_TP),
    Skill_Meditate = GetString(LUIE_STRING_SKILL_MEDITATE_TP),
    Skill_Introspection = GetString(LUIE_STRING_SKILL_INTROSPECTION_TP),

    -- Undaunted
    Skill_Blood_Altar = GetString(LUIE_STRING_SKILL_BLOOD_ALTAR_TP),
    Skill_Overflowing_Altar = GetString(LUIE_STRING_SKILL_OVERFLOWING_ALTAR_TP),
    Skill_Trapping_Webs = GetString(LUIE_STRING_SKILL_TRAPPING_WEBS_TP),
    Skill_Shadow_Silk = GetString(LUIE_STRING_SKILL_SHADOW_SILK_TP),
    Skill_Tangling_Webs = GetString(LUIE_STRING_SKILL_TANGLING_WEBS_TP),
    Skill_Trapping_Webs_Snare = GetString(LUIE_STRING_SKILL_TRAPPING_WEBS_SNARE_TP),
    Skill_Spawn_Broodling = GetString(LUIE_STRING_SKILL_SPAWN_BROODLING_TP),
    Skill_Inner_Beast = GetString(LUIE_STRING_SKILL_INNER_BEAST_TP),
    Skill_Radiate = GetString(LUIE_STRING_SKILL_RADIATE_TP),
    Skill_Bone_Shield = GetString(LUIE_STRING_SKILL_BONE_SHIELD_TP),
    Skill_Spiked_Bone_Shield = GetString(LUIE_STRING_SKILL_SPIKED_BONE_SHIELD_TP),
    Skill_Bone_Surge = GetString(LUIE_STRING_SKILL_BONE_SURGE_TP),
    Skill_Necrotic_Orb = GetString(LUIE_STRING_SKILL_NECROTIC_ORB_TP),
    Skill_Energy_Orb = GetString(LUIE_STRING_SKILL_ENERGY_ORB_TP),

    ----------------------------------------------------------------
    -- ALLIANCE WAR SKILLS -----------------------------------------
    ----------------------------------------------------------------

    -- Assault
    Skill_Continuous_Attack_Rank_1 = GetString(LUIE_STRING_SKILL_CONTINUOUS_ATTACK_RANK_1_TP),
    Skill_Continuous_Attack_Rank_2 = GetString(LUIE_STRING_SKILL_CONTINUOUS_ATTACK_RANK_2_TP),
    Skill_Retreating_Maneuver = GetString(LUIE_STRING_SKILL_RETREATING_MANEUEVER_TP),
    Skill_Caltrops = GetString(LUIE_STRING_SKILL_CALTROPS_TP),
    Skill_Anti_Cavalry_Caltrops = GetString(LUIE_STRING_SKILL_ANTI_CAVALRY_CALTROPS_TP),
    Skill_Anti_Cavalry_Caltrops_Debuff = GetString(LUIE_STRING_SKILL_ANTI_CAVALRY_CALTROPS_DEBUFF_TP),
    Skill_Razor_Caltrops = GetString(LUIE_STRING_SKILL_RAZOR_CALTROPS_TP),
    Skill_Razor_Caltrops_Debuff = GetString(LUIE_STRING_SKILL_RAZOR_CALTROPS_DEBUFF_TP),
    Skill_Magicka_Detonation = GetString(LUIE_STRING_SKILL_MAGICKA_DETONATION_TP),
    Skill_Inevitable_Detonation = GetString(LUIE_STRING_SKILL_INEVITABLE_DETONATION_TP),
    Skill_Proximity_Detonation = GetString(LUIE_STRING_SKILL_PROXIMITY_DETONATION_TP),
    Skill_War_Horn = GetString(LUIE_STRING_SKILL_WAR_HORN_TP),
    Skill_War_Horn_Dummy = GetString(LUIE_STRING_SKILL_WAR_HORN_DUMMY_TP),
    Skill_Study_Horn = GetString(LUIE_STRING_SKILL_STURDY_HORN_TP),

    -- Support
    Skill_Siege_Shield = GetString(LUIE_STRING_SKILL_SIEGE_SHIELD_TP),
    Skill_Siege_Shield_Ground = GetString(LUIE_STRING_SKILL_SIEGE_SHIELD_GROUND_TP),
    Skill_Siege_Weapon_Shield = GetString(LUIE_STRING_SKILL_SIEGE_WEAPON_SHIELD_TP),
    Skill_Siege_Weapon_Shield_Ground = GetString(LUIE_STRING_SKILL_SIEGE_WEAPON_SHIELD_GROUND_TP),
    Skill_Propelling_Shield = GetString(LUIE_STRING_SKILL_PROPELLING_SHIELD_TP),
    Skill_Propelling_Shield_Ground = GetString(LUIE_STRING_SKILL_PROPELLING_SHIELD_GROUND_TP),
    Skill_Guard_Self = GetString(LUIE_STRING_SKILL_GUARD_SELF_TP),
    Skill_Guard_Other = GetString(LUIE_STRING_SKILL_GUARD_OTHER_TP),
    Skill_Revealing_Flare = GetString(LUIE_STRING_SKILL_REVEALING_FLARE_TP),
    Skill_Blinding_Flare = GetString(LUIE_STRING_SKILL_BLINDING_FLARE_TP),
    Skill_Replenishing_Barrier = GetString(LUIE_STRING_SKILL_REPLENISHING_BARRIER_TP),

    -- ---------------------------------------------------
    -- CYRODIIL ------------------------------------------
    -- ---------------------------------------------------

    Skill_AvA_Sanctuary = GetString(LUIE_STRING_SKILL_AVA_SANCTUARY_TP),
    Skill_Lightning_Ballista_Bolt = GetString(LUIE_STRING_SKILL_LIGHTNING_BALLISTA_BOLT_TP),
    Skill_Meatbag_Catapult_AOE = GetString(LUIE_STRING_SKILL_MEATBAG_CATAPULT_AOE_TP),
    Skill_Meatbag_Catapult_Ground = GetString(LUIE_STRING_SKILL_MEATBAG_CATAPULT_GROUND_TP),
    Skill_Oil_Catapult_Ground = GetString(LUIE_STRING_SKILL_OIL_CATAPULT_GROUND_TP),
    Skill_Scattershot_Catapult_AOE = GetString(LUIE_STRING_SKILL_SCATTERSHOT_CATAPULT_AOE_TP),
    Skill_Scattershot_Catapult_Ground = GetString(LUIE_STRING_SKILL_SCATTERSHOT_CATAPULT_GROUND_TP),
    Skill_Guard_Detection = GetString(LUIE_STRING_SKILL_GUARD_DETECTION_TP),
    Skill_Blessing_of_War = GetString(LUIE_STRING_SKILL_BLESSING_OF_WAR_TP),
    Skill_Home_Keep_Bonus = GetString(LUIE_STRING_SKILL_HOME_KEEP_BONUS_TP),
    Skill_Enemy_Keep_Bonus_I = zo_strformat(GetString(LUIE_STRING_SKILL_ENEMY_KEEP_BONUS_TP), 7, 1),
    Skill_Enemy_Keep_Bonus_II = zo_strformat(GetString(LUIE_STRING_SKILL_ENEMY_KEEP_BONUS_TP), 8, 2),
    Skill_Enemy_Keep_Bonus_III = zo_strformat(GetString(LUIE_STRING_SKILL_ENEMY_KEEP_BONUS_TP), 9, 3),
    Skill_Enemy_Keep_Bonus_IV = zo_strformat(GetString(LUIE_STRING_SKILL_ENEMY_KEEP_BONUS_TP), 10, 4),
    Skill_Enemy_Keep_Bonus_V = zo_strformat(GetString(LUIE_STRING_SKILL_ENEMY_KEEP_BONUS_TP), 11, 5),
    Skill_Enemy_Keep_Bonus_VI = zo_strformat(GetString(LUIE_STRING_SKILL_ENEMY_KEEP_BONUS_TP), 12, 6),
    Skill_Enemy_Keep_Bonus_VII = zo_strformat(GetString(LUIE_STRING_SKILL_ENEMY_KEEP_BONUS_TP), 13, 7),
    Skill_Enemy_Keep_Bonus_VIII = zo_strformat(GetString(LUIE_STRING_SKILL_ENEMY_KEEP_BONUS_TP), 14, 8),
    Skill_Enemy_Keep_Bonus_IX = zo_strformat(GetString(LUIE_STRING_SKILL_ENEMY_KEEP_BONUS_TP), 15, 9),
    Skill_Edge_Keep_Bonus_I = zo_strformat(GetString(LUIE_STRING_SKILL_EDGE_KEEP_BONUS_TP), 8),
    Skill_Edge_Keep_Bonus_II = zo_strformat(GetString(LUIE_STRING_SKILL_EDGE_KEEP_BONUS_TP), 16),
    Skill_Edge_Keep_Bonus_III = zo_strformat(GetString(LUIE_STRING_SKILL_EDGE_KEEP_BONUS_TP), 24),
    Skill_Defensive_Scroll_Bonus_I = zo_strformat(GetString(LUIE_STRING_SKILL_DEFENSIVE_SCROLL_BONUS_TP), 2),
    Skill_Defensive_Scroll_Bonus_II = zo_strformat(GetString(LUIE_STRING_SKILL_DEFENSIVE_SCROLL_BONUS_TP), 5),
    Skill_Offensive_Scroll_Bonus_I = zo_strformat(GetString(LUIE_STRING_SKILL_OFFENSIVE_SCROLL_BONUS_TP), 2),
    Skill_Offensive_Scroll_Bonus_II = zo_strformat(GetString(LUIE_STRING_SKILL_OFFENSIVE_SCROLL_BONUS_TP), 5),
    Skill_Emperorship_Alliance_Bonus_I = zo_strformat(GetString(LUIE_STRING_SKILL_EMPERORSHIP_ALLIANCE_BONUS_TP), 900),
    Skill_Emperorship_Alliance_Bonus_II = zo_strformat(GetString(LUIE_STRING_SKILL_EMPERORSHIP_ALLIANCE_BONUS_TP), 1050),
    Skill_Emperorship_Alliance_Bonus_III = zo_strformat(GetString(LUIE_STRING_SKILL_EMPERORSHIP_ALLIANCE_BONUS_TP), 1250),
    Skill_Emperorship_Alliance_Bonus_IV = zo_strformat(GetString(LUIE_STRING_SKILL_EMPERORSHIP_ALLIANCE_BONUS_TP), 1400),
    Skill_Emperorship_Alliance_Bonus_V = zo_strformat(GetString(LUIE_STRING_SKILL_EMPERORSHIP_ALLIANCE_BONUS_TP), 1600),
    Skill_Emperorship_Alliance_Bonus_VI = zo_strformat(GetString(LUIE_STRING_SKILL_EMPERORSHIP_ALLIANCE_BONUS_TP), 1750),
    Skill_Razor_Armor = GetString(LUIE_STRING_SKILL_RAZOR_ARMOR_TP),
    Skill_Unstable_Core_Cyrodiil = GetString(LUIE_STRING_SKILL_UNSTABLE_CORE_CYRODIIL_TP),
    Skill_Shattering_Prison_Cyrodiil = GetString(LUIE_STRING_SKILL_SHATTERING_PRISON_CYRODIIL_TP),
    Skill_Siege_Shield_Cyrodiil = GetString(LUIE_STRING_SKILL_SIEGE_SHIELD_CYRODIIL_TP),
    Skill_Power_Bash_Cyrodiil = GetString(LUIE_STRING_SKILL_POWER_BASH_CYRODIIL_TP),
    Skill_Rune_Focus_Cyrodiil = GetString(LUIE_STRING_SKILL_RUNE_FOCUS_CYRODIIL_TP),

    Skill_Elder_Scroll_Altadoon = zo_strformat(GetString(LUIE_STRING_SKILL_ELDER_SCROLL_TP), GetAbilityName(15177)),
    Skill_Elder_Scroll_Mnem = zo_strformat(GetString(LUIE_STRING_SKILL_ELDER_SCROLL_TP), GetAbilityName(15178)),
    Skill_Elder_Scroll_Ghartok = zo_strformat(GetString(LUIE_STRING_SKILL_ELDER_SCROLL_TP), GetAbilityName(22282)),
    Skill_Elder_Scroll_Chim = zo_strformat(GetString(LUIE_STRING_SKILL_ELDER_SCROLL_TP), GetAbilityName(22295)),
    Skill_Elder_Scroll_Ni_Mohk = zo_strformat(GetString(LUIE_STRING_SKILL_ELDER_SCROLL_TP), GetAbilityName(22297)),
    Skill_Elder_Scroll_Alma_Ruma = zo_strformat(GetString(LUIE_STRING_SKILL_ELDER_SCROLL_TP), GetAbilityName(22299)),

    Skill_Ruinous_Cyclone = GetString(LUIE_STRING_SKILL_RUINOUS_CYCLONE),

    Skill_Wall_of_Souls = GetString(LUIE_STRING_SKILL_WALL_OF_SOULS_TP),

    -- ---------------------------------------------------
    -- BATTLEGROUNDS -------------------------------------
    -- ---------------------------------------------------

    Skill_Mark_of_the_Worm = GetString(LUIE_STRING_SKILL_MARK_OF_THE_WORM_TP),

    -- ---------------------------------------------------
    -- TRAPS ---------------------------------------------
    -- ---------------------------------------------------

    Skill_Slaughterfish_Attack = GetString(LUIE_STRING_SKILL_SLAUGHTERFISH_ATTACK_TP),

    Skill_Spike_Trap = GetString(LUIE_STRING_SKILL_SPIKE_TRAP_TP),
    Skill_Spike_Trap_Auridon = GetString(LUIE_STRING_SKILL_SPIKE_TRAP_AURIDON_TP),
    Skill_Trap_Static_Pitcher = GetString(LUIE_STRING_SKILL_STATIC_PITCHER_TP),
    Skill_Trap_Stunted_Current = GetString(LUIE_STRING_SKILL_STUNTED_CURRENT_TP),

    ----------------------------------------------------------------
    -- NPCS ------------------------------------------------------
    ----------------------------------------------------------------

    -- Basic / Shared
    Skill_Backstabber = GetString(LUIE_STRING_SKILL_BACKSTABBER_TP),
    Skill_Recover = GetString(LUIE_STRING_SKILL_RECOVER_TP),
    Skill_Recover_Duel = GetString(LUIE_STRING_SKILL_RECOVER_DUEL_TP),

    -- Animals
    Skill_Ancient_Skin = zo_strformat(GetString(LUIE_STRING_SKILL_HARDENED_CARAPACE_TP), 9),
    Skill_Weakness_Lion = GetString(LUIE_STRING_SKILL_WEAKNESS_LION_TP),
    Skill_Hardened_Shell = GetString(LUIE_STRING_SKILL_HARDENED_SHELL_TP),
    Skill_Slash_Cliff_Strider = GetString(LUIE_STRING_SKILL_SLASH_CLIFF_STRIDER_TP),
    Skill_Baleful_Call = GetString(LUIE_STRING_SKILL_BALEFUL_CALL_TP),

    -- Human NPCs
    Skill_Cleave_Stance = GetString(LUIE_STRING_SKILL_CLEAVE_STANCE_TP),
    Skill_Defensive_Ward = GetString(LUIE_STRING_SKILL_DEFENSIVE_WARD_TP),
    Skill_Soul_Tether_NPC = GetString(LUIE_STRING_SKILL_SOUL_TETHER_NPC_TP),
    -- Skill_Focused_Healing                           = GetString(LUIE_STRING_SKILL_FOCUSED_HEALING_TP),
    Skill_Rite_of_Passage_NPC = GetString(LUIE_STRING_SKILL_RITE_OF_PASSAGE_NPC_TP),
    Skill_Throw_Dagger = GetString(LUIE_STRING_SKILL_THROW_DAGGER_TP),
    Skill_Agony = GetString(LUIE_STRING_SKILL_AGONY_TP),
    Skill_Ice_Barrier = GetString(LUIE_STRING_SKILL_ICE_BARRIER_TP),
    Skill_Agonizing_Fury = GetString(LUIE_STRING_SKILL_AGONIZING_FURY_TP),
    Skill_Grasping_Vines = GetString(LUIE_STRING_SKILL_GRASPING_VINES_TP),
    Skill_Retaliation_NPC = GetString(LUIE_STRING_SKILL_RETALIATION_NPC_TP),
    Skill_Briarheart_Resurrection = GetString(LUIE_STRING_SKILL_BRIARHEART_RESURRECTION_TP),
    Skill_Enrage_Devoted = GetString(LUIE_STRING_SKILL_ENRAGE_DEVOTED_TP),
    Skill_Uncanny_Dodge = GetString(LUIE_STRING_SKILL_UNCANNY_DODGE_TP),
    Skill_Block_NPC = GetString(LUIE_STRING_SKILL_BLOCK_NPC_TP),
    Skill_Block_NPC_Theater = GetString(LUIE_STRING_SKILL_BLOCK_NPC_THEATER_TP),
    Skill_Call_Ally = GetString(LUIE_STRING_SKILL_CALL_ALLY_TP),
    Skill_Feral_Guardian_NPC = GetString(LUIE_STRING_SKILL_FERAL_GUARDIAN_NPC_TP),
    Skill_Shadowy_Duplicate = GetString(LUIE_STRING_SKILL_SHADOWY_DUPLICATE_TP),
    Skill_Shadowy_Barrier = GetString(LUIE_STRING_SKILL_SHADOWY_BARRIER_TP),
    Skill_Fiendish_Healing = GetString(LUIE_STRING_SKILL_FIENDISH_HEALING_TP),
    Skill_War_Horn_NPC = GetString(LUIE_STRING_SKILL_WAR_HORN_NPC_TP),
    Skill_Radiant_Magelight_NPC = GetString(LUIE_STRING_SKILL_RADIANT_MAGELIGHT_NPC_TP),
    Skill_Dampen_Magic = GetString(LUIE_STRING_SKILL_DAMPEN_MAGIC_TP),
    Skill_Summon_the_Dead = GetString(LUIE_STRING_SKILL_SUMMON_THE_DEAD_TP),
    Skill_Burdening_Eye = GetString(LUIE_STRING_SKILL_BURDENING_EYE_TP),
    Skill_Spell_Absorption = GetString(LUIE_STRING_SKILL_SPELL_ABSORPTION_TP),
    Skill_Shard_Shield = GetString(LUIE_STRING_SKILL_SHARD_SHIELD_TP),
    Skill_Til_Death = GetString(LUIE_STRING_SKILL_TIL_DEATH_TP),
    Skill_Til_Death_Self = GetString(LUIE_STRING_SKILL_TIL_DEATH_SELF_TP),

    -- Insects
    Skill_Hardened_Carapace = zo_strformat(GetString(LUIE_STRING_SKILL_HARDENED_CARAPACE_TP), 15),
    Skill_Inject_Larva = GetString(LUIE_STRING_SKILL_INJECT_LARVA_TP),
    Skill_Latch_On = GetString(LUIE_STRING_SKILL_LATCH_ON_TP),
    Skill_Kotu_Gava_Swarm = GetString(LUIE_STRING_SKILL_KOTU_GAVA_SWARM_TP),
    Skill_Colonize = GetString(LUIE_STRING_SKILL_COLONIZE_TP),

    -- Monsters
    Skill_Harmony = GetString(LUIE_STRING_SKILL_HARMONY_TP),
    Skill_Summon_Spectral_Lamia = GetString(LUIE_STRING_SKILL_SUMMON_SPECTRAL_LAMIA_TP),
    Skill_Weakness_NPC_Summon = GetString(LUIE_STRING_SKILL_WEAKNESS_NPC_SUMMON_TP),
    Skill_Ice_Pillar = GetString(LUIE_STRING_SKILL_ICE_PILLAR_TP),
    Skill_Summon_Beast = GetString(LUIE_STRING_SKILL_SUMMON_BEAST_TP),
    Skill_Control_Beast = GetString(LUIE_STRING_SKILL_CONTROL_BEAST_TP),
    Skill_Healing_Salve = GetString(LUIE_STRING_SKILL_HEALING_SALVE_TP),
    Skill_Reflective_Shadows = GetString(LUIE_STRING_SKILL_REFLECTIVE_SHADOWS_TP),
    Skill_Steal_Essence = GetString(LUIE_STRING_SKILL_STEAL_ESSENCE_TP),
    Skill_Flame_Ray = GetString(LUIE_STRING_SKILL_FLAME_RAY_TP),
    Skill_Frost_Ray = GetString(LUIE_STRING_SKILL_FROST_RAY_TP),
    Skill_Lacerate_Gargoyle = GetString(LUIE_STRING_SKILL_LACERATE_GARGOYLE_TP),
    Skill_Vampiric_Touch_Gargoyle = GetString(LUIE_STRING_SKILL_VAMPIRIC_TOUCH_GARGOYLE_TP),
    Skill_Elemental_Weapon_NPC = GetString(LUIE_STRING_SKILL_ELEMENTAL_WEAPON_NPC_TP),
    Skill_Regeneration_Troll = GetString(LUIE_STRING_SKILL_REGENERATION_TROLL_TP),
    Skill_Consuming_Omen = GetString(LUIE_STRING_SKILL_CONSUMING_OMEN_TP),
    Skill_Consuming_Omen_Snare = GetString(LUIE_STRING_SKILL_CONSUMING_OMEN_SNARE_TP),
    Skill_Close_Wounds = GetString(LUIE_STRING_SKILL_CLOSE_WOUNDS_TP),

    -- Daedra
    Skill_Empower_Atronach_Flame = GetString(LUIE_STRING_SKILL_EMPOWER_ATRONACH_FLAME_TP),
    Skill_Empower_Atronach_Flame_Unlimited = GetString(LUIE_STRING_SKILL_EMPOWER_ATRONACH_FLAME_UNLIMITED_TP),
    Skill_Empower_Atronach_Frost = GetString(LUIE_STRING_SKILL_EMPOWER_ATRONACH_FROST_TP),
    Skill_Empower_Atronach_Storm = GetString(LUIE_STRING_SKILL_EMPOWER_ATRONACH_STORM_TP),
    Skill_Lightning_Rod = GetString(LUIE_STRING_SKILL_LIGHTNING_ROD_TP),
    Skill_Storm_Bound = GetString(LUIE_STRING_SKILL_STORM_BOUND_TP),
    Skill_Chilling_Aura = GetString(LUIE_STRING_SKILL_CHILLING_AURA_TP),
    Skill_Radiance = GetString(LUIE_STRING_SKILL_RADIANCE_TP),
    Skill_Devour_Clannfear = GetString(LUIE_STRING_SKILL_DEVOUR_CLANNFEAR_TP),
    Skill_Aura_of_Protection = GetString(LUIE_STRING_SKILL_AURA_OF_PROTECTION_TP),
    Skill_Aura_of_Protection_Other = GetString(LUIE_STRING_SKILL_AURA_OF_PROTECTION_OTHER_TP),
    Skill_Devour_Hunger = GetString(LUIE_STRING_SKILL_DEVOUR_HUNGER_TP),
    Skill_Torpor = GetString(LUIE_STRING_SKILL_TORPOR_TP),
    Skill_Summon_Spiderling = GetString(LUIE_STRING_SKILL_SUMMON_SPIDERLING_TP),
    Skill_Unyielding_Mace = GetString(LUIE_STRING_SKILL_UNYIELDING_MACE_TP),
    Skill_Wing_Gust_Snare = GetString(LUIE_STRING_SKILL_WING_GUST_SNARE),
    Skill_Wing_Gust_Stun = GetString(LUIE_STRING_SKILL_WING_GUST_STUN),

    -- Undead
    Skill_Vampiric_Drain_NPC = GetString(LUIE_STRING_SKILL_VAMPIRIC_DRAIN_NPC_TP),

    -- Dwemer
    Skill_Static_Field = GetString(LUIE_STRING_SKILL_STATIC_FIELD_TP),
    Skill_Shock_Barrage = GetString(LUIE_STRING_SKILL_SHOCK_BARRAGE_TP),
    Skill_Polarizing_Field = GetString(LUIE_STRING_SKILL_POLARIZING_FIELD_TP),
    Skill_Static_Shield = GetString(LUIE_STRING_SKILL_STATIC_SHIELD_TP),
    Skill_Turret_Mode = GetString(LUIE_STRING_SKILL_TURRET_MODE_TP),

    ----------------------------------------------------------------
    -- WORLD -------------------------------------------------------
    ----------------------------------------------------------------

    Skill_Static_Charge = GetString(LUIE_STRING_SKILL_STATIC_CHARGE_TP),

    ----------------------------------------------------------------
    -- WORLD BOSSES ------------------------------------------------
    ----------------------------------------------------------------

    Skill_Molten_Pillar = GetString(LUIE_STRING_SKILL_MOLTEN_PILLAR_TP),
    Skill_Trapping_Bolt = GetString(LUIE_STRING_SKILL_TRAPPING_BOLT_WORLD_TP),
    Skill_Poison_Spit = GetString(LUIE_STRING_SKILL_POISON_SPIT_TP),
    Skill_Graven_Slash = GetString(LUIE_STRING_SKILL_GRAVEN_SLASH_TP),
    Skill_Constricting_Webs = GetString(LUIE_STRING_SKILL_CONSTRICTING_WEBS_TP),

    ----------------------------------------------------------------
    -- QUESTS ------------------------------------------------------
    ----------------------------------------------------------------

    -- MSQ
    Skill_Eye_of_the_Sentinel = GetString(LUIE_STRING_SKILL_EYE_OF_THE_SENTINEL_TP),
    Skill_Incapacitating_Terror = GetString(LUIE_STRING_SKILL_INCAPACITATING_TERROR_TP),

    -- Aldmeri Quests
    Skill_Blessing_Gathwen = GetString(LUIE_STRING_SKILL_BLESSING_GATHWEN_TP),
    Skill_Disguise_Altmer_Glamour = GetString(LUIE_STRING_SKILL_DISGUISE_ALTMER_GLAMOUR_TP),
    Skill_Spiritual_Cloak = GetString(LUIE_STRING_SKILL_SPIRITUAL_CLOAK_TP),
    Skill_Aetherial_Shift = GetString(LUIE_STRING_SKILL_AETHERIAL_SHIFT_TP),
    Skill_Divine_Speed = GetString(LUIE_STRING_SKILL_DIVINE_SPEED_TP),
    Skill_Lightning_Fury = GetString(LUIE_STRING_SKILL_QUEST_LIGHTNING_FURY_TP),
    Skill_Blacksaps_Brew = GetString(LUIE_STRING_SKILL_BLACKSAPS_BREW_TP),
    Skill_Vision_Journey = GetString(LUIE_STRING_SKILL_VISION_JOURNEY_TP),
    Skill_Snakes_Scales = GetString(LUIE_STRING_SKILL_SNAKE_SCALES_TP),
    Skill_Wolfs_Pelt = GetString(LUIE_STRING_SKILL_WOLFS_PELT_TP),
    Skill_Tigers_Fur = GetString(LUIE_STRING_SKILL_TIGERS_FUR_TP),
    Skill_Soul_Binding = GetString(LUIE_STRING_SKILL_SOUL_BINDING_TP),
    Skill_Spirit_Armor = GetString(LUIE_STRING_SKILL_SPIRIT_ARMOR_TP),
    Skill_Fancy_Clothing = GetString(LUIE_STRING_SKILL_FANCY_CLOTHING_TP),
    Skill_Wilderkings_Protection = GetString(LUIE_STRING_SKILL_WILDERKINGS_PROTECTION_TP),
    Skill_Burrow = GetString(LUIE_STRING_SKILL_BURROW_TP),
    Skill_Shadow_Wood = GetString(LUIE_STRING_SKILL_SHADOW_WOOD_TP),
    Skill_Ancient_Wrath = GetString(LUIE_STRING_SKILL_ANCIENT_WRATH_TP),
    Skill_Necrotic_Circle_Stun = GetString(LUIE_STRING_SKILL_NECROTIC_CIRCLE_STUN_TP),

    -- Daggerfall Covenant Quests
    Skill_Vision_of_the_Past = GetString(LUIE_STRING_SKILL_VISION_OF_THE_PAST_TP),

    -- Elsweyr Quests
    Skill_Flame_Aura = GetString(LUIE_STRING_SKILL_FLAME_AURA),

    -- Greymoor Quests
    Skill_Freezing_Vines = GetString(LUIE_STRING_SKILL_FREEZING_VINES_TP),

    ----------------------------------------------------------------
    -- ARENAS ------------------------------------------------------
    ----------------------------------------------------------------

    -- Dragonstar Arena
    Skill_Expert_Hunter_NPC = GetString(LUIE_STRING_SKILL_EXPERT_HUNTER_NPC_TP),
    Skill_Circle_of_Protection_NPC = GetString(LUIE_STRING_SKILL_CIRCLE_OF_PROTECTION_NPC_TP),
    Skill_Pierce_Armor_NPC = GetString(LUIE_STRING_SKILL_PIERCE_ARMOR_NPC_TP),
    Skill_Deep_Slash_NPC = GetString(LUIE_STRING_SKILL_DEEP_SLASH_NPC_TP),
    Skill_Biting_Cold = GetString(LUIE_STRING_SKILL_BITING_COLD_TP),
    Skill_Biting_Cold_Vet = GetString(LUIE_STRING_SKILL_BITING_COLD_VET_TP),
    Skill_Frost_Clench_NPC = GetString(LUIE_STRING_SKILL_FROST_CLENCH_NPC_TP),
    Skill_U_Wall_of_Frost_NPC = GetString(LUIE_STRING_SKILL_UWOF_NPC_TP),
    Skill_Elemental_Susceptibility_NPC = GetString(LUIE_STRING_SKILL_ELEMENTAL_SUSCEPTIBILITY_NPC_TP),
    Skill_Ember_Explosion = GetString(LUIE_STRING_SKILL_EMBER_EXPLOSION_TP),
    Skill_Thundering_Presence_NPC = GetString(LUIE_STRING_SKILL_THUNDERING_PRESENCE_NPC_TP),
    Skill_Bound_Aegis_NPC = GetString(LUIE_STRING_SKILL_BOUND_AEGIS_NPC_TP),
    Skill_Mark_Target_NPC = GetString(LUIE_STRING_SKILL_MARK_TARGET_NPC_TP),
    Skill_Enslavement = GetString(LUIE_STRING_SKILL_ENSLAVEMENT_TP),

    Skill_Molten_Armaments_NPC = GetString(LUIE_STRING_SKILL_MOLTEN_ARMAMENTS_NPC_TP),
    Skill_Cinder_Storm_NPC = GetString(LUIE_STRING_SKILL_CINDER_STORM_NPC_TP),
    Skill_Corrosive_Armor_NPC = GetString(LUIE_STRING_SKILL_CORROSIVE_ARMOR_NPC_TP),
    Skill_Corrosive_Armor_Debuff_NPC = GetString(LUIE_STRING_SKILL_CORROSIVE_ARMOR_NPC_DEBUFF_TP),
    Skill_Entropy_NPC = GetString(LUIE_STRING_SKILL_ENTROPY_NPC_TP),
    Skill_Petrify_NPC = GetString(LUIE_STRING_SKILL_PETRIFY_NPC_TP),
    Skill_Celestial_Ward = GetString(LUIE_STRING_SKILL_CELESTIAL_WARD_TP),
    Skill_Celestial_Blast = GetString(LUIE_STRING_SKILL_CELESTIAL_BLAST_TP),
    Skill_Standard_of_Might_NPC = GetString(LUIE_STRING_SKILL_STANDARD_OF_MIGHT_NPC_TP),
    Skill_Standard_of_Might_NPC_Ground = GetString(LUIE_STRING_SKILL_STANDARD_OF_MIGHT_NPC_GROUND_TP),
    Skill_Draining_Poison = GetString(LUIE_STRING_SKILL_DRAINING_POISON_TP),
    Skill_Natures_Blessing = GetString(LUIE_STRING_SKILL_NATURES_BLESSING_TP),
    Skill_Natures_Blessing_Ground = GetString(LUIE_STRING_SKILL_NATURES_BLESSING_GROUND_TP),
    Skill_Acid_Spray_NPC = GetString(LUIE_STRING_SKILL_ACID_SPRAY_NPC_TP),
    Skill_Dark_Flare_NPC = GetString(LUIE_STRING_SKILL_DARK_FLARE_NPC_TP),
    Skill_Purifying_Light_NPC = GetString(LUIE_STRING_SKILL_PURIFYING_LIGHT_NPC_TP),
    Skill_Unstable_Core_NPC = GetString(LUIE_STRING_SKILL_UNSTABLE_CORE_NPC_TP),
    Skill_Searing_Light = GetString(LUIE_STRING_SKILL_SEARING_LIGHT_TP),
    Skill_Solar_Disturbance_NPC = GetString(LUIE_STRING_SKILL_SOLAR_DISTURBANCE_NPC_TP),
    Skill_Dark_Dark_NPC = GetString(LUIE_STRING_SKILL_DARK_DEAL_NPC_TP),
    Skill_Ice_Charge = GetString(LUIE_STRING_SKILL_ICE_CHARGE_TP),
    Skill_Poison_Mist = GetString(LUIE_STRING_SKILL_POISON_MIST_TP),
    Skill_Drain_Essence_Vamp_NPC = GetString(LUIE_STRING_SKILL_DRAIN_ESSENCE_VAMP_NPC_TP),
    Skill_Malefic_Wreath = GetString(LUIE_STRING_SKILL_MALEFIC_WREATH_TP),
    Skill_Crippling_Grasp_NPC = GetString(LUIE_STRING_SKILL_CRIPPLING_GRASP_NPC_TP),
    Skill_Power_Extraction_NPC = GetString(LUIE_STRING_SKILLPOWER_EXTRACTION_NPC_TP),
    Skill_Marked_for_Death = GetString(LUIE_STRING_SKILL_MARKED_FOR_DEATH_TP),

    Skill_Devouring_Swarm = GetString(LUIE_STRING_SKILL_DEVOURING_SWARM_TP),
    Skill_Devouring_Swarm_Ground = GetString(LUIE_STRING_SKILL_DEVOURING_SWARM_GROUND_TP),

    Skill_Enrage_FG_Gladiator = GetString(LUIE_STRING_SKILL_ENRAGE_FG_GLADIATOR_TP),
    Skill_Torch_Grab = GetString(LUIE_STRING_SKILL_TORCH_GRAB_TP),
    Skill_Warming_Aura = GetString(LUIE_STRING_SKILL_WARMING_AURA_TP),

    -- Maelstrom Arena
    Skill_Sigil_of_Haste = GetString(LUIE_STRING_SKILL_SIGIL_OF_HASTE_TP),
    Skill_Sigil_of_Power = zo_strformat(GetString(LUIE_STRING_SKILL_SIGIL_OF_POWER_TP), 990),
    Skill_Sigil_of_Power_Veteran = zo_strformat(GetString(LUIE_STRING_SKILL_SIGIL_OF_POWER_TP), 1188),
    Skill_Sigil_of_Healing = GetString(LUIE_STRING_SKILL_SIGIL_OF_HEALING_TP),
    Skill_Sigil_of_Defense = GetString(LUIE_STRING_SKILL_SIGIL_OF_DEFENSE_TP),

    Skill_Defiled_Grave = GetString(LUIE_STRING_SKILL_DEFILED_GRAVE_TP),
    Skill_Defensive_Protocol = GetString(LUIE_STRING_SKILL_DEFENSIVE_PROTOCOL_TP),
    Skill_Overcharged = GetString(LUIE_STRING_SKILL_OVERCHARGED_DWEMER_TP),
    Skill_Overheated = GetString(LUIE_STRING_SKILL_OVERHEATED_DWEMER_TP),
    Skill_Overheated_VET = GetString(LUIE_STRING_SKILL_OVERHEATED_DWEMER_VET_TP),
    Skill_Voltaic_Overload = GetString(LUIE_STRING_SKILL_VOLTAIC_OVERLOAD_TP),
    Skill_Frigid_Waters = GetString(LUIE_STRING_SKILL_FRIGID_WATERS_TP),
    Skill_Cold_Snap = GetString(LUIE_STRING_SKILL_COLD_SNAP_TP),
    Skill_Blade_Trap_VMA = GetString(LUIE_STRING_SKILL_BLADE_TRAP_VMA),

    ----------------------------------------------------------------
    -- DUNGEONS ------------------------------------------------------
    ----------------------------------------------------------------

    -- Banished Cells I
    Skill_Summon_Dark_Proxy = GetString(LUIE_STRING_SKILL_SUMMON_DARK_PROXY_TP),
    Skill_Summon_Clannfear = GetString(LUIE_STRING_SKILL_SUMMON_CLANNFEAR_TP),

    -- Banished Cells II
    Skill_Curse_of_Suffering = GetString(LUIE_STRING_SKILL_CURSE_OF_SUFFERING_TP),
    Skill_Curse_of_Dominance = GetString(LUIE_STRING_SKILL_CURSE_OF_DOMINANCE_TP),
    Skill_Resilience = GetString(LUIE_STRING_SKILL_RESILIENCE_TP),
    Skill_Levitate_Suffering = GetString(LUIE_STRING_SKILL_LEVITATE_SUFFERING_TP),
    Skill_Levitating_Dominance = GetString(LUIE_STRING_SKILL_LEVITATE_DOMINANCE_TP),

    -- Elden Hollow II
    Skill_Siphon_Magicka = GetString(LUIE_STRING_SKILL_SIPHON_MAGICKA_TP),
    Skill_Siphon_Stamina = GetString(LUIE_STRING_SKILL_SIPHON_STAMINA_TP),
    Skill_Dark_Root_Stamina = GetString(LUIE_STRING_SKILL_DARK_ROOT_STAMINA_TP),
    Skill_Dark_Root_Magicka = GetString(LUIE_STRING_SKILL_DARK_ROOT_MAGICKA_TP),

    -- City of Ash I
    Skill_Blazing_Arrow = GetString(LUIE_STRING_SKILL_BLAZING_ARROW_TP),
    Skill_Blazing_Embers = GetString(LUIE_STRING_SKILL_BLAZING_EMBERS_TP),

    -- City of Ash II
    Skill_Enrage_Horvantud = GetString(LUIE_STRING_SKILL_ENRAGE_HORVANTUD),
    Skill_Flame_Tsunami = GetString(LUIE_STRING_SKILL_FLAME_TSUNAMI_TP),
    Skill_Ignore_Pain = GetString(LUIE_STRING_SKILL_IGNORE_PAIN_TP),
    Skill_Magma_Prison = GetString(LUIE_STRING_SKILL_MAGMA_PRISON_TP),
    Skill_Volcanic_Shield = GetString(LUIE_STRING_SKILL_VOLCANIC_SHIELD_TP),

    -- Tempest Island
    Skill_Backstab = GetString(LUIE_STRING_SKILL_BACKSTAB_TP),
    Skill_Enervating_Stone = GetString(LUIE_STRING_SKILL_ENERVATING_STONE_TP),
    Skill_Ethereal_Chain = GetString(LUIE_STRING_SKILL_ETHEREAL_CHAIN_TP),

    -- Selene's Web
    Skill_Ensnare = GetString(LUIE_STRING_SKILL_ENSNARE_TP),
    Skill_Mirror_Ward = GetString(LUIE_STRING_SKILL_MIRROR_WARD_TP),
    Skill_Poison_Shot = GetString(LUIE_STRING_SKILL_POISON_SHOT_TP),
    Skill_Venomous_Burst = GetString(LUIE_STRING_SKILL_VENOMOUS_BURST_TP),
    Skill_Web_Wrap = GetString(LUIE_STRING_SKILL_WEB_WRAP_TP),

    -- Spindleclutch I
    Skill_Inject_Poison = GetString(LUIE_STRING_SKILL_INJECT_POISON_TP),
    Skill_Fighters_Boon = GetString(LUIE_STRING_SKILL_FIGHTERS_BOON_TP),

    -- Spindleclutch II
    Skill_Enervating_Seal = GetString(LUIE_STRING_SKILL_ENERVATING_SEAL_TP),
    Skill_Blood_Pool = GetString(LUIE_STRING_SKILL_BLOOD_POOL_TP),

    -- Wayrest Sewers I
    Skill_Growing_Torment = GetString(LUIE_STRING_SKILL_GROWING_TORMENT_TP),

    -- Wayrest Sewers II
    Skill_Rend_Soul = GetString(LUIE_STRING_SKILL_REND_SOUL_TP),
    Skill_Scorching_Flames = GetString(LUIE_STRING_SKILL_SCORCHING_FLAMES_TP),

    -- Crypt of Hearts I
    Skill_Immolate_Colossus = GetString(LUIE_STRING_SKILL_IMMOLATE_COLOSSUS_TP),
    Skill_Lightning_Empowerment = GetString(LUIE_STRING_SKILL_LIGHTNING_EMPOWERMENT_TP),
    Skill_Lightning_Empowerment_Enrage = GetString(LUIE_STRING_SKILL_LIGHTNING_EMPOWERMENT_ENRAGE_TP),
    Skill_Incensed = GetString(LUIE_STRING_SKILL_INCENSED_TP),
    Skill_Incensed_Enrage = GetString(LUIE_STRING_SKILL_INCENSED_ENRAGE_TP),

    -- Crypt of Hearts II
    Skill_Summon_Death_Spider = GetString(LUIE_STRING_SKILL_SUMMON_DEATH_SPIDER_TP),
    Skill_Chattering_Web = GetString(LUIE_STRING_SKILL_CHATTERING_WEB_TP),
    Skill_Fire_Form = GetString(LUIE_STRING_SKILL_FIRE_FORM_TP),
    Skill_Shock_Form = GetString(LUIE_STRING_SKILL_SHOCK_FORM_TP),
    Skill_Void_Grip = GetString(LUIE_STRING_SKILL_VOID_GRIP_TP),
    Skill_Cold_Strike = GetString(LUIE_STRING_SKILL_COLD_STRIKE_TP),
    Skill_Blood_Lust = GetString(LUIE_STRING_SKILL_BLOOD_LUST_TP),
    Skill_Resist_Necrosis = GetString(LUIE_STRING_SKILL_RESIST_NECROSIS_TP),

    -- Volenfell
    Skill_Explosive_Bolt = GetString(LUIE_STRING_SKILL_EXPLOSIVE_BOLT_TP),
    Skill_Hemorrhaging_Tear = GetString(LUIE_STRING_SKILL_HEMORRHAGING_TEAR_TP),

    -- Frostvault
    Skill_Maim = GetString(LUIE_STRING_SKILL_MAIM_NPC_TP),

    -- ---------------------------------------------------
    -- KEEP UPGRADE --------------------------------------
    -- ---------------------------------------------------

    Keep_Upgrade_Food_Guard_Range = GetString(LUIE_STRING_KEEP_UPGRADE_FOOD_GUARD_RANGE_TP),
    Keep_Upgrade_Food_Heartier_Guards = GetString(LUIE_STRING_KEEP_UPGRADE_FOOD_HEARTIER_GUARDS_TP),
    Keep_Upgrade_Food_Resistant_Guards = GetString(LUIE_STRING_KEEP_UPGRADE_FOOD_RESISTANT_GUARDS_TP),
    Keep_Upgrade_Food_Stronger_Guards = GetString(LUIE_STRING_KEEP_UPGRADE_FOOD_STRONGER_GUARDS_TP),
    Keep_Upgrade_Ore_Armored_Guards = GetString(LUIE_STRING_KEEP_UPGRADE_ORE_ARMORED_GUARDS_TP),
    Keep_Upgrade_Ore_Corner_Build = GetString(LUIE_STRING_KEEP_UPGRADE_ORE_CORNER_BUILD_TP),
    Keep_Upgrade_Ore_Siege_Platform = GetString(LUIE_STRING_KEEP_UPGRADE_ORE_SIEGE_PLATFORM_TP),
    Keep_Upgrade_Ore_Stronger_Walls = GetString(LUIE_STRING_KEEP_UPGRADE_ORE_STRONGER_WALLS_TP),
    Keep_Upgrade_Ore_Wall_Regeneration = GetString(LUIE_STRING_KEEP_UPGRADE_ORE_WALL_REGENERATION_TP),
    Keep_Upgrade_Wood_Archer_Guard = GetString(LUIE_STRING_KEEP_UPGRADE_WOOD_ARCHER_GUARD_TP),
    Keep_Upgrade_Wood_Door_Regeneration = GetString(LUIE_STRING_KEEP_UPGRADE_WOOD_DOOR_REGENERATION_TP),
    Keep_Upgrade_Wood_Siege_Cap = GetString(LUIE_STRING_KEEP_UPGRADE_WOOD_SIEGE_CAP_TP),
    Keep_Upgrade_Wood_Stronger_Doors = GetString(LUIE_STRING_KEEP_UPGRADE_WOOD_STRONGER_DOORS_TP),

    Keep_Upgrade_Food_Mender_Abilities = GetString(LUIE_STRING_KEEP_UPGRADE_FOOD_MENDER_ABILITIES_TP),
    Keep_Upgrade_Food_Honor_Guard_Abilities = GetString(LUIE_STRING_KEEP_UPGRADE_FOOD_HONOR_GUARD_ABILITIES_TP),
    Keep_Upgrade_Food_Mage_Abilities = GetString(LUIE_STRING_KEEP_UPGRADE_FOOD_MAGE_ABILITIES_TP),
    Keep_Upgrade_Food_Guard_Abilities = GetString(LUIE_STRING_KEEP_UPGRADE_FOOD_GUARD_ABILITIES_TP),
}

--- @class (partial) Tooltips
Data.Tooltips = tooltips
