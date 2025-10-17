--- @diagnostic disable: undefined-field, missing-fields
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local UI = LUIE.UI

-- Unit Frames namespace
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

local AbbreviateNumber = LUIE.AbbreviateNumber
local printToChat = LUIE.PrintToChat

local type = type
local pairs = pairs
local ipairs = ipairs
local table = table
local table_insert = table.insert
local table_sort = table.sort
local table_remove = table.remove
local string_format = string.format
local zo_strformat = zo_strformat

local eventManager = GetEventManager()
local sceneManager = SCENE_MANAGER

local leaderIcons =
{
    [0] = "LuiExtended/media/unitframes/unitframes_class_none.dds",
    [1] = "/esoui/art/icons/guildranks/guild_rankicon_misc01.dds",
}

local moduleName = UnitFrames.moduleName


-- local group
-- local unitTag
-- local playerTlw
local CP_BAR_COLORS = ZO_CP_BAR_GRADIENT_COLORS

---
--- @param iconPath string
--- @param text string
--- @param iconSize number?
--- @return string
local function FormatTextWithIcon(iconPath, text, iconSize)
    iconSize = iconSize or 20
    return zo_iconFormat(iconPath, iconSize, iconSize) .. " " .. text
end

local g_PendingUpdate =
{
    Group = { flag = false, delay = 200, name = moduleName .. "PendingGroupUpdate" },
    VeteranXP = { flag = false, delay = 5000, name = moduleName .. "PendingVeteranXP" },
}

-- Labels for Offline/Dead/Resurrection Status
local strDead = GetString(SI_UNIT_FRAME_STATUS_DEAD)
local strOffline = GetString(SI_UNIT_FRAME_STATUS_OFFLINE)
local strResCast = GetString(SI_PLAYER_TO_PLAYER_RESURRECT_BEING_RESURRECTED)
local strResSelf = GetString(LUIE_STRING_UF_DEAD_STATUS_REVIVING)
local strResPending = GetString(SI_PLAYER_TO_PLAYER_RESURRECT_HAS_RESURRECT_PENDING)
local strResCastRaid = GetString(LUIE_STRING_UF_DEAD_STATUS_RES_SHORTHAND)
local strResPendingRaid = GetString(LUIE_STRING_UF_DEAD_STATUS_RES_PENDING_SHORTHAND)


function UnitFrames.CustomFramesApplyBarAlignment()
    if UnitFrames.CustomFrames["player"] then
        local hpBar = UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_HEALTH]
        if hpBar and hpBar.bar then
            -- Ensure we have a valid alignment value, default to 1 if nil
            local healthAlignment = UnitFrames.SV.BarAlignPlayerHealth or 1
            hpBar.bar:SetBarAlignment(healthAlignment - 1)
            if hpBar.trauma then
                hpBar.trauma:SetBarAlignment(healthAlignment - 1)
            end
        end

        local magBar = UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_MAGICKA]
        if magBar and magBar.bar then
            local magickaAlignment = UnitFrames.SV.BarAlignPlayerMagicka or 1
            magBar.bar:SetBarAlignment(magickaAlignment - 1)
        end

        local stamBar = UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_STAMINA]
        if stamBar and stamBar.bar then
            local staminaAlignment = UnitFrames.SV.BarAlignPlayerStamina or 1
            stamBar.bar:SetBarAlignment(staminaAlignment - 1)
        end
    end

    if UnitFrames.CustomFrames["reticleover"] then
        local hpBar = UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH]
        if hpBar and hpBar.bar then
            local targetAlignment = UnitFrames.SV.BarAlignTarget or 1
            hpBar.bar:SetBarAlignment(targetAlignment - 1)
            if hpBar.trauma then
                hpBar.trauma:SetBarAlignment(targetAlignment - 1)
            end
            if hpBar.invulnerable then
                hpBar.invulnerable:SetBarAlignment(targetAlignment - 1)
            end
            if hpBar.invulnerableInlay then
                hpBar.invulnerableInlay:SetBarAlignment(targetAlignment - 1)
            end
        end
    end

    for i = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
        local unitTag = "boss" .. i
        if DoesUnitExist(unitTag) then
            if UnitFrames.CustomFrames[unitTag] then
                local hpBar = UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH]
                if hpBar then
                    hpBar.bar:SetBarAlignment(UnitFrames.SV.BarAlignTarget - 1)
                    if hpBar.trauma then
                        hpBar.trauma:SetBarAlignment(UnitFrames.SV.BarAlignTarget - 1)
                    end
                    if hpBar.invulnerable then
                        hpBar.invulnerable:SetBarAlignment(UnitFrames.SV.BarAlignTarget - 1)
                    end
                    if hpBar.invulnerableInlay then
                        hpBar.invulnerableInlay:SetBarAlignment(UnitFrames.SV.BarAlignTarget - 1)
                    end
                end
            end
        end
    end
end

-- Main entry point to this module
function UnitFrames.Initialize(enabled)
    -- Load settings
    local isCharacterSpecific = LUIESV["Default"][GetDisplayName()]["$AccountWide"].CharacterSpecificSV
    if isCharacterSpecific then
        UnitFrames.SV = ZO_SavedVars:New(LUIE.SVName, LUIE.SVVer, "UnitFrames", UnitFrames.Defaults)
    else
        UnitFrames.SV = ZO_SavedVars:NewAccountWide(LUIE.SVName, LUIE.SVVer, "UnitFrames", UnitFrames.Defaults)
    end

    if UnitFrames.SV.DefaultOocTransparency < 0 or UnitFrames.SV.DefaultOocTransparency > 100 then
        UnitFrames.SV.DefaultOocTransparency = UnitFrames.Defaults.DefaultOocTransparency
    end
    if UnitFrames.SV.DefaultIncTransparency < 0 or UnitFrames.SV.DefaultIncTransparency > 100 then
        UnitFrames.SV.DefaultIncTransparency = UnitFrames.Defaults.DefaultIncTransparency
    end

    -- Disable module if setting not toggled on
    if not enabled then
        return
    end
    UnitFrames.Enabled = true

    -- Even if used do not want to use neither DefaultFrames nor CustomFrames, let us still create tables to hold health and shield values
    -- { powerValue, powerMax, powerEffectiveMax, shield, trauma }
    UnitFrames.savedHealth.player = { 1, 1, 1, 0, 0 }
    UnitFrames.savedHealth.controlledsiege = { 1, 1, 1, 0, 0 }
    UnitFrames.savedHealth.reticleover = { 1, 1, 1, 0, 0 }
    UnitFrames.savedHealth.companion = { 1, 1, 1, 0, 0 }
    for i = 1, 12 do
        UnitFrames.savedHealth["group" .. i] = { 1, 1, 1, 0, 0 }
    end
    for i = 1, 7 do
        UnitFrames.savedHealth["boss" .. i] = { 1, 1, 1, 0, 0 }
    end
    for i = 1, 7 do
        UnitFrames.savedHealth["playerpet" .. i] = { 1, 1, 1, 0, 0 }
    end

    -- Get execute threshold percentage
    UnitFrames.targetThreshold = UnitFrames.SV.ExecutePercentage

    -- Get low health threshold percentage
    UnitFrames.healthThreshold = UnitFrames.SV.LowResourceHealth
    UnitFrames.magickaThreshold = UnitFrames.SV.LowResourceMagicka
    UnitFrames.staminaThreshold = UnitFrames.SV.LowResourceStamina

    -- Variable adjustment if needed
    if not LUIESV["Default"][GetDisplayName()]["$AccountWide"].AdjustVarsUF then
        LUIESV["Default"][GetDisplayName()]["$AccountWide"].AdjustVarsUF = 0
    end
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].AdjustVarsUF < 2 then
        UnitFrames.SV["CustomFramesPetFramePos"] = nil
    end
    -- Increment so this doesn't occur again.
    LUIESV["Default"][GetDisplayName()]["$AccountWide"].AdjustVarsUF = 2

    UnitFrames.CreateDefaultFrames()
    UnitFrames.CreateCustomFrames()

    function BOSS_BAR:RefreshBossHealthBar(smoothAnimate)
        local totalHealth = 0
        local totalMaxHealth = 0

        for unitTag, bossEntry in pairs(self.bossHealthValues) do
            totalHealth = totalHealth + bossEntry.health
            totalMaxHealth = totalMaxHealth + bossEntry.maxHealth
        end

        local halfHealth = zo_floor(totalHealth / 2)
        local halfMax = zo_floor(totalMaxHealth / 2)
        for i = 1, #self.bars do
            ZO_StatusBar_SmoothTransition(self.bars[i], halfHealth, halfMax, not smoothAnimate)
        end
        self.healthText:SetText(ZO_FormatResourceBarCurrentAndMax(totalHealth, totalMaxHealth))

        if UnitFrames.SV.DefaultFramesNewBoss == 2 then
            COMPASS_FRAME:SetBossBarActive(totalHealth > 0)
        end
    end

    UnitFrames.SaveDefaultFramePositions()
    UnitFrames.RepositionDefaultFrames()
    UnitFrames.SetDefaultFramesTransparency()

    -- Set event handlers
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED, UnitFrames.OnPlayerActivated)
    -- eventManager:RegisterForEvent(moduleName, EVENT_POWER_UPDATE, UnitFrames.OnPowerUpdate) -- Now handled by UnitFrames_MostRecentPowerUpdateHandler
    UnitFrames.RegisterRecentEventHandler()

    eventManager:RegisterForEvent(moduleName, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, UnitFrames.OnVisualizationAdded)
    eventManager:RegisterForEvent(moduleName, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, UnitFrames.OnVisualizationRemoved)
    eventManager:RegisterForEvent(moduleName, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, UnitFrames.OnVisualizationUpdated)
    eventManager:RegisterForEvent(moduleName, EVENT_TARGET_CHANGED, UnitFrames.OnTargetChange)
    eventManager:RegisterForEvent(moduleName, EVENT_RETICLE_TARGET_CHANGED, UnitFrames.OnReticleTargetChanged)
    eventManager:RegisterForEvent(moduleName, EVENT_DISPOSITION_UPDATE, UnitFrames.OnDispositionUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_UNIT_CREATED, UnitFrames.OnUnitCreated)
    eventManager:RegisterForEvent(moduleName, EVENT_LEVEL_UPDATE, UnitFrames.OnLevelUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_CHAMPION_POINT_UPDATE, UnitFrames.OnLevelUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_TITLE_UPDATE, UnitFrames.TitleUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_RANK_POINT_UPDATE, UnitFrames.TitleUpdate)

    -- Next events make sense only for CustomFrames
    if UnitFrames.CustomFrames["player"] or UnitFrames.CustomFrames["reticleover"] or UnitFrames.CustomFrames["companion"] or UnitFrames.CustomFrames["SmallGroup1"] or UnitFrames.CustomFrames["RaidGroup1"] or UnitFrames.CustomFrames["boss1"] or UnitFrames.CustomFrames["PetGroup1"] then
        eventManager:RegisterForEvent(moduleName, EVENT_COMBAT_EVENT, UnitFrames.OnCombatEvent)
        eventManager:AddFilterForEvent(moduleName, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, true)

        eventManager:RegisterForEvent(moduleName, EVENT_UNIT_DESTROYED, UnitFrames.OnUnitDestroyed)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTIVE_COMPANION_STATE_CHANGED, UnitFrames.ActiveCompanionStateChanged)
        eventManager:RegisterForEvent(moduleName, EVENT_FRIEND_ADDED, UnitFrames.SocialUpdateFrames)
        eventManager:RegisterForEvent(moduleName, EVENT_FRIEND_REMOVED, UnitFrames.SocialUpdateFrames)
        eventManager:RegisterForEvent(moduleName, EVENT_IGNORE_ADDED, UnitFrames.SocialUpdateFrames)
        eventManager:RegisterForEvent(moduleName, EVENT_IGNORE_REMOVED, UnitFrames.SocialUpdateFrames)
        eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_COMBAT_STATE, UnitFrames.OnPlayerCombatState)
        eventManager:RegisterForEvent(moduleName, EVENT_WEREWOLF_STATE_CHANGED, UnitFrames.OnWerewolf)
        eventManager:RegisterForEvent(moduleName, EVENT_BEGIN_SIEGE_CONTROL, UnitFrames.OnSiege)
        eventManager:RegisterForEvent(moduleName, EVENT_END_SIEGE_CONTROL, UnitFrames.OnSiege)
        eventManager:RegisterForEvent(moduleName, EVENT_LEAVE_RAM_ESCORT, UnitFrames.OnSiege)
        eventManager:RegisterForEvent(moduleName, EVENT_MOUNTED_STATE_CHANGED, UnitFrames.OnMount)
        eventManager:RegisterForEvent(moduleName, EVENT_EXPERIENCE_UPDATE, UnitFrames.OnXPUpdate)
        eventManager:RegisterForEvent(moduleName, EVENT_CHAMPION_POINT_GAINED, UnitFrames.OnChampionPointGained)
        eventManager:RegisterForEvent(moduleName, EVENT_GROUP_SUPPORT_RANGE_UPDATE, UnitFrames.OnGroupSupportRangeUpdate)
        eventManager:RegisterForEvent(moduleName, EVENT_GROUP_MEMBER_CONNECTED_STATUS, UnitFrames.OnGroupMemberConnectedStatus)
        eventManager:RegisterForEvent(moduleName, EVENT_GROUP_MEMBER_ROLE_CHANGED, UnitFrames.OnGroupMemberRoleChange)
        eventManager:RegisterForEvent(moduleName, EVENT_GROUP_UPDATE, UnitFrames.OnGroupMemberChange)
        eventManager:RegisterForEvent(moduleName, EVENT_GROUP_MEMBER_JOINED, UnitFrames.OnGroupMemberChange)
        eventManager:RegisterForEvent(moduleName, EVENT_GROUP_MEMBER_LEFT, UnitFrames.OnGroupMemberChange)
        eventManager:RegisterForEvent(moduleName, EVENT_UNIT_DEATH_STATE_CHANGED, UnitFrames.OnDeath)
        eventManager:RegisterForEvent(moduleName, EVENT_LEADER_UPDATE, UnitFrames.OnLeaderUpdate)
        eventManager:RegisterForEvent(moduleName, EVENT_BOSSES_CHANGED, UnitFrames.OnBossesChanged)

        eventManager:RegisterForEvent(moduleName, EVENT_GUILD_SELF_LEFT_GUILD, UnitFrames.SocialUpdateFrames)
        eventManager:RegisterForEvent(moduleName, EVENT_GUILD_SELF_JOINED_GUILD, UnitFrames.SocialUpdateFrames)
        eventManager:RegisterForEvent(moduleName, EVENT_GUILD_MEMBER_ADDED, UnitFrames.SocialUpdateFrames)
        eventManager:RegisterForEvent(moduleName, EVENT_GUILD_MEMBER_REMOVED, UnitFrames.SocialUpdateFrames)

        if UnitFrames.SV.CustomTargetMarker then
            eventManager:RegisterForEvent(moduleName, EVENT_TARGET_MARKER_UPDATE, UnitFrames.OnTargetMarkerUpdate)
        end

        -- Group Election Info
        UnitFrames.RegisterForGroupElectionEvents()
    end

    UnitFrames.defaultTargetNameLabel = ZO_TargetUnitFramereticleoverName

    -- Initialize coloring. This is actually needed when user does NOT want those features
    UnitFrames.TargetColorByReaction()
    UnitFrames.ReticleColorByReaction()
end

-- Update selection for target name coloring
function UnitFrames.TargetColorByReaction(value)
    -- If we have a parameter, save it
    if value ~= nil then
        UnitFrames.SV.TargetColourByReaction = value
    end
    -- If this Target name coloring is not required, revert it back to white
    if not value then
        UnitFrames.defaultTargetNameLabel:SetColor(1, 1, 1, 1)
    end
end

-- Update selection for target name coloring
function UnitFrames.ReticleColorByReaction(value)
    if value ~= nil then
        UnitFrames.SV.ReticleColourByReaction = value
    end
    -- If this Reticle coloring is not required, revert it back to white
    if not value then
        ZO_ReticleContainerReticle:SetColor(1, 1, 1, 1)
    end
end

-- Helper function to format label alignment and position
---
--- @param label table|LabelControl
--- @param isCenter boolean
--- @param centerFormat string
--- @param leftFormat string
--- @param parent object
function UnitFrames.FormatLabelAlignment(label, isCenter, centerFormat, leftFormat, parent)
    if isCenter then
        label.format = centerFormat
        label:ClearAnchors()
        label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        label:SetAnchor(CENTER, parent, CENTER, 0, 0)
    else
        label.format = leftFormat
        label:ClearAnchors()
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetAnchor(LEFT, parent, LEFT, 5, 0)
    end
end

-- Helper function to format secondary label
---
--- @param label table|LabelControl
--- @param isCenter boolean
--- @param secondaryFormat string
function UnitFrames.FormatSecondaryLabel(label, isCenter, secondaryFormat)
    label.format = isCenter and "Nothing" or secondaryFormat
end

-- Helper function to format a simple label
---
--- @param label table|LabelControl
--- @param format string
function UnitFrames.FormatSimpleLabel(label, format)
    label.format = format
end

-- Runs on the EVENT_PLAYER_ACTIVATED listener.
-- This handler fires every time the player is loaded. Used to set initial values.
---
--- @param eventId integer
--- @param initial boolean
function UnitFrames.OnPlayerActivated(eventId, initial)
    -- Reload values for player frames
    UnitFrames.ReloadValues("player")
    UnitFrames.UpdateRegen("player", STAT_MAGICKA_REGEN_COMBAT, ATTRIBUTE_MAGICKA, COMBAT_MECHANIC_FLAGS_MAGICKA)
    UnitFrames.UpdateRegen("player", STAT_STAMINA_REGEN_COMBAT, ATTRIBUTE_STAMINA, COMBAT_MECHANIC_FLAGS_STAMINA)

    -- Create UI elements for default group members frames
    if UnitFrames.DefaultFrames.SmallGroup then
        for i = 1, 12 do
            local unitTag = "group" .. i
            if DoesUnitExist(unitTag) then
                UnitFrames.DefaultFramesCreateUnitGroupControls(unitTag)
            end
        end
    end

    -- If CustomFrames are used then values will be reloaded in following function
    if UnitFrames.CustomFrames["SmallGroup1"] ~= nil or UnitFrames.CustomFrames["RaidGroup1"] ~= nil then
        UnitFrames.CustomFramesGroupUpdate()

        -- Else we need to manually scan and update DefaultFrames
    elseif UnitFrames.DefaultFrames.SmallGroup then
        for i = 1, 12 do
            local unitTag = "group" .. i
            if DoesUnitExist(unitTag) then
                UnitFrames.ReloadValues(unitTag)
            end
        end
    end

    UnitFrames.OnReticleTargetChanged(nil)
    UnitFrames.OnBossesChanged()
    UnitFrames.OnPlayerCombatState(EVENT_PLAYER_COMBAT_STATE, IsUnitInCombat("player"))
    UnitFrames.CustomFramesGroupAlpha()
    UnitFrames.CustomFramesSetupAlternative()

    -- Apply bar colors here, has to be after player init to get group roles
    UnitFrames.CustomFramesApplyColors(false)

    -- We need to call this here to clear companion/pet unit frames when entering houses/instances as they are not destroyed
    UnitFrames.CompanionUpdate()
    UnitFrames.CustomPetUpdate()
end

function UnitFrames.CustomFramesUnreferencePetControl(first)
    local last = 7
    for i = first, last do
        local unitTag = "PetGroup" .. i
        UnitFrames.CustomFrames[unitTag].unitTag = nil
        UnitFrames.CustomFrames[unitTag].control:SetHidden(true)
    end
end

function UnitFrames.CompanionUpdate()
    if UnitFrames.CustomFrames["companion"] == nil then
        return
    end
    if UnitFrames.CustomFrames["companion"].tlw == nil then
        return
    end
    local unitTag = "companion"
    if DoesUnitExist(unitTag) then
        if UnitFrames.CustomFrames[unitTag] then
            UnitFrames.CustomFrames[unitTag].control:SetHidden(false)
            UnitFrames.ReloadValues(unitTag)
        end
    else
        UnitFrames.CustomFrames[unitTag].control:SetHidden(true)
    end
end

function UnitFrames.CustomPetUpdate()
    if UnitFrames.CustomFrames["PetGroup1"] == nil then
        return
    end

    if UnitFrames.CustomFrames["PetGroup1"].tlw == nil then
        return
    end

    local petList = {}

    -- First we query all pet unitTag for existence and save them to local list
    local n = 1 -- counter used to reference custom frames. it always continuous while games unitTag could have gaps
    for i = 1, 7 do
        local unitTag = "playerpet" .. i
        if DoesUnitExist(unitTag) then
            -- Compare whitelist entries and only add this pet to the list if it is whitelisted.
            local unitName = GetUnitName(unitTag)
            local compareWhitelist = zo_strlower(unitName)
            local addPet
            for k, _ in pairs(UnitFrames.SV.whitelist) do
                k = zo_strlower(k)
                if compareWhitelist == k then
                    addPet = true
                end
            end
            if addPet then
                table_insert(petList, { ["unitTag"] = unitTag, ["unitName"] = unitName })
                -- CustomFrames
                n = n + 1
            end
        else
            -- For non-existing unitTags we will remove reference from CustomFrames table
            UnitFrames.CustomFrames[unitTag] = nil
        end
    end

    UnitFrames.CustomFramesUnreferencePetControl(n)

    table_sort(petList, function (x, y)
        return x.unitName < y.unitName
    end)

    local o = 0
    for _, v in ipairs(petList) do
        o = o + 1
        UnitFrames.CustomFrames[v.unitTag] = UnitFrames.CustomFrames["PetGroup" .. o]
        if UnitFrames.CustomFrames[v.unitTag] then
            UnitFrames.CustomFrames[v.unitTag].control:SetHidden(false)
            UnitFrames.CustomFrames[v.unitTag].unitTag = v.unitTag
            UnitFrames.ReloadValues(v.unitTag)
        end
    end
end

