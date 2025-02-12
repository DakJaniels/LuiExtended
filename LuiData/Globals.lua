-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- Global Variables

-- LUIE_CC_ICON
LUIE_CC_ICON_STUN = "/esoui/art/icons/ability_debuff_stun.dds"
-- LUIE_CC_ICON_KNOCKDOWN = "/esoui/art/icons/ability_debuff_stun.dds" -- Knockdown's are considered stuns
LUIE_CC_ICON_KNOCKBACK = "/esoui/art/icons/ability_debuff_knockback.dds"
LUIE_CC_ICON_PULL = "/esoui/art/icons/ability_debuff_levitate.dds"
LUIE_CC_ICON_DISORIENT = "/esoui/art/icons/ability_debuff_disorient.dds"
LUIE_CC_ICON_FEAR = "/esoui/art/icons/ability_debuff_fear.dds"
LUIE_CC_ICON_CHARM = "/esoui/art/icons/ability_buff_minor_expedition.dds" -- Temporary icon until I can identify the game's correct charm icon
LUIE_CC_ICON_STAGGER = "/esoui/art/icons/ability_debuff_stagger.dds"
LUIE_CC_ICON_SILENCE = "/esoui/art/icons/ability_debuff_silence.dds"
LUIE_CC_ICON_SNARE = "/esoui/art/icons/ability_debuff_snare.dds"
LUIE_CC_ICON_ROOT = "/esoui/art/icons/ability_debuff_root.dds"
LUIE_CC_ICON_IMMUNE = "LuiExtended/media/icons/abilities/ability_innate_cc_immunity.dds"

-- LUIE_CC_TYPE
LUIE_CC_TYPE_STUN = 1           -- Stun
LUIE_CC_TYPE_KNOCKDOWN = 2      -- Knockdown
LUIE_CC_TYPE_KNOCKBACK = 3      -- Knockback
LUIE_CC_TYPE_PULL = 4           -- Pull
LUIE_CC_TYPE_DISORIENT = 5      -- Disorient
LUIE_CC_TYPE_FEAR = 6           -- Fear
LUIE_CC_TYPE_STAGGER = 7        -- Stagger
LUIE_CC_TYPE_SILENCE = 8        -- Silence
LUIE_CC_TYPE_SNARE = 9          -- Snare
LUIE_CC_TYPE_ROOT = 10          -- Immobilize
LUIE_CC_TYPE_UNBREAKABLE = 11   -- Unbreakable CC
LUIE_CC_TYPE_TRAP = 12          -- Trap
LUIE_CC_TYPE_ENVIRONMENTAL = 13 -- Environmental Hazard (I.E. Lava)
LUIE_CC_TYPE_CHARM = 14         -- Charm

-- LUIE_BUFF_TYPE
LUIE_BUFF_TYPE_BUFF = 1                  -- Buff
LUIE_BUFF_TYPE_DEBUFF = 2                -- Debuff
LUIE_BUFF_TYPE_UB_BUFF = 3               -- Unbreakable buff
LUIE_BUFF_TYPE_UB_DEBUFF = 4             -- Unbreakable debuff
LUIE_BUFF_TYPE_GROUND_BUFF_TRACKER = 5   -- Player cast ground AOE buff
LUIE_BUFF_TYPE_GROUND_DEBUFF_TRACKER = 6 -- Player cast ground AOE debuff
LUIE_BUFF_TYPE_GROUND_AOE_BUFF = 7       -- Standing in a ground buff
LUIE_BUFF_TYPE_GROUND_AOE_DEBUFF = 8     -- Standing in a ground debuff
LUIE_BUFF_TYPE_ENVIRONMENT_BUFF = 9      -- Area buff (entire zone, etc) -- TODO: Implement if needed
LUIE_BUFF_TYPE_ENVIRONMENT_DEBUFF = 10   -- Hazard (lava, shock water, entire zone/room, etc) -- TODO: Implement if needed
LUIE_BUFF_TYPE_NONE = 11

