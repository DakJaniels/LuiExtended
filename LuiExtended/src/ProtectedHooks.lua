-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- Protected Function Workarounds
---
--- This file contains hooks for protected functions that need to be called
--- from potentially tainted/insecure code. These functions use CallSecureProtected
--- to bypass ESO's UI security restrictions.
---
--- CRITICAL: Do not modify these hooks unless you understand ESO's UI taint system.
--- Incorrect modifications can break protected functionality like ability dragging.

--- Hook ZO_ActiveSkillProgressionData:TryPickup to use CallSecureProtected
--- This prevents "Attempt to access a private function from insecure code" errors
--- when dragging abilities after addon code has tainted the UI callstack.
---
--- Original issue: Custom icon hooks would taint the callstack, causing PickupAbilityById
--- to fail with a security error when trying to drag abilities.
---
--- Solution: Wrap PickupAbilityById in CallSecureProtected, which allows calling
--- protected functions even from tainted code.
---
--- PickupAbilityById is used at two callsites. Last check 2025-11-03
function LUIE.ApplyProtectedHooks()
    -- Hook for regular active skills
    --- @diagnostic disable-next-line: duplicate-set-field
    function ZO_ActiveSkillProgressionData:TryPickup()
        local isPurchased = self.skillData:IsPurchased()

        if SKILLS_AND_ACTION_BAR_MANAGER:DoesSkillPointAllocationModeBatchSave() then
            local skillPointAllocator = self.skillData:GetPointAllocator()
            isPurchased = skillPointAllocator:IsPurchased()
        end

        if isPurchased then
            local success, result = CallSecureProtected("PickupAbilityById", self:GetEffectiveAbilityId())
            if success then
                return result
            end
            -- If CallSecureProtected failed, fall through to return false
        end

        return false
    end

    -- Hook for crafted active skills (Scribing system)
    --- @diagnostic disable-next-line: duplicate-set-field
    function ZO_CraftedActiveSkillProgressionData:TryPickup()
        if self.skillData:IsPurchased() then
            local success, result = CallSecureProtected("PickupAbilityById", self:GetEffectiveAbilityId())
            if success then
                return result
            end
        end
    end
end