-- Runs on the EVENT_ACTIVE_COMPANION_STATE_CHANGED listener.
---
--- @param eventId integer
--- @param newState CompanionState
--- @param oldState CompanionState
function UnitFrames.ActiveCompanionStateChanged(eventId, newState, oldState)
    if UnitFrames.CustomFrames["companion"] == nil then
        return
    end

    local unitTag = "companion"
    UnitFrames.CustomFrames[unitTag].control:SetHidden(true)
    if DoesUnitExist(unitTag) then
        if UnitFrames.CustomFrames[unitTag] then
            UnitFrames.CompanionUpdate()
        end
    end
end

-- Runs on the EVENT_UNIT_CREATED listener.
-- Used to create DefaultFrames UI controls and request delayed CustomFrames group frame update
---
--- @param eventId integer
--- @param unitTag string
function UnitFrames.OnUnitCreated(eventId, unitTag)
    -- if LUIE.IsDevDebugEnabled() then
    --     LUIE.Debug(string_format("[%s] OnUnitCreated: %s (%s)", GetTimeString(), unitTag, GetUnitName(unitTag)))
    -- end
    -- Create on-fly UI controls for default UI group member and reread his values
    if UnitFrames.DefaultFrames.SmallGroup then
        UnitFrames.DefaultFramesCreateUnitGroupControls(unitTag)
    end
    -- If CustomFrames are used then values for unitTag will be reloaded in delayed full group update
    if UnitFrames.CustomFrames["SmallGroup1"] ~= nil or UnitFrames.CustomFrames["RaidGroup1"] ~= nil then
        -- Make sure we do not try to update bars on this unitTag before full group update is complete
        if "group" == (zo_strsub(unitTag, 0, 5)) then
            UnitFrames.CustomFrames[unitTag] = nil
        end
        -- We should avoid calling full update on CustomFrames too often
        if not g_PendingUpdate.Group.flag then
            g_PendingUpdate.Group.flag = true
            eventManager:RegisterForUpdate(g_PendingUpdate.Group.name, g_PendingUpdate.Group.delay, UnitFrames.CustomFramesGroupUpdate)
        end
        -- Else we need to manually update this unitTag in UnitFrames.DefaultFrames
    elseif UnitFrames.DefaultFrames.SmallGroup then
        UnitFrames.ReloadValues(unitTag)
    end

    if UnitFrames.CustomFrames["PetGroup1"] ~= nil then
        if "playerpet" == (zo_strsub(unitTag, 0, 9)) then
            UnitFrames.CustomFrames[unitTag] = nil
        end
        UnitFrames.CustomPetUpdate()
    end
end

-- Runs on the EVENT_UNIT_DESTROYED listener.
-- Used to request delayed CustomFrames group frame update
---
--- @param eventId integer
--- @param unitTag string
function UnitFrames.OnUnitDestroyed(eventId, unitTag)
    -- if LUIE.IsDevDebugEnabled() then
    --     LUIE.Debug(string_format("[%s] OnUnitDestroyed: %s (%s)", GetTimeString(), unitTag, GetUnitName(unitTag)))
    -- end
    -- Make sure we do not try to update bars on this unitTag before full group update is complete
    if "group" == (zo_strsub(unitTag, 0, 5)) then
        UnitFrames.CustomFrames[unitTag] = nil
    end
    -- We should avoid calling full update on CustomFrames too often
    if not g_PendingUpdate.Group.flag then
        g_PendingUpdate.Group.flag = true
        eventManager:RegisterForUpdate(g_PendingUpdate.Group.name, g_PendingUpdate.Group.delay, UnitFrames.CustomFramesGroupUpdate)
    end

    if "playerpet" == (zo_strsub(unitTag, 0, 9)) then
        UnitFrames.CustomFrames[unitTag] = nil
    end

    if UnitFrames.CustomFrames["PetGroup1"] ~= nil then
        UnitFrames.CustomPetUpdate()
    end
end

-- Runs on the EVENT_TARGET_CHANGE listener.
-- This handler fires every time the someone target changes.
-- This function is needed in case the player teleports via Way Shrine
---
--- @param eventId integer
--- @param unitTag string
function UnitFrames.OnTargetChange(eventId, unitTag)
    if unitTag ~= "player" then
        return
    end
    UnitFrames.OnReticleTargetChanged(eventId)
end

-- Runs on the EVENT_RETICLE_TARGET_CHANGED listener.
-- This handler fires every time the player's reticle target changes.
-- Used to read initial values of target's health and shield.
function UnitFrames.OnReticleTargetChanged(eventCode)
    if DoesUnitExist("reticleover") then
        UnitFrames.ReloadValues("reticleover")

        local isWithinRange = IsUnitInGroupSupportRange("reticleover")

        -- Now select appropriate custom color to target name and (possibly) reticle
        local color, reticle_color
        local interactableCheck = false
        local reactionType = GetUnitReaction("reticleover")
        local attackable = IsUnitAttackable("reticleover")
        -- Select color accordingly to reactionType, attackable and interactable
        if reactionType == UNIT_REACTION_HOSTILE then
            color = UnitFrames.SV.Target_FontColour_Hostile
            reticle_color = attackable and UnitFrames.SV.Target_FontColour_Hostile or UnitFrames.SV.Target_FontColour
            interactableCheck = true
        elseif reactionType == UNIT_REACTION_PLAYER_ALLY then
            color = UnitFrames.SV.Target_FontColour_FriendlyPlayer
            reticle_color = UnitFrames.SV.Target_FontColour_FriendlyPlayer
        elseif attackable and reactionType ~= UNIT_REACTION_HOSTILE then -- those are neutral targets that can become hostile on attack
            color = UnitFrames.SV.Target_FontColour
            reticle_color = color
        else
            -- Rest cases are ally/friendly/npc, and with possibly interactable
            color = (reactionType == UNIT_REACTION_FRIENDLY or reactionType == UNIT_REACTION_NPC_ALLY) and UnitFrames.SV.Target_FontColour_FriendlyNPC or UnitFrames.SV.Target_FontColour
            reticle_color = color
            interactableCheck = true
        end

        -- Here we need to check if interaction is possible, and then rewrite reticle_color variable
        if interactableCheck then
            local interactableAction = GetGameCameraInteractableActionInfo()
            -- Action, interactableName, interactionBlocked, isOwned, additionalInfo, context
            if interactableAction ~= nil then
                reticle_color = UnitFrames.SV.ReticleColour_Interact
            end
        end

        -- Is current target Critter? In Update 6 they all have 9 health
        local isCritter = (UnitFrames.savedHealth.reticleover[3] <= 9)
        local isGuard = IsUnitInvulnerableGuard("reticleover")

        -- Hide custom label on Default Frames for critters.
        if UnitFrames.DefaultFrames.reticleover[COMBAT_MECHANIC_FLAGS_HEALTH] then
            UnitFrames.DefaultFrames.reticleover[COMBAT_MECHANIC_FLAGS_HEALTH].label:SetHidden(isCritter)
            UnitFrames.DefaultFrames.reticleover[COMBAT_MECHANIC_FLAGS_HEALTH].label:SetHidden(isGuard)
        end

        -- Update level display based off our setting for Champion Points
        if UnitFrames.DefaultFrames.reticleover.isPlayer then
            UnitFrames.UpdateDefaultLevelTarget()
        end

        -- Update color of default target if requested
        if UnitFrames.SV.TargetColourByReaction then
            UnitFrames.defaultTargetNameLabel:SetColor(color[1], color[2], color[3], isWithinRange and 1 or 0.5)
        end
        if UnitFrames.SV.ReticleColourByReaction then
            ZO_ReticleContainerReticle:SetColor(reticle_color[1], reticle_color[2], reticle_color[3], 1)
        end

        -- And color of custom target name always. Also change 'labelOne' for critters
        if UnitFrames.CustomFrames["reticleover"] then
            UnitFrames.CustomFrames["reticleover"].hostile = (reactionType == UNIT_REACTION_HOSTILE) and UnitFrames.SV.TargetEnableSkull
            UnitFrames.CustomFrames["reticleover"].skull:SetHidden(not UnitFrames.CustomFrames["reticleover"].hostile or (UnitFrames.savedHealth.reticleover[1] == 0) or (100 * UnitFrames.savedHealth.reticleover[1] / UnitFrames.savedHealth.reticleover[3] > UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH].threshold))
            UnitFrames.CustomFrames["reticleover"].name:SetColor(color[1], color[2], color[3], 1)
            UnitFrames.CustomFrames["reticleover"].className:SetColor(color[1], color[2], color[3], 1)
            if isCritter then
                UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH].labelOne:SetText(" - Critter - ")
            end
            if isGuard then
                UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH].labelOne:SetText(" - Invulnerable - ")
            end
            UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH].labelTwo:SetHidden(isCritter or isGuard or not UnitFrames.CustomFrames["reticleover"].dead:IsHidden())

            if IsUnitReincarnating("reticleover") then
                UnitFrames.CustomFramesSetDeadLabel(UnitFrames.CustomFrames["reticleover"], strResSelf)
                eventManager:RegisterForUpdate(moduleName .. "Res" .. "reticleover", 100, function ()
                    UnitFrames.ResurrectionMonitor("reticleover")
                end)
            end

            -- Finally show custom target frame
            UnitFrames.CustomFrames["reticleover"].control:SetHidden(false)
            if UnitFrames.SV.QuickHideDead then
                local isMonster = IsGameCameraInteractableUnitMonster()
                local isNPC = reactionType == UNIT_REACTION_NEUTRAL
                    or reactionType == UNIT_REACTION_FRIENDLY
                    or reactionType == UNIT_REACTION_NPC_ALLY
                    or (reactionType == UNIT_REACTION_HOSTILE and isMonster)
                local shouldHide = IsUnitDead("reticleover") and isNPC
                -- if LUIE.IsDevDebugEnabled() then
                --     LUIE.Debug("reactionType:%d isMonster:%s isNPC:%s", reactionType, tostring(isMonster), tostring(isNPC))
                -- end
                UnitFrames.CustomFrames["reticleover"].control:SetHidden(shouldHide)
            end
        end

        -- Unhide second target frame only for player enemies
        if UnitFrames.CustomFrames["AvaPlayerTarget"] then
            UnitFrames.CustomFrames["AvaPlayerTarget"].control:SetHidden(not (UnitFrames.CustomFrames["AvaPlayerTarget"].isPlayer and (reactionType == UNIT_REACTION_HOSTILE) and not IsUnitDead("reticleover")))
        end

        -- Update position of default target class icon
        if UnitFrames.SV.TargetShowClass and UnitFrames.DefaultFrames.reticleover.isPlayer then
            UnitFrames.DefaultFrames.reticleover.classIcon:ClearAnchors()
            UnitFrames.DefaultFrames.reticleover.classIcon:SetAnchor(TOPRIGHT, ZO_TargetUnitFramereticleoverTextArea, TOPLEFT, UnitFrames.DefaultFrames.reticleover.isChampion and -32 or -2, -4)
        else
            UnitFrames.DefaultFrames.reticleover.classIcon:SetHidden(true)
        end
        -- Instead just make sure it is hidden
        if not UnitFrames.SV.TargetShowFriend or not UnitFrames.DefaultFrames.reticleover.isPlayer then
            UnitFrames.DefaultFrames.reticleover.friendIcon:SetHidden(true)
        end

        UnitFrames.CustomFramesApplyReactionColor(UnitFrames.DefaultFrames.reticleover.isPlayer)

        -- Target is invalid: reset stored values to defaults
    else
        UnitFrames.savedHealth.reticleover = { 1, 1, 1, 0, 0 }

        --[[ Removed due to causing custom UI elements to abruptly fade out. Left here in case there is any reason to re-enable.
        if UnitFrames.DefaultFrames.reticleover[COMBAT_MECHANIC_FLAGS_HEALTH] then
            UnitFrames.DefaultFrames.reticleover[COMBAT_MECHANIC_FLAGS_HEALTH].label:SetHidden(true)
        end
        UnitFrames.DefaultFrames.reticleover.classIcon:SetHidden(true)
        UnitFrames.DefaultFrames.reticleover.friendIcon:SetHidden(true)
        ]]
        --

        -- Hide target frame bars control, LTE will clear buffs and remove then itself, SpellCastBuffs should continue to display ground buffs
        if UnitFrames.CustomFrames["reticleover"] then
            UnitFrames.CustomFrames["reticleover"].hostile = false
            UnitFrames.CustomFrames["reticleover"].skull:SetHidden(true)
            UnitFrames.CustomFrames["reticleover"].control:SetHidden(true) -- UnitFrames.CustomFrames["reticleover"].canHide )
        end
        -- Hide second target frame
        if UnitFrames.CustomFrames["AvaPlayerTarget"] then
            UnitFrames.CustomFrames["AvaPlayerTarget"].control:SetHidden(true) -- UnitFrames.CustomFrames["AvaPlayerTarget"].canHide )
        end

        -- Revert back the color of reticle to white
        if UnitFrames.SV.ReticleColourByReaction then
            ZO_ReticleContainerReticle:SetColor(1, 1, 1, 1)
        end
    end

    -- Finally if user does not want to have default target frame we have to hide it here all the time
    if not UnitFrames.DefaultFrames.reticleover[COMBAT_MECHANIC_FLAGS_HEALTH] and UnitFrames.SV.DefaultFramesNewTarget == 1 then
        ZO_TargetUnitFramereticleover:SetHidden(true)
    end
end

-- Runs on the EVENT_DISPOSITION_UPDATE listener.
-- Used to reread parameters of the target
function UnitFrames.OnDispositionUpdate(eventCode, unitTag)
    if unitTag == "reticleover" then
        UnitFrames.OnReticleTargetChanged(eventCode)
    end
end

-- Used to query initial values and display them in corresponding control
function UnitFrames.ReloadValues(unitTag)
    -- Build list of powerTypes this unitTag has in both DefaultFrames and CustomFrames
    local powerTypes = {}
    if UnitFrames.DefaultFrames[unitTag] then
        for powerType, _ in pairs(UnitFrames.DefaultFrames[unitTag]) do
            if type(powerType) == "number" then
                powerTypes[powerType] = true
            end
        end
    end
    if UnitFrames.CustomFrames[unitTag] then
        for powerType, _ in pairs(UnitFrames.CustomFrames[unitTag]) do
            if type(powerType) == "number" then
                powerTypes[powerType] = true
            end
        end
    end
    if UnitFrames.AvaCustFrames[unitTag] then
        for powerType, _ in pairs(UnitFrames.AvaCustFrames[unitTag]) do
            if type(powerType) == "number" then
                powerTypes[powerType] = true
            end
        end
    end

    -- For all attributes query its value and force updating
    for powerType, _ in pairs(powerTypes) do
        local powerValue, powerMax, powerEffectiveMax = GetUnitPower(unitTag, powerType)
        UnitFrames.OnPowerUpdate(unitTag, nil, powerType, powerValue, powerMax, powerEffectiveMax)
    end

    -- Update shield value on controls; this will also update health attribute value, again.
    local shield, _ = GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)
    UnitFrames.UpdateShield(unitTag, shield or 0, nil)

    -- Update trauma value on controls
    local trauma, _ = GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_TRAUMA, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)
    UnitFrames.UpdateTrauma(unitTag, trauma or 0, nil)

    -- Now we need to update Name labels, classIcon
    UnitFrames.UpdateStaticControls(UnitFrames.DefaultFrames[unitTag])
    UnitFrames.UpdateStaticControls(UnitFrames.CustomFrames[unitTag])
    UnitFrames.UpdateStaticControls(UnitFrames.AvaCustFrames[unitTag])

    -- Get regen/degen values
    UnitFrames.UpdateRegen(unitTag, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)

    -- Get initial stats
    UnitFrames.UpdateStat(unitTag, STAT_ARMOR_RATING, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)
    UnitFrames.UpdateStat(unitTag, STAT_POWER, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)

    if unitTag == "player" then
        UnitFrames.statFull[COMBAT_MECHANIC_FLAGS_HEALTH] = (UnitFrames.savedHealth.player[1] == UnitFrames.savedHealth.player[3])
        UnitFrames.CustomFramesApplyInCombat()
    end
end

--[[ -- Helper tables for next function
-- I believe this is mostly deprecated, as we no longer want to show the level of anything but a player target
local HIDE_LEVEL_REACTIONS =
{
    [UNIT_REACTION_FRIENDLY] = true,
    [UNIT_REACTION_NPC_ALLY] = true,
}
-- I believe this is mostly deprecated, as we no longer want to show the level of anything but a player target
local HIDE_LEVEL_TYPES =
{
    [UNIT_TYPE_SIEGEWEAPON] = true,
    [UNIT_TYPE_INTERACTFIXTURE] = true,
    [UNIT_TYPE_INTERACTOBJ] = true,
    [UNIT_TYPE_SIMPLEINTERACTFIXTURE] = true,
    [UNIT_TYPE_SIMPLEINTERACTOBJ] = true,
}
 ]]
local function IsGuildMate(unitTag)
    local displayName = GetUnitDisplayName(unitTag)
    if displayName == UnitFrames.playerDisplayName then
        return
    end
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        if GetGuildMemberIndexFromDisplayName(guildId, displayName) ~= nil then
            return true
        end
    end
    return false
end

