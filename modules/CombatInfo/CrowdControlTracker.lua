-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.CombatInfo
local CombatInfo = LUIE.CombatInfo
--- @class (partial) CrowdControlTracker
local CrowdControlTracker = CombatInfo.CrowdControlTracker

local Effects = LUIE.Data.Effects
local CrowdControl = LUIE.Data.CrowdControl
local eventManager = GetEventManager()
local animationManager = GetAnimationManager()
local table_insert = table.insert
local table_remove = table.remove
local pairs = pairs

local PriorityOne, PriorityTwo, PriorityThree, PriorityFour, PrioritySix, PrioritySeven, PriorityEight

local staggerDuration = 800
local areaDuration = 1100
local rootDuration = 1100
local negateDuration = 20000
local graceTime = 5

local isRooted = false
local rootEndTime = 0

local iconFont = "$(GAMEPAD_BOLD_FONT)|25|thick-outline"
local staggerFont = "$(GAMEPAD_BOLD_FONT)|36|thick-outline"

local iconBorder = "LuiExtended/media/combatinfo/crowdcontroltracker/border.dds"

local defaultDisorientIcon
local defaultImmuneIcon

local SET_SCALE_FROM_SV = true
local BREAK_FREE_ID = 16565
local GENERIC_ROOT_ABILITY_ID = 146956
local ICON_MISSING = "icon_missing"

local ACTION_RESULT_AREA_EFFECT = 669966
local negateValidNames =
{
    ["Negate Magic"] = true,
    ["Absorption Field"] = true,
    ["Suppression Field"] = true,
    ["Antimagic Field"] = true,
}

CrowdControlTracker.controlTypes =
{
    ACTION_RESULT_STUNNED,
    ACTION_RESULT_FEARED,
    ACTION_RESULT_DISORIENTED,
    ACTION_RESULT_CHARMED,
    ACTION_RESULT_SILENCED,
    ACTION_RESULT_STAGGERED,
    ACTION_RESULT_AREA_EFFECT,
    ACTION_RESULT_ROOTED,
    ACTION_RESULT_SNARED,
}

CrowdControlTracker.actionResults =
{
    [ACTION_RESULT_STUNNED] = true,
    [ACTION_RESULT_DISORIENTED] = true,
    [ACTION_RESULT_FEARED] = true,
    [ACTION_RESULT_CHARMED] = true,
    [ACTION_RESULT_ROOTED] = true,
    [ACTION_RESULT_SNARED] = true,
}

CrowdControlTracker.controlText =
{
    [ACTION_RESULT_STUNNED] = "STUNNED",
    [ACTION_RESULT_FEARED] = "FEARED",
    [ACTION_RESULT_DISORIENTED] = "DISORIENTED",
    [ACTION_RESULT_CHARMED] = "CHARMED",
    [ACTION_RESULT_SILENCED] = "SILENCED",
    [ACTION_RESULT_STAGGERED] = "STAGGER",
    [ACTION_RESULT_IMMUNE] = "IMMUNE",
    [ACTION_RESULT_DODGED] = "DODGED",
    [ACTION_RESULT_BLOCKED] = "BLOCKED",
    [ACTION_RESULT_BLOCKED_DAMAGE] = "BLOCKED",
    [ACTION_RESULT_AREA_EFFECT] = "AREA DAMAGE",
    [ACTION_RESULT_ROOTED] = "ROOTED",
    [ACTION_RESULT_SNARED] = "SNARED",
}

CrowdControlTracker.aoeHitTypes =
{
    [ACTION_RESULT_BLOCKED] = true,
    [ACTION_RESULT_BLOCKED_DAMAGE] = true,
    [ACTION_RESULT_CRITICAL_DAMAGE] = true,
    [ACTION_RESULT_DAMAGE] = true,
    [ACTION_RESULT_DAMAGE_SHIELDED] = true,
    [ACTION_RESULT_IMMUNE] = true,
    [ACTION_RESULT_MISS] = true,
    [ACTION_RESULT_PARTIAL_RESIST] = true,
    [ACTION_RESULT_REFLECTED] = true,
    [ACTION_RESULT_RESIST] = true,
    [ACTION_RESULT_WRECKING_DAMAGE] = true,
    [ACTION_RESULT_ROOTED] = true,
    [ACTION_RESULT_SNARED] = true,
    [ACTION_RESULT_DOT_TICK] = true,
    [ACTION_RESULT_DOT_TICK_CRITICAL] = true,
}

local LUIE_CCTracker = GetControl("LUIE_CCTracker")