-- Add localized strings for this and use SI_blabla, # to get the right string for determing TYPE on buff mouseover
--[[
[1] = "Buff",
[2] = "Debuff",
[3] = "Unbreakable Buff",
[4] = "Unbreakable Debuff",
[5] = "Ground Buff",
[6] = "Ground Debuff",
[7] = "Environmental Buff"
[8] = "Environmental Debuff"
[9] = "None",
]]
--

-- LUIE_COMBAT_ALERT_TYPE
LUIE_COMBAT_ALERT_TYPE_UNMIT = 1
LUIE_COMBAT_ALERT_TYPE_DESTROY = 2
LUIE_COMBAT_ALERT_TYPE_POWER = 3
LUIE_COMBAT_ALERT_TYPE_SUMMON = 4
LUIE_COMBAT_ALERT_TYPE_SHARED = 5

-- LUIE_ALERT_SOUND_TYPE
LUIE_ALERT_SOUND_TYPE_ST = 1             -- Single Target
LUIE_ALERT_SOUND_TYPE_ST_CC = 2          -- Single Target with CC
LUIE_ALERT_SOUND_TYPE_AOE = 3            -- Conal/Radial attacks
LUIE_ALERT_SOUND_TYPE_AOE_CC = 4         -- Conal/Radial attacks with CC
LUIE_ALERT_SOUND_TYPE_POWER_ATTACK = 5   -- (ONE-SHOT) Power attacks that need to be blocked
LUIE_ALERT_SOUND_TYPE_RADIAL_AVOID = 6   -- (ONE-SHOT) Radial/aoe/etc attacks that need to be avoided
LUIE_ALERT_SOUND_TYPE_TRAVELER = 7       -- Traveling ground line aoes
LUIE_ALERT_SOUND_TYPE_TRAVELER_CC = 8    -- Traveling ground like aoes (with CC component)
LUIE_ALERT_SOUND_TYPE_GROUND = 9         -- Ground aoe effects
LUIE_ALERT_SOUND_TYPE_METEOR = 10        -- Meteor type AOE's
LUIE_ALERT_SOUND_TYPE_UNMIT = 11         -- Unmitigable Single Target (Fossilize type effects)
LUIE_ALERT_SOUND_TYPE_UNMIT_AOE = 12     -- Unmitigable AOE (Room/area wide effect)
LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE = 13  -- Power Buff (Damage)
LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE = 14 -- Power Buff (Defense/Misc)
LUIE_ALERT_SOUND_TYPE_SUMMON = 15        -- Summon Buff
LUIE_ALERT_SOUND_TYPE_DESTROY = 16       -- Destroy (Priority Target)
LUIE_ALERT_SOUND_TYPE_HEAL = 17          -- Heal (Interrupt)

-- LUIE_QUEST_MESSAGE
LUIE_QUEST_MESSAGE_TURNIN = 1
LUIE_QUEST_MESSAGE_USE = 2
LUIE_QUEST_MESSAGE_EXHAUST = 3
LUIE_QUEST_MESSAGE_OFFER = 4
LUIE_QUEST_MESSAGE_DISCARD = 5
LUIE_QUEST_MESSAGE_CONFISCATE = 6
LUIE_QUEST_MESSAGE_COMBINE = 7
LUIE_QUEST_MESSAGE_MIX = 8
LUIE_QUEST_MESSAGE_BUNDLE = 9
LUIE_QUEST_MESSAGE_LOOT = 10
LUIE_QUEST_MESSAGE_OPEN = 11
LUIE_QUEST_MESSAGE_ADMINISTER = 12
LUIE_QUEST_MESSAGE_PLACE = 13
LUIE_QUEST_MESSAGE_STEAL = 14

-- -----------------------------------------------------------------------------
do
    if not GetItemLinkOnUseAbilityDescription then
        --- @param itemLink string
        --- @return string abilityDescription
        GetItemLinkOnUseAbilityDescription = function (itemLink)
            local hasAbility, abilityHeader, abilityDescription, cooldown, hasScaling, minLevel, maxLevel, isChampionPoints, remainingCooldown = GetItemLinkOnUseAbilityInfo(itemLink)
            return abilityDescription
        end
    end
end
-- -----------------------------------------------------------------------------