-- Updates text labels, classIcon, etc
function UnitFrames.UpdateStaticControls(unitFrame)
    if unitFrame == nil then
        return
    end

    -- Get the unitTag to determine the method of name display
    local DisplayOption
    if unitFrame.unitTag == "player" then
        DisplayOption = UnitFrames.SV.DisplayOptionsPlayer
    elseif unitFrame.unitTag == "reticleover" then
        DisplayOption = UnitFrames.SV.DisplayOptionsTarget
    else
        DisplayOption = UnitFrames.SV.DisplayOptionsGroupRaid
    end

    unitFrame.isPlayer = IsUnitPlayer(unitFrame.unitTag)
    unitFrame.isChampion = IsUnitChampion(unitFrame.unitTag)
    unitFrame.isLevelCap = (GetUnitChampionPoints(unitFrame.unitTag) == UnitFrames.MaxChampionPoint)
    unitFrame.avaRankValue = GetUnitAvARank(unitFrame.unitTag)

    -- First update roleIcon, classIcon and friendIcon, so then we can set maximal length of name label
    if unitFrame.roleIcon ~= nil then
        local role = GetGroupMemberSelectedRole(unitFrame.unitTag)
        -- d (unitFrame.unitTag.." - "..role)
        local unitRole = LUIE.GetRoleIcon(role)
        unitFrame.roleIcon:SetTexture(unitRole)
    end
    -- If unitFrame has difficulty stars
    if unitFrame.star1 ~= nil and unitFrame.star2 ~= nil and unitFrame.star3 ~= nil then
        local unitDifficulty = GetUnitDifficulty(unitFrame.unitTag)
        unitFrame.star1:SetHidden(unitDifficulty < 2)
        unitFrame.star2:SetHidden(unitDifficulty < 3)
        unitFrame.star3:SetHidden(unitDifficulty < 4)
    end
    -- If unitFrame has unit classIcon control
    if unitFrame.classIcon ~= nil then
        local unitDifficulty = GetUnitDifficulty(unitFrame.unitTag)
        local classIcon = LUIE.GetClassIcon(GetUnitClassId(unitFrame.unitTag))
        local showClass = (unitFrame.isPlayer and classIcon ~= nil) or (unitDifficulty > 1)
        if unitFrame.isPlayer then
            unitFrame.classIcon:SetTexture(classIcon)
        elseif unitDifficulty == 2 then
            unitFrame.classIcon:SetTexture("LuiExtended/media/unitframes/unitframes_level_elite.dds")
        elseif unitDifficulty >= 3 then
            unitFrame.classIcon:SetTexture("LuiExtended/media/unitframes/unitframes_level_elite.dds")
        end
        if unitFrame.unitTag == "player" then
            unitFrame.classIcon:SetHidden(not UnitFrames.SV.PlayerEnableYourname)
        else
            unitFrame.classIcon:SetHidden(not showClass)
        end
    end
    -- unitFrame frame also have a text label for class name: right now only target
    if unitFrame.className then
        local classId = GetUnitClassId(unitFrame.unitTag)
        local className = zo_strformat(GetString(SI_CLASS_NAME), GetClassName(GENDER_MALE, classId))
        local showClass = unitFrame.isPlayer and className ~= nil and UnitFrames.SV.TargetEnableClass
        if showClass then
            local classNameText = StringOnlyGSUB(className, "%^%a+", "")
            unitFrame.className:SetText(classNameText)
        end
        -- this condition is somehow extra, but let keep it to be in consistency with all others
        if unitFrame.unitTag == "player" then
            unitFrame.className:SetHidden(not UnitFrames.SV.PlayerEnableYourname)
        else
            unitFrame.className:SetHidden(not showClass)
        end
    end
    -- If unitFrame has unit classIcon control
    if unitFrame.friendIcon ~= nil then
        local isIgnored = unitFrame.isPlayer and IsUnitIgnored(unitFrame.unitTag)
        local isFriend = unitFrame.isPlayer and IsUnitFriend(unitFrame.unitTag)
        local isGuild = unitFrame.isPlayer and not isFriend and not isIgnored and IsGuildMate(unitFrame.unitTag)
        if isIgnored or isFriend or isGuild then
            unitFrame.friendIcon:SetTexture(isIgnored and "LuiExtended/media/unitframes/unitframes_social_ignore.dds" or isFriend and "/esoui/art/campaign/campaignbrowser_friends.dds" or "/esoui/art/campaign/campaignbrowser_guild.dds")
            unitFrame.friendIcon:SetHidden(false)
        else
            unitFrame.friendIcon:SetHidden(true)
        end
    end
    -- If unitFrame has unit name label control
    if unitFrame.name ~= nil then
        -- Only apply this formatting to non-group frames
        if unitFrame.name:GetParent() == unitFrame.topInfo and unitFrame.unitTag == "reticleover" then
            local width = unitFrame.topInfo:GetWidth()
            if unitFrame.classIcon then
                width = width - unitFrame.classIcon:GetWidth()
            end
            if unitFrame.isPlayer then
                if unitFrame.friendIcon then
                    width = width - unitFrame.friendIcon:GetWidth()
                end
                if unitFrame.level then
                    width = width - 2.3 * unitFrame.levelIcon:GetWidth()
                end
            end
            unitFrame.name:SetWidth(width)
        end

        -- Handle name text formatting
        local nameText
        if unitFrame.isPlayer and DisplayOption == 3 then
            nameText = GetUnitName(unitFrame.unitTag) .. " " .. GetUnitDisplayName(unitFrame.unitTag)
        elseif unitFrame.isPlayer and DisplayOption == 1 then
            nameText = GetUnitDisplayName(unitFrame.unitTag)
        else
            nameText = GetUnitName(unitFrame.unitTag)
        end

        -- Add target marker icon if present
        if UnitFrames.SV.CustomTargetMarker then
            local targetMarkerType = GetUnitTargetMarkerType(unitFrame.unitTag)
            if targetMarkerType ~= TARGET_MARKER_TYPE_NONE then
                local iconPath = ZO_GetPlatformTargetMarkerIcon(targetMarkerType)
                if iconPath then
                    nameText = FormatTextWithIcon(iconPath, nameText)
                end
            end
        end

        unitFrame.name:SetText(nameText)
    end
    -- If unitFrame has level label control
    if unitFrame.level ~= nil then
        -- Show level for players and non-friendly NPCs
        local showLevel = unitFrame.isPlayer -- or not ( IsUnitInvulnerableGuard( unitFrame.unitTag ) or HIDE_LEVEL_TYPES[GetUnitType( unitFrame.unitTag )] or HIDE_LEVEL_REACTIONS[GetUnitReaction( unitFrame.unitTag )] ) -- No longer need to display level for anything but players
        if showLevel then
            if unitFrame.unitTag == "player" or unitFrame.unitTag == "reticleover" then
                unitFrame.levelIcon:ClearAnchors()
                unitFrame.levelIcon:SetAnchor(LEFT, unitFrame.topInfo, LEFT, unitFrame.name:GetTextWidth() + 1, 0)
            end
            unitFrame.levelIcon:SetTexture(unitFrame.isChampion and "LuiExtended/media/unitframes/unitframes_level_champion.dds" or "LuiExtended/media/unitframes/unitframes_level_normal.dds")
            -- Level label should be already anchored
            unitFrame.level:SetText(tostring(unitFrame.isChampion and GetUnitChampionPoints(unitFrame.unitTag) or GetUnitLevel(unitFrame.unitTag)))
        end
        if unitFrame.unitTag == "player" then
            unitFrame.levelIcon:SetHidden(not UnitFrames.SV.PlayerEnableYourname)
            unitFrame.level:SetHidden(not UnitFrames.SV.PlayerEnableYourname)
        else
            unitFrame.levelIcon:SetHidden(not showLevel)
            unitFrame.level:SetHidden(not showLevel)
        end
    end
    local savedTitle
    -- If unitFrame has unit title label control
    if unitFrame.title ~= nil then
        local title = GetUnitCaption(unitFrame.unitTag)
        local ava = ""
        if unitFrame.isPlayer then
            title = GetUnitTitle(unitFrame.unitTag)
            ava = GetAvARankName(GetUnitGender(unitFrame.unitTag), unitFrame.avaRankValue)
            if UnitFrames.SV.TargetEnableRank and not UnitFrames.SV.TargetEnableTitle then
                title = (ava ~= "") and ava or ""
            elseif UnitFrames.SV.TargetEnableTitle and not UnitFrames.SV.TargetEnableRank then
                title = (title ~= "") and title or ""
            elseif UnitFrames.SV.TargetEnableTitle and UnitFrames.SV.TargetEnableRank then
                if UnitFrames.SV.TargetTitlePriority == "Title" then
                    title = (title ~= "") and title or (ava ~= "") and ava or ""
                else
                    title = (ava ~= "") and ava or (title ~= "") and title or ""
                end
            end
        end
        title = title or ""
        local titletext = StringOnlyGSUB(title, "%^%a+", "")
        unitFrame.title:SetText(titletext)
        if unitFrame.unitTag == "reticleover" then
            unitFrame.title:SetHidden(not UnitFrames.SV.TargetEnableRank and not UnitFrames.SV.TargetEnableTitle)
        end

        if title == "" then
            savedTitle = ""
        end
    end
    -- If unitFrame has unit AVA rank control
    if unitFrame.avaRank ~= nil then
        if unitFrame.isPlayer then
            unitFrame.avaRankIcon:SetTexture(GetAvARankIcon(unitFrame.avaRankValue))
            local alliance = GetUnitAlliance(unitFrame.unitTag)
            local color = GetAllianceColor(alliance)
            unitFrame.avaRankIcon:SetColor(color.r, color.g, color.b)

            if unitFrame.unitTag == "reticleover" and UnitFrames.SV.TargetEnableRankIcon then
                unitFrame.avaRank:SetText(tostring(unitFrame.avaRankValue))
                if unitFrame.avaRankValue > 0 then
                    unitFrame.avaRank:SetHidden(false)
                else
                    unitFrame.avaRank:SetHidden(true)
                end
                unitFrame.avaRankIcon:SetHidden(false)
            else
                unitFrame.avaRank:SetHidden(true)
                unitFrame.avaRankIcon:SetHidden(true)
            end
        else
            unitFrame.avaRank:SetHidden(true)
            unitFrame.avaRankIcon:SetHidden(true)
        end
    end
    -- Reanchor buffs if title changes
    if unitFrame.buffs and unitFrame.unitTag == "reticleover" then
        if UnitFrames.SV.PlayerFrameOptions ~= 1 then
            if (not UnitFrames.SV.TargetEnableRank and not UnitFrames.SV.TargetEnableTitle and not UnitFrames.SV.TargetEnableRankIcon) or (savedTitle == "" and not UnitFrames.SV.TargetEnableRankIcon and unitFrame.isPlayer) or (savedTitle == "" and not unitFrame.isPlayer) then
                unitFrame.debuffs:ClearAnchors()
                unitFrame.debuffs:SetAnchor(TOP, unitFrame.control, BOTTOM, 0, 5)
            else
                unitFrame.debuffs:ClearAnchors()
                unitFrame.debuffs:SetAnchor(TOP, unitFrame.buffAnchor, BOTTOM, 0, 5)
            end
        else
            if (not UnitFrames.SV.TargetEnableRank and not UnitFrames.SV.TargetEnableTitle and not UnitFrames.SV.TargetEnableRankIcon) or (savedTitle == "" and not UnitFrames.SV.TargetEnableRankIcon and unitFrame.isPlayer) or (savedTitle == "" and not unitFrame.isPlayer) then
                unitFrame.buffs:ClearAnchors()
                unitFrame.buffs:SetAnchor(TOP, unitFrame.control, BOTTOM, 0, 5)
            else
                unitFrame.buffs:ClearAnchors()
                unitFrame.buffs:SetAnchor(TOP, unitFrame.buffAnchor, BOTTOM, 0, 5)
            end
        end
    end
    -- If unitFrame has dead/offline indicator, then query its state and act accordingly
    if unitFrame.dead ~= nil then
        if not IsUnitOnline(unitFrame.unitTag) then
            UnitFrames.OnGroupMemberConnectedStatus(nil, unitFrame.unitTag, false)
        elseif IsUnitDead(unitFrame.unitTag) then
            UnitFrames.OnDeath(nil, unitFrame.unitTag, true)
        else
            UnitFrames.CustomFramesSetDeadLabel(unitFrame, nil)
        end
    end
    -- Finally set transparency for group frames that has .control field
    if unitFrame.unitTag and "group" == (zo_strsub(unitFrame.unitTag, 0, 5)) and unitFrame.control then
        unitFrame.control:SetAlpha(IsUnitInGroupSupportRange(unitFrame.unitTag) and (UnitFrames.SV.GroupAlpha * 0.01) or (UnitFrames.SV.GroupAlpha * 0.01) / 2)
    end
end

-- Updates title for unit if changed, and also re-anchors buffs or toggles display on/off if the unitTag had no title selected previously
-- Called from EVENT_TITLE_UPDATE & EVENT_RANK_POINT_UPDATE
function UnitFrames.TitleUpdate(eventCode, unitTag)
    UnitFrames.UpdateStaticControls(UnitFrames.DefaultFrames[unitTag])
    UnitFrames.UpdateStaticControls(UnitFrames.CustomFrames[unitTag])
    UnitFrames.UpdateStaticControls(UnitFrames.AvaCustFrames[unitTag])
end

-- Forces to reload static information on unit frames.
-- Called from EVENT_LEVEL_UPDATE and EVENT_VETERAN_RANK_UPDATE listeners.
function UnitFrames.OnLevelUpdate(eventCode, unitTag, level)
    UnitFrames.UpdateStaticControls(UnitFrames.DefaultFrames[unitTag])
    UnitFrames.UpdateStaticControls(UnitFrames.CustomFrames[unitTag])
    UnitFrames.UpdateStaticControls(UnitFrames.AvaCustFrames[unitTag])

    -- For Custom Player Frame we have to setup experience bar
    if unitTag == "player" and UnitFrames.CustomFrames["player"] and UnitFrames.CustomFrames["player"].Experience then
        UnitFrames.CustomFramesSetupAlternative()
    end
end

-- Runs on the EVENT_PLAYER_COMBAT_STATE listener.
-- This handler fires every time player enters or leaves combat
function UnitFrames.OnPlayerCombatState(eventCode, inCombat)
    UnitFrames.statFull.combat = not inCombat
    UnitFrames.CustomFramesApplyInCombat()
end

-- Runs on the EVENT_WEREWOLF_STATE_CHANGED listener.
function UnitFrames.OnWerewolf(eventCode, werewolf)
    UnitFrames.CustomFramesSetupAlternative(werewolf, false, false)
end

-- Runs on the EVENT_BEGIN_SIEGE_CONTROL, EVENT_END_SIEGE_CONTROL, EVENT_LEAVE_RAM_ESCORT listeners.
function UnitFrames.OnSiege(eventCode)
    UnitFrames.CustomFramesSetupAlternative(false, nil, false)
end

-- Runs on the EVENT_MOUNTED_STATE_CHANGED listener.
function UnitFrames.OnMount(eventCode, mounted)
    UnitFrames.CustomFramesSetupAlternative(IsPlayerInWerewolfForm(), false, mounted)
end

-- Runs on the EVENT_EXPERIENCE_UPDATE listener.
function UnitFrames.OnXPUpdate(eventCode, unitTag, currentExp, maxExp, reason)
    if unitTag ~= "player" or not UnitFrames.CustomFrames["player"] then
        return
    end
    if UnitFrames.CustomFrames["player"].isChampion then
        -- Query for Veteran and Champion XP not more then once every 5 seconds
        if not g_PendingUpdate.VeteranXP.flag then
            g_PendingUpdate.VeteranXP.flag = true
            eventManager:RegisterForUpdate(g_PendingUpdate.VeteranXP.name, g_PendingUpdate.VeteranXP.delay, UnitFrames.UpdateVeteranXP)
        end
    elseif UnitFrames.CustomFrames["player"].Experience then
        UnitFrames.CustomFrames["player"].Experience.bar:SetValue(currentExp)
    end
end

-- Helper function that updates Champion XP bar. Called from event listener with 5 sec delay
function UnitFrames.UpdateVeteranXP()
    -- Unregister update function
    eventManager:UnregisterForUpdate(g_PendingUpdate.VeteranXP.name)

    if UnitFrames.CustomFrames["player"] then
        if UnitFrames.CustomFrames["player"].Experience then
            UnitFrames.CustomFrames["player"].Experience.bar:SetValue(GetUnitChampionPoints("player"))
        elseif UnitFrames.CustomFrames["player"].ChampionXP then
            local enlightenedPool = 4 * GetEnlightenedPool()
            local xp = GetPlayerChampionXP()
            local maxBar = GetNumChampionXPInChampionPoint(GetPlayerChampionPointsEarned())
            -- If Champion Points are maxed out then fill the bar all the way up.
            if maxBar == nil then
                maxBar = xp
            end
            local enlightenedBar = enlightenedPool + xp
            if enlightenedBar > maxBar then
                enlightenedBar = maxBar
            end -- If the enlightenment pool extends past the current level then cap it at the maximum bar value.

            UnitFrames.CustomFrames["player"].ChampionXP.bar:SetValue(xp)
            UnitFrames.CustomFrames["player"].ChampionXP.enlightenment:SetValue(enlightenedBar)
        end
    end
    -- Clear local flag
    g_PendingUpdate.VeteranXP.flag = false
end

-- Runs on the EVENT_GROUP_SUPPORT_RANGE_UPDATE listener.
function UnitFrames.OnGroupSupportRangeUpdate(eventCode, unitTag, status)
    if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag].control then
        UnitFrames.CustomFrames[unitTag].control:SetAlpha(status and (UnitFrames.SV.GroupAlpha * 0.01) or (UnitFrames.SV.GroupAlpha * 0.01) / 2)
    end
end

-- Runs on the EVENT_GROUP_MEMBER_CONNECTED_STATUS listener.
function UnitFrames.OnGroupMemberConnectedStatus(eventCode, unitTag, isOnline)
    if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag].dead then
        UnitFrames.CustomFramesSetDeadLabel(UnitFrames.CustomFrames[unitTag], isOnline and nil or strOffline)
    end
    if isOnline and (UnitFrames.SV.ColorRoleGroup or UnitFrames.SV.ColorRoleRaid) then
        UnitFrames.CustomFramesApplyColors(false)
    end
end

function UnitFrames.OnGroupMemberRoleChange(eventCode, unitTag, dps, healer, tank)
    if UnitFrames.CustomFrames[unitTag] then
        if UnitFrames.SV.ColorRoleGroup or UnitFrames.SV.ColorRoleRaid then
            UnitFrames.CustomFramesApplyColorsSingle(unitTag)
        end
        UnitFrames.ReloadValues(unitTag)
        UnitFrames.CustomFramesApplyLayoutGroup(false)
        UnitFrames.CustomFramesApplyLayoutRaid(false)
    end
end

function UnitFrames.OnGroupMemberChange(eventCode, memberName)
    zo_callLater(function ()
                     UnitFrames.CustomFramesApplyColors(false)
                 end, 200)
end

-- Runs on the EVENT_UNIT_DEATH_STATE_CHANGED listener.
-- This handler fires every time a valid unitTag dies or is resurrected
function UnitFrames.OnDeath(eventCode, unitTag, isDead)
    if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag].dead then
        UnitFrames.ResurrectionMonitor(unitTag)
    end

    -- Manually hide regen/degen animation as well as stat-changing icons, because game does not always issue corresponding event before unit is dead
    if isDead and UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH] then
        local thb = UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH] -- not a backdrop
        -- 1. Regen/degen
        UnitFrames.DisplayRegen(thb.regen1, false)
        UnitFrames.DisplayRegen(thb.regen2, false)
        UnitFrames.DisplayRegen(thb.degen1, false)
        UnitFrames.DisplayRegen(thb.degen2, false)
        -- 2. Stats
        if thb.stat then
            for _, statControls in pairs(thb.stat) do
                if statControls.dec then
                    statControls.dec:SetHidden(true)
                end
                if statControls.inc then
                    statControls.inc:SetHidden(true)
                end
            end
        end
    end
end

function UnitFrames.ResurrectionMonitor(unitTag)
    eventManager:UnregisterForUpdate(moduleName .. "Res" .. unitTag)

    -- Check to make sure this unit exists & the custom frame exists
    if not DoesUnitExist(unitTag) then
        return
    end
    if not UnitFrames.CustomFrames[unitTag] then
        return
    end

    if IsUnitDead(unitTag) then
        if IsUnitBeingResurrected(unitTag) then
            UnitFrames.CustomFramesSetDeadLabel(UnitFrames.CustomFrames[unitTag], UnitFrames.isRaid and strResCastRaid or strResCast)
        elseif DoesUnitHaveResurrectPending(unitTag) then
            UnitFrames.CustomFramesSetDeadLabel(UnitFrames.CustomFrames[unitTag], UnitFrames.isRaid and strResPendingRaid or strResPending)
        else
            UnitFrames.CustomFramesSetDeadLabel(UnitFrames.CustomFrames[unitTag], strDead)
        end
        eventManager:RegisterForUpdate(moduleName .. "Res" .. unitTag, 100, function ()
            UnitFrames.ResurrectionMonitor(unitTag)
        end)
    elseif IsUnitReincarnating(unitTag) then
        UnitFrames.CustomFramesSetDeadLabel(UnitFrames.CustomFrames[unitTag], strResSelf)
        eventManager:RegisterForUpdate(moduleName .. "Res" .. unitTag, 100, function ()
            UnitFrames.ResurrectionMonitor(unitTag)
        end)
    else
        UnitFrames.CustomFramesSetDeadLabel(UnitFrames.CustomFrames[unitTag], nil)
    end
end

-- Runs on the EVENT_LEADER_UPDATE listener.
--- @param eventId integer
--- @param leaderTag string
function UnitFrames.OnLeaderUpdate(eventId, leaderTag)
    UnitFrames.CustomFramesApplyLayoutGroup(false)
    UnitFrames.CustomFramesApplyLayoutRaid(false)
end

-- Runs on the EVENT_TARGET_MARKER_UPDATE listener.
--- @param eventId integer
function UnitFrames.OnTargetMarkerUpdate(eventId)
    -- Define unit frame types to check
    local unitTypes =
    {
        "player",
        "reticleover",
        "companion",
        "SmallGroup",
        "RaidGroup",
        "boss",
        "AvaPlayerTarget",
        "PetGroup"
    }

    -- Update each unit frame type
    for _, baseType in ipairs(unitTypes) do
        -- Handle base unit frame (no index)
        local baseFrame = UnitFrames.CustomFrames[baseType]
        if baseFrame then
            if UnitFrames.SV.CustomTargetMarker then
                local markerType = GetUnitTargetMarkerType(baseType)
                if markerType ~= TARGET_MARKER_TYPE_NONE then
                    local nameText = GetUnitName(baseType)
                    local iconPath = ZO_GetPlatformTargetMarkerIcon(markerType)
                    if iconPath then
                        nameText = FormatTextWithIcon(iconPath, nameText)
                        baseFrame.name:SetText(nameText)
                    end
                else
                    -- If no marker, reset to default name
                    local nameText
                    if IsUnitPlayer(baseType) then
                        local DisplayOption = UnitFrames.SV.DisplayOptionsGroupRaid
                        if baseType == "player" then
                            DisplayOption = UnitFrames.SV.DisplayOptionsPlayer
                        elseif baseType == "reticleover" then
                            DisplayOption = UnitFrames.SV.DisplayOptionsTarget
                        end

                        if DisplayOption == 3 then
                            nameText = GetUnitName(baseType) .. " " .. GetUnitDisplayName(baseType)
                        elseif DisplayOption == 1 then
                            nameText = GetUnitDisplayName(baseType)
                        else
                            nameText = GetUnitName(baseType)
                        end
                    else
                        nameText = GetUnitName(baseType)
                    end
                    baseFrame.name:SetText(nameText)
                end
            end
            UnitFrames.UpdateStaticControls(baseFrame)
        end

        -- Handle indexed unit frames (1-12)
        for i = 1, MAX_GROUP_SIZE_THRESHOLD do
            local unitTag = baseType .. i
            local unitFrame = UnitFrames.CustomFrames[unitTag]
            if unitFrame then
                if UnitFrames.SV.CustomTargetMarker then
                    local markerType = GetUnitTargetMarkerType(unitTag)
                    if markerType ~= TARGET_MARKER_TYPE_NONE then
                        local nameText = GetUnitName(unitTag)
                        local iconPath = ZO_GetPlatformTargetMarkerIcon(markerType)
                        if iconPath then
                            nameText = FormatTextWithIcon(iconPath, nameText)
                            unitFrame.name:SetText(nameText)
                        end
                    else
                        -- If no marker, reset to default name
                        local nameText
                        if IsUnitPlayer(unitTag) then
                            local DisplayOption = UnitFrames.SV.DisplayOptionsGroupRaid

                            if DisplayOption == 3 then
                                nameText = GetUnitName(unitTag) .. " " .. GetUnitDisplayName(unitTag)
                            elseif DisplayOption == 1 then
                                nameText = GetUnitDisplayName(unitTag)
                            else
                                nameText = GetUnitName(unitTag)
                            end
                        else
                            nameText = GetUnitName(unitTag)
                        end
                        unitFrame.name:SetText(nameText)
                    end
                end
                UnitFrames.UpdateStaticControls(unitFrame)
            end
        end
    end
end

-- This function is used to setup alternative bar for player
-- Priority order: Werewolf -> Siege -> Mount -> ChampionXP / Experience
local XP_BAR_COLORS = ZO_XP_BAR_GRADIENT_COLORS[2]