function CrowdControlTracker:OnOff()
    if CombatInfo.SV.cct.enabled and not (CombatInfo.SV.cct.enabledOnlyInCyro and LUIE.ResolvePVPZone()) then
        if not self.addonEnabled then
            self.addonEnabled = true
            eventManager:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, self.Initialize)
            eventManager:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, function (...)
                self:OnCombat(...)
            end)
            eventManager:RegisterForEvent(self.name, EVENT_PLAYER_STUNNED_STATE_CHANGED, function (...)
                self:OnStunnedState(...)
            end)
            eventManager:RegisterForEvent(self.name, EVENT_DISPLAY_ACTIVE_COMBAT_TIP, function (...)
                self:OnCombatTipAdded(...)
            end)
            eventManager:RegisterForEvent(self.name, EVENT_REMOVE_ACTIVE_COMBAT_TIP, function (...)
                self:OnCombatTipRemoved(...)
            end)
            eventManager:RegisterForEvent(self.name, EVENT_UNIT_DEATH_STATE_CHANGED, function (eventCode, unitTag, isDead)
                if isDead then
                    self:FullReset()
                end
            end)
            eventManager:AddFilterForEvent(self.name, EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
            self.Initialize()
        end
    else
        if self.addonEnabled then
            self.addonEnabled = false
            eventManager:UnregisterForEvent(self.name, EVENT_PLAYER_ACTIVATED)
            eventManager:UnregisterForEvent(self.name, EVENT_COMBAT_EVENT)
            eventManager:UnregisterForEvent(self.name, EVENT_DISPLAY_ACTIVE_COMBAT_TIP)
            eventManager:UnregisterForEvent(self.name, EVENT_REMOVE_ACTIVE_COMBAT_TIP)
            eventManager:UnregisterForEvent(self.name, EVENT_PLAYER_STUNNED_STATE_CHANGED)
            eventManager:UnregisterForEvent(self.name, EVENT_UNIT_DEATH_STATE_CHANGED)
            LUIE_CCTracker:SetHidden(true)
        end
    end
end

function CrowdControlTracker.Initialize()
    CrowdControlTracker:OnOff()
    if CombatInfo.SV.cct.enabled then
        CrowdControlTracker.currentlyPlaying = nil
        CrowdControlTracker.breakFreePlaying = nil
        CrowdControlTracker.immunePlaying = nil
        CrowdControlTracker:FullReset()
    end
end

local priority = 0
local function AddAOECategory(categoryTable, setting)
    if setting then
        for k, v in pairs(categoryTable) do
            priority = priority + v
            CrowdControlTracker.aoeTypesId[k] = priority
        end
        priority = priority + 1
    end
end

function CrowdControlTracker.UpdateAOEList()
    CrowdControlTracker.aoeTypesId = {}

    AddAOECategory(CrowdControl.aoePlayerUltimate, CombatInfo.SV.cct.aoePlayerUltimate)
    AddAOECategory(CrowdControl.aoePlayerSet, CombatInfo.SV.cct.aoePlayerSet)
    AddAOECategory(CrowdControl.aoePlayerNormal, CombatInfo.SV.cct.aoePlayerNormal)
    AddAOECategory(CrowdControl.aoeTraps, CombatInfo.SV.cct.aoeTraps)
    AddAOECategory(CrowdControl.aoeNPCBoss, CombatInfo.SV.cct.aoeNPCBoss)
    AddAOECategory(CrowdControl.aoeNPCElite, CombatInfo.SV.cct.aoeNPCElite)
    AddAOECategory(CrowdControl.aoeNPCNormal, CombatInfo.SV.cct.aoeNPCNormal)
    priority = 0
end

function CrowdControlTracker.PlaySoundAoe(abilityId)
    -- I hope you like inline conditionals, because we've got them for days!
    -- If we have sound enabled for the type of AOE this ability is then fetch it.
    local playSound = ((CrowdControl.aoePlayerUltimate[abilityId] and CombatInfo.SV.cct.aoePlayerUltimateSoundToggle) and CombatInfo.SV.cct.aoePlayerUltimateSound) or ((CrowdControl.aoePlayerSet[abilityId] and CombatInfo.SV.cct.aoePlayerSetSoundToggle) and CombatInfo.SV.cct.aoePlayerSetSound) or ((CrowdControl.aoePlayerNormal[abilityId] and CombatInfo.SV.cct.aoePlayerNormalSoundToggle) and CombatInfo.SV.cct.aoePlayerNormalSound) or ((CrowdControl.aoeTraps[abilityId] and CombatInfo.SV.cct.aoeTrapsSoundToggle) and CombatInfo.SV.cct.aoeTrapsSound) or ((CrowdControl.aoeNPCBoss[abilityId] and CombatInfo.SV.cct.aoeNPCBossSoundToggle) and CombatInfo.SV.cct.aoeNPCBossSound) or ((CrowdControl.aoeNPCElite[abilityId] and CombatInfo.SV.cct.aoeNPCEliteSoundToggle) and CombatInfo.SV.cct.aoeNPCEliteSound) or ((CrowdControl.aoeNPCNormal[abilityId] and CombatInfo.SV.cct.aoeNPCNormalSoundToggle) and CombatInfo.SV.cct.aoeNPCNormalSound)

    -- If we found a sound, then play it (twice so it's a bit louder)
    if playSound then
        PlaySound(LUIE.Sounds[playSound])
        PlaySound(LUIE.Sounds[playSound])
    else
        return
    end
end

-- GAP between INIT and code for now

function CrowdControlTracker:SavePosition()
    local coordX, coordY = LUIE_CCTracker:GetCenter()
    CombatInfo.SV.cct.offsetX = coordX - (GuiRoot:GetWidth() / 2)
    CombatInfo.SV.cct.offsetY = coordY - (GuiRoot:GetHeight() / 2)
    LUIE_CCTracker:ClearAnchors()
    LUIE_CCTracker:SetAnchor(CENTER, GuiRoot, CENTER, CombatInfo.SV.cct.offsetX, CombatInfo.SV.cct.offsetY)
end

function CrowdControlTracker.ResetPosition()
    CombatInfo.SV.cct.offsetX = 0
    CombatInfo.SV.cct.offsetY = 0
    LUIE_CCTracker:ClearAnchors()
    LUIE_CCTracker:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
end

function CrowdControlTracker:OnUpdate(control)
    if CrowdControlTracker.Timer == 0 or not CrowdControlTracker.Timer then
        return
    end

    local timeLeft = zo_ceil(CrowdControlTracker.Timer - GetFrameTimeSeconds())
    if timeLeft > 0 then
        LUIE_CCTracker_Timer_Label:SetText(timeLeft)
    end
end

function CrowdControlTracker:OnProc(ccDuration, interval)
    self:OnAnimation(LUIE_CCTracker, "proc")

    if CombatInfo.SV.cct.playSound then
        local playSound = CombatInfo.SV.cct.playSoundOption
        if playSound then
            PlaySound(LUIE.Sounds[playSound])
            PlaySound(LUIE.Sounds[playSound])
        end
    end

    self.Timer = GetFrameTimeSeconds() + (interval / 1000)

    local remaining, duration, global = GetSlotCooldownInfo(1)
    if remaining > 0 then
        LUIE_CCTracker_IconFrame_GlobalCooldown:ResetCooldown()
        if CombatInfo.SV.cct.showGCD and LUIE.ResolvePVPZone() then
            LUIE_CCTracker_IconFrame_GlobalCooldown:SetHidden(false)
            LUIE_CCTracker_IconFrame_GlobalCooldown:StartCooldown(remaining, remaining, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false)
            zo_callLater(function ()
                LUIE_CCTracker_IconFrame_GlobalCooldown:SetHidden(true)
            end, remaining)
        end
    end

    LUIE_CCTracker_IconFrame_Cooldown:ResetCooldown()
    LUIE_CCTracker_IconFrame_Cooldown:StartCooldown(interval, ccDuration, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, false)

    self:SetupDisplay("timer")
end

function CrowdControlTracker:OnAnimation(control, animationType, param)
    self:SetupDisplay(animationType)
    if CombatInfo.SV.cct.playAnimation then
        if animationType == "immune" then
            self.immunePlaying = self:StartAnimation(control, animationType)
        elseif animationType == "breakfree" then
            self.breakFreePlaying = self:BreakFreeAnimation()
        else
            self.currentlyPlaying = self:StartAnimation(control, animationType)
        end
    elseif param then
        LUIE_CCTracker:SetHidden(not CombatInfo.SV.cct.unlock)
    end
end

function CrowdControlTracker:AoePriority(abilityId, result)
    if self.aoeTypesId[abilityId] and self.aoeHitTypes[result] and (not self.aoeTypesId[PrioritySix.abilityId] or (self.aoeTypesId[abilityId] <= self.aoeTypesId[PrioritySix.abilityId])) then
        return true
    else
        return false
    end
end

local function ResolveAbilityName(abilityId, sourceName)
    local abilityName = GetAbilityName(abilityId)

    if Effects.EffectOverrideByName[abilityId] then
        sourceName = zo_strformat("<<C:1>>", sourceName)
        if Effects.EffectOverrideByName[abilityId][sourceName] then
            abilityName = Effects.EffectOverrideByName[abilityId][sourceName].name or abilityName
        end
    end

    if Effects.ZoneDataOverride[abilityId] then
        local index = GetZoneId(GetCurrentMapZoneIndex())
        local zoneName = GetPlayerLocationName()
        if Effects.ZoneDataOverride[abilityId][index] then
            abilityName = Effects.ZoneDataOverride[abilityId][index].name
        end
        if Effects.ZoneDataOverride[abilityId][zoneName] then
            abilityName = Effects.ZoneDataOverride[abilityId][zoneName].name
        end
    end

    -- Override name, icon, or hide based on Map Name
    if Effects.MapDataOverride[abilityId] then
        local mapName = GetMapName()
        if Effects.MapDataOverride[abilityId][mapName] then
            if Effects.MapDataOverride[abilityId][mapName].name then
                abilityName = Effects.MapDataOverride[abilityId][mapName].name
            end
        end
    end

    return abilityName
end

local function ResolveAbilityIcon(abilityId, sourceName)
    local abilityIcon = GetAbilityIcon(abilityId)

    if Effects.EffectOverrideByName[abilityId] then
        sourceName = zo_strformat("<<C:1>>", sourceName)
        if Effects.EffectOverrideByName[abilityId][sourceName] then
            abilityIcon = Effects.EffectOverrideByName[abilityId][sourceName].icon or abilityIcon
        end
    end

    if Effects.ZoneDataOverride[abilityId] then
        local index = GetZoneId(GetCurrentMapZoneIndex())
        local zoneName = GetPlayerLocationName()
        if Effects.ZoneDataOverride[abilityId][index] then
            abilityIcon = Effects.ZoneDataOverride[abilityId][index].icon
        end
        if Effects.ZoneDataOverride[abilityId][zoneName] then
            abilityIcon = Effects.ZoneDataOverride[abilityId][zoneName].icon
        end
    end

    -- Override name, icon, or hide based on Map Name
    if Effects.MapDataOverride[abilityId] then
        local mapName = GetMapName()
        if Effects.MapDataOverride[abilityId][mapName] then
            if Effects.MapDataOverride[abilityId][mapName].icon then
                abilityIcon = Effects.MapDataOverride[abilityId][mapName].icon
            end
        end
    end

    return abilityIcon
end

function CrowdControlTracker:OnCombat(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, combat_log, sourceUnitId, targetUnitId, abilityId)
    -- LuiExtended Addition
    abilityName = ResolveAbilityName(abilityId, sourceName)
    local abilityIcon = ResolveAbilityIcon(abilityId, sourceName)

    if CrowdControl.IgnoreList[abilityId] then
        return
    end
    local function StringEnd(String, End)
        return End == "" or zo_strsub(String, -zo_strlen(End)) == End
    end

    -- Adjust duration of Player Vampire bite stun
    if abilityId == 40349 then
        hitValue = hitValue - 950
    end

    local malformedName

    if not StringEnd(LUIE.PlayerNameRaw, "^Mx") and not StringEnd(LUIE.PlayerNameRaw, "^Fx") then
        malformedName = true
    end

    if result == ACTION_RESULT_EFFECT_GAINED_DURATION and ((not malformedName and sourceName == LUIE.PlayerNameRaw) or (malformedName and (sourceName == LUIE.PlayerNameRaw .. "^Mx" or sourceName == LUIE.PlayerNameRaw .. "^Fx"))) and (abilityName == "Break Free" or abilityName == GetAbilityName(BREAK_FREE_ID) or abilityId == BREAK_FREE_ID) then
        if CombatInfo.SV.cct.showOptions == "text" then
            self:StopDraw(true)
        else
            self:StopDrawBreakFree()
        end
        return
    end

    -- 51894
    -----------------DISORIENT PROCESSING-------------------------------

    if result == ACTION_RESULT_EFFECT_FADED and ((not malformedName and targetName == LUIE.PlayerNameRaw) or (malformedName and (targetName == LUIE.PlayerNameRaw .. "^Mx" or targetName == LUIE.PlayerNameRaw .. "^Fx"))) then
        if GetFrameTimeMilliseconds() <= (PriorityTwo.endTime + graceTime) and #self.fearsQueue ~= 0 then
            local found_k
            for k, v in pairs(self.fearsQueue) do
                if v == abilityId then
                    found_k = k
                    break
                end
            end
            if found_k then
                table_remove(self.fearsQueue, found_k)
                if #self.fearsQueue == 0 then
                    self:RemoveCC(2, PriorityTwo.endTime)
                end
            end
        elseif GetFrameTimeMilliseconds() <= (PriorityThree.endTime + graceTime) and #self.disorientsQueue ~= 0 then
            local found_k
            for k, v in pairs(self.disorientsQueue) do
                if v == abilityId then
                    found_k = k
                    break
                end
            end
            if found_k then
                table_remove(self.disorientsQueue, found_k)
                if #self.disorientsQueue == 0 then
                    self:RemoveCC(3, PriorityThree.endTime)
                end
            end
        elseif GetFrameTimeMilliseconds() <= (PriorityFour.endTime + graceTime) and #self.negatesQueue ~= 0 then
            local found_k
            for k, v in pairs(self.negatesQueue) do
                if v == abilityId then
                    found_k = k
                    break
                end
            end
            if found_k then
                table_remove(self.negatesQueue, found_k)
                if #self.negatesQueue == 0 then
                    self:RemoveCC(4, PriorityFour.endTime)
                end
            end
        end
    end

    ------------------------------------------------

    -- If AoE effect is flagged as self damage (mostly from lava) id then don't use the normal return statement, otherwise return based off primary conditions.
    if ((not malformedName and sourceName == LUIE.PlayerNameRaw) or (malformedName and (sourceName == LUIE.PlayerNameRaw .. "^Mx" or sourceName == LUIE.PlayerNameRaw .. "^Fx"))) and CrowdControl.LavaAlerts[abilityId] then
        --
    else
        if ((not malformedName and targetName ~= LUIE.PlayerNameRaw) or (malformedName and (targetName ~= LUIE.PlayerNameRaw .. "^Mx" and targetName ~= LUIE.PlayerNameRaw .. "^Fx"))) or targetName == "" or targetType ~= 1 or ((not malformedName and sourceName == LUIE.PlayerNameRaw) or (malformedName and (sourceName == LUIE.PlayerNameRaw .. "^Mx" or sourceName == LUIE.PlayerNameRaw .. "^Fx"))) or sourceName == "" or sourceUnitId == 0 or self.breakFreePlaying then
            return
        end
    end

    if CombatInfo.SV.cct.showAoe and (self:AoePriority(abilityId, result) or (CrowdControl.SpecialCC[abilityId] and result == ACTION_RESULT_EFFECT_GAINED)) then
        if not CrowdControlTracker.aoeTypesId[abilityId] then
            return
        end
        if CrowdControl.SpecialCC[abilityId] and result ~= ACTION_RESULT_EFFECT_GAINED then
            return
        end

        -- PlaySoundAoe
        CrowdControlTracker.PlaySoundAoe(abilityId)

        local currentEndTimeArea = GetFrameTimeMilliseconds() + areaDuration
        PrioritySeven = { endTime = currentEndTimeArea, abilityId = abilityId, abilityIcon = abilityIcon, hitValue = hitValue, result = ACTION_RESULT_AREA_EFFECT, abilityName = abilityName }
        if PriorityOne.endTime == 0 and PriorityTwo.endTime == 0 and PriorityThree.endTime == 0 and PriorityFour.endTime == 0 and PrioritySix.endTime == 0 then
            self.currentCC = 7
            zo_callLater(function ()
                self:RemoveCC(7, currentEndTimeArea)
            end, areaDuration + graceTime)
            self:OnDraw(abilityId, abilityIcon, areaDuration, ACTION_RESULT_AREA_EFFECT, abilityName, areaDuration)
        end
    end

    local validResults =
    {
        [ACTION_RESULT_EFFECT_GAINED_DURATION] = true,
        [ACTION_RESULT_STUNNED] = true,
        [ACTION_RESULT_FEARED] = true,
        [ACTION_RESULT_STAGGERED] = true,
        [ACTION_RESULT_IMMUNE] = true,
        [ACTION_RESULT_DODGED] = true,
        [ACTION_RESULT_BLOCKED] = true,
        [ACTION_RESULT_BLOCKED_DAMAGE] = true,
        [ACTION_RESULT_DISORIENTED] = true,
        [ACTION_RESULT_CHARMED] = true,
        [ACTION_RESULT_ROOTED] = true,
        [ACTION_RESULT_SNARED] = true,
        [ACTION_RESULT_SILENCED] = true,
    }

    if not validResults[result] then
        return
    end

    -- if result == ACTION_RESULT_STUNNED then
    -- d('STUNNED after')
    -- end

    -- if result~=ACTION_RESULT_EFFECT_GAINED_DURATION and result~=ACTION_RESULT_STUNNED and result~=ACTION_RESULT_FEARED and result~=ACTION_RESULT_STAGGERED and result~=ACTION_RESULT_IMMUNE and result~=ACTION_RESULT_DISORIENTED then return end

    if abilityName == LUIE.Data.Abilities.Trap_Hiding_Spot then -- TODO: Put IDs here instead or add to blacklist instead
        return
    end

    -------------STAGGERED EVENT TRIGGER--------------------
    if CombatInfo.SV.cct.showStaggered and result == ACTION_RESULT_STAGGERED and self.currentCC == 0 then
        zo_callLater(function ()
            self:RemoveCC(5, GetFrameTimeMilliseconds())
        end, staggerDuration)
        self:OnDraw(abilityId, abilityIcon, staggerDuration, result, abilityName, staggerDuration)
    end
    --------------------------------------------------------

    -------------IMMUNE EVENT TRIGGER-----------------------
    if CombatInfo.SV.cct.showImmune and result == ACTION_RESULT_IMMUNE and (result == ACTION_RESULT_DODGED or result == ACTION_RESULT_BLOCKED or result == ACTION_RESULT_BLOCKED_DAMAGE) and not (CombatInfo.SV.cct.showImmuneOnlyInCyro and not LUIE.ResolvePVPZone()) and not self.currentlyPlaying and self.currentCC == 0 then
        if abilityIcon ~= nil then
            self:OnDraw(abilityId, abilityIcon, CombatInfo.SV.cct.immuneDisplayTime, result, abilityName, CombatInfo.SV.cct.immuneDisplayTime)
        end
    end
    -------------------------------------------------------

    if not self.incomingCC then
        self.incomingCC = {}
    end

    if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
        if negateValidNames[GetAbilityName(abilityId)] then
            if hitValue < negateDuration then
                hitValue = negateDuration
            end
            local currentEndTimeSilence = GetFrameTimeMilliseconds() + hitValue
            table_insert(self.negatesQueue, abilityId)
            PriorityFour =
            {
                endTime = currentEndTimeSilence,
                abilityId = abilityId,
                abilityIcon = abilityIcon,
                hitValue = hitValue,
                result = ACTION_RESULT_SILENCED,
                abilityName = abilityName,
            }
            if PriorityOne.endTime == 0 and PriorityTwo.endTime == 0 and PriorityThree.endTime == 0 then
                self.currentCC = 4
                zo_callLater(function ()
                    self:RemoveCC(4, currentEndTimeSilence)
                end, hitValue + graceTime)
                self:OnDraw(abilityId, abilityIcon, hitValue, ACTION_RESULT_SILENCED, abilityName, hitValue)
            end
        else
            -- d("EVENT " .. " DURATION " .. tostring(GetFrameTimeMilliseconds()))
            -- if self.incomingCC[ACTION_RESULT_FEARED] then
            -- d("FEAR DURATION " .. tostring(GetFrameTimeMilliseconds()))
            -- end
            local currentTime = GetFrameTimeMilliseconds()
            local currentEndTime = currentTime + hitValue
            if abilityId == self.incomingCC[ACTION_RESULT_STUNNED] and (currentEndTime + 200) > PriorityOne.endTime then
                -- self.incomingCC[ACTION_RESULT_STUNNED] = nil
                -- callbackManager:RegisterCallback("OnIncomingStun", function()
                if self.breakFreePlaying then
                    if isRooted then
                        isRooted = false
                    end
                    return
                end
                PriorityOne =
                {
                    endTime = (GetFrameTimeMilliseconds() + hitValue),
                    abilityId = abilityId,
                    abilityIcon = abilityIcon,
                    hitValue = hitValue,
                    result = ACTION_RESULT_STUNNED,
                    abilityName = abilityName,
                }
                self.currentCC = 1
                zo_callLater(function ()
                    self:RemoveCC(1, currentEndTime)
                end, hitValue + graceTime + 1000)
                self:OnDraw(abilityId, abilityIcon, hitValue, ACTION_RESULT_STUNNED, abilityName, hitValue)
                -- end)
                -- zo_callLater(function() callbackManager:UnregisterAllCallbacks("OnIncomingStun") end, 1)
                self.incomingCC = {}
            elseif abilityId == self.incomingCC[ACTION_RESULT_FEARED] and (currentEndTime + 200) > PriorityOne.endTime and (currentEndTime + 200) > PriorityTwo.endTime then
                table_insert(self.fearsQueue, abilityId)
                PriorityTwo =
                {
                    endTime = currentEndTime,
                    abilityId = abilityId,
                    abilityIcon = abilityIcon,
                    hitValue = hitValue,
                    result = ACTION_RESULT_FEARED,
                    abilityName = abilityName,
                }
                if PriorityOne.endTime == 0 then
                    self.currentCC = 2
                    zo_callLater(function ()
                        self:RemoveCC(2, currentEndTime)
                    end, hitValue + graceTime)
                    self:OnDraw(abilityId, abilityIcon, hitValue, ACTION_RESULT_FEARED, abilityName, hitValue)
                end
                self.incomingCC = {}
            elseif abilityId == self.incomingCC[ACTION_RESULT_CHARMED] and (currentEndTime + 200) > PriorityOne.endTime and (currentEndTime + 200) > PriorityTwo.endTime then
                table_insert(self.fearsQueue, abilityId)
                PriorityTwo =
                {
                    endTime = currentEndTime,
                    abilityId = abilityId,
                    abilityIcon = abilityIcon,
                    hitValue = hitValue,
                    result = ACTION_RESULT_CHARMED,
                    abilityName = abilityName,
                }
                if PriorityOne.endTime == 0 then
                    self.currentCC = 2
                    zo_callLater(function ()
                        self:RemoveCC(2, currentEndTime)
                    end, hitValue + graceTime)
                    self:OnDraw(abilityId, abilityIcon, hitValue, ACTION_RESULT_CHARMED, abilityName, hitValue)
                end
                self.incomingCC = {}
            elseif abilityId == self.incomingCC[ACTION_RESULT_DISORIENTED] and (currentEndTime + 200) > PriorityOne.endTime and (currentEndTime + 200) > PriorityTwo.endTime and currentEndTime > PriorityThree.endTime then
                -- self.incomingCC[ACTION_RESULT_DISORIENTED] == nil
                table_insert(self.disorientsQueue, abilityId)
                PriorityThree =
                {
                    endTime = currentEndTime,
                    abilityId = abilityId,
                    abilityIcon = abilityIcon,
                    hitValue = hitValue,
                    result = ACTION_RESULT_DISORIENTED,
                    abilityName = abilityName,
                }
                if PriorityOne.endTime == 0 and PriorityTwo.endTime == 0 then
                    self.currentCC = 3
                    zo_callLater(function ()
                        self:RemoveCC(3, currentEndTime)
                    end, hitValue + graceTime)
                    self:OnDraw(abilityId, abilityIcon, hitValue, ACTION_RESULT_DISORIENTED, abilityName, hitValue)
                end
                self.incomingCC = {}
            elseif CombatInfo.SV.cct.showRoot and (abilityId == GENERIC_ROOT_ABILITY_ID or abilityId == self.incomingCC[ACTION_RESULT_ROOTED]) and (currentEndTime + 200) > PriorityOne.endTime and (currentEndTime + 200) > PriorityTwo.endTime and currentEndTime > PriorityThree.endTime and currentEndTime > PriorityFour.endTime then
                -- table_insert(self.rootsQueue, abilityId)
                PrioritySix = { endTime = currentEndTime, abilityId = abilityId, abilityIcon = abilityIcon, hitValue = hitValue, result = result, abilityName = abilityName }
                if PriorityOne.endTime == 0 and PriorityTwo.endTime == 0 and PriorityThree.endTime == 0 and PriorityFour.endTime == 0 then
                    self.currentCC = 6
                    rootEndTime = currentEndTime
                    zo_callLater(function ()
                        self:RemoveCC(6, currentEndTime)
                    end, hitValue + graceTime)
                    self:OnDraw(abilityId, abilityIcon, hitValue, ACTION_RESULT_ROOTED, abilityName, hitValue)
                end
                self.incomingCC = {}
            elseif (CombatInfo.SV.cct.showSnare and abilityId == self.incomingCC[ACTION_RESULT_SNARED] and not self.aoeTypesId[abilityId]) and (currentEndTime + 200) > PriorityOne.endTime and (currentEndTime + 200) > PriorityTwo.endTime and currentEndTime > PriorityThree.endTime and currentEndTime > PriorityFour.endTime then
                -- table_insert(self.snaresQueue, abilityId)
                PriorityEight = { endTime = currentEndTime, abilityId = abilityId, abilityIcon = abilityIcon, hitValue = hitValue, result = result, abilityName = abilityName }
                if PriorityOne.endTime == 0 and PriorityTwo.endTime == 0 and PriorityThree.endTime == 0 and PriorityFour.endTime == 0 and PrioritySeven.endTime == 0 then
                    self.currentCC = 8
                    zo_callLater(function ()
                        self:RemoveCC(8, currentEndTime)
                    end, hitValue + graceTime)
                    self:OnDraw(abilityId, abilityIcon, hitValue, ACTION_RESULT_SNARED, abilityName, hitValue)
                end
                self.incomingCC = {}
            else
                table_insert(self.effectsGained,
                    {
                        abilityId = abilityId,
                        hitValue = hitValue,
                        sourceUnitId = sourceUnitId,
                        abilityGraphic = abilityGraphic,
                    })
            end
        end
    elseif #self.effectsGained > 0 then
        local foundValue = self:FindEffectGained(abilityId, sourceUnitId, abilityGraphic)
        -- if not foundValue then return end

        if foundValue then
            local currentTime = GetFrameTimeMilliseconds()
            local currentEndTime = currentTime + foundValue.hitValue

            if (result == ACTION_RESULT_FEARED or result == ACTION_RESULT_CHARMED) and (currentEndTime + 200) > PriorityOne.endTime and (currentEndTime + 200) > PriorityTwo.endTime then
                table_insert(self.fearsQueue, abilityId)
                PriorityTwo =
                {
                    endTime = currentEndTime,
                    abilityId = abilityId,
                    abilityIcon = abilityIcon,
                    hitValue = foundValue.hitValue,
                    result = result,
                    abilityName = abilityName,
                }
                if PriorityOne.endTime == 0 then
                    self.currentCC = 2
                    zo_callLater(function ()
                        self:RemoveCC(2, currentEndTime)
                    end, foundValue.hitValue + graceTime)
                    self:OnDraw(abilityId, abilityIcon, foundValue.hitValue, result, abilityName, foundValue.hitValue)
                end
            end
            self.effectsGained = {}
        end
    end

    if self.actionResults[result] then
        self.incomingCC[result] = abilityId
        -- if result == ACTION_RESULT_FEARED then
        -- d("FEAR EVENT " .. tostring(GetFrameTimeMilliseconds()))
        -- end

        -- d("EVENT " .. tostring(result) .. " " .. tostring(GetFrameTimeMilliseconds()))
        -- return
    end

    -- else
    -- if #self.effectsGained>0 then
    -- local foundValue=self:FindEffectGained(abilityId, sourceUnitId, abilityGraphic)
    -- if not foundValue then return end

    -- local currentTime=GetFrameTimeMilliseconds()
    -- local currentEndTime=currentTime+foundValue.hitValue
    -- if result==ACTION_RESULT_STUNNED and (currentEndTime+200)>PriorityOne.endTime then
    -- callbackManager:RegisterCallback("OnIncomingStun", function()
    -- if self.breakFreePlaying then return end
    -- PriorityOne = {endTime=(GetFrameTimeMilliseconds()+foundValue.hitValue), abilityId=abilityId, hitValue=foundValue.hitValue, result=result, abilityName=abilityName}
    -- self.currentCC = 1
    -- zo_callLater(function() self:RemoveCC(1, currentEndTime) end, foundValue.hitValue+graceTime+1000)
    -- d('draw stun')
    -- self:OnDraw(abilityId, abilityIcon, foundValue.hitValue, result, abilityName, foundValue.hitValue)
    -- end)
    -- zo_callLater(function() callbackManager:UnregisterAllCallbacks("OnIncomingStun") end, 1)

    -- elseif result==ACTION_RESULT_FEARED and (currentEndTime+200)>PriorityOne.endTime and (currentEndTime+200)>PriorityTwo.endTime then
    -- table_insert(self.fearsQueue, abilityId)
    -- PriorityTwo = {endTime=currentEndTime, abilityId=abilityId, hitValue=foundValue.hitValue, result=result, abilityName=abilityName}
    -- if PriorityOne.endTime==0 then
    -- self.currentCC=2
    -- zo_callLater(function() self:RemoveCC(2, currentEndTime) end, foundValue.hitValue+graceTime)
    -- self:OnDraw(abilityId, abilityIcon, foundValue.hitValue, result, abilityName, foundValue.hitValue)
    -- end

    -- elseif result==ACTION_RESULT_DISORIENTED and (currentEndTime+200)>PriorityOne.endTime and (currentEndTime+200)>PriorityTwo.endTime and currentEndTime>PriorityThree.endTime then
    -- table_insert(self.disorientsQueue, abilityId)
    -- PriorityThree = {endTime=currentEndTime, abilityId=abilityId, hitValue=foundValue.hitValue, result=result, abilityName=abilityName}
    -- if PriorityOne.endTime==0 and PriorityTwo.endTime==0 then
    -- self.currentCC=3
    -- zo_callLater(function() self:RemoveCC(3, currentEndTime) end, foundValue.hitValue+graceTime)
    -- self:OnDraw(abilityId, abilityIcon, foundValue.hitValue, result, abilityName, foundValue.hitValue)
    -- end
    -- end
    -- self.effectsGained={}
    -- end
    -- end
end

-- Refactored version of CrowdControlTracker:RemoveCC
-- Extracts repetitive code into reusable helper functions.

-- Helper function to create a reset CC priority table.
local function resetPriority()
    return { endTime = 0, abilityId = 0, abilityIcon = "", hitValue = 0, result = 0, abilityName = "" }
end

-- Helper that schedules the next CC removal and triggers a redraw.
local function removeCCAndCallLater(tracker, nextCCType, nextCCInterval, nextCCPriority)
    tracker.currentCC = nextCCType
    zo_callLater(function ()
        tracker:RemoveCC(nextCCType, nextCCPriority.endTime)
    end, nextCCInterval)
    tracker:OnDraw(nextCCPriority.abilityId, nextCCPriority.abilityIcon, nextCCPriority.hitValue, nextCCPriority.result, nextCCPriority.abilityName, nextCCInterval)
end

-- Helper that checks CC conditions and decides whether to advance to the next CC.
local function checkAndRemoveCC(tracker, ccType, ccPriority, nextCCType, nextCCInterval, nextCCPriority, currentEndTime)
    if ccType == tracker.currentCC and ccPriority.endTime ~= currentEndTime then
        return
    end

    ccPriority = resetPriority()

    if nextCCInterval > 0 then
        removeCCAndCallLater(tracker, nextCCType, nextCCInterval, nextCCPriority)
        return
    end
end

function CrowdControlTracker:RemoveCC(ccType, currentEndTime)
    local stagger

    if (self.currentCC == 0 and ccType ~= 5) or self.breakFreePlaying then
        return
    end

    local currentTime = GetFrameTimeMilliseconds()
    local secondInterval = PriorityTwo.endTime - currentTime
    local thirdInterval = PriorityThree.endTime - currentTime
    local fourthInterval = PriorityFour.endTime - currentTime
    local sixthInterval = PrioritySix.endTime - currentTime
    local seventhInterval = PrioritySeven.endTime - currentTime
    local eighthInterval = PriorityEight.endTime - currentTime

    if ccType == 1 then -- STUN
        checkAndRemoveCC(self, 1, PriorityOne, 2, secondInterval, PriorityTwo, currentEndTime)
        checkAndRemoveCC(self, 2, PriorityTwo, 3, thirdInterval, PriorityThree, currentEndTime)
        checkAndRemoveCC(self, 3, PriorityThree, 4, fourthInterval, PriorityFour, currentEndTime)
        checkAndRemoveCC(self, 4, PriorityFour, 6, sixthInterval, PrioritySix, currentEndTime)
        checkAndRemoveCC(self, 6, PrioritySix, 7, seventhInterval, PrioritySeven, currentEndTime)
        checkAndRemoveCC(self, 7, PrioritySeven, 8, eighthInterval, PriorityEight, currentEndTime)
    elseif ccType == 2 then -- FEAR
        if (self.currentCC == 1 or self.currentCC == 2) and PriorityTwo.endTime ~= currentEndTime then
            return
        end

        PriorityTwo = resetPriority()

        if PriorityOne.endTime > 0 and self.currentCC == 1 then
            return
        end

        checkAndRemoveCC(self, 3, PriorityThree, 3, thirdInterval, PriorityThree, currentEndTime)
        checkAndRemoveCC(self, 4, PriorityFour, 4, fourthInterval, PriorityFour, currentEndTime)
        checkAndRemoveCC(self, 6, PrioritySix, 6, sixthInterval, PrioritySix, currentEndTime)
        checkAndRemoveCC(self, 7, PrioritySeven, 7, seventhInterval, PrioritySeven, currentEndTime)
        checkAndRemoveCC(self, 8, PriorityEight, 8, eighthInterval, PriorityEight, currentEndTime)
    elseif ccType == 3 then -- DISORIENT
        if (self.currentCC > 0 and self.currentCC < 4) and PriorityThree.endTime ~= currentEndTime then
            return
        end

        PriorityThree = resetPriority()

        if (PriorityOne.endTime > 0 and self.currentCC == 1) or (PriorityTwo.endTime > 0 and self.currentCC == 2) then
            return
        end

        checkAndRemoveCC(self, 4, PriorityFour, 4, fourthInterval, PriorityFour, currentEndTime)
        checkAndRemoveCC(self, 6, PrioritySix, 6, sixthInterval, PrioritySix, currentEndTime)
        checkAndRemoveCC(self, 7, PrioritySeven, 7, seventhInterval, PrioritySeven, currentEndTime)
        checkAndRemoveCC(self, 8, PriorityEight, 8, eighthInterval, PriorityEight, currentEndTime)
    elseif ccType == 4 then -- SILENCE
        if self.currentCC ~= 0 and PriorityFour.endTime ~= currentEndTime then
            return
        end

        PriorityFour = resetPriority()

        if (PriorityOne.endTime > 0 and self.currentCC == 1) or
        (PriorityTwo.endTime > 0 and self.currentCC == 2) or
        (PriorityThree.endTime > 0 and self.currentCC == 3) then
            return
        end

        checkAndRemoveCC(self, 6, PrioritySix, 6, sixthInterval, PrioritySix, currentEndTime)
        checkAndRemoveCC(self, 7, PrioritySeven, 7, seventhInterval, PrioritySeven, currentEndTime)
        checkAndRemoveCC(self, 8, PriorityEight, 8, eighthInterval, PriorityEight, currentEndTime)
    elseif ccType == 5 then -- STAGGER
        if self.currentCC ~= 0 then
            return
        else
            stagger = true
        end
    elseif ccType == 6 then -- ROOT
        if self.currentCC ~= 0 and PrioritySix.endTime ~= currentEndTime then
            return
        end

        PrioritySix = resetPriority()

        if (PriorityOne.endTime > 0 and self.currentCC == 1) or
        (PriorityTwo.endTime > 0 and self.currentCC == 2) or
        (PriorityThree.endTime > 0 and self.currentCC == 3) or
        (PriorityFour.endTime > 0 and self.currentCC == 4) then
            return
        end

        checkAndRemoveCC(self, 7, PrioritySeven, 7, seventhInterval, PrioritySeven, currentEndTime)
        checkAndRemoveCC(self, 8, PriorityEight, 8, eighthInterval, PriorityEight, currentEndTime)
    elseif ccType == 7 then -- AOE
        if self.currentCC ~= 0 and PrioritySeven.endTime ~= currentEndTime then
            return
        end

        PrioritySeven = resetPriority()

        if (PriorityOne.endTime > 0 and self.currentCC == 1) or
        (PriorityTwo.endTime > 0 and self.currentCC == 2) or
        (PriorityThree.endTime > 0 and self.currentCC == 3) or
        (PriorityFour.endTime > 0 and self.currentCC == 4) or
        (PrioritySix.endTime > 0 and self.currentCC == 6) then
            return
        end

        checkAndRemoveCC(self, 8, PriorityEight, 8, eighthInterval, PriorityEight, currentEndTime)
    elseif ccType == 8 then -- SNARE
        if self.currentCC ~= 0 and PriorityEight.endTime ~= currentEndTime then
            return
        end

        PriorityEight = resetPriority()

        if (PriorityOne.endTime > 0 and self.currentCC == 1) or
        (PriorityTwo.endTime > 0 and self.currentCC == 2) or
        (PriorityThree.endTime > 0 and self.currentCC == 3) or
        (PriorityFour.endTime > 0 and self.currentCC == 4) or
        (PrioritySix.endTime > 0 and self.currentCC == 6) or
        (PrioritySeven.endTime > 0 and self.currentCC == 7) then
            return
        end
    end

    if CombatInfo.SV.cct.showOptions == "text" then
        stagger = true
    end

    self:StopDraw(stagger)
end

function CrowdControlTracker:OnStunnedState(eventCode, playerStunned)
    -- d('playerStunned: '..tostring(playerStunned))
    if not playerStunned then
        -- d("PriorityOne.endTime", PriorityOne.endTime)
        if PriorityOne.endTime ~= 0 then
            self:RemoveCC(1, PriorityOne.endTime)
        end
    else
        -- callbackManager:FireCallbacks("OnIncomingStun")
    end
end

function CrowdControlTracker:OnCombatTipAdded(eventCode, combatTipID)
    -- Break roots when another CC type hits since there is some oddity with the tip removal event when a hard CC hits
    if combatTipID == 18 then
        isRooted = false
    end

    if not (combatTipID == 19) then
        return
    end
    isRooted = true
    --[[ CrowdControlTracker:OnCombat(eventCode, result, isError, abilityName, abilityGraphic,
    abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType,
    damageType, combat_log, sourceUnitId, targetUnitId, abilityId)]]
    self:OnCombat(eventCode, ACTION_RESULT_EFFECT_GAINED_DURATION, nil, "Rooted", LUIE_CC_ICON_ROOT, nil, "CombatTip", "CombatTip", LUIE.PlayerNameRaw, 1, rootDuration, nil, nil, nil, 1, nil, GENERIC_ROOT_ABILITY_ID)
    if isRooted then
        zo_callLater(function ()
            self:PopRootAlert(eventCode, combatTipID)
        end, rootDuration + graceTime)
    end
end

function CrowdControlTracker:PopRootAlert(eventCode, combatTipID)
    if not (combatTipID == 19) or not isRooted then
        return
    end
    --[[ CrowdControlTracker:OnCombat(eventCode, result, isError, abilityName, abilityGraphic,
    abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType,
    damageType, combat_log, sourceUnitId, targetUnitId, abilityId)]]
    self:OnCombat(eventCode, ACTION_RESULT_EFFECT_GAINED_DURATION, nil, "Rooted", LUIE_CC_ICON_ROOT, nil, "CombatTip", "CombatTip", LUIE.PlayerNameRaw, 1, rootDuration, nil, nil, nil, 1, nil, GENERIC_ROOT_ABILITY_ID)
    if isRooted then
        zo_callLater(function ()
            self:PopRootAlert(eventCode, combatTipID)
        end, rootDuration + graceTime)
    end
end

function CrowdControlTracker:OnCombatTipRemoved(eventCode, combatTipID, result)
    if not (combatTipID == 19) then
        return
    end
    isRooted = false
    self:RemoveCC(6, rootEndTime)
end

function CrowdControlTracker:GetDefaultIcon(ccType)
    -- Define mapping of action results to icons
    local iconMap =
    {
        [ACTION_RESULT_STUNNED] = LUIE_CC_ICON_STUN,
        [ACTION_RESULT_KNOCKBACK] = LUIE_CC_ICON_KNOCKBACK,
        [ACTION_RESULT_LEVITATED] = LUIE_CC_ICON_PULL,
        [ACTION_RESULT_FEARED] = LUIE_CC_ICON_FEAR,
        [ACTION_RESULT_CHARMED] = LUIE_CC_ICON_CHARM,
        [ACTION_RESULT_DISORIENTED] = LUIE_CC_ICON_DISORIENT,
        [ACTION_RESULT_SILENCED] = LUIE_CC_ICON_SILENCE,
        [ACTION_RESULT_ROOTED] = LUIE_CC_ICON_ROOT,
        [ACTION_RESULT_SNARED] = LUIE_CC_ICON_SNARE,
        -- Group immune-type results
        [ACTION_RESULT_IMMUNE] = LUIE_CC_ICON_IMMUNE,
        [ACTION_RESULT_DODGED] = LUIE_CC_ICON_IMMUNE,
        [ACTION_RESULT_BLOCKED] = LUIE_CC_ICON_IMMUNE,
        [ACTION_RESULT_BLOCKED_DAMAGE] = LUIE_CC_ICON_IMMUNE,
    }

    return iconMap[ccType]
end

function CrowdControlTracker:ShouldUseDefaultIcon(abilityId)
    if Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].cc then
        if CombatInfo.SV.cct.defaultIconOptions == 1 then
            return true
        elseif CombatInfo.SV.cct.defaultIconOptions == 2 then
            return Effects.EffectOverride[abilityId].isPlayerAbility and true or false
        elseif CombatInfo.SV.cct.defaultIconOptions == 3 then
            return Effects.EffectOverride[abilityId].isPlayerAbility and true or false
        end
    end
end

function CrowdControlTracker:SetupDefaultIcon(abilityId, ccType)
    -- Map CC types to action results for special stun effects
    local stunOverrideMap =
    {
        [LUIE_CC_TYPE_KNOCKBACK] = ACTION_RESULT_KNOCKBACK,
        [LUIE_CC_TYPE_PULL] = ACTION_RESULT_LEVITATED,
    }

    -- Override ccType for stun effects with special handling
    if  ccType == ACTION_RESULT_STUNNED
    and Effects.EffectOverride[abilityId]
    and Effects.EffectOverride[abilityId].cc then
        ccType = stunOverrideMap[Effects.EffectOverride[abilityId].cc] or ccType
    end

    return self:GetDefaultIcon(ccType)
end

function CrowdControlTracker:OnDraw(abilityId, abilityIcon, ccDuration, result, abilityName, interval)
    -- Error prevention
    if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
        return
    end

    if result == ACTION_RESULT_STAGGERED then
        self:OnAnimation(LUIE_CCTracker, "stagger")
        return
    end

    if (result == ACTION_RESULT_ROOTED) and not isRooted then
        return
    end

    -- Override icon with default if enabled
    if CombatInfo.SV.cct.useDefaultIcon and result ~= ACTION_RESULT_AREA_EFFECT and self:ShouldUseDefaultIcon(abilityId) == true then
        abilityIcon = self:SetupDefaultIcon(abilityId, result)
    end

    local ccText
    if CombatInfo.SV.cct.useAbilityName then
        ccText = zo_strformat(SI_ABILITY_NAME, abilityName)
    else
        ccText = self.controlText[result]
    end

    -- If the effect is flagged as unbreakable in the Effect Override table then switch the effect to color as unbreakable (unless its an AOE).
    if Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].unbreakable and not CrowdControlTracker.aoeTypesId[abilityId] then
        self:SetupInfo(ccText, CombatInfo.SV.cct.colors.unbreakable, abilityIcon)
        -- If the effect is labeled as a Knockback or Pull then change the color setting.
    elseif result == ACTION_RESULT_STUNNED and Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].cc then
        if Effects.EffectOverride[abilityId].cc == LUIE_CC_TYPE_KNOCKBACK then
            self:SetupInfo(ccText, CombatInfo.SV.cct.colors[ACTION_RESULT_KNOCKBACK], abilityIcon)
        elseif Effects.EffectOverride[abilityId].cc == LUIE_CC_TYPE_PULL then
            self:SetupInfo(ccText, CombatInfo.SV.cct.colors[ACTION_RESULT_LEVITATED], abilityIcon)
        else
            self:SetupInfo(ccText, CombatInfo.SV.cct.colors[result], abilityIcon)
        end
    else
        self:SetupInfo(ccText, CombatInfo.SV.cct.colors[result], abilityIcon)
    end

    if result == ACTION_RESULT_SILENCED or result == ACTION_RESULT_AREA_EFFECT or result == ACTION_RESULT_ROOTED then
        if CombatInfo.SV.cct.showOptions == "text" then
            self:OnAnimation(LUIE_CCTracker_TextFrame, "silence")
        else
            self:OnAnimation(LUIE_CCTracker_IconFrame, "silence")
        end
    elseif result == ACTION_RESULT_IMMUNE or result == ACTION_RESULT_DODGED or result == ACTION_RESULT_BLOCKED or result == ACTION_RESULT_BLOCKED_DAMAGE then
        self:OnAnimation(LUIE_CCTracker, "immune")
    else
        self:OnProc(ccDuration, interval)
    end

    if (result == ACTION_RESULT_ROOTED) and isRooted then
        if CombatInfo.SV.cct.playSound then
            local playSound = CombatInfo.SV.cct.playSoundOption
            if playSound then
                PlaySound(LUIE.Sounds[playSound])
                PlaySound(LUIE.Sounds[playSound])
            end
        end
    end
