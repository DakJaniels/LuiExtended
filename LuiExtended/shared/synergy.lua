--- @diagnostic disable: duplicate-set-field
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local Data = LuiData.Data
local Effects = Data.Effects

LUIE.HookSynergy = function ()
    if IsConsoleUI() then return end
    -- Hook synergy popup Icon/Name (to fix inconsistencies and add custom icons for some Quest/Encounter based Synergies)
    -- Use ZO_PostHook to modify after original function runs, preserving base game behavior
    ZO_PostHook(ZO_Synergy, "OnSynergyAbilityChanged", function (self)
        -- Quick check: only process if synergy override table exists and has entries
        if not Effects.SynergyNameOverride or not next(Effects.SynergyNameOverride) then
            return
        end

        local hasSynergy, synergyName = GetCurrentSynergyInfo()

        -- Only process if synergy is available and we have an override for it
        if hasSynergy and synergyName and Effects.SynergyNameOverride[synergyName] then
            local override = Effects.SynergyNameOverride[synergyName]

            -- Apply icon override if present
            if override.icon then
                self.icon:SetTexture(override.icon)
            end

            -- Apply name override if present
            if override.name then
                local overridePrompt = zo_strformat(SI_USE_SYNERGY, override.name)
                self.action:SetText(overridePrompt)
            end
        end
    end)
end