---
--- @param isWerewolf boolean|nil
--- @param isSiege boolean|nil
--- @param isMounted boolean|nil
function UnitFrames.CustomFramesSetupAlternative(isWerewolf, isSiege, isMounted)
    if not UnitFrames.CustomFrames["player"] then
        return
    end
    -- If any of input parameters are nil, we need to query them
    if isWerewolf == nil then
        isWerewolf = IsPlayerInWerewolfForm()
    end
    if isSiege == nil then
        isSiege = (IsPlayerControllingSiegeWeapon() or IsPlayerEscortingRam())
    end
    if isMounted == nil then
        isMounted = IsMounted()
    end

    local center, color, icon
    local hidden = false
    local right = false
    local left = false
    local recenter = false

    local phb = UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_HEALTH]  -- Not a backdrop
    local pmb = UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_MAGICKA] -- Not a backdrop
    local psb = UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_STAMINA] -- Not a backdrop
    local alt = UnitFrames.CustomFrames["player"].alternative

    if UnitFrames.SV.PlayerEnableAltbarMSW and isWerewolf then
        icon = "LuiExtended/media/unitframes/unitframes_bar_werewolf.dds"
        center = { 0.05, 0, 0, 0.9 }
        color = { 0.8, 0, 0, 0.9 }

        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_WEREWOLF] = UnitFrames.CustomFrames["player"].alternative
        UnitFrames.CustomFrames["controlledsiege"][COMBAT_MECHANIC_FLAGS_HEALTH] = nil
        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA] = nil
        UnitFrames.CustomFrames["player"].ChampionXP = nil
        UnitFrames.CustomFrames["player"].Experience = nil
        local powerValue, powerMax, powerEffectiveMax = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_WEREWOLF)
        UnitFrames.OnPowerUpdate("player", nil, COMBAT_MECHANIC_FLAGS_WEREWOLF, powerValue, powerMax, powerEffectiveMax)

        if UnitFrames.SV.PlayerFrameOptions ~= 1 then
            if UnitFrames.SV.ReverseResourceBars then
                right = true
            else
                left = true
            end
        else
            recenter = true
        end

        UnitFrames.CustomFrames["player"].alternative.bar:SetMouseEnabled(true)
        UnitFrames.CustomFrames["player"].alternative.bar:SetHandler("OnMouseEnter", UnitFrames.AltBar_OnMouseEnterWerewolf)
        UnitFrames.CustomFrames["player"].alternative.bar:SetHandler("OnMouseExit", UnitFrames.AltBar_OnMouseExit)
        UnitFrames.CustomFrames["player"].alternative.enlightenment:SetHidden(true)
    elseif UnitFrames.SV.PlayerEnableAltbarMSW and isSiege then
        icon = "LuiExtended/media/unitframes/unitframes_bar_siege.dds"
        center = { 0.05, 0, 0, 0.9 }
        color = { 0.8, 0, 0, 0.9 }

        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_WEREWOLF] = nil
        UnitFrames.CustomFrames["controlledsiege"][COMBAT_MECHANIC_FLAGS_HEALTH] = UnitFrames.CustomFrames["player"].alternative
        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA] = nil
        UnitFrames.CustomFrames["player"].ChampionXP = nil
        UnitFrames.CustomFrames["player"].Experience = nil
        local powerValue, powerMax, powerEffectiveMax = GetUnitPower("controlledsiege", COMBAT_MECHANIC_FLAGS_HEALTH)
        UnitFrames.OnPowerUpdate("controlledsiege", nil, COMBAT_MECHANIC_FLAGS_HEALTH, powerValue, powerMax, powerEffectiveMax)

        recenter = true

        UnitFrames.CustomFrames["player"].alternative.bar:SetMouseEnabled(true)
        UnitFrames.CustomFrames["player"].alternative.bar:SetHandler("OnMouseEnter", UnitFrames.AltBar_OnMouseEnterSiege)
        UnitFrames.CustomFrames["player"].alternative.bar:SetHandler("OnMouseExit", UnitFrames.AltBar_OnMouseExit)
        UnitFrames.CustomFrames["player"].alternative.enlightenment:SetHidden(true)
    elseif UnitFrames.SV.PlayerEnableAltbarMSW and isMounted then
        icon = "LuiExtended/media/unitframes/unitframes_bar_mount.dds"
        center =
        {
            0.1 * UnitFrames.SV.CustomColourStamina[1],
            0.1 * UnitFrames.SV.CustomColourStamina[2],
            0.1 * UnitFrames.SV.CustomColourStamina[3],
            0.9,
        }
        color =
        {
            UnitFrames.SV.CustomColourStamina[1],
            UnitFrames.SV.CustomColourStamina[2],
            UnitFrames.SV.CustomColourStamina[3],
            0.9,
        }

        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_WEREWOLF] = nil
        UnitFrames.CustomFrames["controlledsiege"][COMBAT_MECHANIC_FLAGS_HEALTH] = nil
        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA] = UnitFrames.CustomFrames["player"].alternative
        UnitFrames.CustomFrames["player"].ChampionXP = nil
        UnitFrames.CustomFrames["player"].Experience = nil
        local powerValue, powerMax, powerEffectiveMax = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA)
        UnitFrames.OnPowerUpdate("player", nil, COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA, powerValue, powerMax, powerEffectiveMax)

        if UnitFrames.SV.PlayerFrameOptions ~= 1 then
            if UnitFrames.SV.ReverseResourceBars then
                left = true
            else
                right = true
            end
        else
            recenter = true
        end

        UnitFrames.CustomFrames["player"].alternative.bar:SetMouseEnabled(true)
        UnitFrames.CustomFrames["player"].alternative.bar:SetHandler("OnMouseEnter", UnitFrames.AltBar_OnMouseEnterMounted)
        UnitFrames.CustomFrames["player"].alternative.bar:SetHandler("OnMouseExit", UnitFrames.AltBar_OnMouseExit)
        UnitFrames.CustomFrames["player"].alternative.enlightenment:SetHidden(true)
    elseif UnitFrames.SV.PlayerEnableAltbarXP and (UnitFrames.CustomFrames["player"].isLevelCap or UnitFrames.CustomFrames["player"].isChampion) then
        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_WEREWOLF] = nil
        UnitFrames.CustomFrames["controlledsiege"][COMBAT_MECHANIC_FLAGS_HEALTH] = nil
        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA] = nil
        UnitFrames.CustomFrames["player"].ChampionXP = UnitFrames.CustomFrames["player"].alternative
        UnitFrames.CustomFrames["player"].Experience = nil

        UnitFrames.OnChampionPointGained() -- Setup bar color and proper icon

        local enlightenedPool = 4 * GetEnlightenedPool()
        local xp = GetPlayerChampionXP()
        local maxBar = GetNumChampionXPInChampionPoint(GetPlayerChampionPointsEarned())
        -- If Champion Points are maxed out then fill the bar all the way up.
        if maxBar == nil then
            maxBar = xp
        end
        local enlightenedBar = enlightenedPool + xp
        if enlightenedBar > maxBar then
            enlightenedBar = maxBar
        end -- If the enlightenment pool extends past the current level then cap it at the maximum bar value.

        UnitFrames.CustomFrames["player"].ChampionXP.enlightenment:SetMinMax(0, maxBar)
        UnitFrames.CustomFrames["player"].ChampionXP.enlightenment:SetValue(enlightenedBar)

        UnitFrames.CustomFrames["player"].ChampionXP.bar:SetMinMax(0, maxBar)
        UnitFrames.CustomFrames["player"].ChampionXP.bar:SetValue(xp)

        recenter = true

        UnitFrames.CustomFrames["player"].alternative.bar:SetMouseEnabled(true)
        UnitFrames.CustomFrames["player"].alternative.bar:SetHandler("OnMouseEnter", UnitFrames.AltBar_OnMouseEnterXP)
        UnitFrames.CustomFrames["player"].alternative.bar:SetHandler("OnMouseExit", UnitFrames.AltBar_OnMouseExit)
        UnitFrames.CustomFrames["player"].alternative.enlightenment:SetHidden(false)
    elseif UnitFrames.SV.PlayerEnableAltbarXP then
        icon = "LuiExtended/media/unitframes/unitframes_level_normal.dds"
        center = { 0, 0.1, 0.1, 0.9 }
        color = { XP_BAR_COLORS.r, XP_BAR_COLORS.g, XP_BAR_COLORS.b, 0.9 } -- { 0, 0.9, 0.9, 0.9 }

        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_WEREWOLF] = nil
        UnitFrames.CustomFrames["controlledsiege"][COMBAT_MECHANIC_FLAGS_HEALTH] = nil
        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA] = nil
        UnitFrames.CustomFrames["player"].ChampionXP = nil
        UnitFrames.CustomFrames["player"].Experience = UnitFrames.CustomFrames["player"].alternative

        local championXP = GetNumChampionXPInChampionPoint(GetPlayerChampionPointsEarned())
        if championXP == nil then
            championXP = GetPlayerChampionXP()
        end
        UnitFrames.CustomFrames["player"].Experience.bar:SetMinMax(0, UnitFrames.CustomFrames["player"].isChampion and championXP or GetUnitXPMax("player"))
        UnitFrames.CustomFrames["player"].Experience.bar:SetValue(UnitFrames.CustomFrames["player"].isChampion and GetPlayerChampionXP() or GetUnitXP("player"))

        recenter = true
        -- Otherwise bar should be hidden and no tracking be done

        UnitFrames.CustomFrames["player"].alternative.bar:SetMouseEnabled(true)
        UnitFrames.CustomFrames["player"].alternative.bar:SetHandler("OnMouseEnter", UnitFrames.AltBar_OnMouseEnterXP)
        UnitFrames.CustomFrames["player"].alternative.bar:SetHandler("OnMouseExit", UnitFrames.AltBar_OnMouseExit)
        UnitFrames.CustomFrames["player"].alternative.enlightenment:SetHidden(true)
    else
        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_WEREWOLF] = nil
        UnitFrames.CustomFrames["controlledsiege"][COMBAT_MECHANIC_FLAGS_HEALTH] = nil
        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA] = nil
        UnitFrames.CustomFrames["player"].ChampionXP = nil
        UnitFrames.CustomFrames["player"].Experience = nil

        hidden = true
        UnitFrames.CustomFrames["player"].alternative.bar:SetMouseEnabled(false)
        UnitFrames.CustomFrames["player"].alternative.enlightenment:SetHidden(true)
    end

    -- Setup of bar colors and icon
    if center then
        UnitFrames.CustomFrames["player"].alternative.backdrop:SetCenterColor(unpack(center))
    end
    if color then
        UnitFrames.CustomFrames["player"].alternative.bar:SetColor(unpack(color))
    end
    if icon then
        UnitFrames.CustomFrames["player"].alternative.icon:SetTexture(icon)
    end

    local altW = zo_ceil(UnitFrames.SV.PlayerBarWidth * 2 / 3)
    local padding = alt.icon:GetWidth()
    -- Hide bar and reanchor buffs
    UnitFrames.CustomFrames["player"].botInfo:SetHidden(hidden)
    UnitFrames.CustomFrames["player"].buffAnchor:SetHidden(hidden)
    UnitFrames.CustomFrames["player"].buffs:ClearAnchors()
    if UnitFrames.SV.PlayerFrameOptions == 3 then
        if UnitFrames.SV.HideBarMagicka and UnitFrames.SV.HideBarStamina then
            UnitFrames.CustomFrames["player"].buffs:SetAnchor(TOP, hidden and UnitFrames.CustomFrames["player"].control or UnitFrames.CustomFrames["player"].buffAnchor, BOTTOM, 0, 5)
        else
            UnitFrames.CustomFrames["player"].buffs:SetAnchor(TOP, hidden and UnitFrames.CustomFrames["player"].control or UnitFrames.CustomFrames["player"].buffAnchor, BOTTOM, 0, 5 + UnitFrames.SV.PlayerBarHeightStamina + UnitFrames.SV.PlayerBarSpacing)
        end
    else
        UnitFrames.CustomFrames["player"].buffs:SetAnchor(TOP, hidden and UnitFrames.CustomFrames["player"].control or UnitFrames.CustomFrames["player"].buffAnchor, BOTTOM, 0, 5)
    end
    if right then
        if UnitFrames.SV.HideBarStamina or UnitFrames.SV.HideBarMagicka then
            UnitFrames.CustomFrames["player"].botInfo:SetAnchor(TOP, phb.backdrop, BOTTOM, 0, 2)
            alt.backdrop:ClearAnchors()
            alt.backdrop:SetAnchor(CENTER, UnitFrames.CustomFrames["player"].botInfo, CENTER, padding * 0.5 + 1, 0)
            alt.backdrop:SetWidth(altW)
            alt.icon:ClearAnchors()
            alt.icon:SetAnchor(RIGHT, alt.backdrop, LEFT, -2, 0)
        else
            if UnitFrames.SV.ReverseResourceBars then
                UnitFrames.CustomFrames["player"].botInfo:SetAnchor(TOP, pmb.backdrop, BOTTOM, 0, 2)
            else
                UnitFrames.CustomFrames["player"].botInfo:SetAnchor(TOP, psb.backdrop, BOTTOM, 0, 2)
            end
            alt.backdrop:ClearAnchors()
            alt.backdrop:SetAnchor(LEFT, UnitFrames.CustomFrames["player"].botInfo, LEFT, padding + 5, 0)
            alt.backdrop:SetWidth(altW)
            alt.icon:ClearAnchors()
            alt.icon:SetAnchor(RIGHT, alt.backdrop, LEFT, -2, 0)
        end
    elseif left then
        if UnitFrames.SV.HideBarStamina or UnitFrames.SV.HideBarMagicka then
            UnitFrames.CustomFrames["player"].botInfo:SetAnchor(TOP, phb.backdrop, BOTTOM, 0, 2)
            alt.backdrop:ClearAnchors()
            alt.backdrop:SetAnchor(CENTER, UnitFrames.CustomFrames["player"].botInfo, CENTER, padding * 0.5 + 1, 0)
            alt.backdrop:SetWidth(altW)
            alt.icon:ClearAnchors()
            alt.icon:SetAnchor(RIGHT, alt.backdrop, LEFT, -2, 0)
        else
            if UnitFrames.SV.ReverseResourceBars then
                UnitFrames.CustomFrames["player"].botInfo:SetAnchor(TOP, psb.backdrop, BOTTOM, 0, 2)
            else
                UnitFrames.CustomFrames["player"].botInfo:SetAnchor(TOP, pmb.backdrop, BOTTOM, 0, 2)
            end
            alt.backdrop:ClearAnchors()
            alt.backdrop:SetAnchor(RIGHT, UnitFrames.CustomFrames["player"].botInfo, RIGHT, -padding - 5, 0)
            alt.backdrop:SetWidth(altW)
            alt.icon:ClearAnchors()
            alt.icon:SetAnchor(LEFT, alt.backdrop, RIGHT, 2, 0)
        end
        -- alt.icon:ClearAnchors()
    elseif recenter then
        if UnitFrames.SV.PlayerFrameOptions == 1 then
            UnitFrames.CustomFrames["player"].botInfo:SetAnchor(TOP, nil, BOTTOM, 0, 2)
            alt.backdrop:ClearAnchors()
            alt.backdrop:SetAnchor(CENTER, UnitFrames.CustomFrames["player"].botInfo, CENTER, padding * 0.5 + 1, 0)
            alt.backdrop:SetWidth(altW)
            alt.icon:ClearAnchors()
            alt.icon:SetAnchor(RIGHT, alt.backdrop, LEFT, -2, 0)
        elseif UnitFrames.SV.PlayerFrameOptions == 2 then
            UnitFrames.CustomFrames["player"].botInfo:SetAnchor(TOP, nil, BOTTOM, 0, 2)
            alt.backdrop:ClearAnchors()
            alt.backdrop:SetAnchor(CENTER, UnitFrames.CustomFrames["player"].botInfo, CENTER, padding * 0.5 + 1, 0)
            alt.backdrop:SetWidth(altW)
            alt.icon:ClearAnchors()
            alt.icon:SetAnchor(RIGHT, alt.backdrop, LEFT, -2, 0)
        elseif UnitFrames.SV.PlayerFrameOptions == 3 then
            if UnitFrames.SV.HideBarStamina and UnitFrames.SV.HideBarMagicka then
                UnitFrames.CustomFrames["player"].botInfo:SetAnchor(TOP, nil, BOTTOM, 0, 2)
            elseif UnitFrames.SV.HideBarStamina and not UnitFrames.SV.HideBarMagicka then
                if UnitFrames.SV.ReverseResourceBars then
                    UnitFrames.CustomFrames["player"].botInfo:SetAnchor(TOP, pmb.backdrop, BOTTOMLEFT, 0, 2)
                else
                    UnitFrames.CustomFrames["player"].botInfo:SetAnchor(TOP, pmb.backdrop, BOTTOMRIGHT, 0, 2)
                end
            else
                if UnitFrames.SV.ReverseResourceBars then
                    UnitFrames.CustomFrames["player"].botInfo:SetAnchor(TOP, psb.backdrop, BOTTOMRIGHT, 0, 2)
                else
                    UnitFrames.CustomFrames["player"].botInfo:SetAnchor(TOP, psb.backdrop, BOTTOMLEFT, 0, 2)
                end
            end
            alt.backdrop:ClearAnchors()
            alt.backdrop:SetAnchor(CENTER, UnitFrames.CustomFrames["player"].botInfo, CENTER, padding * 0.5 + 1, 0)
            alt.backdrop:SetWidth(altW)
            alt.icon:ClearAnchors()
            alt.icon:SetAnchor(RIGHT, alt.backdrop, LEFT, -2, 0)
        else
            UnitFrames.CustomFrames["player"].botInfo:SetAnchor(TOP, nil, BOTTOM, 0, 2)
        end
    end
end

-- Runs on EVENT_CHAMPION_POINT_GAINED event listener
-- Used to change icon on alternative bar for next champion point type
function UnitFrames.OnChampionPointGained(eventCode)
    if UnitFrames.CustomFrames["player"] and UnitFrames.CustomFrames["player"].ChampionXP then
        local championPoints = GetPlayerChampionPointsEarned()
        local attribute
        if championPoints == 3600 then
            attribute = GetChampionPointPoolForRank(championPoints)
        else
            attribute = GetChampionPointPoolForRank(championPoints + 1)
        end
        local color = (UnitFrames.SV.PlayerChampionColour and CP_BAR_COLORS[attribute]) and CP_BAR_COLORS[attribute][2] or XP_BAR_COLORS
        local color2 = (UnitFrames.SV.PlayerChampionColour and CP_BAR_COLORS[attribute]) and CP_BAR_COLORS[attribute][1] or XP_BAR_COLORS
        UnitFrames.CustomFrames["player"].ChampionXP.backdrop:SetCenterColor(0.1 * color.r, 0.1 * color.g, 0.1 * color.b, 0.9)
        UnitFrames.CustomFrames["player"].ChampionXP.enlightenment:SetColor(color2.r, color2.g, color2.b, 0.40)
        UnitFrames.CustomFrames["player"].ChampionXP.bar:SetColor(color.r, color.g, color.b, 0.9)
        local disciplineData = CHAMPION_DATA_MANAGER:FindChampionDisciplineDataByType(attribute)
        local icon = disciplineData and disciplineData:GetHUDIcon()
        UnitFrames.CustomFrames["player"].ChampionXP.icon:SetTexture(icon)
    end
end

-- Runs on the EVENT_COMBAT_EVENT listener.
---
--- @param eventId integer
--- @param result ActionResult
--- @param isError boolean
--- @param abilityName string
--- @param abilityGraphic integer
--- @param abilityActionSlotType ActionSlotType
--- @param sourceName string
--- @param sourceType CombatUnitType
--- @param targetName string
--- @param targetType CombatUnitType
--- @param hitValue integer
--- @param powerType CombatMechanicFlags
--- @param damageType DamageType
--- @param log boolean
--- @param sourceUnitId integer
--- @param targetUnitId integer
--- @param abilityId integer
--- @param overflow integer
function UnitFrames.OnCombatEvent(eventId, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if isError and sourceType == COMBAT_UNIT_TYPE_PLAYER and targetType == COMBAT_UNIT_TYPE_PLAYER and UnitFrames.CustomFrames["player"] ~= nil and UnitFrames.CustomFrames["player"][powerType] ~= nil and UnitFrames.CustomFrames["player"][powerType].backdrop ~= nil and (powerType == COMBAT_MECHANIC_FLAGS_HEALTH or powerType == COMBAT_MECHANIC_FLAGS_STAMINA or powerType == COMBAT_MECHANIC_FLAGS_MAGICKA) then
        if UnitFrames.powerError[powerType] or IsUnitDead("player") then
            return
        end

        UnitFrames.powerError[powerType] = true
        -- Save original center color and color to red
        local backdrop = UnitFrames.CustomFrames["player"][powerType].backdrop
        --- @cast backdrop BackdropControl
        local r, g, b = backdrop:GetCenterColor()
        if powerType == COMBAT_MECHANIC_FLAGS_STAMINA then
            backdrop:SetCenterColor(0, 0.2, 0, 0.9)
        elseif powerType == COMBAT_MECHANIC_FLAGS_MAGICKA then
            backdrop:SetCenterColor(0, 0.05, 0.35, 0.9)
        else
            backdrop:SetCenterColor(0.4, 0, 0, 0.9)
        end

        -- Make a delayed call to return original color
        local uniqueId = moduleName .. "PowerError" .. powerType
        local firstRun = true

        eventManager:RegisterForUpdate(uniqueId, 300, function ()
            if firstRun then
                backdrop:SetCenterColor(r, g, b, 0.9)
                firstRun = false
            else
                eventManager:UnregisterForUpdate(uniqueId)
                UnitFrames.powerError[powerType] = false
            end
        end)
    end
end

-- Helper function to update visibility of 'death/offline' label and hide bars and bar labels
function UnitFrames.CustomFramesSetDeadLabel(unitFrame, newValue)
    unitFrame.dead:SetHidden(newValue == nil)
    if newValue ~= nil then
        unitFrame.dead:SetText(newValue)
    end
    if newValue == "Offline" then
        if unitFrame.level ~= nil then
            unitFrame.level:SetHidden(newValue ~= "Dead" or newValue ~= nil)
        end
        if unitFrame.levelIcon ~= nil then
            unitFrame.levelIcon:SetHidden(newValue ~= "Dead" or newValue ~= nil)
        end
        if unitFrame.friendIcon ~= nil then
            unitFrame.friendIcon:SetHidden(newValue ~= "Dead" or newValue ~= nil)
        end
        if unitFrame.classIcon ~= nil then
            unitFrame.classIcon:SetTexture("/esoui/art/contacts/social_status_offline.dds")
        end
    end
    if unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH] then
        if unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH].bar ~= nil then
            local isUnwaveringPower = (GetUnitAttributeVisualizerEffectInfo(unitFrame.unitTag, ATTRIBUTE_VISUAL_UNWAVERING_POWER, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH) or 0)
            -- Don't unhide the HP bar if this unit is invulnerable
            if isUnwaveringPower == 0 then
                unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH].bar:SetHidden(newValue ~= nil)
            end
        end
        if unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH].label ~= nil then
            unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH].label:SetHidden(newValue ~= nil)
        end
        if unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH].labelOne ~= nil then
            unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH].labelOne:SetHidden(newValue ~= nil)
        end
        if unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH].labelTwo ~= nil then
            unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH].labelTwo:SetHidden(newValue ~= nil)
        end
        if unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH].name ~= nil then
            unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH].name:SetHidden(newValue ~= nil)
        end
    end
end