end

function CrowdControlTracker:IconHidden(hidden)
    if CombatInfo.SV.cct.showOptions == "text" then
        LUIE_CCTracker_IconFrame:SetHidden(true)
    else
        LUIE_CCTracker_IconFrame:SetHidden(hidden)
    end
end

function CrowdControlTracker:TimerHidden(hidden)
    if CombatInfo.SV.cct.showOptions == "text" then
        LUIE_CCTracker_Timer:SetHidden(true)
    else
        LUIE_CCTracker_Timer:SetHidden(hidden)
    end
end

function CrowdControlTracker:TextHidden(hidden)
    if CombatInfo.SV.cct.showOptions == "icon" then
        LUIE_CCTracker_TextFrame:SetHidden(true)
    else
        LUIE_CCTracker_TextFrame:SetHidden(hidden)
    end
end

function CrowdControlTracker:BreakFreeHidden(hidden)
    if CombatInfo.SV.cct.showOptions == "text" then
        LUIE_CCTracker_BreakFreeFrame:SetHidden(true)
    else
        LUIE_CCTracker_BreakFreeFrame:SetHidden(hidden)
    end
end

function CrowdControlTracker:SetupInfo(ccText, ccColor, abilityIcon)
    LUIE_CCTracker_TextFrame_Label:SetFont(iconFont)
    LUIE_CCTracker_TextFrame_Label:SetText(ccText)
    LUIE_CCTracker_TextFrame_Label:SetColor(unpack(ccColor))
    LUIE_CCTracker_IconFrame_Icon:SetTexture(abilityIcon)
    LUIE_CCTracker_IconFrame_Icon:SetColor(1, 1, 1, 1)
    LUIE_CCTracker_IconFrame_IconBG:SetColor(unpack(ccColor))
    LUIE_CCTracker_IconFrame_IconBorder:SetColor(unpack(ccColor))
    LUIE_CCTracker_IconFrame_IconBorderHighlight:SetColor(unpack(ccColor))
    LUIE_CCTracker_Timer_Label:SetColor(unpack(ccColor))
