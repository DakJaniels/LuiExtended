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
    -- Hook synergy popup Icon/Name (to fix inconsistencies and add custom icons for some Quest/Encounter based Synergies)
    function ZO_Synergy:OnSynergyAbilityChanged()
        local hasSynergy, synergyName, iconFilename, prompt = GetCurrentSynergyInfo()

        if hasSynergy then
            -- Apply LUIE custom overrides if they exist
            if Effects.SynergyNameOverride[synergyName] then
                if Effects.SynergyNameOverride[synergyName].icon then
                    iconFilename = Effects.SynergyNameOverride[synergyName].icon
                end
                if Effects.SynergyNameOverride[synergyName].name then
                    synergyName = Effects.SynergyNameOverride[synergyName].name
                end
            end

            if self.lastSynergyName ~= synergyName then
                PlaySound(SOUNDS.ABILITY_SYNERGY_READY)

                if prompt == "" then
                    prompt = zo_strformat(SI_USE_SYNERGY, synergyName)
                end
                self.action:SetText(prompt)
                self.lastSynergyName = synergyName
            end

            self.icon:SetTexture(iconFilename)
            SHARED_INFORMATION_AREA:SetHidden(self, false)
        else
            SHARED_INFORMATION_AREA:SetHidden(self, true)
            self.lastSynergyName = nil
        end
    end
end