-- Repopulate group members, but try to update only those, that require it
function UnitFrames.CustomFramesGroupUpdate()
    -- if LUIE.IsDevDebugEnabled() then
    --     LUIE.Debug(string_format("[%s] GroupUpdate", GetTimeString()))
    -- end
    -- Unregister update function and clear local flag
    eventManager:UnregisterForUpdate(g_PendingUpdate.Group.name)
    g_PendingUpdate.Group.flag = false

    if UnitFrames.CustomFrames["SmallGroup1"] == nil and UnitFrames.CustomFrames["RaidGroup1"] == nil then
        return
    end

    if UnitFrames.SV.CustomFramesGroup then
        if GetGroupSize() <= 4 then
            ZO_UnitFramesGroups:SetHidden(true)
        end
    end
    if UnitFrames.SV.CustomFramesRaid then
        if GetGroupSize() > 4 or (not UnitFrames.CustomFrames["SmallGroup1"] and UnitFrames.CustomFrames["RaidGroup1"]) then
            ZO_UnitFramesGroups:SetHidden(true)
        end
    end

    -- This requires some tricks if we want to keep list alphabetically sorted
    local groupList = {}

    -- First we query all group unitTag for existence and save them to local list
    -- At the same time we will calculate how many group members we have and then will hide rest of custom control elements
    local n = 0 -- counter used to reference custom frames. it always continuous while games unitTag could have gaps
    for i = 1, 12 do
        local unitTag = "group" .. i
        if DoesUnitExist(unitTag) then
            -- Save this member for later sorting
            table_insert(groupList, { ["unitTag"] = unitTag, ["unitName"] = GetUnitName(unitTag) })
            -- CustomFrames
            n = n + 1
        else
            -- For non-existing unitTags we will remove reference from CustomFrames table
            UnitFrames.CustomFrames[unitTag] = nil
        end
    end

    -- Chose which of custom group frames we are going to use now
    local raid = nil

    -- Now we have to hide all excessive custom group controls
    if n > 4 then
        if UnitFrames.CustomFrames["SmallGroup1"] and UnitFrames.CustomFrames["SmallGroup1"].tlw then -- Custom group frames cannot be used for large groups
            UnitFrames.CustomFramesUnreferenceGroupControl("SmallGroup", 1)
        end
        if UnitFrames.CustomFrames["RaidGroup1"] and UnitFrames.CustomFrames["RaidGroup1"].tlw then -- Real group is large and custom raid frames are enabled
            UnitFrames.CustomFramesUnreferenceGroupControl("RaidGroup", n + 1)
            raid = true
        end
    else
        if UnitFrames.CustomFrames["SmallGroup1"] and UnitFrames.CustomFrames["SmallGroup1"].tlw then -- Custom group frames are enabled and used for small group
            UnitFrames.CustomFramesUnreferenceGroupControl("SmallGroup", n + 1)
            raid = false
            if UnitFrames.CustomFrames["RaidGroup1"] and UnitFrames.CustomFrames["RaidGroup1"].tlw then -- In this case just hide all raid frames if they are enabled
                UnitFrames.CustomFramesUnreferenceGroupControl("RaidGroup", 1)
            end
        elseif UnitFrames.CustomFrames["RaidGroup1"] and UnitFrames.CustomFrames["RaidGroup1"].tlw then -- Use raid frames if Custom Frames are not set to show but Raid frames are
            UnitFrames.CustomFramesUnreferenceGroupControl("RaidGroup", n + 1)
            raid = true
        end
    end

    -- Set raid variable for resurrection monitor.
    if raid ~= nil then
        UnitFrames.isRaid = raid
    end

    -- Here we can check unlikely situation when neither custom frames were selected
    if raid == nil then
        return
    end

    -- Now for small group we can exclude player from the list
    if raid == false and UnitFrames.SV.GroupExcludePlayer then
        for i = 1, #groupList do
            if AreUnitsEqual("player", groupList[i].unitTag) then
                -- Dereference game unitTag from CustomFrames table
                UnitFrames.CustomFrames[groupList[i].unitTag] = nil
                -- Remove element from saved table
                table_remove(groupList, i)
                -- Also remove last used (not removed on previous step) SmallGroup unitTag
                -- Variable 'n' is still holding total number of group members
                -- Thus we need to remove n-th one
                local unitTag = "SmallGroup" .. n
                UnitFrames.CustomFrames[unitTag].unitTag = nil
                UnitFrames.CustomFrames[unitTag].control:SetHidden(true)
                break
            end
        end
    end

    -- Now we have local list with valid units and we are ready to sort it
    -- FIXME: Sorting is again hardcoded to be done always
    -- if not raid or UnitFrames.SV.RaidSort then
    table_sort(groupList, function (x, y)
        return x.unitName < y.unitName
    end)
    -- end

    -- Loop through sorted list and put unitTag references into CustomFrames table
    local m = 0
    for _, v in ipairs(groupList) do
        -- Increase local counter
        m = m + 1
        UnitFrames.CustomFrames[v.unitTag] = UnitFrames.CustomFrames[(raid and "RaidGroup" or "SmallGroup") .. m]
        if UnitFrames.CustomFrames[v.unitTag] and UnitFrames.CustomFrames[v.unitTag].tlw then
            UnitFrames.CustomFrames[v.unitTag].control:SetHidden(false)

            -- For SmallGroup reset topInfo width
            if not raid then
                UnitFrames.CustomFrames[v.unitTag].topInfo:SetWidth(UnitFrames.SV.GroupBarWidth - 5)
            end

            UnitFrames.CustomFrames[v.unitTag].unitTag = v.unitTag
            UnitFrames.ReloadValues(v.unitTag)
        end
    end

    UnitFrames.OnLeaderUpdate(nil, nil)
end

-- Helper function to hide and remove unitTag reference from unused group controls
function UnitFrames.CustomFramesUnreferenceGroupControl(groupType, first)
    local last
    if groupType == "SmallGroup" then
        last = 4
    elseif groupType == "RaidGroup" then
        last = 12
    else
        return
    end

    for i = first, last do
        local unitTag = groupType .. i
        UnitFrames.CustomFrames[unitTag].unitTag = nil
        UnitFrames.CustomFrames[unitTag].control:SetHidden(true)
    end
end

-- Runs EVENT_BOSSES_CHANGED listener
function UnitFrames.OnBossesChanged(eventCode)
    if not UnitFrames.CustomFrames["boss1"] then
        return
    end

    for i = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
        local unitTag = "boss" .. i
        if DoesUnitExist(unitTag) then
            if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag].tlw then
                UnitFrames.CustomFrames[unitTag].control:SetHidden(false)
                UnitFrames.ReloadValues(unitTag)
            end
        else
            if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag].tlw then
                UnitFrames.CustomFrames[unitTag].control:SetHidden(true)
            end
        end
    end
end

-- Helper function to calculate aspect ratio scaling factor
local function GetAspectRatioScaleFactor()
    local screenWidth, screenHeight = GuiRoot:GetDimensions()

    if screenWidth == 0 or screenHeight == 0 then
        return 1.0 -- Fallback to no scaling if dimensions are invalid
    end

    local aspectRatio = screenWidth / screenHeight

    -- Define baseline aspect ratio (16:9)
    local baseline169 = 16 / 9 -- 1.7778

    -- Calculate scaling factor for Y-axis coordinates
    -- For 16:10 displays (1.6), we need to reduce Y-offsets since screens are proportionally taller
    local scaleFactor = aspectRatio / baseline169

    -- Apply manual override if set in saved variables
    if UnitFrames.SV.AspectRatioOverride and UnitFrames.SV.AspectRatioOverride ~= 0 then
        scaleFactor = UnitFrames.SV.AspectRatioOverride
    end

    return scaleFactor
end

-- Helper function to apply aspect ratio scaling to coordinate table
local function ApplyAspectRatioScaling(coords, scaleFactor)
    return { coords[1], coords[2] * scaleFactor }
end

-- Set anchors for all top level windows of CustomFrames
function UnitFrames.CustomFramesSetPositions()
    local default_anchors = {}

    -- Get aspect ratio scaling factor
    local aspectRatioScale = GetAspectRatioScaleFactor()

    -- Base coordinate tables for 16:9 resolutions (source of truth)
    local baseCoordinates =
    {
        [1] =
        { -- 1080p (16:9)
            player = { -492, 205 },
            playerCenter = { 0, 334 },
            reticleover = { 192, 205 },
            reticleoverCenter = { 0, -334 },
            companion = { -954, 180 },
            SmallGroup1 = { -954, -332 },
            PetGroup1 = { -954, 250 },
            RaidGroup1 = { -954, -210 },
            boss1 = { 306, -312 },
            AvaPlayerTarget = { 0, -200 },
        },
        [2] =
        { -- 1440p (16:9)
            player = { -570, 272 },
            playerCenter = { 0, 445 },
            reticleover = { 270, 272 },
            reticleoverCenter = { 0, -445 },
            companion = { -1271, 280 },
            SmallGroup1 = { -1271, -385 },
            PetGroup1 = { -1271, 350 },
            RaidGroup1 = { -1271, -243 },
            boss1 = { 354, -365 },
            AvaPlayerTarget = { 0, -266 },
        },
        [3] =
        { -- 4K (16:9)
            player = { -738, 410 },
            playerCenter = { 0, 668 },
            reticleover = { 438, 410 },
            reticleoverCenter = { 0, -668 },
            companion = { -2036, 380 },
            SmallGroup1 = { -2036, -498 },
            PetGroup1 = { -2036, 450 },
            RaidGroup1 = { -2036, -315 },
            boss1 = { 459, -478 },
            AvaPlayerTarget = { 0, -400 },
        },
    }

    -- Resolution scaling configuration
    -- Maps resolution option to: { baseResolutionIndex, resolutionScale, aspectRatioScale }
    local resolutionConfig =
    {
        [1] = { base = 1, resScale = 1.0, arScale = 1.0 },  -- 1080p (16:9)
        [2] = { base = 2, resScale = 1.0, arScale = 1.0 },  -- 1440p (16:9)
        [3] = { base = 3, resScale = 1.0, arScale = 1.0 },  -- 4K (16:9)
        [4] = { base = 1, resScale = 1.0, arScale = 0.9 },  -- 1080p (16:10)
        [5] = { base = 2, resScale = 1.0, arScale = 0.9 },  -- 1440p (16:10)
        [6] = { base = 1, resScale = 0.64, arScale = 0.9 }, -- Steam Deck (1280x800)
    }

    -- Get configuration for selected resolution
    local config = resolutionConfig[UnitFrames.SV.ResolutionOptions] or resolutionConfig[1]
    local coords = baseCoordinates[config.base]

    -- Apply scaling to all coordinates
    local function scaleCoords(baseCoords)
        return ApplyAspectRatioScaling(
            { baseCoords[1] * config.resScale, baseCoords[2] * config.arScale * config.resScale },
            aspectRatioScale
        )
    end

    -- Apply scaling to all frame positions
    local player = scaleCoords(coords.player)
    local playerCenter = scaleCoords(coords.playerCenter)
    local reticleover = scaleCoords(coords.reticleover)
    local reticleoverCenter = scaleCoords(coords.reticleoverCenter)
    local companion = scaleCoords(coords.companion)
    local SmallGroup1 = scaleCoords(coords.SmallGroup1)
    local RaidGroup1 = scaleCoords(coords.RaidGroup1)
    local PetGroup1 = scaleCoords(coords.PetGroup1)
    local boss1 = scaleCoords(coords.boss1)
    local AvaPlayerTarget = scaleCoords(coords.AvaPlayerTarget)

    if UnitFrames.SV.PlayerFrameOptions == 1 then
        default_anchors["player"] = { TOPLEFT, CENTER, player[1], player[2] }
        default_anchors["reticleover"] = { TOPLEFT, CENTER, reticleover[1], reticleover[2] }
    else
        default_anchors["player"] = { CENTER, CENTER, playerCenter[1], playerCenter[2] }
        default_anchors["reticleover"] = { CENTER, CENTER, reticleoverCenter[1], reticleoverCenter[2] }
    end
    default_anchors["companion"] = { TOPLEFT, CENTER, companion[1], companion[2] }
    default_anchors["SmallGroup1"] = { TOPLEFT, CENTER, SmallGroup1[1], SmallGroup1[2] }
    default_anchors["RaidGroup1"] = { TOPLEFT, CENTER, RaidGroup1[1], RaidGroup1[2] }
    default_anchors["PetGroup1"] = { TOPLEFT, CENTER, PetGroup1[1], PetGroup1[2] }
    default_anchors["boss1"] = { TOPLEFT, CENTER, boss1[1], boss1[2] }
    default_anchors["AvaPlayerTarget"] = { CENTER, CENTER, AvaPlayerTarget[1], AvaPlayerTarget[2] }

    for _, unitTag in pairs(
        {
            "player",
            "reticleover",
            "companion",
            "SmallGroup1",
            "RaidGroup1",
            "boss1",
            "AvaPlayerTarget",
            "PetGroup1",
        }) do
        if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag].tlw then
            local savedPos = UnitFrames.SV[UnitFrames.CustomFrames[unitTag].tlw.customPositionAttr]
            local anchors = (savedPos ~= nil and #savedPos == 2) and { TOPLEFT, TOPLEFT, savedPos[1], savedPos[2] } or default_anchors[unitTag]
            UnitFrames.CustomFrames[unitTag].tlw:ClearAnchors()
            UnitFrames.CustomFrames[unitTag].tlw:SetAnchor(anchors[1], GuiRoot, anchors[2], anchors[3], anchors[4])
            UnitFrames.CustomFrames[unitTag].tlw.preview.anchorLabel:SetText((savedPos ~= nil and #savedPos == 2) and zo_strformat("<<1>>, <<2>>", savedPos[1], savedPos[2]) or "default")
        end
    end
end

-- Reset anchors for all top level windows of CustomFrames
function UnitFrames.CustomFramesResetPosition(playerOnly)
    for _, unitTag in pairs({ "player", "reticleover" }) do
        if UnitFrames.CustomFrames[unitTag] then
            UnitFrames.SV[UnitFrames.CustomFrames[unitTag].tlw.customPositionAttr] = nil
        end
    end
    if playerOnly == false then
        for _, unitTag in pairs({ "companion", "SmallGroup1", "RaidGroup1", "boss1", "AvaPlayerTarget", "PetGroup1" }) do
            if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag].tlw then
                UnitFrames.SV[UnitFrames.CustomFrames[unitTag].tlw.customPositionAttr] = nil
            end
        end
    end
    UnitFrames.CustomFramesSetPositions()
end

function UnitFrames.CustomFramesApplyColorsSingle(unitTag)
    local health =
    {
        UnitFrames.SV.CustomColourHealth[1],
        UnitFrames.SV.CustomColourHealth[2],
        UnitFrames.SV.CustomColourHealth[3],
        0.9,
    }

    local dps =
    {
        UnitFrames.SV.CustomColourDPS[1],
        UnitFrames.SV.CustomColourDPS[2],
        UnitFrames.SV.CustomColourDPS[3],
        0.9,
    }
    local healer =
    {
        UnitFrames.SV.CustomColourHealer[1],
        UnitFrames.SV.CustomColourHealer[2],
        UnitFrames.SV.CustomColourHealer[3],
        0.9,
    }
    local tank =
    {
        UnitFrames.SV.CustomColourTank[1],
        UnitFrames.SV.CustomColourTank[2],
        UnitFrames.SV.CustomColourTank[3],
        0.9,
    }

    local health_bg =
    {
        0.1 * UnitFrames.SV.CustomColourHealth[1],
        0.1 * UnitFrames.SV.CustomColourHealth[2],
        0.1 * UnitFrames.SV.CustomColourHealth[3],
        0.9,
    }

    local dps_bg =
    {
        0.1 * UnitFrames.SV.CustomColourDPS[1],
        0.1 * UnitFrames.SV.CustomColourDPS[2],
        0.1 * UnitFrames.SV.CustomColourDPS[3],
        0.9,
    }
    local healer_bg =
    {
        0.1 * UnitFrames.SV.CustomColourHealer[1],
        0.1 * UnitFrames.SV.CustomColourHealer[2],
        0.1 * UnitFrames.SV.CustomColourHealer[3],
        0.9,
    }
    local tank_bg =
    {
        0.1 * UnitFrames.SV.CustomColourTank[1],
        0.1 * UnitFrames.SV.CustomColourTank[2],
        0.1 * UnitFrames.SV.CustomColourTank[3],
        0.9,
    }

    local groupSize = GetGroupSize()
    local group = groupSize <= 4
    local raid = groupSize > 4
    if not UnitFrames.SV.CustomFramesGroup then
        raid = true
        group = false
    end

    if (group and UnitFrames.SV.ColorRoleGroup) or (raid and UnitFrames.SV.ColorRoleRaid) then
        if UnitFrames.CustomFrames[unitTag] then
            local role = GetGroupMemberSelectedRole(unitTag)
            local unitFrame = UnitFrames.CustomFrames[unitTag]
            local thb = unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH] -- not a backdrop
            if role == 1 then
                thb.bar:SetColor(unpack(dps))
                thb.backdrop:SetCenterColor(unpack(dps_bg))
            elseif role == 4 then
                thb.bar:SetColor(unpack(healer))
                thb.backdrop:SetCenterColor(unpack(healer_bg))
            elseif role == 2 then
                thb.bar:SetColor(unpack(tank))
                thb.backdrop:SetCenterColor(unpack(tank_bg))
            else
                thb.bar:SetColor(unpack(health))
                thb.backdrop:SetCenterColor(unpack(health_bg))
            end
        end
    end
end

function UnitFrames.CustomFramesApplyReactionColor(isPlayer)
    if isPlayer and UnitFrames.SV.FrameColorClass then
        local classColor =
        {
            [1] =
            {
                UnitFrames.SV.CustomColourDragonknight[1],
                UnitFrames.SV.CustomColourDragonknight[2],
                UnitFrames.SV.CustomColourDragonknight[3],
                0.9,
            }, -- Dragonkight
            [2] =
            {
                UnitFrames.SV.CustomColourSorcerer[1],
                UnitFrames.SV.CustomColourSorcerer[2],
                UnitFrames.SV.CustomColourSorcerer[3],
                0.9,
            }, -- Sorcerer
            [3] =
            {
                UnitFrames.SV.CustomColourNightblade[1],
                UnitFrames.SV.CustomColourNightblade[2],
                UnitFrames.SV.CustomColourNightblade[3],
                0.9,
            }, -- Nightblade
            [4] =
            {
                UnitFrames.SV.CustomColourWarden[1],
                UnitFrames.SV.CustomColourWarden[2],
                UnitFrames.SV.CustomColourWarden[3],
                0.9,
            }, -- Warden
            [5] =
            {
                UnitFrames.SV.CustomColourNecromancer[1],
                UnitFrames.SV.CustomColourNecromancer[2],
                UnitFrames.SV.CustomColourNecromancer[3],
                0.9,
            }, -- Necromancer
            [6] =
            {
                UnitFrames.SV.CustomColourTemplar[1],
                UnitFrames.SV.CustomColourTemplar[2],
                UnitFrames.SV.CustomColourTemplar[3],
                0.9,
            }, -- Templar
            [117] =
            {
                UnitFrames.SV.CustomColourArcanist[1],
                UnitFrames.SV.CustomColourArcanist[2],
                UnitFrames.SV.CustomColourArcanist[3],
                0.9,
            }, -- Arcanist
        }

        local classBackground =
        {
            [1] =
            {
                0.1 * UnitFrames.SV.CustomColourDragonknight[1],
                0.1 * UnitFrames.SV.CustomColourDragonknight[2],
                0.1 * UnitFrames.SV.CustomColourDragonknight[3],
                0.9,
            }, -- Dragonkight
            [2] =
            {
                0.1 * UnitFrames.SV.CustomColourSorcerer[1],
                0.1 * UnitFrames.SV.CustomColourSorcerer[2],
                0.1 * UnitFrames.SV.CustomColourSorcerer[3],
                0.9,
            }, -- Sorcerer
            [3] =
            {
                0.1 * UnitFrames.SV.CustomColourNightblade[1],
                0.1 * UnitFrames.SV.CustomColourNightblade[2],
                0.1 * UnitFrames.SV.CustomColourNightblade[3],
                0.9,
            }, -- Nightblade
            [4] =
            {
                0.1 * UnitFrames.SV.CustomColourWarden[1],
                0.1 * UnitFrames.SV.CustomColourWarden[2],
                0.1 * UnitFrames.SV.CustomColourWarden[3],
                0.9,
            }, -- Warden
            [5] =
            {
                0.1 * UnitFrames.SV.CustomColourNecromancer[1],
                0.1 * UnitFrames.SV.CustomColourNecromancer[2],
                0.1 * UnitFrames.SV.CustomColourNecromancer[3],
                0.9,
            }, -- Necromancer
            [6] =
            {
                0.1 * UnitFrames.SV.CustomColourTemplar[1],
                0.1 * UnitFrames.SV.CustomColourTemplar[2],
                0.1 * UnitFrames.SV.CustomColourTemplar[3],
                0.9,
            }, -- Templar
            [117] =
            {
                0.1 * UnitFrames.SV.CustomColourArcanist[1],
                0.1 * UnitFrames.SV.CustomColourArcanist[2],
                0.1 * UnitFrames.SV.CustomColourArcanist[3],
                0.9,
            }, -- Arcanist
        }

        if UnitFrames.CustomFrames["reticleover"] then
            local unitFrame = UnitFrames.CustomFrames["reticleover"]
            local thb = unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH] -- not a backdrop
            local classcolor = classColor[GetUnitClassId("reticleover")]
            local classcolor_bg = classBackground[GetUnitClassId("reticleover")]
            thb.bar:SetColor(unpack(classcolor))
            thb.backdrop:SetCenterColor(unpack(classcolor_bg))
            return -- If we apply Class color then end the function here
        end
    end

    if UnitFrames.SV.FrameColorReaction then
        local reactionColor =
        {
            [UNIT_REACTION_PLAYER_ALLY] =
            {
                UnitFrames.SV.CustomColourPlayer[1],
                UnitFrames.SV.CustomColourPlayer[2],
                UnitFrames.SV.CustomColourPlayer[3],
                0.9,
            },
            [UNIT_REACTION_DEFAULT] =
            {
                UnitFrames.SV.CustomColourFriendly[1],
                UnitFrames.SV.CustomColourFriendly[2],
                UnitFrames.SV.CustomColourFriendly[3],
                0.9,
            },
            [UNIT_REACTION_FRIENDLY] =
            {
                UnitFrames.SV.CustomColourFriendly[1],
                UnitFrames.SV.CustomColourFriendly[2],
                UnitFrames.SV.CustomColourFriendly[3],
                0.9,
            },
            [UNIT_REACTION_NPC_ALLY] =
            {
                UnitFrames.SV.CustomColourFriendly[1],
                UnitFrames.SV.CustomColourFriendly[2],
                UnitFrames.SV.CustomColourFriendly[3],
                0.9,
            },
            [UNIT_REACTION_HOSTILE] =
            {
                UnitFrames.SV.CustomColourHostile[1],
                UnitFrames.SV.CustomColourHostile[2],
                UnitFrames.SV.CustomColourHostile[3],
                0.9,
            },
            [UNIT_REACTION_NEUTRAL] =
            {
                UnitFrames.SV.CustomColourNeutral[1],
                UnitFrames.SV.CustomColourNeutral[2],
                UnitFrames.SV.CustomColourNeutral[3],
                0.9,
            },
            [UNIT_REACTION_COMPANION] =
            {
                UnitFrames.SV.CustomColourCompanion[1],
                UnitFrames.SV.CustomColourCompanion[2],
                UnitFrames.SV.CustomColourCompanion[3],
                0.9,
            },
        }

        local reactionBackground =
        {
            [UNIT_REACTION_PLAYER_ALLY] =
            {
                0.1 * UnitFrames.SV.CustomColourPlayer[1],
                0.1 * UnitFrames.SV.CustomColourPlayer[2],
                0.1 * UnitFrames.SV.CustomColourPlayer[3],
                0.9,
            },
            [UNIT_REACTION_DEFAULT] =
            {
                0.1 * UnitFrames.SV.CustomColourFriendly[1],
                0.1 * UnitFrames.SV.CustomColourFriendly[2],
                0.1 * UnitFrames.SV.CustomColourFriendly[3],
                0.9,
            },
            [UNIT_REACTION_FRIENDLY] =
            {
                0.1 * UnitFrames.SV.CustomColourFriendly[1],
                0.1 * UnitFrames.SV.CustomColourFriendly[2],
                0.1 * UnitFrames.SV.CustomColourFriendly[3],
                0.9,
            },
            [UNIT_REACTION_NPC_ALLY] =
            {
                0.1 * UnitFrames.SV.CustomColourFriendly[1],
                0.1 * UnitFrames.SV.CustomColourFriendly[2],
                0.1 * UnitFrames.SV.CustomColourFriendly[3],
                0.9,
            },
            [UNIT_REACTION_HOSTILE] =
            {
                0.1 * UnitFrames.SV.CustomColourHostile[1],
                0.1 * UnitFrames.SV.CustomColourHostile[2],
                0.1 * UnitFrames.SV.CustomColourHostile[3],
                0.9,
            },
            [UNIT_REACTION_NEUTRAL] =
            {
                0.1 * UnitFrames.SV.CustomColourNeutral[1],
                0.1 * UnitFrames.SV.CustomColourNeutral[2],
                0.1 * UnitFrames.SV.CustomColourNeutral[3],
                0.9,
            },
            [UNIT_REACTION_COMPANION] =
            {
                0.1 * UnitFrames.SV.CustomColourCompanion[1],
                0.1 * UnitFrames.SV.CustomColourCompanion[2],
                0.1 * UnitFrames.SV.CustomColourCompanion[3],
                0.9,
            },
        }

        if UnitFrames.CustomFrames["reticleover"] then
            local unitFrame = UnitFrames.CustomFrames["reticleover"]
            local thb = unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH] -- not a backdrop

            local reactioncolor
            local reactioncolor_bg
            if IsUnitInvulnerableGuard("reticleover") then
                reactioncolor =
                {
                    UnitFrames.SV.CustomColourGuard[1],
                    UnitFrames.SV.CustomColourGuard[2],
                    UnitFrames.SV.CustomColourGuard[3],
                    0.9,
                }
                reactioncolor_bg =
                {
                    0.1 * UnitFrames.SV.CustomColourGuard[1],
                    0.1 * UnitFrames.SV.CustomColourGuard[2],
                    0.1 * UnitFrames.SV.CustomColourGuard[3],
                    0.9,
                }
            else
                reactioncolor = reactionColor[GetUnitReaction("reticleover")]
                reactioncolor_bg = reactionBackground[GetUnitReaction("reticleover")]
            end
            thb.bar:SetColor(unpack(reactioncolor))
            thb.backdrop:SetCenterColor(unpack(reactioncolor_bg))
        end
    else
        local health =
        {
            UnitFrames.SV.CustomColourHealth[1],
            UnitFrames.SV.CustomColourHealth[2],
            UnitFrames.SV.CustomColourHealth[3],
            0.9,
        }
        local health_bg =
        {
            0.1 * UnitFrames.SV.CustomColourHealth[1],
            0.1 * UnitFrames.SV.CustomColourHealth[2],
            0.1 * UnitFrames.SV.CustomColourHealth[3],
            0.9,
        }

        if UnitFrames.CustomFrames["reticleover"] then
            local unitFrame = UnitFrames.CustomFrames["reticleover"]
            local thb = unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH] -- not a backdrop

            thb.bar:SetColor(unpack(health))
            thb.backdrop:SetCenterColor(unpack(health_bg))
        end
    end