end

function CrowdControlTracker:SetupDisplay(displayType)
    if displayType == "silence" then
        LUIE_CCTracker_IconFrame_Cooldown:SetHidden(true)
        LUIE_CCTracker_IconFrame_GlobalCooldown:SetHidden(true)
        LUIE_CCTracker_IconFrame_IconBorderHighlight:SetHidden(false)
        LUIE_CCTracker_IconFrame_Icon:SetTextureCoords(0, 1, 0, 1)
        self:IconHidden(false)
        self:TextHidden(false)
        self:TimerHidden(true)
        self:BreakFreeHidden(true)
        LUIE_CCTracker:SetHidden(false)
    elseif displayType == "immune" then
        LUIE_CCTracker_IconFrame_Cooldown:SetHidden(true)
        LUIE_CCTracker_IconFrame_GlobalCooldown:SetHidden(true)
        LUIE_CCTracker_IconFrame_IconBorderHighlight:SetHidden(true)
        LUIE_CCTracker_IconFrame_Icon:SetTextureCoords(0, 1, 0, 1)
        LUIE_CCTracker_IconFrame_IconBG:SetColor(0, 0, 0, 0)
        self:IconHidden(false)
        self:TextHidden(false)
        self:TimerHidden(true)
        self:BreakFreeHidden(true)
        LUIE_CCTracker:SetHidden(false)
    elseif displayType == "stagger" then
        LUIE_CCTracker_TextFrame_Label:SetText(CrowdControlTracker.controlText[ACTION_RESULT_STAGGERED])
        LUIE_CCTracker_TextFrame_Label:SetColor(unpack(CombatInfo.SV.cct.colors[ACTION_RESULT_STAGGERED]))
        LUIE_CCTracker_TextFrame_Label:SetFont(staggerFont)
        self:TextHidden(false)
        self:IconHidden(true)
        self:TimerHidden(true)
        self:BreakFreeHidden(true)
        LUIE_CCTracker:SetHidden(false)
    elseif displayType == "breakfree" then
        self:IconHidden(true)
        self:TextHidden(true)
        self:TimerHidden(true)
        self:BreakFreeHidden(false)
        LUIE_CCTracker:SetHidden(false)
    elseif displayType == "timer" then
        LUIE_CCTracker_IconFrame_Cooldown:SetHidden(false)
    elseif displayType == "end" then
        LUIE_CCTracker_IconFrame_IconBorderHighlight:SetHidden(false)
        LUIE_CCTracker_IconFrame_Icon:SetTextureCoords(0, 1, 0, 1)
        LUIE_CCTracker_IconFrame_Cooldown:SetHidden(false)
        LUIE_CCTracker_IconFrame_GlobalCooldown:SetHidden(true)
        self:IconHidden(false)
        self:TextHidden(false)
        self:TimerHidden(true)
        self:BreakFreeHidden(true)
        LUIE_CCTracker:SetHidden(false)
    elseif displayType == "endstagger" then
        self:SetupDisplay("end")
        self:IconHidden(true)
    elseif displayType == "proc" then
        LUIE_CCTracker_IconFrame_Icon:SetTextureCoords(0, 1, 0, 1)
        LUIE_CCTracker_IconFrame_IconBorderHighlight:SetHidden(false)
        self:IconHidden(false)
        self:TextHidden(false)
        self:TimerHidden(false)
        self:BreakFreeHidden(true)
        LUIE_CCTracker:SetHidden(false)
    end
