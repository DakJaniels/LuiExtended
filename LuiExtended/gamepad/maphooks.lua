-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local Data = LuiData.Data
local Effects = Data.Effects

function LUIE.HookGamePadMap()
    -- Hook Gamepad Campaign Bonuses Tooltip
    --- @diagnostic disable-next-line: duplicate-set-field
    function CAMPAIGN_BONUSES_GAMEPAD:UpdateToolTip()
        GAMEPAD_TOOLTIPS:ClearLines(GAMEPAD_RIGHT_TOOLTIP)
        if self.abilityList:IsActive() then
            local targetData = self.abilityList:GetTargetData()
            if targetData and targetData.isHeader == false then
                -- Replace description
                if targetData.abilityId then
                    local abilityId = targetData.abilityId
                    if Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].tooltip then
                        targetData.description = Effects.EffectOverride[abilityId].tooltip
                    end
                end
                GAMEPAD_TOOLTIPS:LayoutAvABonus(GAMEPAD_RIGHT_TOOLTIP, targetData)
                self:SetTooltipHidden(false)
                return
            end
        end

        self:SetTooltipHidden(true)
    end
end
