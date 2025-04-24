-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
LUIE.CombatTextPointsExperienceEventListener = LUIE.CombatTextEventListener:Subclass()
local CombatTextPointsExperienceEventListener = LUIE.CombatTextPointsExperienceEventListener

local eventType = LuiData.Data.CombatTextConstants.eventType
local pointType = LuiData.Data.CombatTextConstants.pointType
--- @diagnostic disable-next-line: duplicate-set-field
function CombatTextPointsExperienceEventListener:New()
    local obj = LUIE.CombatTextEventListener:New()
    obj:RegisterForEvent(EVENT_EXPERIENCE_UPDATE, function (...)
        self:OnEvent(...)
    end, REGISTER_FILTER_UNIT_TAG, "player")
    self.gain = 0
    self.timeoutActive = false
    self.isChampion = IsUnitChampion("player")
    if self.isChampion then
        local earned = GetPlayerChampionPointsEarned()
        if earned < 3600 then
            self.previousXp = GetPlayerChampionXP()
            self.previousMaxXp = GetNumChampionXPInChampionPoint(earned)
        end
    end
    self.previousXp = self.previousXp or GetUnitXP("player")
    self.previousMaxXp = self.previousMaxXp or GetUnitXPMax("player")
    return obj
end

function CombatTextPointsExperienceEventListener:OnEvent(unit, currentXp, maxXp)
    if LUIE.CombatText.SV.toggles.showPointsExperience then
        self.isChampion = IsUnitChampion("player")
        if self.isChampion then
            local earned = GetPlayerChampionPointsEarned()
            if earned < 3600 then
                maxXp = GetNumChampionXPInChampionPoint(earned)
                if maxXp ~= nil then
                    currentXp = GetPlayerChampionXP()
                end
            end
        end

        -- Calculate gained xp
        if (maxXp ~= self.previousMaxXp) or (currentXp < self.previousXp) then
            self.gain = self.gain + (self.previousMaxXp - self.previousXp + currentXp)
        else
            self.gain = self.gain + (currentXp - self.previousXp)
        end

        -- Remember values
        self.previousXp = currentXp
        self.previousMaxXp = maxXp

        -- Trigger custom event (500ms buffer)
        if self.gain > 0 and not self.timeoutActive then
            self.timeoutActive = true
            LUIE_CallLater(function ()
                self:TriggerEvent(eventType.POINT, pointType.EXPERIENCE_POINTS, self.gain)
                self.gain = 0
                self.timeoutActive = false
            end, 500)
        end
    end
end