end

function CrowdControlTracker:StopDraw(isTextOnly)
    if self.breakFreePlaying and not self.breakFreePlayingDraw then
        -- d("Stop Draw breakfree returned")
        return
    end
    self:VarReset()
    if isTextOnly then
        self:OnAnimation(LUIE_CCTracker, "endstagger", true)
    else
        self:OnAnimation(LUIE_CCTracker, "end", true)
    end
end

function CrowdControlTracker:StopDrawBreakFree()
    local breakFreeIcon
    local currentCCIcon = ICON_MISSING
    local currentCC = self.currentCC

    if currentCC ~= 0 and currentCC ~= 4 and currentCC ~= 6 then
        local currentResult = self:CCPriority(currentCC).result
        local currentAbilityId = self:CCPriority(currentCC).abilityId
        local currentColor
        if Effects.EffectOverride[currentAbilityId] and Effects.EffectOverride[currentAbilityId].unbreakable then
            currentColor = CombatInfo.SV.cct.colors.unbreakable
        elseif currentResult == ACTION_RESULT_STUNNED and Effects.EffectOverride[currentAbilityId] and Effects.EffectOverride[currentAbilityId].cc then
            if Effects.EffectOverride[currentAbilityId].cc == LUIE_CC_TYPE_KNOCKBACK then
                currentColor = CombatInfo.SV.cct.colors[ACTION_RESULT_KNOCKBACK]
            elseif Effects.EffectOverride[currentAbilityId].cc == LUIE_CC_TYPE_PULL then
                currentColor = CombatInfo.SV.cct.colors[ACTION_RESULT_LEVITATED]
            else
                currentColor = CombatInfo.SV.cct.colors[currentResult]
            end
        else
            currentColor = CombatInfo.SV.cct.colors[currentResult]
        end

        if CombatInfo.SV.cct.useDefaultIcon and currentResult ~= ACTION_RESULT_AREA_EFFECT and self:ShouldUseDefaultIcon(currentAbilityId) == true then
            currentCCIcon = self:SetupDefaultIcon(currentAbilityId, currentResult)
        else
            currentCCIcon = GetAbilityIcon(currentAbilityId)
        end

        LUIE_CCTracker_BreakFreeFrame_Left_IconBG:SetColor(unpack(currentColor))
        LUIE_CCTracker_BreakFreeFrame_Right_IconBG:SetColor(unpack(currentColor))
        LUIE_CCTracker_BreakFreeFrame_Left_IconBorder:SetColor(unpack(currentColor))
        LUIE_CCTracker_BreakFreeFrame_Left_IconBorderHighlight:SetColor(unpack(currentColor))
        LUIE_CCTracker_BreakFreeFrame_Right_IconBorder:SetColor(unpack(currentColor))
        LUIE_CCTracker_BreakFreeFrame_Right_IconBorderHighlight:SetColor(unpack(currentColor))
    end

    self:VarReset()
    self.breakFreePlaying = true

    if not zo_strfind(currentCCIcon, ICON_MISSING) then
        breakFreeIcon = currentCCIcon
    else
        self:VarReset()
        self.breakFreePlaying = true
        self.breakFreePlayingDraw = true
        zo_callLater(function ()
            self.breakFreePlayingDraw = nil
            self.breakFreePlaying = nil
        end, 450)
        LUIE_CCTracker:SetHidden(true)
        return
    end

    LUIE_CCTracker_BreakFreeFrame_Left_Icon:SetColor(1, 1, 1, 1)
    LUIE_CCTracker_BreakFreeFrame_Right_Icon:SetColor(1, 1, 1, 1)
    LUIE_CCTracker_BreakFreeFrame_Left_Icon:SetTexture(breakFreeIcon)
    LUIE_CCTracker_BreakFreeFrame_Left_Icon:SetTextureCoords(0, 0.5, 0, 1)
    LUIE_CCTracker_BreakFreeFrame_Right_Icon:SetTexture(breakFreeIcon)
    LUIE_CCTracker_BreakFreeFrame_Right_Icon:SetTextureCoords(0.5, 1, 0, 1)
    self:OnAnimation(nil, "breakfree", true)