end

-- Apply selected texture for all known bars on custom unit frames
function UnitFrames.CustomFramesApplyTexture()
    local texture = LUIE.StatusbarTextures[UnitFrames.SV.CustomTexture]
    local isRoundTexture = UnitFrames.SV.CustomTexture == "Tube" or UnitFrames.SV.CustomTexture == "Steel"

    -- Helper function to set texture and handle Round texture edge color (Now with placeholder EdgeTexture)
    local function applyTextureToBackdrop(backdrop)
        -- Set the main texture
        backdrop:SetCenterTexture(texture) -- TODO: Add optional tilingInterval, addressMode args here if needed?

        -- Set Blend Mode
        backdrop:SetBlendMode(TEX_BLEND_MODE_ALPHA)

        -- Set Pixel Rounding
        backdrop:SetPixelRoundingEnabled(true) -- Keep true for now, toggle to false to test sharpness.

        if isRoundTexture then
            -- Still setting edge color to transparent for round textures
            backdrop:SetEdgeColor(0, 0, 0, 0)
        else
            backdrop:SetEdgeColor(0, 0, 0, 0.5)
        end
    end

    -- After texture is applied unhide frames, so player can see changes even from menu
    if UnitFrames.CustomFrames["player"] and UnitFrames.CustomFrames["player"].tlw then
        applyTextureToBackdrop(UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_HEALTH].backdrop)
        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_HEALTH].bar:SetTexture(texture)
        -- local healthStatusBarControl = UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_HEALTH].bar
        -- if healthStatusBarControl then
        --     healthStatusBarControl:EnableFadeOut(true)
        --     healthStatusBarControl:EnableLeadingEdge(true)
        --     healthStatusBarControl:SetPixelRoundingEnabled(true)
        -- end
        if UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_HEALTH].shieldbackdrop then
            applyTextureToBackdrop(UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_HEALTH].shieldbackdrop)
        end
        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_HEALTH].shield:SetTexture(texture)
        -- local shieldStatusBarControl = UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_HEALTH].shield
        -- if shieldStatusBarControl then
        --     shieldStatusBarControl:EnableFadeOut(true)
        --     shieldStatusBarControl:EnableLeadingEdge(true)
        --     shieldStatusBarControl:SetPixelRoundingEnabled(true)
        -- end
        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_HEALTH].trauma:SetTexture(texture)
        applyTextureToBackdrop(UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_MAGICKA].backdrop)
        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_MAGICKA].bar:SetTexture(texture)
        -- local magikaStatusBarControl = UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_MAGICKA].bar
        -- if magikaStatusBarControl then
        --     magikaStatusBarControl:EnableFadeOut(true)
        --     magikaStatusBarControl:EnableLeadingEdge(true)
        --     magikaStatusBarControl:SetPixelRoundingEnabled(true)
        -- end
        applyTextureToBackdrop(UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_STAMINA].backdrop)
        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_STAMINA].bar:SetTexture(texture)
        -- local staminaStatusBarControl = UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_STAMINA].bar
        -- if staminaStatusBarControl then
        --     staminaStatusBarControl:EnableFadeOut(true)
        --     staminaStatusBarControl:EnableLeadingEdge(true)
        --     staminaStatusBarControl:SetPixelRoundingEnabled(true)
        -- end
        applyTextureToBackdrop(UnitFrames.CustomFrames["player"].alternative.backdrop)
        UnitFrames.CustomFrames["player"].alternative.bar:SetTexture(texture)
        UnitFrames.CustomFrames["player"].alternative.enlightenment:SetTexture(texture)
        UnitFrames.CustomFrames["player"].tlw:SetHidden(false)
    end

    if UnitFrames.CustomFrames["reticleover"] and UnitFrames.CustomFrames["reticleover"].tlw then
        applyTextureToBackdrop(UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH].backdrop)
        UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH].bar:SetTexture(texture)
        -- local healthStatusBarControl = UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH].bar
        -- if healthStatusBarControl then
        --     healthStatusBarControl:EnableFadeOut(true)
        --     healthStatusBarControl:EnableLeadingEdge(true)
        --     healthStatusBarControl:SetPixelRoundingEnabled(true)
        -- end
        if UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH].shieldbackdrop then
            applyTextureToBackdrop(UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH].shieldbackdrop)
        end
        UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH].shield:SetTexture(texture)
        -- local shieldStatusBarControl = UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH].shield
        -- if shieldStatusBarControl then
        --     shieldStatusBarControl:EnableFadeOut(true)
        --     shieldStatusBarControl:EnableLeadingEdge(true)
        --     shieldStatusBarControl:SetPixelRoundingEnabled(true)
        -- end
        UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH].trauma:SetTexture(texture)
        UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH].invulnerable:SetTexture(texture)
        UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH].invulnerableInlay:SetTexture("LuiExtended/media/unitframes/invulnerable_munge.dds")
        -- local invulInlay = UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH].invulnerableInlay
        -- if invulInlay then
        --     invulInlay:EnableFadeOut(true)
        --     invulInlay:EnableLeadingEdge(true)
        --     invulInlay:SetPixelRoundingEnabled(true)
        --     invulInlay:SetTextureCoords(0, 1, 0, 1) -- full texture
        -- end
        UnitFrames.CustomFrames["reticleover"].tlw:SetHidden(false)
    end

    if UnitFrames.CustomFrames["AvaPlayerTarget"] and UnitFrames.CustomFrames["AvaPlayerTarget"].tlw then
        applyTextureToBackdrop(UnitFrames.CustomFrames["AvaPlayerTarget"][COMBAT_MECHANIC_FLAGS_HEALTH].backdrop)
        UnitFrames.CustomFrames["AvaPlayerTarget"][COMBAT_MECHANIC_FLAGS_HEALTH].bar:SetTexture(texture)
        if UnitFrames.CustomFrames["AvaPlayerTarget"][COMBAT_MECHANIC_FLAGS_HEALTH].shieldbackdrop then
            applyTextureToBackdrop(UnitFrames.CustomFrames["AvaPlayerTarget"][COMBAT_MECHANIC_FLAGS_HEALTH].shieldbackdrop)
        end
        UnitFrames.CustomFrames["AvaPlayerTarget"][COMBAT_MECHANIC_FLAGS_HEALTH].shield:SetTexture(texture)
        -- local shieldStatusBarControl = UnitFrames.CustomFrames["AvaPlayerTarget"][COMBAT_MECHANIC_FLAGS_HEALTH].shield
        -- if shieldStatusBarControl then
        --     shieldStatusBarControl:EnableFadeOut(true)
        --     shieldStatusBarControl:EnableLeadingEdge(true)
        --     shieldStatusBarControl:SetPixelRoundingEnabled(true)
        -- end
        UnitFrames.CustomFrames["AvaPlayerTarget"][COMBAT_MECHANIC_FLAGS_HEALTH].trauma:SetTexture(texture)
        UnitFrames.CustomFrames["AvaPlayerTarget"][COMBAT_MECHANIC_FLAGS_HEALTH].invulnerable:SetTexture(texture)
        UnitFrames.CustomFrames["AvaPlayerTarget"][COMBAT_MECHANIC_FLAGS_HEALTH].invulnerableInlay:SetTexture("LuiExtended/media/unitframes/invulnerable_munge.dds")
        -- local invulInlay = UnitFrames.CustomFrames["AvaPlayerTarget"][COMBAT_MECHANIC_FLAGS_HEALTH].invulnerableInlay
        -- if invulInlay then
        --     invulInlay:EnableFadeOut(true)
        --     invulInlay:EnableLeadingEdge(true)
        --     invulInlay:SetPixelRoundingEnabled(true)
        --     invulInlay:SetTextureCoords(0, 1, 0, 1) -- full texture
        -- end
        UnitFrames.CustomFrames["AvaPlayerTarget"].tlw:SetHidden(false)
    end

    if UnitFrames.CustomFrames["companion"] and UnitFrames.CustomFrames["companion"].tlw then
        applyTextureToBackdrop(UnitFrames.CustomFrames["companion"][COMBAT_MECHANIC_FLAGS_HEALTH].backdrop)
        UnitFrames.CustomFrames["companion"][COMBAT_MECHANIC_FLAGS_HEALTH].bar:SetTexture(texture)
        UnitFrames.CustomFrames["companion"][COMBAT_MECHANIC_FLAGS_HEALTH].shield:SetTexture(texture)
        -- local shieldStatusBarControl = UnitFrames.CustomFrames["companion"][COMBAT_MECHANIC_FLAGS_HEALTH].shield
        -- if shieldStatusBarControl then
        --     shieldStatusBarControl:EnableFadeOut(true)
        --     shieldStatusBarControl:EnableLeadingEdge(true)
        --     shieldStatusBarControl:SetPixelRoundingEnabled(true)
        -- end
        UnitFrames.CustomFrames["companion"][COMBAT_MECHANIC_FLAGS_HEALTH].trauma:SetTexture(texture)
        UnitFrames.CustomFrames["companion"].tlw:SetHidden(false)
    end

    if UnitFrames.CustomFrames["SmallGroup1"] and UnitFrames.CustomFrames["SmallGroup1"].tlw then
        for i = 1, 4 do
            local unitTag = "SmallGroup" .. i
            applyTextureToBackdrop(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].backdrop)
            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].bar:SetTexture(texture)
            if UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].shieldbackdrop then
                applyTextureToBackdrop(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].shieldbackdrop)
            end
            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].shield:SetTexture(texture)
            -- local shieldStatusBarControl = UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].shield
            -- if shieldStatusBarControl then
            --     shieldStatusBarControl:EnableFadeOut(true)
            --     shieldStatusBarControl:EnableLeadingEdge(true)
            --     shieldStatusBarControl:SetPixelRoundingEnabled(true)
            -- end
            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].trauma:SetTexture(texture)
        end
        UnitFrames.CustomFrames["SmallGroup1"].tlw:SetHidden(false)
    end

    if UnitFrames.CustomFrames["RaidGroup1"] and UnitFrames.CustomFrames["RaidGroup1"].tlw then
        for i = 1, 12 do
            local unitTag = "RaidGroup" .. i
            applyTextureToBackdrop(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].backdrop)
            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].bar:SetTexture(texture)
            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].shield:SetTexture(texture)
            -- local shieldStatusBarControl = UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].shield
            -- if shieldStatusBarControl then
            --     shieldStatusBarControl:EnableFadeOut(true)
            --     shieldStatusBarControl:EnableLeadingEdge(true)
            --     shieldStatusBarControl:SetPixelRoundingEnabled(true)
            -- end
            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].trauma:SetTexture(texture)
        end
        UnitFrames.CustomFrames["RaidGroup1"].tlw:SetHidden(false)
    end

    if UnitFrames.CustomFrames["PetGroup1"] and UnitFrames.CustomFrames["PetGroup1"].tlw then
        for i = 1, 7 do
            local unitTag = "PetGroup" .. i
            applyTextureToBackdrop(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].backdrop)
            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].bar:SetTexture(texture)
            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].shield:SetTexture(texture)
            -- local shieldStatusBarControl = UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].shield
            -- if shieldStatusBarControl then
            --     shieldStatusBarControl:EnableFadeOut(true)
            --     shieldStatusBarControl:EnableLeadingEdge(true)
            --     shieldStatusBarControl:SetPixelRoundingEnabled(true)
            -- end
            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].trauma:SetTexture(texture)
        end
        UnitFrames.CustomFrames["PetGroup1"].tlw:SetHidden(false)
    end

    if UnitFrames.CustomFrames["boss1"] and UnitFrames.CustomFrames["boss1"].tlw then
        for i = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
            local unitTag = "boss" .. i
            applyTextureToBackdrop(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].backdrop)
            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].bar:SetTexture(texture)
            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].shield:SetTexture(texture)
            -- local shieldStatusBarControl = UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].shield
            -- if shieldStatusBarControl then
            --     shieldStatusBarControl:EnableFadeOut(true)
            --     shieldStatusBarControl:EnableLeadingEdge(true)
            --     shieldStatusBarControl:SetPixelRoundingEnabled(true)
            -- end
            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].trauma:SetTexture(texture)
            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].invulnerable:SetTexture(texture)
            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].invulnerableInlay:SetTexture("LuiExtended/media/unitframes/invulnerable_munge.dds")
            -- local invulInlay = UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].invulnerableInlay
            -- if invulInlay then
            --     invulInlay:EnableFadeOut(true)
            --     invulInlay:EnableLeadingEdge(true)
            --     invulInlay:SetPixelRoundingEnabled(true)
            --     invulInlay:SetTextureCoords(0, 1, 0, 1) -- full texture
            -- end
        end
        UnitFrames.CustomFrames["boss1"].tlw:SetHidden(false)
    end
end

