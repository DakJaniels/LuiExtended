--- @diagnostic disable: missing-global-doc, duplicate-set-field
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

LUIE.HookGamePadIcons = function ()
    local origSetEntryInfoFromAllocator = ZO_GamepadSkillEntryTemplate_SetEntryInfoFromAllocator
    function ZO_GamepadSkillEntryTemplate_SetEntryInfoFromAllocator(skillEntry)
        origSetEntryInfoFromAllocator(skillEntry)
        local skillData = skillEntry.skillData
        if skillData then
            local skillProgressionData = skillData:GetPointAllocator():GetProgressionData()
            local abilityId = skillProgressionData:GetAbilityId()
            local customIcon = GetAbilityIcon(abilityId)
            if customIcon then
                skillEntry:ClearIcons()
                skillEntry:AddIcon(customIcon)
            end
        end
    end

    local origPreviewSetup = ZO_GamepadSkillEntryPreviewRow_Setup
    function ZO_GamepadSkillEntryPreviewRow_Setup(control, skillData, overrideSlotIndex, overrideHotbar, isReadOnly)
        origPreviewSetup(control, skillData, overrideSlotIndex, overrideHotbar, isReadOnly)
        local skillProgressionData = skillData:GetPointAllocatorProgressionData()
        local abilityId = skillProgressionData:GetAbilityId()
        local customIcon = GetAbilityIcon(abilityId)
        if customIcon then
            control.icon:SetTexture(customIcon)
        end
    end
end