end

function CrowdControlTracker:FindEffectGained(abilityId, sourceUnitId, abilityGraphic)
    local foundValue
    for k, v in pairs(self.effectsGained) do
        if v.abilityId == abilityId and v.sourceUnitId == sourceUnitId and v.abilityGraphic == abilityGraphic then
            foundValue = v
            break
        end
    end
    return foundValue
end

function CrowdControlTracker:CCPriority(ccType)
    -- Map CC types to their priority tables
    local priorityMap =
    {
        [1] = PriorityOne,   -- STUN
        [2] = PriorityTwo,   -- FEAR/CHARM
        [3] = PriorityThree, -- DISORIENT
        [4] = PriorityFour,  -- SILENCE
        [6] = PrioritySix,   -- ROOT
        [7] = PrioritySeven, -- AOE
        [8] = PriorityEight, -- SNARE
    }

    return priorityMap[ccType]
end

function CrowdControlTracker:BreakFreeAnimation()
    if self.currentlyPlaying then
        self.currentlyPlaying:Stop()
    end
    if self.immunePlaying then
        self.immunePlaying:Stop()
    end

    local leftSide, rightSide = LUIE_CCTracker_BreakFreeFrame_Left, LUIE_CCTracker_BreakFreeFrame_Right

    LUIE_CCTracker:SetScale(CombatInfo.SV.cct.controlScale)
    leftSide:ClearAnchors()
    leftSide:SetAnchor(RIGHT, LUIE_CCTracker_BreakFreeFrame_Middle, LEFT, 1 - 20, 0)
    rightSide:ClearAnchors()
    rightSide:SetAnchor(LEFT, LUIE_CCTracker_BreakFreeFrame_Middle, RIGHT, -1 + 20, 0)
    leftSide:SetAlpha(1)
    rightSide:SetAlpha(1)

    local timeline = animationManager:CreateTimeline()
    local animDuration = 300
    local animDelay = 150

    self:InsertAnimationType(timeline, ANIMATION_SCALE, leftSide, animDelay, 0, ZO_EaseOutCubic, 1.0, 2)
    self:InsertAnimationType(timeline, ANIMATION_SCALE, rightSide, animDelay, 0, ZO_EaseOutCubic, 1.0, 2)
    self:InsertAnimationType(timeline, ANIMATION_SCALE, leftSide, animDuration, animDelay, ZO_EaseOutCubic, 1.8, 0.1)
    self:InsertAnimationType(timeline, ANIMATION_SCALE, rightSide, animDuration, animDelay, ZO_EaseOutCubic, 1.8, 0.1)
    self:InsertAnimationType(timeline, ANIMATION_ALPHA, leftSide, animDuration, animDelay, ZO_EaseInOutQuintic, 1, 0)
    self:InsertAnimationType(timeline, ANIMATION_ALPHA, rightSide, animDuration, animDelay, ZO_EaseInOutQuintic, 1, 0)
    self:InsertAnimationType(timeline, ANIMATION_TRANSLATE, leftSide, animDuration, animDelay, ZO_EaseOutCubic, 0, 0, -550, 0)
    self:InsertAnimationType(timeline, ANIMATION_TRANSLATE, rightSide, animDuration, animDelay, ZO_EaseOutCubic, 0, 0, 550, 0)

    timeline:SetHandler("OnStop", function ()
        leftSide:ClearAnchors()
        leftSide:SetAnchor(LEFT, LUIE_CCTracker_BreakFreeFrame, LEFT, 0, 0)
        leftSide:SetScale(1)
        rightSide:ClearAnchors()
        rightSide:SetAnchor(RIGHT, LUIE_CCTracker_BreakFreeFrame, RIGHT, 0, 0)
        rightSide:SetScale(1)
        self.breakFreePlaying = nil
    end)

    timeline:PlayFromStart()

    return timeline