-- Set dimensions of custom group frame and anchors or raid group members
function UnitFrames.CustomFramesApplyLayoutPlayer(unhide)
    -- Player frame
    if UnitFrames.CustomFrames.player then
        local player = UnitFrames.CustomFrames.player

        local phb = player[COMBAT_MECHANIC_FLAGS_HEALTH]  -- Not a backdrop
        local pmb = player[COMBAT_MECHANIC_FLAGS_MAGICKA] -- Not a backdrop
        local psb = player[COMBAT_MECHANIC_FLAGS_STAMINA] -- Not a backdrop
        local alt = player.alternative                    -- Not a backdrop

        if UnitFrames.SV.PlayerFrameOptions == 1 then
            if not UnitFrames.SV.HideBarMagicka and not UnitFrames.SV.HideBarStamina then
                player.tlw:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightHealth + UnitFrames.SV.PlayerBarHeightMagicka + UnitFrames.SV.PlayerBarHeightStamina + 2 * UnitFrames.SV.PlayerBarSpacing + (phb.shieldbackdrop and UnitFrames.SV.CustomShieldBarHeight or 0))
                player.control:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightHealth + UnitFrames.SV.PlayerBarHeightMagicka + UnitFrames.SV.PlayerBarHeightStamina + 2 * UnitFrames.SV.PlayerBarSpacing + (phb.shieldbackdrop and UnitFrames.SV.CustomShieldBarHeight or 0))
            elseif UnitFrames.SV.HideBarMagicka and not UnitFrames.SV.HideBarStamina then
                player.tlw:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightHealth + UnitFrames.SV.PlayerBarHeightStamina + UnitFrames.SV.PlayerBarSpacing + (phb.shieldbackdrop and UnitFrames.SV.CustomShieldBarHeight or 0))
                player.control:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightHealth + UnitFrames.SV.PlayerBarHeightStamina + UnitFrames.SV.PlayerBarSpacing + (phb.shieldbackdrop and UnitFrames.SV.CustomShieldBarHeight or 0))
            elseif UnitFrames.SV.HideBarStamina and not UnitFrames.SV.HideBarMagicka then
                player.tlw:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightHealth + UnitFrames.SV.PlayerBarHeightMagicka + UnitFrames.SV.PlayerBarSpacing + (phb.shieldbackdrop and UnitFrames.SV.CustomShieldBarHeight or 0))
                player.control:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightHealth + UnitFrames.SV.PlayerBarHeightMagicka + UnitFrames.SV.PlayerBarSpacing + (phb.shieldbackdrop and UnitFrames.SV.CustomShieldBarHeight or 0))
            else
                player.tlw:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightHealth + (phb.shieldbackdrop and UnitFrames.SV.CustomShieldBarHeight or 0))
                player.control:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightHealth + (phb.shieldbackdrop and UnitFrames.SV.CustomShieldBarHeight or 0))
            end

            player.topInfo:SetWidth(UnitFrames.SV.PlayerBarWidth)
            player.botInfo:SetWidth(UnitFrames.SV.PlayerBarWidth)
            player.buffAnchor:SetWidth(UnitFrames.SV.PlayerBarWidth)

            player.name:SetWidth(UnitFrames.SV.PlayerBarWidth - 90)
            player.buffs:SetWidth(UnitFrames.SV.PlayerBarWidth)
            player.debuffs:SetWidth(UnitFrames.SV.PlayerBarWidth)

            player.levelIcon:ClearAnchors()
            player.levelIcon:SetAnchor(LEFT, player.topInfo, LEFT, player.name:GetTextWidth() + 1, 0)

            player.name:SetHidden(not UnitFrames.SV.PlayerEnableYourname)
            player.level:SetHidden(not UnitFrames.SV.PlayerEnableYourname)
            player.levelIcon:SetHidden(not UnitFrames.SV.PlayerEnableYourname)
            player.classIcon:SetHidden(not UnitFrames.SV.PlayerEnableYourname)

            local altW = zo_ceil(UnitFrames.SV.PlayerBarWidth * 2 / 3)

            if not UnitFrames.SV.HideBarHealth then
                phb.backdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightHealth)
            end
            phb.backdrop:SetHidden(UnitFrames.SV.HideBarHealth)

            if not UnitFrames.SV.ReverseResourceBars then
                pmb.backdrop:ClearAnchors()
                if not UnitFrames.SV.HideBarMagicka then
                    if phb.shieldbackdrop then
                        phb.shieldbackdrop:ClearAnchors()
                        phb.shieldbackdrop:SetAnchor(TOP, phb.backdrop, BOTTOM, 0, 0)
                        phb.shieldbackdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.CustomShieldBarHeight)
                        pmb.backdrop:SetAnchor(TOP, phb.shieldbackdrop, BOTTOM, 0, UnitFrames.SV.PlayerBarSpacing)
                    else
                        pmb.backdrop:SetAnchor(TOP, phb.backdrop, BOTTOM, 0, UnitFrames.SV.PlayerBarSpacing)
                    end
                    pmb.backdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightMagicka)
                else
                    if phb.shieldbackdrop then
                        phb.shieldbackdrop:ClearAnchors()
                        phb.shieldbackdrop:SetAnchor(TOP, phb.backdrop, BOTTOM, 0, 0)
                        phb.shieldbackdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.CustomShieldBarHeight)
                    end
                end

                psb.backdrop:ClearAnchors()
                if not UnitFrames.SV.HideBarStamina then
                    if not UnitFrames.SV.HideBarMagicka then
                        psb.backdrop:SetAnchor(TOP, pmb.backdrop, BOTTOM, 0, UnitFrames.SV.PlayerBarSpacing)
                    else
                        if phb.shieldbackdrop then
                            psb.backdrop:SetAnchor(TOP, phb.shieldbackdrop, BOTTOM, 0, UnitFrames.SV.PlayerBarSpacing)
                        else
                            psb.backdrop:SetAnchor(TOP, phb.backdrop, BOTTOM, 0, UnitFrames.SV.PlayerBarSpacing)
                        end
                    end
                    psb.backdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightStamina)
                end
            else
                psb.backdrop:ClearAnchors()
                if not UnitFrames.SV.HideBarStamina then
                    if phb.shieldbackdrop then
                        phb.shieldbackdrop:ClearAnchors()
                        phb.shieldbackdrop:SetAnchor(TOP, phb.backdrop, BOTTOM, 0, 0)
                        phb.shieldbackdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.CustomShieldBarHeight)
                        psb.backdrop:SetAnchor(TOP, phb.shieldbackdrop, BOTTOM, 0, UnitFrames.SV.PlayerBarSpacing)
                    else
                        psb.backdrop:SetAnchor(TOP, phb.backdrop, BOTTOM, 0, UnitFrames.SV.PlayerBarSpacing)
                    end
                    psb.backdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightStamina)
                else
                    if phb.shieldbackdrop then
                        phb.shieldbackdrop:ClearAnchors()
                        phb.shieldbackdrop:SetAnchor(TOP, phb.backdrop, BOTTOM, 0, 0)
                        phb.shieldbackdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.CustomShieldBarHeight)
                    end
                end

                pmb.backdrop:ClearAnchors()
                if not UnitFrames.SV.HideBarMagicka then
                    if not UnitFrames.SV.HideBarStamina then
                        pmb.backdrop:SetAnchor(TOP, psb.backdrop, BOTTOM, 0, UnitFrames.SV.PlayerBarSpacing)
                    else
                        if phb.shieldbackdrop then
                            pmb.backdrop:SetAnchor(TOP, phb.shieldbackdrop, BOTTOM, 0, UnitFrames.SV.PlayerBarSpacing)
                        else
                            pmb.backdrop:SetAnchor(TOP, phb.backdrop, BOTTOM, 0, UnitFrames.SV.PlayerBarSpacing)
                        end
                    end
                    pmb.backdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightMagicka)
                end
            end
            alt.backdrop:SetWidth(altW)
            if not UnitFrames.SV.HideLabelHealth then
                phb.labelOne:SetDimensions(UnitFrames.SV.PlayerBarWidth - 50, UnitFrames.SV.PlayerBarHeightHealth - 2)
                phb.labelTwo:SetDimensions(UnitFrames.SV.PlayerBarWidth - 50, UnitFrames.SV.PlayerBarHeightHealth - 2)
            end
            if not UnitFrames.SV.HideLabelMagicka then
                pmb.labelOne:SetDimensions(UnitFrames.SV.PlayerBarWidth - 50, UnitFrames.SV.PlayerBarHeightMagicka - 2)
                pmb.labelTwo:SetDimensions(UnitFrames.SV.PlayerBarWidth - 50, UnitFrames.SV.PlayerBarHeightMagicka - 2)
            end
            if not UnitFrames.SV.HideLabelStamina then
                psb.labelOne:SetDimensions(UnitFrames.SV.PlayerBarWidth - 50, UnitFrames.SV.PlayerBarHeightStamina - 2)
                psb.labelTwo:SetDimensions(UnitFrames.SV.PlayerBarWidth - 50, UnitFrames.SV.PlayerBarHeightStamina - 2)
            end
        elseif UnitFrames.SV.PlayerFrameOptions == 2 then
            player.tlw:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightHealth + (phb.shieldbackdrop and UnitFrames.SV.CustomShieldBarHeight or 0))
            player.control:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightHealth + (phb.shieldbackdrop and UnitFrames.SV.CustomShieldBarHeight or 0))

            player.topInfo:SetWidth(UnitFrames.SV.PlayerBarWidth)
            player.botInfo:SetWidth(UnitFrames.SV.PlayerBarWidth)
            player.buffAnchor:SetWidth(UnitFrames.SV.PlayerBarWidth)

            player.name:SetWidth(UnitFrames.SV.PlayerBarWidth - 90)
            player.buffs:SetWidth(1000)
            player.debuffs:SetWidth(1000)

            player.levelIcon:ClearAnchors()
            player.levelIcon:SetAnchor(LEFT, player.topInfo, LEFT, player.name:GetTextWidth() + 1, 0)

            player.name:SetHidden(not UnitFrames.SV.PlayerEnableYourname)
            player.level:SetHidden(not UnitFrames.SV.PlayerEnableYourname)
            player.levelIcon:SetHidden(not UnitFrames.SV.PlayerEnableYourname)
            player.classIcon:SetHidden(not UnitFrames.SV.PlayerEnableYourname)

            local altW = zo_ceil(UnitFrames.SV.PlayerBarWidth * 2 / 3)

            phb.backdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightHealth)
            phb.backdrop:SetHidden(UnitFrames.SV.HideBarHealth)

            if phb.shieldbackdrop then
                phb.shieldbackdrop:ClearAnchors()
                phb.shieldbackdrop:SetAnchor(TOP, phb.backdrop, BOTTOM, 0, 0)
                phb.shieldbackdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.CustomShieldBarHeight)
            end

            if not UnitFrames.SV.ReverseResourceBars then
                pmb.backdrop:ClearAnchors()
                if not UnitFrames.SV.HideBarMagicka then
                    pmb.backdrop:SetAnchor(RIGHT, phb.backdrop, LEFT, -UnitFrames.SV.AdjustMagickaHPos, UnitFrames.SV.AdjustMagickaVPos)
                    pmb.backdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightMagicka)
                end

                psb.backdrop:ClearAnchors()
                if not UnitFrames.SV.HideBarStamina then
                    psb.backdrop:SetAnchor(LEFT, phb.backdrop, RIGHT, UnitFrames.SV.AdjustStaminaHPos, UnitFrames.SV.AdjustStaminaVPos)
                    psb.backdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightStamina)
                end
            else
                psb.backdrop:ClearAnchors()
                if not UnitFrames.SV.HideBarStamina then
                    psb.backdrop:SetAnchor(RIGHT, phb.backdrop, LEFT, -UnitFrames.SV.AdjustStaminaHPos, UnitFrames.SV.AdjustStaminaVPos)
                    psb.backdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightStamina)
                end

                pmb.backdrop:ClearAnchors()
                if not UnitFrames.SV.HideBarMagicka then
                    pmb.backdrop:SetAnchor(LEFT, phb.backdrop, RIGHT, UnitFrames.SV.AdjustMagickaHPos, UnitFrames.SV.AdjustMagickaVPos)
                    pmb.backdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightMagicka)
                end
            end
            alt.backdrop:SetWidth(altW)

            if not UnitFrames.SV.HideLabelHealth then
                phb.labelOne:SetDimensions(UnitFrames.SV.PlayerBarWidth - 50, UnitFrames.SV.PlayerBarHeightHealth - 2)
                phb.labelTwo:SetDimensions(UnitFrames.SV.PlayerBarWidth - 50, UnitFrames.SV.PlayerBarHeightHealth - 2)
            end
            if not UnitFrames.SV.HideLabelMagicka then
                pmb.labelOne:SetDimensions(UnitFrames.SV.PlayerBarWidth - 50, UnitFrames.SV.PlayerBarHeightMagicka - 2)
                pmb.labelTwo:SetDimensions(UnitFrames.SV.PlayerBarWidth - 50, UnitFrames.SV.PlayerBarHeightMagicka - 2)
            end
            if not UnitFrames.SV.HideLabelStamina then
                psb.labelOne:SetDimensions(UnitFrames.SV.PlayerBarWidth - 50, UnitFrames.SV.PlayerBarHeightStamina - 2)
                psb.labelTwo:SetDimensions(UnitFrames.SV.PlayerBarWidth - 50, UnitFrames.SV.PlayerBarHeightStamina - 2)
            end
        else
            player.tlw:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightHealth + (phb.shieldbackdrop and UnitFrames.SV.CustomShieldBarHeight or 0))
            player.control:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightHealth + (phb.shieldbackdrop and UnitFrames.SV.CustomShieldBarHeight or 0))

            player.topInfo:SetWidth(UnitFrames.SV.PlayerBarWidth)
            player.botInfo:SetWidth(UnitFrames.SV.PlayerBarWidth)
            player.buffAnchor:SetWidth(UnitFrames.SV.PlayerBarWidth)

            player.name:SetWidth(UnitFrames.SV.PlayerBarWidth - 90)
            player.buffs:SetWidth(1000)
            player.debuffs:SetWidth(1000)

            player.levelIcon:ClearAnchors()
            player.levelIcon:SetAnchor(LEFT, player.topInfo, LEFT, player.name:GetTextWidth() + 1, 0)

            player.name:SetHidden(not UnitFrames.SV.PlayerEnableYourname)
            player.level:SetHidden(not UnitFrames.SV.PlayerEnableYourname)
            player.levelIcon:SetHidden(not UnitFrames.SV.PlayerEnableYourname)
            player.classIcon:SetHidden(not UnitFrames.SV.PlayerEnableYourname)

            local altW = zo_ceil(UnitFrames.SV.PlayerBarWidth * 2 / 3)

            phb.backdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightHealth)
            phb.backdrop:SetHidden(UnitFrames.SV.HideBarHealth)

            if not UnitFrames.SV.ReverseResourceBars then
                pmb.backdrop:ClearAnchors()
                if not UnitFrames.SV.HideBarMagicka then
                    if phb.shieldbackdrop then
                        phb.shieldbackdrop:ClearAnchors()
                        phb.shieldbackdrop:SetAnchor(TOP, phb.backdrop, BOTTOM, 0, 0)
                        phb.shieldbackdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.CustomShieldBarHeight)
                        pmb.backdrop:SetAnchor(TOP, phb.shieldbackdrop, BOTTOMLEFT, 0, UnitFrames.SV.PlayerBarSpacing)
                    else
                        pmb.backdrop:SetAnchor(TOP, phb.backdrop, BOTTOMLEFT, 0, UnitFrames.SV.PlayerBarSpacing)
                    end
                    pmb.backdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightMagicka)
                else
                    if phb.shieldbackdrop then
                        phb.shieldbackdrop:ClearAnchors()
                        phb.shieldbackdrop:SetAnchor(TOP, phb.backdrop, BOTTOM, 0, 0)
                        phb.shieldbackdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.CustomShieldBarHeight)
                    end
                end

                psb.backdrop:ClearAnchors()
                if not UnitFrames.SV.HideBarStamina then
                    if phb.shieldbackdrop then
                        psb.backdrop:SetAnchor(TOP, phb.shieldbackdrop, BOTTOMRIGHT, 0, UnitFrames.SV.PlayerBarSpacing)
                    else
                        psb.backdrop:SetAnchor(TOP, phb.backdrop, BOTTOMRIGHT, 0, UnitFrames.SV.PlayerBarSpacing)
                    end
                    psb.backdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightStamina)
                end
            else
                psb.backdrop:ClearAnchors()
                if not UnitFrames.SV.HideBarStamina then
                    if phb.shieldbackdrop then
                        phb.shieldbackdrop:ClearAnchors()
                        phb.shieldbackdrop:SetAnchor(TOP, phb.backdrop, BOTTOM, 0, 0)
                        phb.shieldbackdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.CustomShieldBarHeight)
                        psb.backdrop:SetAnchor(TOP, phb.shieldbackdrop, BOTTOMLEFT, 0, UnitFrames.SV.PlayerBarSpacing)
                    else
                        psb.backdrop:SetAnchor(TOP, phb.backdrop, BOTTOMLEFT, 0, UnitFrames.SV.PlayerBarSpacing)
                    end
                    psb.backdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightStamina)
                else
                    if phb.shieldbackdrop then
                        phb.shieldbackdrop:ClearAnchors()
                        phb.shieldbackdrop:SetAnchor(TOP, phb.backdrop, BOTTOM, 0, 0)
                        phb.shieldbackdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.CustomShieldBarHeight)
                    end
                end

                pmb.backdrop:ClearAnchors()
                if not UnitFrames.SV.HideBarMagicka then
                    if phb.shieldbackdrop then
                        pmb.backdrop:SetAnchor(TOP, phb.shieldbackdrop, BOTTOMRIGHT, 0, UnitFrames.SV.PlayerBarSpacing)
                    else
                        pmb.backdrop:SetAnchor(TOP, phb.backdrop, BOTTOMRIGHT, 0, UnitFrames.SV.PlayerBarSpacing)
                    end
                    pmb.backdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightMagicka)
                end
            end

            player.botInfo:SetWidth(UnitFrames.SV.PlayerBarWidth)
            player.buffAnchor:SetWidth(UnitFrames.SV.PlayerBarWidth)
            alt.backdrop:SetWidth(altW)

            if not UnitFrames.SV.HideLabelHealth then
                phb.labelOne:SetDimensions(UnitFrames.SV.PlayerBarWidth - 50, UnitFrames.SV.PlayerBarHeightHealth - 2)
                phb.labelTwo:SetDimensions(UnitFrames.SV.PlayerBarWidth - 50, UnitFrames.SV.PlayerBarHeightHealth - 2)
            end
            if not UnitFrames.SV.HideLabelMagicka then
                pmb.labelOne:SetDimensions(UnitFrames.SV.PlayerBarWidth - 50, UnitFrames.SV.PlayerBarHeightMagicka - 2)
                pmb.labelTwo:SetDimensions(UnitFrames.SV.PlayerBarWidth - 50, UnitFrames.SV.PlayerBarHeightMagicka - 2)
            end
            if not UnitFrames.SV.HideLabelStamina then
                psb.labelOne:SetDimensions(UnitFrames.SV.PlayerBarWidth - 50, UnitFrames.SV.PlayerBarHeightStamina - 2)
                psb.labelTwo:SetDimensions(UnitFrames.SV.PlayerBarWidth - 50, UnitFrames.SV.PlayerBarHeightStamina - 2)
            end
        end
        if unhide then
            player.tlw:SetHidden(false)
        end
    end

    -- Target frame
    if UnitFrames.CustomFrames.reticleover then
        local target = UnitFrames.CustomFrames.reticleover

        local thb = target[COMBAT_MECHANIC_FLAGS_HEALTH] -- Not a backdrop

        target.tlw:SetDimensions(UnitFrames.SV.TargetBarWidth, UnitFrames.SV.TargetBarHeight + (thb.shieldbackdrop and UnitFrames.SV.CustomShieldBarHeight or 0))
        target.control:SetDimensions(UnitFrames.SV.TargetBarWidth, UnitFrames.SV.TargetBarHeight + (thb.shieldbackdrop and UnitFrames.SV.CustomShieldBarHeight or 0))
        target.topInfo:SetWidth(UnitFrames.SV.TargetBarWidth)
        target.botInfo:SetWidth(UnitFrames.SV.TargetBarWidth)
        target.buffAnchor:SetWidth(UnitFrames.SV.TargetBarWidth)

        target.name:SetWidth(UnitFrames.SV.TargetBarWidth - 50)
        target.title:SetWidth(UnitFrames.SV.TargetBarWidth - 50)

        if UnitFrames.SV.PlayerFrameOptions == 1 then
            target.buffs:SetWidth(UnitFrames.SV.TargetBarWidth)
            target.debuffs:SetWidth(UnitFrames.SV.TargetBarWidth)
        else
            target.buffs:SetWidth(1000)
            target.debuffs:SetWidth(1000)
        end

        if not UnitFrames.SV.TargetEnableTitle and not UnitFrames.SV.TargetEnableRank then
            target.title:SetHidden(true)
        else
            target.title:SetHidden(false)
        end
        target.avaRank:SetHidden(not UnitFrames.SV.TargetEnableRankIcon)
        target.avaRankIcon:SetHidden(not UnitFrames.SV.TargetEnableRankIcon)

        local enable
        if not UnitFrames.SV.TargetEnableTitle and not UnitFrames.SV.TargetEnableRank and not UnitFrames.SV.TargetEnableRankIcon then
            enable = false
        else
            enable = true
        end

        if UnitFrames.SV.PlayerFrameOptions == 1 then
            target.buffs:ClearAnchors()
            target.buffs:SetAnchor(TOP, not enable and target.control or target.buffAnchor, BOTTOM, 0, 5)
        else
            target.debuffs:ClearAnchors()
            target.debuffs:SetAnchor(TOP, not enable and target.control or target.buffAnchor, BOTTOM, 0, 5)
        end

        target.levelIcon:ClearAnchors()
        target.levelIcon:SetAnchor(LEFT, target.topInfo, LEFT, target.name:GetTextWidth() + 1, 0)

        target.skull:SetDimensions(2 * UnitFrames.SV.TargetBarHeight, 2 * UnitFrames.SV.TargetBarHeight)

        thb.backdrop:SetDimensions(UnitFrames.SV.TargetBarWidth, UnitFrames.SV.TargetBarHeight)
        if thb.shieldbackdrop then
            thb.shieldbackdrop:ClearAnchors()
            thb.shieldbackdrop:SetAnchor(TOP, thb.backdrop, BOTTOM, 0, 0)
            thb.shieldbackdrop:SetDimensions(UnitFrames.SV.TargetBarWidth, UnitFrames.SV.CustomShieldBarHeight)
        end

        thb.labelOne:SetDimensions(UnitFrames.SV.TargetBarWidth - 50, UnitFrames.SV.TargetBarHeight - 2)
        thb.labelTwo:SetDimensions(UnitFrames.SV.TargetBarWidth - 50, UnitFrames.SV.TargetBarHeight - 2)

        if unhide then
            target.tlw:SetHidden(false)
            target.control:SetHidden(false)
        end
    end

    -- Another Target frame (for PvP)
    if UnitFrames.CustomFrames.AvaPlayerTarget then
        local target = UnitFrames.CustomFrames.AvaPlayerTarget

        local thb = target[COMBAT_MECHANIC_FLAGS_HEALTH] -- Not a backdrop

        target.tlw:SetDimensions(UnitFrames.SV.AvaTargetBarWidth, UnitFrames.SV.AvaTargetBarHeight + (thb.shieldbackdrop and UnitFrames.SV.CustomShieldBarHeight or 0))
        target.control:SetDimensions(UnitFrames.SV.AvaTargetBarWidth, UnitFrames.SV.AvaTargetBarHeight + (thb.shieldbackdrop and UnitFrames.SV.CustomShieldBarHeight or 0))
        target.topInfo:SetWidth(UnitFrames.SV.AvaTargetBarWidth)
        target.botInfo:SetWidth(UnitFrames.SV.AvaTargetBarWidth)
        target.buffAnchor:SetWidth(UnitFrames.SV.AvaTargetBarWidth)

        target.name:SetWidth(UnitFrames.SV.AvaTargetBarWidth - 50)

        thb.backdrop:SetDimensions(UnitFrames.SV.AvaTargetBarWidth, UnitFrames.SV.AvaTargetBarHeight)
        if thb.shieldbackdrop then
            thb.shieldbackdrop:ClearAnchors()
            thb.shieldbackdrop:SetAnchor(TOP, thb.backdrop, BOTTOM, 0, 0)
            thb.shieldbackdrop:SetDimensions(UnitFrames.SV.AvaTargetBarWidth, UnitFrames.SV.CustomShieldBarHeight)
        end

        thb.label:SetHeight(UnitFrames.SV.AvaTargetBarHeight - 2)
        thb.labelOne:SetHeight(UnitFrames.SV.AvaTargetBarHeight - 2)
        thb.labelTwo:SetHeight(UnitFrames.SV.AvaTargetBarHeight - 2)

        if unhide then
            target.tlw:SetHidden(false)
            target.control:SetHidden(false)
        end
    end
end

