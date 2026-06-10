--- @diagnostic disable: duplicate-set-field
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local Data = LuiData.Data
local Effects = Data.Effects

--- @class ZO_Synergy : ZO_Object
--- @field icon TextureControl
--- @field action LabelControl
--- @field lastSynergyName? string

-- Hook synergy popup Icon/Name (to fix inconsistencies and add custom icons for some Quest/Encounter based Synergies)
function LUIE.HookSynergy()
    if ZO_IsConsoleOrGameCoreUI() then return end

    -- PostHook: Used to modify after original function runs, preserving base game behavior
    ---
    --- @param self ZO_Synergy
    ZO_PostHook(ZO_Synergy, "OnSynergyAbilityChanged", function (self)
        local hasSynergy, synergyName = GetCurrentSynergyInfo()

        -- Apply icon/name overrides for quest and encounter synergies
        if not Effects.SynergyNameOverride or not next(Effects.SynergyNameOverride) then
            return
        end

        if hasSynergy and synergyName and Effects.SynergyNameOverride[synergyName] then
            --- @type SynergyNameOverrideEntry
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