end

function CrowdControlTracker:StartAnimation(control, animType, test)
    if self.currentlyPlaying then
        self.currentlyPlaying:Stop()
    end
    if self.immunePlaying then
        self.immunePlaying:Stop()
    end

    local _, point, relativeTo, relativePoint, offsetX, offsetY = control:GetAnchor()
    control:ClearAnchors()
    control:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)

    local timeline = animationManager:CreateTimeline()

    if animType == "proc" then
        if control:GetAlpha() == 0 then
            self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, 100, 0, ZO_EaseInQuadratic, 0, 1)
        else
            control:SetAlpha(1)
        end
        self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 100, 0, ZO_EaseInQuadratic, 1, 2.2, SET_SCALE_FROM_SV)
        self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 200, 200, ZO_EaseOutQuadratic, 2.2, 1, SET_SCALE_FROM_SV)
    elseif animType == "end" or animType == "endstagger" then
        local currentAlpha = control:GetAlpha()
        self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, 150, 0, ZO_EaseOutQuadratic, currentAlpha, 0)
    elseif animType == "silence" then
        if LUIE_CCTracker:GetAlpha() < 1 then
            self:InsertAnimationType(timeline, ANIMATION_ALPHA, LUIE_CCTracker, 100, 0, ZO_EaseInQuadratic, 0, 1)
            self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 100, 0, ZO_EaseInQuadratic, 1, 2.5, SET_SCALE_FROM_SV)
            self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 200, 200, ZO_EaseOutQuadratic, 2.5, 1, SET_SCALE_FROM_SV)
        else
            LUIE_CCTracker:SetAlpha(1)
            self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 250, 0, ZO_EaseInQuadratic, 1, 1.5, SET_SCALE_FROM_SV)
            self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 250, 250, ZO_EaseOutQuadratic, 1.5, 1, SET_SCALE_FROM_SV)
        end
    elseif animType == "stagger" then
        self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, 50, 0, ZO_EaseInQuadratic, 0, 1)
        self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 50, 0, ZO_EaseInQuadratic, 1, 1.5, SET_SCALE_FROM_SV)
        self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 50, 100, ZO_EaseOutQuadratic, 1.5, 1, SET_SCALE_FROM_SV)
    elseif animType == "immune" then
        control:SetScale(CombatInfo.SV.cct.controlScale * 1)
        self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, 10, 0, ZO_EaseInQuadratic, 0, 0.6)
        self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, CombatInfo.SV.cct.immuneDisplayTime, 100, ZO_EaseInOutQuadratic, 0.6, 0)
    end

    timeline:SetHandler("OnStop", function ()
        control:SetScale(CombatInfo.SV.cct.controlScale)
        control:ClearAnchors()
        control:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
        self.currentlyPlaying = nil
        self.immunePlaying = nil
    end)

    timeline:PlayFromStart()
    return timeline