-- Set dimensions of custom group frame and anchors or raid group members
function UnitFrames.CustomFramesApplyLayoutGroup(unhide)
    if not UnitFrames.CustomFrames["SmallGroup1"] then
        return
    end

    -- If SmallGroup1 exists but doesn't have a tlw property, return to avoid nil errors
    if not UnitFrames.CustomFrames["SmallGroup1"].tlw then
        return
    end

    local groupBarHeight = UnitFrames.SV.GroupBarHeight
    if UnitFrames.SV.CustomShieldBarSeparate then
        groupBarHeight = groupBarHeight + UnitFrames.SV.CustomShieldBarHeight
    end

    local group = UnitFrames.CustomFrames["SmallGroup1"].tlw
    group:SetDimensions(UnitFrames.SV.GroupBarWidth, groupBarHeight * 4 + UnitFrames.SV.GroupBarSpacing * 3.5)

    for i = 1, 4 do
        local unitFrame = UnitFrames.CustomFrames["SmallGroup" .. i]
        local unitTag = GetGroupUnitTagByIndex(i)

        local ghb = unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH] -- Not a backdrop
        local phb = nil                                     -- TODO: Not sure what changing the anchors below to the proper "ghb" would do so leaving this here (everything already works)

        unitFrame.control:ClearAnchors()
        unitFrame.control:SetAnchor(TOPLEFT, group, TOPLEFT, 0, 0.5 * UnitFrames.SV.GroupBarSpacing + (groupBarHeight + UnitFrames.SV.GroupBarSpacing) * (i - 1))
        unitFrame.control:SetDimensions(UnitFrames.SV.GroupBarWidth, groupBarHeight)
        unitFrame.topInfo:SetWidth(UnitFrames.SV.GroupBarWidth - 5)

        unitFrame.levelIcon:ClearAnchors()

        if IsUnitGroupLeader(unitTag) then
            unitFrame.name:SetWidth(UnitFrames.SV.GroupBarWidth - 137)
            unitFrame.name:ClearAnchors()
            unitFrame.name:SetAnchor(LEFT, unitFrame.topInfo, LEFT, 22, -8)
            unitFrame.levelIcon:SetAnchor(LEFT, unitFrame.topInfo, LEFT, unitFrame.name:GetTextWidth() + 23, 0)
            unitFrame.leader:SetTexture(leaderIcons[1])
        else
            unitFrame.name:SetWidth(UnitFrames.SV.GroupBarWidth - 115)
            unitFrame.name:ClearAnchors()
            unitFrame.name:SetAnchor(LEFT, unitFrame.topInfo, LEFT, 0, -8)
            unitFrame.levelIcon:SetAnchor(LEFT, unitFrame.topInfo, LEFT, unitFrame.name:GetTextWidth() + 1, 0)
            unitFrame.leader:SetTexture(leaderIcons[0])
        end

        ghb.backdrop:SetDimensions(UnitFrames.SV.GroupBarWidth, UnitFrames.SV.GroupBarHeight)
        if ghb.shieldbackdrop then
            ghb.shieldbackdrop:ClearAnchors()
            ghb.shieldbackdrop:SetAnchor(TOP, ghb.backdrop, BOTTOM, 0, 0)
            ghb.shieldbackdrop:SetDimensions(UnitFrames.SV.GroupBarWidth, UnitFrames.SV.CustomShieldBarHeight)
        end

        local role = GetGroupMemberSelectedRole(unitTag)

        -- First HP Label
        if UnitFrames.SV.RoleIconSmallGroup and role then
            ghb.labelOne:SetDimensions(UnitFrames.SV.GroupBarWidth - 52, UnitFrames.SV.GroupBarHeight - 2)
            ghb.labelOne:SetAnchor(LEFT, phb, LEFT, 25, 0)
            unitFrame.dead:ClearAnchors()
            unitFrame.dead:SetAnchor(LEFT, phb, LEFT, 25, 0)
        else
            ghb.labelOne:SetDimensions(UnitFrames.SV.GroupBarWidth - 72, UnitFrames.SV.GroupBarHeight - 2)
            ghb.labelOne:SetAnchor(LEFT, phb, LEFT, 5, 0)
            unitFrame.dead:ClearAnchors()
            unitFrame.dead:SetAnchor(LEFT, phb, LEFT, 5, 0)
        end
        unitFrame.roleIcon:SetHidden(not UnitFrames.SV.RoleIconSmallGroup)

        -- Second HP Label
        ghb.labelTwo:SetDimensions(UnitFrames.SV.GroupBarWidth - 50, UnitFrames.SV.GroupBarHeight - 2)
    end

    if unhide then
        group:SetHidden(false)
    end
end

local function insertRole(list, currentRole)
    for index = 1, GetGroupSize() do
        local playerRole = GetGroupMemberSelectedRole(GetGroupUnitTagByIndex(index))
        if playerRole == currentRole then
            table.insert(list, index)
        end
    end
end

--- @param index number
--- @param itemsPerColumn number
--- @param spacerHeight number
--- @return number xOffset
--- @return number yOffset
local function calculateFramePosition(index, itemsPerColumn, spacerHeight)
    local column = zo_floor((index - 1) / itemsPerColumn)
    local row = (index - 1) % itemsPerColumn + 1
    local xOffset = UnitFrames.SV.RaidBarWidth * column
    local yOffset = UnitFrames.SV.RaidBarHeight * (row - 1)

    -- Add spacers if enabled (every 4 members)
    if UnitFrames.SV.RaidSpacers then
        -- Calculate how many spacer sections we've passed in the current column
        local spacersInCurrentColumn = zo_floor((row - 1) / 4)
        yOffset = yOffset + (spacerHeight * spacersInCurrentColumn)
    end

    return xOffset, yOffset
end

local function applyIconSettings(unitFrame, unitTag, role, rhb)
    local nameWidth = UnitFrames.SV.RaidBarWidth - UnitFrames.SV.RaidNameClip - 27
    local nameHeight = UnitFrames.SV.RaidBarHeight - 2

    if UnitFrames.SV.RaidIconOptions == nil then
        UnitFrames.SV.RaidIconOptions = 1
    end

    if UnitFrames.SV.RaidIconOptions > 1 then
        if UnitFrames.SV.RaidIconOptions == 2 then
            unitFrame.name:SetDimensions(nameWidth, nameHeight)
            unitFrame.name:SetAnchor(LEFT, rhb, LEFT, 22, 0)
            unitFrame.roleIcon:SetHidden(true)
            unitFrame.classIcon:SetHidden(false)
        elseif UnitFrames.SV.RaidIconOptions == 3 then
            if role ~= nil then
                unitFrame.name:SetDimensions(nameWidth, nameHeight)
                unitFrame.name:SetAnchor(LEFT, rhb, LEFT, 22, 0)
                unitFrame.roleIcon:SetHidden(false)
                unitFrame.classIcon:SetHidden(true)
            else
                unitFrame.name:SetDimensions(UnitFrames.SV.RaidBarWidth - UnitFrames.SV.RaidNameClip - 10, nameHeight)
                unitFrame.name:SetAnchor(LEFT, rhb, LEFT, 5, 0)
                unitFrame.roleIcon:SetHidden(true)
                unitFrame.classIcon:SetHidden(true)
            end
        elseif UnitFrames.SV.RaidIconOptions == 4 then
            if LUIE.ResolvePVPZone() then
                unitFrame.name:SetDimensions(nameWidth, nameHeight)
                unitFrame.name:SetAnchor(LEFT, rhb, LEFT, 22, 0)
                unitFrame.roleIcon:SetHidden(true)
                unitFrame.classIcon:SetHidden(false)
            elseif role ~= nil then
                unitFrame.name:SetDimensions(nameWidth, nameHeight)
                unitFrame.name:SetAnchor(LEFT, rhb, LEFT, 22, 0)
                unitFrame.roleIcon:SetHidden(false)
                unitFrame.classIcon:SetHidden(true)
            else
                unitFrame.name:SetDimensions(UnitFrames.SV.RaidBarWidth - UnitFrames.SV.RaidNameClip - 10, nameHeight)
                unitFrame.name:SetAnchor(LEFT, rhb, LEFT, 5, 0)
                unitFrame.roleIcon:SetHidden(true)
                unitFrame.classIcon:SetHidden(true)
            end
        elseif UnitFrames.SV.RaidIconOptions == 5 then
            if LUIE.ResolvePVPZone() and role ~= nil then
                unitFrame.name:SetDimensions(nameWidth, nameHeight)
                unitFrame.name:SetAnchor(LEFT, rhb, LEFT, 22, 0)
                unitFrame.roleIcon:SetHidden(false)
                unitFrame.classIcon:SetHidden(true)
            elseif not LUIE.ResolvePVPZone() then
                unitFrame.name:SetDimensions(nameWidth, nameHeight)
                unitFrame.name:SetAnchor(LEFT, rhb, LEFT, 22, 0)
                unitFrame.roleIcon:SetHidden(true)
                unitFrame.classIcon:SetHidden(false)
            else
                unitFrame.name:SetDimensions(UnitFrames.SV.RaidBarWidth - UnitFrames.SV.RaidNameClip - 10, nameHeight)
                unitFrame.name:SetAnchor(LEFT, rhb, LEFT, 5, 0)
                unitFrame.roleIcon:SetHidden(true)
                unitFrame.classIcon:SetHidden(true)
            end
        end
    else
        unitFrame.name:SetDimensions(UnitFrames.SV.RaidBarWidth - UnitFrames.SV.RaidNameClip - 10, UnitFrames.SV.RaidBarHeight - 2)
        unitFrame.name:SetAnchor(LEFT, rhb, LEFT, 5, 0)
        unitFrame.roleIcon:SetHidden(true)
        unitFrame.classIcon:SetHidden(true)
    end
end

function UnitFrames.CustomFramesApplyLayoutRaid(unhide)
    -- Early return if raid group frames don't exist
    if not UnitFrames.CustomFrames["RaidGroup1"] then
        return
    end

    -- If RaidGroup1 exists but doesn't have a tlw property, return to avoid nil errors
    if not UnitFrames.CustomFrames["RaidGroup1"].tlw then
        return
    end

    -- Configuration constants
    local spacerHeight = 3

    -- Determine layout dimensions based on selected layout option
    local columns, rows
    if UnitFrames.SV.RaidLayout == "6 x 2" then
        columns, rows = 6, 2
    elseif UnitFrames.SV.RaidLayout == "3 x 4" then
        columns, rows = 3, 4
    elseif UnitFrames.SV.RaidLayout == "2 x 6" then
        columns, rows = 2, 6
    else -- Default "1 x 12"
        columns, rows = 1, 12
    end

    local itemsPerColumn = rows

    -- Get reference to main raid frame container
    local raid = UnitFrames.CustomFrames["RaidGroup1"].tlw

    -- Calculate total width including optional spacers
    local totalWidth = UnitFrames.SV.RaidBarWidth * columns
    if UnitFrames.SV.RaidSpacers then
        totalWidth = totalWidth + (spacerHeight * (rows / 4))
    end

    -- Set main frame dimensions
    raid:SetDimensions(totalWidth, UnitFrames.SV.RaidBarHeight * rows)

    -- Set preview dimensions
    local groupWidth = UnitFrames.SV.RaidBarWidth * columns
    local groupHeight = UnitFrames.SV.RaidBarHeight * rows
    raid.preview:SetDimensions(groupWidth, groupHeight)

    -- Build player list (sorted by role if enabled)
    local playerList = {}
    if UnitFrames.SV.SortRoleRaid then
        local roles = { LFG_ROLE_TANK, LFG_ROLE_HEAL, LFG_ROLE_DPS, LFG_ROLE_INVALID }
        for _, value in ipairs(roles) do
            insertRole(playerList, value)
        end
    end

    -- Position and configure each unit frame
    for i = 1, GetGroupSize() do
        local index = UnitFrames.SV.SortRoleRaid and playerList[i] or i
        local unitFrame = UnitFrames.CustomFrames["RaidGroup" .. index]
        local unitTag = GetGroupUnitTagByIndex(index)

        -- Calculate position based on layout
        local xOffset, yOffset = calculateFramePosition(i, itemsPerColumn, spacerHeight)

        -- Set frame position and dimensions
        unitFrame.control:ClearAnchors()
        unitFrame.control:SetAnchor(TOPLEFT, raid, TOPLEFT, xOffset, yOffset)
        unitFrame.control:SetDimensions(UnitFrames.SV.RaidBarWidth, UnitFrames.SV.RaidBarHeight)

        -- Apply role and class icon settings
        local role = GetGroupMemberSelectedRole(unitTag)
        local rhb = nil -- Health bar reference for anchoring
        applyIconSettings(unitFrame, unitTag, role, rhb)

        -- Apply special settings for group leader
        if IsUnitGroupLeader(unitTag) then
            unitFrame.name:SetDimensions(UnitFrames.SV.RaidBarWidth - UnitFrames.SV.RaidNameClip - 27, UnitFrames.SV.RaidBarHeight - 2)
            unitFrame.name:SetAnchor(LEFT, rhb, LEFT, 22, 0)
            unitFrame.roleIcon:SetHidden(true)
            unitFrame.classIcon:SetHidden(true)
            unitFrame.leader:SetTexture(leaderIcons[1])
        else
            unitFrame.leader:SetTexture(leaderIcons[0])
        end

        -- Set dimensions for death and health labels
        unitFrame.dead:SetDimensions(UnitFrames.SV.RaidBarWidth - 50, UnitFrames.SV.RaidBarHeight - 2)
        unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH].label:SetDimensions(UnitFrames.SV.RaidBarWidth - 50, UnitFrames.SV.RaidBarHeight - 2)

        -- Special settings for offline players
        if not IsUnitOnline(unitTag) then
            unitFrame.name:SetDimensions(UnitFrames.SV.RaidBarWidth - UnitFrames.SV.RaidNameClip, UnitFrames.SV.RaidBarHeight - 2)
            unitFrame.name:SetAnchor(LEFT, rhb, LEFT, 5, 0)
            unitFrame.classIcon:SetHidden(true)
        end
    end

    -- Show raid frames if requested
    if unhide then
        raid:SetHidden(false)
    end
end

-- Set dimensions of custom companion frame and anchors
function UnitFrames.CustomFramesApplyLayoutCompanion(unhide)
    if not UnitFrames.CustomFrames["companion"] then
        return
    end

    if not UnitFrames.CustomFrames["companion"].tlw then
        return
    end

    local companion = UnitFrames.CustomFrames["companion"].tlw
    companion:SetDimensions(UnitFrames.SV.CompanionWidth, UnitFrames.SV.CompanionHeight)

    local unitFrame = UnitFrames.CustomFrames["companion"]
    unitFrame.control:ClearAnchors()
    unitFrame.control:SetAnchorFill()
    unitFrame.control:SetDimensions(UnitFrames.SV.CompanionWidth, UnitFrames.SV.CompanionHeight)
    unitFrame.name:SetDimensions(UnitFrames.SV.CompanionWidth - UnitFrames.SV.CompanionNameClip - 10, UnitFrames.SV.CompanionHeight - 2)
    unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH].label:SetDimensions(UnitFrames.SV.CompanionWidth - 50, UnitFrames.SV.CompanionHeight - 2)

    if unhide then
        companion:SetHidden(false)
    end
end

-- Set dimensions of custom pet frame and anchors
function UnitFrames.CustomFramesApplyLayoutPet(unhide)
    if not UnitFrames.CustomFrames["PetGroup1"] then
        return
    end

    if not UnitFrames.CustomFrames["PetGroup1"].tlw then
        return
    end

    local pet = UnitFrames.CustomFrames["PetGroup1"].tlw
    pet:SetDimensions(UnitFrames.SV.PetWidth, UnitFrames.SV.PetHeight * 7 + 21)

    for i = 1, 7 do
        local unitFrame = UnitFrames.CustomFrames["PetGroup" .. i]

        unitFrame.control:ClearAnchors()
        unitFrame.control:SetAnchor(TOPLEFT, pet, TOPLEFT, 0, (UnitFrames.SV.PetHeight + 3) * (i - 1))
        unitFrame.control:SetDimensions(UnitFrames.SV.PetWidth, UnitFrames.SV.PetHeight)
        unitFrame.name:SetDimensions(UnitFrames.SV.PetWidth - UnitFrames.SV.PetNameClip - 10, UnitFrames.SV.PetHeight - 2)
        unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH].label:SetDimensions(UnitFrames.SV.PetWidth - 50, UnitFrames.SV.PetHeight - 2)
    end

    if unhide then
        pet:SetHidden(false)
    end
end

-- Set dimensions of custom raid frame and anchors or raid group members
function UnitFrames.CustomFramesApplyLayoutBosses()
    if not UnitFrames.CustomFrames["boss1"] then
        return
    end
    if not UnitFrames.CustomFrames["boss1"].tlw then
        return
    end

    local bosses = UnitFrames.CustomFrames["boss1"].tlw

    bosses:SetDimensions(UnitFrames.SV.BossBarWidth, UnitFrames.SV.BossBarHeight * 6 + 2 * 5)

    for i = 1, 7 do
        local unitFrame = UnitFrames.CustomFrames["boss" .. i]

        unitFrame.control:ClearAnchors()
        unitFrame.control:SetAnchor(TOPLEFT, bosses, TOPLEFT, 0, (UnitFrames.SV.BossBarHeight + 2) * (i - 1))
        unitFrame.control:SetDimensions(UnitFrames.SV.BossBarWidth, UnitFrames.SV.BossBarHeight)

        unitFrame.name:SetDimensions(UnitFrames.SV.BossBarWidth - 50, UnitFrames.SV.BossBarHeight - 2)

        unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH].label:SetDimensions(UnitFrames.SV.BossBarWidth - 50, UnitFrames.SV.BossBarHeight - 2)
    end

    bosses:SetHidden(false)
end

-- This function reduces opacity of custom frames when player is out of combat and has full attributes
function UnitFrames.CustomFramesApplyInCombat()
    local idle = true
    if UnitFrames.SV.CustomOocAlphaPower then
        for _, value in pairs(UnitFrames.statFull) do
            idle = idle and value
        end
    else
        idle = UnitFrames.statFull.combat
    end

    local oocAlphaPlayer = 0.01 * UnitFrames.SV.PlayerOocAlpha
    local incAlphaPlayer = 0.01 * UnitFrames.SV.PlayerIncAlpha

    local oocAlphaTarget = 0.01 * UnitFrames.SV.TargetOocAlpha
    local incAlphaTarget = 0.01 * UnitFrames.SV.TargetIncAlpha

    local oocAlphaBoss = 0.01 * UnitFrames.SV.BossOocAlpha
    local incAlphaBoss = 0.01 * UnitFrames.SV.BossIncAlpha

    local oocAlphaPet = 0.01 * UnitFrames.SV.PetOocAlpha
    local incAlphaPet = 0.01 * UnitFrames.SV.PetIncAlpha

    local oocAlphaCompanion = 0.01 * UnitFrames.SV.CompanionOocAlpha
    local incAlphaCompanion = 0.01 * UnitFrames.SV.CompanionIncAlpha

    -- Apply to all frames
    if UnitFrames.CustomFrames["player"] and UnitFrames.CustomFrames["player"].tlw then
        UnitFrames.CustomFrames["player"].control:SetAlpha(idle and oocAlphaPlayer or incAlphaPlayer)
        if UnitFrames.SV.HideBuffsPlayerOoc then
            UnitFrames.CustomFrames["player"].buffs:SetHidden(idle and true or false)
            UnitFrames.CustomFrames["player"].debuffs:SetHidden(idle and true or false)
        else
            UnitFrames.CustomFrames["player"].buffs:SetHidden(false)
            UnitFrames.CustomFrames["player"].debuffs:SetHidden(false)
        end
    end
    if UnitFrames.CustomFrames["AvaPlayerTarget"] and UnitFrames.CustomFrames["AvaPlayerTarget"].tlw then
        UnitFrames.CustomFrames["AvaPlayerTarget"].control:SetAlpha(idle and oocAlphaTarget or incAlphaTarget)
    end
    if UnitFrames.CustomFrames["reticleover"] and UnitFrames.CustomFrames["reticleover"].tlw then
        UnitFrames.CustomFrames["reticleover"].control:SetAlpha(idle and oocAlphaTarget or incAlphaTarget)
        if UnitFrames.SV.HideBuffsTargetOoc then
            UnitFrames.CustomFrames["reticleover"].buffs:SetHidden(idle and true or false)
            UnitFrames.CustomFrames["reticleover"].debuffs:SetHidden(idle and true or false)
        else
            UnitFrames.CustomFrames["reticleover"].buffs:SetHidden(false)
            UnitFrames.CustomFrames["reticleover"].debuffs:SetHidden(false)
        end
    end

    -- Set companion transparency
    if UnitFrames.CustomFrames["companion"] and UnitFrames.CustomFrames["companion"].tlw then
        UnitFrames.CustomFrames["companion"].control:SetAlpha(idle and oocAlphaCompanion or incAlphaCompanion)
    end

    -- Set boss transparency
    for i = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
        local unitTag = "boss" .. i
        if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag].tlw then
            UnitFrames.CustomFrames[unitTag].control:SetAlpha(idle and oocAlphaBoss or incAlphaBoss)
        end
    end

    -- Set pet transparency
    for i = 1, 7 do
        local unitTag = "PetGroup" .. i
        if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag].tlw then
            UnitFrames.CustomFrames[unitTag].control:SetAlpha(idle and oocAlphaPet or incAlphaPet)
        end
    end
end

function UnitFrames.CustomFramesGroupAlpha()
    local alphaGroup = 0.01 * UnitFrames.SV.GroupAlpha

    for i = 1, 4 do
        local unitTag = "SmallGroup" .. i
        if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag].tlw then
            UnitFrames.CustomFrames[unitTag].control:SetAlpha(IsUnitInGroupSupportRange(UnitFrames.CustomFrames[unitTag].unitTag) and alphaGroup or (alphaGroup / 2))
        end
    end

    for i = 1, 12 do
        local unitTag = "RaidGroup" .. i
        if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag].tlw then
            UnitFrames.CustomFrames[unitTag].control:SetAlpha(IsUnitInGroupSupportRange(UnitFrames.CustomFrames[unitTag].unitTag) and alphaGroup or (alphaGroup / 2))
        end
    end
end

function UnitFrames.CustomFramesReloadLowResourceThreshold()
    UnitFrames.healthThreshold = UnitFrames.SV.LowResourceHealth
    UnitFrames.magickaThreshold = UnitFrames.SV.LowResourceMagicka
    UnitFrames.staminaThreshold = UnitFrames.SV.LowResourceStamina

    if UnitFrames.CustomFrames["player"] and UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_HEALTH] then
        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_HEALTH].threshold = UnitFrames.healthThreshold
    end
    if UnitFrames.CustomFrames["player"] and UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_MAGICKA] then
        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_MAGICKA].threshold = UnitFrames.magickaThreshold
    end
    if UnitFrames.CustomFrames["player"] and UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_STAMINA] then
        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_STAMINA].threshold = UnitFrames.staminaThreshold
    end
end

-- Updates group frames when a relevant social change event happens
function UnitFrames.SocialUpdateFrames()
    for i = 1, 12 do
        local unitTag = "group" .. i
        if DoesUnitExist(unitTag) then
            UnitFrames.ReloadValues(unitTag)
        end
    end
    UnitFrames.ReloadValues("reticleover")
end
