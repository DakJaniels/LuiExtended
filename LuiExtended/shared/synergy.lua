--- @diagnostic disable: duplicate-set-field
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local Data = LuiData.Data
local Effects = Data.Effects


-- Finds the abilityId of the synergy currently shown by GetCurrentSynergyInfo() by matching its
-- name through GetSynergyInfoAtIndex. The list index order is not guaranteed to match priority
-- order, so index 1 is not reliable; name-matching against the current synergy name is the only
-- safe way to get the abilityId.
local function GetCurrentSynergyAbilityId(currentName)
    local numSynergies = GetNumberOfAvailableSynergies()
    for i = 1, numSynergies do
        local name, _, _, _, abilityId = GetSynergyInfoAtIndex(i)
        if name == currentName then
            return abilityId
        end
    end
end

-- ZO_Synergy:OnSynergyAbilityChanged only plays the sound when self.lastSynergyName ~= synergyName.
-- Setting lastSynergyName to the current name before the method runs makes that check false,
-- skipping PlaySound without touching any other base-game behavior.

-- Hook synergy popup Icon/Name (to fix inconsistencies and add custom icons for some Quest/Encounter based Synergies)
LUIE.HookSynergy = function ()
    if IsConsoleUI() then return end


    -- PreHook: suppress the base game's PlaySound for blacklisted synergies.
    ---
    --- @param self ZO_Synergy
    ZO_PreHook(ZO_Synergy, "OnSynergyAbilityChanged", function (self)
        local synergySettings = LUIE.CombatInfo and LUIE.CombatInfo.SV and LUIE.CombatInfo.SV.synergy
        if synergySettings and synergySettings.enabled and next(synergySettings.blacklist) then
            local hasSynergy, synergyName = GetCurrentSynergyInfo()
            if hasSynergy then
                local abilityId = GetCurrentSynergyAbilityId(synergyName)
                if abilityId and synergySettings.blacklist[abilityId] then
                    self.lastSynergyName = synergyName
                end
            end
        end
    end)

    -- PostHook: Used to modify after original function runs, preserving base game behavior
    ---
    --- @param self ZO_Synergy
    ZO_PostHook(ZO_Synergy, "OnSynergyAbilityChanged", function (self)
        local hasSynergy, synergyName = GetCurrentSynergyInfo()

        -- Suppress the base game popup for blacklisted synergies.
        -- Hide through SHARED_INFORMATION_AREA so the visibility state stays coherent;
        -- the next OnSynergyAbilityChanged restores it if a non-blacklisted synergy takes over.
        if hasSynergy then
            local synergySettings = LUIE.CombatInfo and LUIE.CombatInfo.SV and LUIE.CombatInfo.SV.synergy
            if synergySettings and synergySettings.enabled and next(synergySettings.blacklist) then
                local abilityId = GetCurrentSynergyAbilityId(synergyName)
                if abilityId and synergySettings.blacklist[abilityId] then
                    SHARED_INFORMATION_AREA:SetHidden(self, true)
                    return
                end
            end
        end

        -- Apply icon/name overrides for quest and encounter synergies
        if not Effects.SynergyNameOverride or not next(Effects.SynergyNameOverride) then
            return
        end

        if hasSynergy and synergyName and Effects.SynergyNameOverride[synergyName] then
            local override = Effects.SynergyNameOverride[synergyName]

            if override.icon then
                self.icon:SetTexture(override.icon)
            end

            if override.name then
                local overridePrompt = zo_strformat(SI_USE_SYNERGY, override.name)
                self.action:SetText(overridePrompt)
            end
        end
    end)
end