end

function CrowdControlTracker:InsertAnimationType(animHandler, animType, control, animDuration, animDelay, animEasing, ...)
    if not animHandler then
        return
    end
    if animType == ANIMATION_SCALE then
        local animationScale, startScale, endScale, scaleFromSV = animHandler:InsertAnimation(ANIMATION_SCALE, control, animDelay), ...
        if scaleFromSV then
            startScale = startScale * CombatInfo.SV.cct.controlScale
            endScale = endScale * CombatInfo.SV.cct.controlScale
        end
        animationScale:SetScaleValues(startScale, endScale)
        animationScale:SetDuration(animDuration)
        animationScale:SetEasingFunction(animEasing)
    elseif animType == ANIMATION_ALPHA then
        local animationAlpha, startAlpha, endAlpha = animHandler:InsertAnimation(ANIMATION_ALPHA, control, animDelay), ...
        animationAlpha:SetAlphaValues(startAlpha, endAlpha)
        animationAlpha:SetDuration(animDuration)
        animationAlpha:SetEasingFunction(animEasing)
    elseif animType == ANIMATION_TRANSLATE then
        local animationTranslate, startX, startY, offsetX, offsetY = animHandler:InsertAnimation(ANIMATION_TRANSLATE, control, animDelay), ...
        animationTranslate:SetTranslateOffsets(startX, startY, offsetX, offsetY)
        animationTranslate:SetDuration(animDuration)
        animationTranslate:SetEasingFunction(animEasing)
    end
end

function CrowdControlTracker:InitControls()
    LUIE_CCTracker:ClearAnchors()
    LUIE_CCTracker:SetAnchor(CENTER, GuiRoot, CENTER, CombatInfo.SV.cct.offsetX, CombatInfo.SV.cct.offsetY)
    LUIE_CCTracker:SetScale(CombatInfo.SV.cct.controlScale)
    LUIE_CCTracker_TextFrame_Label:SetFont(iconFont)
    if CombatInfo.SV.cct.unlock then
        LUIE_CCTracker_TextFrame_Label:SetText("Unlocked")
    else
        LUIE_CCTracker_TextFrame_Label:SetText("")
    end
    self:TextHidden(false)
    LUIE_CCTracker_IconFrame_IconBorder:SetTexture(iconBorder)
    LUIE_CCTracker_IconFrame_IconBorderHighlight:SetTexture(iconBorder)
    LUIE_CCTracker_IconFrame_IconBorder:SetHidden(false)
    LUIE_CCTracker_IconFrame_IconBorderHighlight:SetHidden(false)
    LUIE_CCTracker_IconFrame_Cooldown:ResetCooldown()
    LUIE_CCTracker_IconFrame_Cooldown:SetHidden(true)
    LUIE_CCTracker_IconFrame_GlobalCooldown:ResetCooldown()
    LUIE_CCTracker_IconFrame_GlobalCooldown:SetHidden(true)
    LUIE_CCTracker_IconFrame_Icon:SetTexture(defaultImmuneIcon)
    LUIE_CCTracker_IconFrame_Icon:SetTextureCoords(0.2, 0.8, 0.2, 0.8)
    LUIE_CCTracker_IconFrame_IconBG:SetColor(1, 1, 1, 1)
    LUIE_CCTracker_IconFrame_Icon:SetColor(1, 1, 1, 1)
    self:IconHidden(false)
    LUIE_CCTracker_IconFrame_IconBorder:SetColor(1, 1, 1, 1)
    LUIE_CCTracker_IconFrame_IconBorderHighlight:SetColor(1, 1, 1, 1)
    LUIE_CCTracker_TextFrame_Label:SetColor(1, 1, 1, 1)

    LUIE_CCTracker:SetMouseEnabled(CombatInfo.SV.cct.unlock)
    LUIE_CCTracker:SetMovable(CombatInfo.SV.cct.unlock)
    LUIE_CCTracker:SetAlpha(1)

    LUIE_CCTracker_BreakFreeFrame_Left_IconBorder:SetTexture(iconBorder)
    LUIE_CCTracker_BreakFreeFrame_Left_IconBorderHighlight:SetTexture(iconBorder)
    LUIE_CCTracker_BreakFreeFrame_Left_IconBorder:SetTextureCoords(0, 0.5, 0, 1)
    LUIE_CCTracker_BreakFreeFrame_Left_IconBorderHighlight:SetTextureCoords(0, 0.5, 0, 1)
    LUIE_CCTracker_BreakFreeFrame_Right_IconBorder:SetTexture(iconBorder)
    LUIE_CCTracker_BreakFreeFrame_Right_IconBorderHighlight:SetTexture(iconBorder)
    LUIE_CCTracker_BreakFreeFrame_Right_IconBorder:SetTextureCoords(0.5, 1, 0, 1)
    LUIE_CCTracker_BreakFreeFrame_Right_IconBorderHighlight:SetTextureCoords(0.5, 1, 0, 1)
    LUIE_CCTracker_BreakFreeFrame_Left_Icon:SetTexture(defaultDisorientIcon)
    LUIE_CCTracker_BreakFreeFrame_Left_Icon:SetTextureCoords(0, 0.5, 0, 1)
    LUIE_CCTracker_BreakFreeFrame_Right_Icon:SetTexture(defaultDisorientIcon)
    LUIE_CCTracker_BreakFreeFrame_Right_Icon:SetTextureCoords(0.5, 1, 0, 1)
    self:BreakFreeHidden(true)
    self:TimerHidden(not CombatInfo.SV.cct.unlock)
    LUIE_CCTracker_Timer_Label:SetText("69")
    LUIE_CCTracker_Timer_Label:SetColor(1, 1, 1, 1)
    LUIE_CCTracker:SetHidden(not CombatInfo.SV.cct.unlock)
end

function CrowdControlTracker:FullReset()
    self:VarReset()
    if self.currentlyPlaying then
        self.currentlyPlaying:Stop()
    end

    if self.breakFreePlaying then
        if not self.breakFreePlayingDraw then
            self.breakFreePlaying:Stop()
        end
    else
        self.breakFreePlayingDraw = nil
        self.breakFreePlaying = nil
    end
    if self.immunePlaying then
        self.immunePlaying:Stop()
    end
    self:InitControls()
end

function CrowdControlTracker:VarReset()
    self.effectsGained = {}
    self.disorientsQueue = {}
    self.fearsQueue = {}
    self.negatesQueue = {}
    -- self.rootsQueue = {}
    -- self.snaresQueue = {}
    self.currentCC = 0
    PriorityOne = { endTime = 0, abilityId = 0, abilityIcon = "", hitValue = 0, result = 0, abilityName = "" }
    PriorityTwo = { endTime = 0, abilityId = 0, abilityIcon = "", hitValue = 0, result = 0, abilityName = "" }
    PriorityThree = { endTime = 0, abilityId = 0, abilityIcon = "", hitValue = 0, result = 0, abilityName = "" }
    PriorityFour = { endTime = 0, abilityId = 0, abilityIcon = "", hitValue = 0, result = 0, abilityName = "" }
    PrioritySix = { endTime = 0, abilityId = 0, abilityIcon = "", hitValue = 0, result = 0, abilityName = "" }
    PrioritySeven = { endTime = 0, abilityId = 0, abilityIcon = "", hitValue = 0, result = 0, abilityName = "" }
    PriorityEight = { endTime = 0, abilityId = 0, abilityIcon = "", hitValue = 0, result = 0, abilityName = "" }
    self.Timer = 0
end
