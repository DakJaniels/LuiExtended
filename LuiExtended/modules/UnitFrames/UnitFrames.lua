-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Unit Frames namespace
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames
--- @class LUIE_CustomFrameObject
local FrameObject = LUIE_CustomFrameObject

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

local leaderIcons =
{
    [0] = [[/esoui/art/icons/heraldrycrests_misc_blank_01.dds]],
    [1] = [[/esoui/art/icons/guildranks/guild_rankicon_misc01.dds]],
}

local moduleName = UnitFrames.moduleName


-- local group
-- local unitTag
-- local playerTlw

local g_PendingUpdate =
{
    Group = { flag = false, delay = 200, name = moduleName .. "PendingGroupUpdate" },
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
            -- Default alignment to 1 when nil
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
            UnitFrames.PlayerDodgePrediction.StopStaminaBarSmoothAnimation(stamBar.bar)
        end
        UnitFrames.PlayerDodgePrediction.Refresh()
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
    local isCharacterSpecific = LUIE.IsCharacterSpecificSavedVarsEnabled()
    if isCharacterSpecific then
        UnitFrames.SV = ZO_SavedVars:New(LUIE.ModuleSavedVarNames.UnitFrames, LUIE.SVVer, nil, UnitFrames.Defaults, LUIE.SavedVarsProfile)
    else
        UnitFrames.SV = ZO_SavedVars:NewAccountWide(LUIE.ModuleSavedVarNames.UnitFrames, LUIE.SVVer, nil, UnitFrames.Defaults, LUIE.SavedVarsProfile)
    end

    -- Migrate old string-based font styles to numeric constants (run once)
    -- Migrate font styles (string/display/nil -> valid 0-7); run once per account.
    -- Per-category CustomFrameAppearance.fontStyle values are normalized inside
    -- MigrateCustomFrameAppearance, so only the default font style is handled here.
    if not LUIE.IsMigrationDone("unitframes_fontstyles_v2") then
        UnitFrames.SV.DefaultFontStyle = LUIE.MigrateFontStyle(UnitFrames.SV.DefaultFontStyle)
        LUIE.MarkMigrationDone("unitframes_fontstyles_v2")
    end

    UnitFrames.MigrateCustomFrameAppearance()
    UnitFrames.MigrateCustomFrameAppearanceCompactFontSync()
    UnitFrames.MigrateLuiMediaAppearanceKeys()
    UnitFrames.MigratePlayerTargetLabelFormats()
    UnitFrames.MigrateCanonicalFormatStrings()
    UnitFrames.MigratePlayerTargetOverlayFlags()
    UnitFrames.MigratePowerOverlayDefaultOff()
    UnitFrames.MigrateVeterancyOverlandPerFrameType()

    if UnitFrames.SV.DefaultOocTransparency < 0 or UnitFrames.SV.DefaultOocTransparency > 100 then
        UnitFrames.SV.DefaultOocTransparency = UnitFrames.Defaults.DefaultOocTransparency
    end
    if UnitFrames.SV.DefaultIncTransparency < 0 or UnitFrames.SV.DefaultIncTransparency > 100 then
        UnitFrames.SV.DefaultIncTransparency = UnitFrames.Defaults.DefaultIncTransparency
    end
    if UnitFrames.SV.CustomColourShield and UnitFrames.SV.CustomColourShield[4] == nil then
        UnitFrames.SV.CustomColourShield[4] = UnitFrames.Defaults.CustomColourShield[4]
    end

    -- Disable module if setting not toggled on
    if not enabled then
        return
    end
    UnitFrames.Enabled = true

    UnitFrames.InitializeBossThresholdCrutchCache()

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
    local coreAw = LUIE.GetCoreAccountWideRawTable()
    if not coreAw.AdjustVarsUF then
        coreAw.AdjustVarsUF = 0
    end
    if coreAw.AdjustVarsUF < 2 then
        UnitFrames.SV["CustomFramesPetFramePos"] = nil
    end
    -- Increment so this doesn't occur again.
    coreAw.AdjustVarsUF = 2

    if not UnitFrames.companionAbilityTrack then
        UnitFrames.companionAbilityTrack = LUIE_CompanionAbilityTrack:New()
    end
    if not UnitFrames.companionRapportFlourish then
        UnitFrames.companionRapportFlourish = LUIE_CompanionRapportFlourish:New()
    end

    UnitFrames.CreateDefaultFrames()
    UnitFrames.CreateCustomFrames()
    UnitFrames.ApplyHideDefaultPlayerAttributeBarsIfNeeded()
    UnitFrames.PlayerDodgePrediction.Initialize()

    -- Initialize LibGroupBroadcast integrations if available
    if UnitFrames.GroupResources then
        UnitFrames.GroupResources.Initialize()
        UnitFrames.GroupResources.SetupFrames()
    end

    -- Initialize GroupCombatStats
    if UnitFrames.GroupCombatStats then
        UnitFrames.GroupCombatStats.Initialize()
        UnitFrames.GroupCombatStats.SetupFrames()
    end

    -- Initialize GroupPotionCooldowns
    if UnitFrames.GroupPotionCooldowns then
        UnitFrames.GroupPotionCooldowns.Initialize()
        UnitFrames.GroupPotionCooldowns.SetupFrames()
    end

    -- Initialize GroupFoodDrinkBuff
    if UnitFrames.GroupFoodDrinkBuff then
        UnitFrames.GroupFoodDrinkBuff.Initialize()
    end

    if UnitFrames.companionAbilityTrack then
        UnitFrames.companionAbilityTrack:Initialize()
    end

    UnitFrames.ResetCompassBarMenu()

    UnitFrames.SaveDefaultFramePositions()
    UnitFrames.RepositionDefaultFrames()
    UnitFrames.SetDefaultFramesTransparency()

    -- Initialize visualizer coordinators for all tracked units
    -- Each coordinator registers its own attribute visual events with unit tag filtering
    UnitFrames.InitializeDefaultVisualizers()

    -- Set event handlers
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED, UnitFrames.OnPlayerActivated)
    -- eventManager:RegisterForEvent(moduleName, EVENT_POWER_UPDATE, UnitFrames.OnPowerUpdate) -- Now handled by UnitFrames_MostRecentPowerUpdateHandler
    UnitFrames.RegisterRecentEventHandler()

    -- Note: EVENT_UNIT_ATTRIBUTE_VISUAL_* events now handled per-unit by coordinator instances
    eventManager:RegisterForEvent(moduleName, EVENT_TARGET_CHANGED, UnitFrames.OnTargetChange)
    eventManager:RegisterForEvent(moduleName, EVENT_RETICLE_TARGET_CHANGED, UnitFrames.OnReticleTargetChanged)
    eventManager:RegisterForEvent(moduleName, EVENT_RETICLE_TARGET_PLAYER_CHANGED, UnitFrames.OnReticleTargetPlayerChanged)
    eventManager:RegisterForEvent(moduleName, EVENT_DISPOSITION_UPDATE, UnitFrames.OnDispositionUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_UNIT_CREATED, UnitFrames.OnUnitCreated)
    eventManager:RegisterForEvent(moduleName, EVENT_LEVEL_UPDATE, UnitFrames.OnLevelUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_CHAMPION_POINT_UPDATE, UnitFrames.OnLevelUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_TITLE_UPDATE, UnitFrames.TitleUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_RANK_POINT_UPDATE, UnitFrames.TitleUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_OVERLAND_DIFFICULTY_CHANGED, UnitFrames.RefreshVeterancyOverlandFrameStaticControls)
    eventManager:RegisterForEvent(moduleName, EVENT_ACTIVE_VETERANCY_SEASON_UPDATED, UnitFrames.RefreshVeterancyOverlandFrameStaticControls)

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
        UnitFrames.AlternativeBarRegisterEvents()
        eventManager:RegisterForEvent(moduleName, EVENT_GROUP_SUPPORT_RANGE_UPDATE, UnitFrames.OnGroupSupportRangeUpdate)
        eventManager:RegisterForEvent(moduleName, EVENT_GROUP_MEMBER_CONNECTED_STATUS, UnitFrames.OnGroupMemberConnectedStatus)
        eventManager:RegisterForEvent(moduleName, EVENT_GROUP_MEMBER_ROLE_CHANGED, UnitFrames.OnGroupMemberRoleChange)
        eventManager:RegisterForEvent(moduleName, EVENT_GROUP_UPDATE, UnitFrames.OnGroupMemberChange)
        eventManager:RegisterForEvent(moduleName, EVENT_GROUP_MEMBER_JOINED, UnitFrames.OnGroupMemberChange)
        eventManager:RegisterForEvent(moduleName, EVENT_GROUP_MEMBER_LEFT, UnitFrames.OnGroupMemberChange)
        eventManager:RegisterForEvent(moduleName, EVENT_UNIT_DEATH_STATE_CHANGED, UnitFrames.OnDeath)
        eventManager:RegisterForEvent(moduleName, EVENT_LEADER_UPDATE, UnitFrames.OnLeaderUpdate)
        eventManager:RegisterForEvent(moduleName, EVENT_BOSSES_CHANGED, UnitFrames.OnBossesChanged)

        UnitFrames.RegisterBossThresholdCrutchListener()

        eventManager:RegisterForEvent(moduleName, EVENT_GUILD_SELF_LEFT_GUILD, UnitFrames.SocialUpdateFrames)
        eventManager:RegisterForEvent(moduleName, EVENT_GUILD_SELF_JOINED_GUILD, UnitFrames.SocialUpdateFrames)
        eventManager:RegisterForEvent(moduleName, EVENT_GUILD_MEMBER_ADDED, UnitFrames.SocialUpdateFrames)
        eventManager:RegisterForEvent(moduleName, EVENT_GUILD_MEMBER_REMOVED, UnitFrames.SocialUpdateFrames)

        if UnitFrames.SV.CustomTargetMarker then
            eventManager:RegisterForEvent(moduleName, EVENT_TARGET_MARKER_UPDATE, UnitFrames.OnTargetMarkerUpdate)
        end

        -- Group Election Info
        UnitFrames.RegisterForGroupElectionEvents()

        -- Register for screen resolution changes to recalculate positioning
        eventManager:RegisterForEvent(moduleName, EVENT_SCREEN_RESIZED, function (eventId, pixelWidth, pixelHeight)
            -- if LUIE.IsDevDebugEnabled() then
            --     LUIE:Log("Debug", "Unit Frames: Screen resolution changed to " .. pixelWidth .. LUIE_TINY_X_FORMATTER .. pixelHeight .. " pixels, recalculating positions")
            -- end
            UnitFrames.CustomFramesSetPositions()
        end)

        -- Register periodic update for group combat glow (checks every 500ms)
        if UnitFrames.CustomFrames["SmallGroup1"] or UnitFrames.CustomFrames["RaidGroup1"] then
            eventManager:RegisterForUpdate(moduleName .. "_CombatGlow", 500, UnitFrames.UpdateGroupCombatGlow)
        end

        if UnitFrames.CustomFrames["companion"] then
            eventManager:RegisterForUpdate(moduleName .. "_CompanionCombat", 500, function ()
                UnitFrames.CustomFramesApplyCompanionInCombat()
                UnitFrames.UpdateCompanionCombatGlow()
            end)
        end
        if UnitFrames.CustomFrames["PetGroup1"] then
            eventManager:RegisterForUpdate(moduleName .. "_PetCombat", 500, function ()
                UnitFrames.CustomFramesApplyPetInCombat()
                UnitFrames.UpdatePetCombatGlow()
            end)
        end
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
    UnitFrames.TryShowPendingCrutchAlertsVersionWarning()

    UnitFrames.ApplyHideDefaultPlayerAttributeBarsIfNeeded()

    -- Reload values for player frames (this triggers visualizer OnUnitChanged which initializes all power types)
    UnitFrames.ReloadValues("player")

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
    UnitFrames.CustomFramesApplyColors()

    -- We need to call this here to clear companion/pet unit frames when entering houses/instances as they are not destroyed
    UnitFrames.CompanionUpdate()
    UnitFrames.CustomPetUpdate()
    UnitFrames.UpdatePlayerFrameDeathVisibility()
end

function UnitFrames.CustomFramesUnreferencePetControl(first)
    local last = 7
    for i = first, last do
        local unitTag = "PetGroup" .. i
        local frame = UnitFrames.CustomFrames[unitTag]
        if frame then
            frame.unitTag = nil
            if frame.SyncAttributeVisualizerUnitTag then
                frame:SyncAttributeVisualizerUnitTag()
            end
            frame.control:SetHidden(true)
        end
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
            UnitFrames.CustomFramesApplyCompanionInCombat(true)
            UnitFrames.UpdateCompanionCombatGlow()
        end
        if UnitFrames.companionAbilityTrack then
            UnitFrames.companionAbilityTrack:RefreshAll()
        end
    else
        UnitFrames.CustomFrames[unitTag].control:SetHidden(true)
        if UnitFrames.companionAbilityTrack then
            UnitFrames.companionAbilityTrack:RefreshAll()
        end
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
            local petFrame = UnitFrames.CustomFrames[v.unitTag]
            if petFrame.SyncAttributeVisualizerUnitTag then
                petFrame:SyncAttributeVisualizerUnitTag()
            end
            UnitFrames.ReloadValues(v.unitTag)
        end
    end
    UnitFrames.CustomFramesApplyPetInCombat(true)
    UnitFrames.UpdatePetCombatGlow()
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
    --     LUIE:Log("Debug",string_format("[%s] OnUnitCreated: %s (%s)", GetTimeString(), unitTag, GetUnitName(unitTag)))
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
            UnitFrames.ClearPowerUpdateSnapshot(unitTag)
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
            UnitFrames.ClearPowerUpdateSnapshot(unitTag)
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
    --     LUIE:Log("Debug",string_format("[%s] OnUnitDestroyed: %s (%s)", GetTimeString(), unitTag, GetUnitName(unitTag)))
    -- end
    UnitFrames.ClearPowerUpdateSnapshot(unitTag)
    -- Visualizer modules are singletons; nil their per-unitTag recency-info
    -- subtree so it can be collected (otherwise it persists for the session).
    UnitFrames.ClearVisualizerRecencyInfo(unitTag)
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

--- @param reactionType integer|nil
--- @return boolean
function UnitFrames.ShouldShowAvaPlayerTargetForReticleover(reactionType)
    if not UnitFrames.SV.AvaCustFramesTarget then
        return false
    end
    if not UnitFrames.CustomFrames["AvaPlayerTarget"] then
        return false
    end
    if not DoesUnitExist("reticleover") then
        return false
    end
    if not IsUnitPlayer("reticleover") then
        return false
    end
    if reactionType ~= UNIT_REACTION_HOSTILE then
        return false
    end
    if IsUnitDead("reticleover") then
        return false
    end
    return true
end

-- Clears the custom target frame and reticleover buffs (used when no target and not lingering, or when linger timeout fires).
function UnitFrames.ClearTargetFrame()
    UnitFrames.targetFrameLingered = false
    UnitFrames.savedHealth.reticleover = { 1, 1, 1, 0, 0 }
    if UnitFrames.CustomFrames["reticleover"] then
        UnitFrames.reticleoverHostile = false
        UnitFrames.CustomFrames["reticleover"].skull:SetHidden(true)
        UnitFrames.CustomFrames["reticleover"].control:SetHidden(true)
    end
    if UnitFrames.CustomFrames["AvaPlayerTarget"] then
        UnitFrames.CustomFrames["AvaPlayerTarget"].control:SetHidden(true)
    end
    if UnitFrames.SV.ReticleColourByReaction then
        ZO_ReticleContainerReticle:SetColor(1, 1, 1, 1)
    end
    if LUIE.SpellCastBuffs and LUIE.SpellCastBuffs.ReloadEffects then
        LUIE.SpellCastBuffs.ReloadEffects("reticleover")
    end
end

-- Runs on the EVENT_RETICLE_TARGET_CHANGED listener.
-- This handler fires every time the player's reticle target changes.
-- Used to read initial values of target's health and shield.
function UnitFrames.OnReticleTargetChanged(eventCode)
    if DoesUnitExist("reticleover") then
        if UnitFrames.targetLingerTimerActive then
            eventManager:UnregisterForUpdate(UnitFrames.targetLingerTimeoutName)
            UnitFrames.targetLingerTimerActive = false
        end
        UnitFrames.ReloadValues("reticleover")

        if UnitFrames.SV.TargetShowOverlandDifficulty and UnitFrames.CustomFrames["reticleover"] then
            UnitFrames.ScheduleReticleoverOverlandStaticRefresh()
        end

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
            UnitFrames.LayoutDefaultReticleoverTargetIcons()
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
            UnitFrames.reticleoverHostile = (reactionType == UNIT_REACTION_HOSTILE) and UnitFrames.SV.TargetEnableSkull
            UnitFrames.CustomFrames["reticleover"].skull:SetHidden(not UnitFrames.reticleoverHostile or (UnitFrames.savedHealth.reticleover[1] == 0) or (100 * UnitFrames.savedHealth.reticleover[1] / UnitFrames.savedHealth.reticleover[3] > UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH].threshold))
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

            local showAvaPlayerTarget = UnitFrames.ShouldShowAvaPlayerTargetForReticleover(reactionType)
            if not showAvaPlayerTarget then
                UnitFrames.CustomFrames["reticleover"].control:SetHidden(false)
                if UnitFrames.SV.QuickHideDead then
                    local isMonster
                    if UnitFrames.SV.QuickHideDeadUseUnitMonster and IsUnitMonster then
                        isMonster = IsUnitMonster("reticleover")
                    else
                        isMonster = IsGameCameraInteractableUnitMonster()
                    end
                    local isNPC = reactionType == UNIT_REACTION_NEUTRAL
                        or reactionType == UNIT_REACTION_FRIENDLY
                        or reactionType == UNIT_REACTION_NPC_ALLY
                        or (reactionType == UNIT_REACTION_HOSTILE and isMonster)
                    local shouldHide = IsUnitDead("reticleover") and isNPC
                    UnitFrames.CustomFrames["reticleover"].control:SetHidden(shouldHide)
                end
            else
                UnitFrames.CustomFrames["reticleover"].control:SetHidden(true)
            end
            UnitFrames.targetFrameLingered = true
        end

        local avaPlayerTargetFrame = UnitFrames.CustomFrames["AvaPlayerTarget"]
        if avaPlayerTargetFrame then
            local showAvaPlayerTarget = UnitFrames.ShouldShowAvaPlayerTargetForReticleover(reactionType)
            if showAvaPlayerTarget then
                avaPlayerTargetFrame.name:SetColor(color[1], color[2], color[3], 1)
                avaPlayerTargetFrame.className:SetColor(color[1], color[2], color[3], 1)
            end
            avaPlayerTargetFrame.control:SetHidden(not showAvaPlayerTarget)
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
        local linger = UnitFrames.SV.TargetLingerInCursorMode and UnitFrames.CustomFrames["reticleover"] and UnitFrames.targetFrameLingered
        if not linger then
            UnitFrames.ClearTargetFrame()

            --[[ Removed due to causing custom UI elements to abruptly fade out. Left here in case there is any reason to re-enable.
            if UnitFrames.DefaultFrames.reticleover[COMBAT_MECHANIC_FLAGS_HEALTH] then
                UnitFrames.DefaultFrames.reticleover[COMBAT_MECHANIC_FLAGS_HEALTH].label:SetHidden(true)
            end
            UnitFrames.DefaultFrames.reticleover.classIcon:SetHidden(true)
            UnitFrames.DefaultFrames.reticleover.friendIcon:SetHidden(true)
            ]]
            --
        else
            local duration = UnitFrames.SV.TargetLingerDuration and UnitFrames.SV.TargetLingerDuration > 0 and UnitFrames.SV.TargetLingerDuration or 0
            if duration > 0 and not UnitFrames.targetLingerTimerActive then
                UnitFrames.targetLingerTimerActive = true
                eventManager:RegisterForUpdate(UnitFrames.targetLingerTimeoutName, duration * 1000, function ()
                    eventManager:UnregisterForUpdate(UnitFrames.targetLingerTimeoutName)
                    UnitFrames.targetLingerTimerActive = false
                    UnitFrames.ClearTargetFrame()
                end)
            end
        end

        -- Revert back the color of reticle to white
        if UnitFrames.SV.ReticleColourByReaction then
            ZO_ReticleContainerReticle:SetColor(1, 1, 1, 1)
        end
    end

    -- Finally if user does not want to have default target frame we have to hide it here all the time
    if not UnitFrames.DefaultFrames.reticleover[COMBAT_MECHANIC_FLAGS_HEALTH] and UnitFrames.ShouldHideVanillaTargetFrameForCustomTarget() then
        ZO_TargetUnitFramereticleover:SetHidden(true)
    end
end

function UnitFrames.OnReticleTargetPlayerChanged(eventCode)
    local frame = UnitFrames.CustomFrames["reticleover"]
    if frame then
        FrameObject.UpdateStaticControls(frame)
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
    UnitFrames.ClearPowerUpdateSnapshot(unitTag)
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

    -- Trigger visualizer reinitialization (handles all visual states with proper sequence IDs)
    -- This replaces the manual module Update calls to keep sequence IDs in order
    UnitFrames.ForEachVisualizerForUnit(unitTag, function (coordinator)
        coordinator:OnUnitChanged()
    end)

    -- Now we need to update Name labels, classIcon
    UnitFrames.UpdateStaticControls(UnitFrames.DefaultFrames[unitTag])
    UnitFrames.UpdateStaticControls(UnitFrames.CustomFrames[unitTag])
    UnitFrames.UpdateStaticControls(UnitFrames.AvaCustFrames[unitTag])

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

-- Updates text labels, classIcon, etc (see _StaticControls/Generic.lua)
-- Called from EVENT_TITLE_UPDATE & EVENT_RANK_POINT_UPDATE
function UnitFrames.TitleUpdate(eventCode, unitTag)
    UnitFrames.UpdateStaticControls(UnitFrames.DefaultFrames[unitTag])
    UnitFrames.UpdateStaticControls(UnitFrames.CustomFrames[unitTag])
    UnitFrames.UpdateStaticControls(UnitFrames.AvaCustFrames[unitTag])
    UnitFrames.RefreshDefaultTargetLevelDisplayIfNeeded(unitTag)
end

-- Re-run UpdateStaticControls on player, target, and group after overland/veterancy season changes or related LAM toggles.
function UnitFrames.RefreshVeterancyOverlandFrameStaticControls()
    if UnitFrames.CustomFrames["reticleover"] then
        UnitFrames.UpdateStaticControls(UnitFrames.CustomFrames["reticleover"])
    end
    if UnitFrames.CustomFrames["AvaPlayerTarget"] then
        UnitFrames.UpdateStaticControls(UnitFrames.CustomFrames["AvaPlayerTarget"])
    end
    if UnitFrames.CustomFrames["player"] then
        UnitFrames.UpdateStaticControls(UnitFrames.CustomFrames["player"])
    end
    for i = 1, 12 do
        local unitTag = "group" .. i
        if UnitFrames.DefaultFrames[unitTag] and DoesUnitExist(unitTag) then
            UnitFrames.UpdateStaticControls(UnitFrames.DefaultFrames[unitTag])
        end
    end
    if UnitFrames.CustomFramesGroupUpdate then
        UnitFrames.CustomFramesGroupUpdate()
    end
end

function UnitFrames.RefreshCustomTargetFrameStaticControls()
    if UnitFrames.CustomFrames["reticleover"] then
        UnitFrames.UpdateStaticControls(UnitFrames.CustomFrames["reticleover"])
    end
end

function UnitFrames.RefreshCustomSmallGroupFrameStaticControls()
    for smallGroupIndex = 1, 4 do
        local registryKey = "SmallGroup" .. smallGroupIndex
        local unitFrame = UnitFrames.CustomFrames[registryKey]
        if unitFrame then
            UnitFrames.UpdateStaticControls(unitFrame)
        end
    end
end

-- Forces to reload static information on unit frames.
-- Called from EVENT_LEVEL_UPDATE and EVENT_VETERAN_RANK_UPDATE listeners.
function UnitFrames.OnLevelUpdate(eventCode, unitTag, level)
    UnitFrames.UpdateStaticControls(UnitFrames.DefaultFrames[unitTag])
    UnitFrames.UpdateStaticControls(UnitFrames.CustomFrames[unitTag])
    UnitFrames.UpdateStaticControls(UnitFrames.AvaCustFrames[unitTag])

    -- For Custom Player Frame we have to setup experience bar
    if unitTag == "player" and UnitFrames.CustomFrames["player"] and (UnitFrames.CustomFrames["player"].Experience or UnitFrames.CustomFrames["player"].ChampionXP) then
        UnitFrames.CustomFramesSetupAlternative()
    end

    UnitFrames.RefreshDefaultTargetLevelDisplayIfNeeded(unitTag)
end

-- Runs on the EVENT_PLAYER_COMBAT_STATE listener.
-- This handler fires every time player enters or leaves combat
function UnitFrames.OnPlayerCombatState(eventCode, inCombat)
    UnitFrames.statFull.combat = not inCombat
    UnitFrames.CustomFramesApplyInCombat()
end

local function UpdateFrameCombatGlow(frame, unitTag, glowColor)
    if not frame or not frame[COMBAT_MECHANIC_FLAGS_HEALTH] or not frame[COMBAT_MECHANIC_FLAGS_HEALTH].combatGlow then
        return
    end
    local glow = frame[COMBAT_MECHANIC_FLAGS_HEALTH].combatGlow
    if not unitTag or not DoesUnitExist(unitTag) then
        glow:SetHidden(true)
        return
    end
    local isInCombat = IsUnitActivelyEngaged(unitTag) or IsUnitInCombat(unitTag)
    if glowColor then
        glow:SetEdgeColor(glowColor[1], glowColor[2], glowColor[3], glowColor[4] or 1)
    end
    glow:SetHidden(not isInCombat)
end

local function UpdateGroupFrameCombatGlow(frame, unitTag, isGroupFrame)
    local glowColor = isGroupFrame and UnitFrames.SV.GroupCombatGlowColor or UnitFrames.SV.RaidCombatGlowColor
    UpdateFrameCombatGlow(frame, unitTag, glowColor)
end

-- Updates combat glow on group frames based on combat state
function UnitFrames.UpdateGroupCombatGlow()
    if not IsUnitGrouped("player") then
        return
    end
    if UnitFrames.SV.GroupCombatGlow and UnitFrames.CustomFrames["SmallGroup1"] and UnitFrames.CustomFrames["SmallGroup1"].tlw then
        for i = 1, 4 do
            local frame = UnitFrames.CustomFrames["SmallGroup" .. i]
            if frame then
                UpdateGroupFrameCombatGlow(frame, frame.unitTag, true)
            end
        end
    end
    if UnitFrames.SV.RaidCombatGlow and UnitFrames.CustomFrames["RaidGroup1"] and UnitFrames.CustomFrames["RaidGroup1"].tlw then
        for i = 1, 12 do
            local frame = UnitFrames.CustomFrames["RaidGroup" .. i]
            if frame then
                UpdateGroupFrameCombatGlow(frame, frame.unitTag, false)
            end
        end
    end
end

-- Updates combat glow border on the companion custom frame (per-unit combat state).
function UnitFrames.UpdateCompanionCombatGlow()
    if UnitFrames.SV.CompanionCombatGlow and UnitFrames.CustomFrames["companion"] and UnitFrames.CustomFrames["companion"].tlw then
        UpdateFrameCombatGlow(UnitFrames.CustomFrames["companion"], "companion", UnitFrames.SV.CompanionCombatGlowColor)
    elseif UnitFrames.CustomFrames["companion"] and UnitFrames.CustomFrames["companion"][COMBAT_MECHANIC_FLAGS_HEALTH] and UnitFrames.CustomFrames["companion"][COMBAT_MECHANIC_FLAGS_HEALTH].combatGlow then
        UnitFrames.CustomFrames["companion"][COMBAT_MECHANIC_FLAGS_HEALTH].combatGlow:SetHidden(true)
    end
end

-- Updates combat glow border on pet custom frames (per-unit combat state).
function UnitFrames.UpdatePetCombatGlow()
    if UnitFrames.SV.PetCombatGlow and UnitFrames.CustomFrames["PetGroup1"] and UnitFrames.CustomFrames["PetGroup1"].tlw then
        for i = 1, 7 do
            local frame = UnitFrames.CustomFrames["PetGroup" .. i]
            if frame and not frame.control:IsHidden() and frame.unitTag then
                UpdateFrameCombatGlow(frame, frame.unitTag, UnitFrames.SV.PetCombatGlowColor)
            elseif frame and frame[COMBAT_MECHANIC_FLAGS_HEALTH] and frame[COMBAT_MECHANIC_FLAGS_HEALTH].combatGlow then
                frame[COMBAT_MECHANIC_FLAGS_HEALTH].combatGlow:SetHidden(true)
            end
        end
    elseif UnitFrames.CustomFrames["PetGroup1"] and UnitFrames.CustomFrames["PetGroup1"].tlw then
        for i = 1, 7 do
            local frame = UnitFrames.CustomFrames["PetGroup" .. i]
            if frame and frame[COMBAT_MECHANIC_FLAGS_HEALTH] and frame[COMBAT_MECHANIC_FLAGS_HEALTH].combatGlow then
                frame[COMBAT_MECHANIC_FLAGS_HEALTH].combatGlow:SetHidden(true)
            end
        end
    end
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
        UnitFrames.CustomFramesApplyColors()
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
                     UnitFrames.CustomFramesApplyColors()
                 end, 200)
end

-- Updates custom player frame visibility based on HidePlayerFrameOnDeath and current death state.
function UnitFrames.UpdatePlayerFrameDeathVisibility()
    if not UnitFrames.CustomFrames["player"] then
        return
    end
    if UnitFrames.SV.HidePlayerFrameOnDeath then
        UnitFrames.CustomFrames["player"].control:SetHidden(IsUnitDead("player"))
    else
        UnitFrames.CustomFrames["player"].control:SetHidden(false)
    end
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
        local regenModule = LUIE_RegenerationModule
        regenModule:DisplayRegen(thb.regen1, false)
        regenModule:DisplayRegen(thb.regen2, false)
        regenModule:DisplayRegen(thb.degen1, false)
        regenModule:DisplayRegen(thb.degen2, false)
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

    if unitTag == "player" then
        UnitFrames.UpdatePlayerFrameDeathVisibility()
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
                        nameText = UnitFrames.FormatTextWithIcon(iconPath, nameText)
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
                            nameText = UnitFrames.FormatTextWithIcon(iconPath, nameText)
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
            local isUnwaveringPower = 0
            local results = { GetAllUnitAttributeVisualizerEffectInfo(unitFrame.unitTag) }
            for i = 1, #results, 6 do
                if  results[i] == ATTRIBUTE_VISUAL_UNWAVERING_POWER
                and results[i + 1] == STAT_MITIGATION
                and results[i + 2] == ATTRIBUTE_HEALTH
                and results[i + 3] == COMBAT_MECHANIC_FLAGS_HEALTH then
                    isUnwaveringPower = results[i + 4]
                    break
                end
            end

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

local function CustomFramesHideDefaultGroupFrames(groupSize)
    local shouldHide = false
    if UnitFrames.SV.CustomFramesGroup and groupSize <= 4 then
        shouldHide = true
    elseif UnitFrames.SV.CustomFramesRaid then
        if groupSize > 4 or (not UnitFrames.CustomFrames["SmallGroup1"] and UnitFrames.CustomFrames["RaidGroup1"]) then
            shouldHide = true
        end
    end
    if shouldHide and ZO_UnitFramesGroups then
        ZO_UnitFramesGroups:SetHidden(true)
    end
end

-- Returns true for raid frames, false for small group frames, nil if neither available.
local function CustomFramesDetermineGroupFrameType(memberCount)
    local hasSmallGroup = UnitFrames.CustomFrames["SmallGroup1"] and UnitFrames.CustomFrames["SmallGroup1"].tlw
    local hasRaidGroup = UnitFrames.CustomFrames["RaidGroup1"] and UnitFrames.CustomFrames["RaidGroup1"].tlw

    if memberCount > 4 then
        if hasSmallGroup then
            UnitFrames.CustomFramesUnreferenceGroupControl("SmallGroup", 1)
        end
        if hasRaidGroup then
            UnitFrames.CustomFramesUnreferenceGroupControl("RaidGroup", memberCount + 1)
            return true
        end
    else
        if hasSmallGroup then
            UnitFrames.CustomFramesUnreferenceGroupControl("SmallGroup", memberCount + 1)
            if hasRaidGroup then
                UnitFrames.CustomFramesUnreferenceGroupControl("RaidGroup", 1)
            end
            return false
        elseif hasRaidGroup then
            UnitFrames.CustomFramesUnreferenceGroupControl("RaidGroup", memberCount + 1)
            return true
        end
    end
    return nil
end

-- Repopulate group members, but try to update only those, that require it
function UnitFrames.CustomFramesGroupUpdate()
    eventManager:UnregisterForUpdate(g_PendingUpdate.Group.name)
    g_PendingUpdate.Group.flag = false

    if not UnitFrames.CustomFrames["SmallGroup1"] and not UnitFrames.CustomFrames["RaidGroup1"] then
        return
    end

    local groupSize = GetGroupSize()
    CustomFramesHideDefaultGroupFrames(groupSize)

    -- Build list of group members
    local groupList = {}
    local memberCount = 0

    for i = 1, 12 do
        local unitTag = "group" .. i
        if DoesUnitExist(unitTag) then
            table_insert(groupList, { unitTag = unitTag, unitName = GetUnitName(unitTag) })
            memberCount = memberCount + 1
        else
            UnitFrames.CustomFrames[unitTag] = nil
        end
    end

    -- Determine which frame type to use
    local useRaidFrames = CustomFramesDetermineGroupFrameType(memberCount)

    if useRaidFrames == nil then
        return -- Neither custom frame type is available
    end

    -- Set raid variable for resurrection monitor
    UnitFrames.isRaid = useRaidFrames

    -- For small groups, optionally exclude player
    if not useRaidFrames and UnitFrames.SV.GroupExcludePlayer then
        for i = 1, #groupList do
            if AreUnitsEqual("player", groupList[i].unitTag) then
                UnitFrames.CustomFrames[groupList[i].unitTag] = nil
                table_remove(groupList, i)

                -- Hide the last SmallGroup frame
                local unitTag = "SmallGroup" .. memberCount
                UnitFrames.CustomFrames[unitTag].unitTag = nil
                UnitFrames.CustomFrames[unitTag].control:SetHidden(true)
                break
            end
        end
    end

    -- Sort group list alphabetically by name
    table_sort(groupList, function (x, y)
        return x.unitName < y.unitName
    end)

    -- Assign sorted members to custom frames
    local framePrefix = useRaidFrames and "RaidGroup" or "SmallGroup"

    for index, member in ipairs(groupList) do
        local frameTag = framePrefix .. index
        UnitFrames.CustomFrames[member.unitTag] = UnitFrames.CustomFrames[frameTag]

        local frame = UnitFrames.CustomFrames[member.unitTag]
        if frame and frame.tlw then
            frame.control:SetHidden(false)

            -- For SmallGroup reset topInfo width
            if not useRaidFrames then
                frame.topInfo:SetWidth(UnitFrames.SV.GroupBarWidth - 5)
            end

            frame.unitTag = member.unitTag
            if frame.SyncAttributeVisualizerUnitTag then
                frame:SyncAttributeVisualizerUnitTag()
            end
            UnitFrames.ReloadValues(member.unitTag)
        end
    end

    UnitFrames.RefreshCustomFrameShields()

    -- Setup LibGroupBroadcast integrations on active frames
    if UnitFrames.GroupCombatStats then
        UnitFrames.GroupCombatStats.SetupFrames()
        -- Immediately refresh to show current data after frame transition
        UnitFrames.GroupCombatStats.RefreshAll()
    end
    if UnitFrames.GroupPotionCooldowns then
        UnitFrames.GroupPotionCooldowns.SetupFrames()
        -- Immediately refresh to show current data after frame transition
        UnitFrames.GroupPotionCooldowns.RefreshAll()
    end
    if UnitFrames.GroupResources then
        UnitFrames.GroupResources.SetupFrames()
        -- Resource bars will be updated by LibGroupBroadcast callbacks
    end

    UnitFrames.OnLeaderUpdate(nil, nil)
end

-- Helper function to hide and remove unitTag reference from unused group controls
function UnitFrames.CustomFramesUnreferenceGroupControl(groupType, first)
    local last = (groupType == "SmallGroup") and 4 or (groupType == "RaidGroup") and 12

    if not last then
        return
    end

    for i = first, last do
        local unitTag = groupType .. i
        local frame = UnitFrames.CustomFrames[unitTag]
        if frame then
            -- Hide LibGroupBroadcast integration elements when unreferencing SmallGroup frames
            if groupType == "SmallGroup" then
                -- Hide combat stats (ultimates, DPS/HPS)
                if UnitFrames.GroupCombatStats then
                    UnitFrames.GroupCombatStats.HideStats(unitTag)
                end

                -- Hide resource bars
                if frame.resourceMagicka then
                    if frame.resourceMagicka.backdrop then frame.resourceMagicka.backdrop:SetHidden(true) end
                    if frame.resourceMagicka.bar then frame.resourceMagicka.bar:SetHidden(true) end
                end
                if frame.resourceStamina then
                    if frame.resourceStamina.backdrop then frame.resourceStamina.backdrop:SetHidden(true) end
                    if frame.resourceStamina.bar then frame.resourceStamina.bar:SetHidden(true) end
                end

                -- Hide potion cooldown
                if frame.potionCooldown then
                    if frame.potionCooldown.backdrop then frame.potionCooldown.backdrop:SetHidden(true) end
                    if frame.potionCooldown.icon then frame.potionCooldown.icon:SetHidden(true) end
                    if frame.potionCooldown.label then frame.potionCooldown.label:SetHidden(true) end
                end

                -- Hide container
                if frame.libGroupContainer then
                    frame.libGroupContainer:SetHidden(true)
                end
            end

            frame.unitTag = nil
            if frame.SyncAttributeVisualizerUnitTag then
                frame:SyncAttributeVisualizerUnitTag()
            end
            frame.control:SetHidden(true)
        end
    end
end

-- Runs EVENT_BOSSES_CHANGED listener
function UnitFrames.OnBossesChanged(eventCode)
    if not UnitFrames.CustomFrames["boss1"] then
        return
    end

    local hasBosses = false
    for i = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
        local unitTag = "boss" .. i
        local frame = UnitFrames.CustomFrames[unitTag]

        if frame and frame.tlw then
            if DoesUnitExist(unitTag) then
                frame.control:SetHidden(false)
                UnitFrames.ReloadValues(unitTag)
                hasBosses = true
            else
                frame.control:SetHidden(true)
            end
        end
    end

    if hasBosses then
        UnitFrames.UpdateBossThresholds()
    else
        -- Bosses despawned (wipe, end of encounter, etc.): drop cached columns and hide
        -- stack + per-bar markers; otherwise lines/labels stay on screen.
        UnitFrames.ClearBossThresholdsOnBossDespawn()
    end
end

--- Set anchors for all top level windows of CustomFrames
function UnitFrames.CustomFramesSetPositions()
    --- @type table<string, table>
    local default_anchors = {}

    local screenWidth, screenHeight = GuiRoot:GetDimensions()

    if screenWidth == 0 or screenHeight == 0 then
        screenWidth, screenHeight = 1920, 1080
    end

    -- Base coordinates for 1080p reference (UI units)
    local baseCoordinates =
    {
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
    }

    -- Current frame dimensions from saved variables
    local frameDimensions =
    {
        player = { width = UnitFrames.SV.PlayerBarWidth, height = UnitFrames.SV.PlayerBarHeightHealth },
        reticleover = { width = UnitFrames.SV.TargetBarWidth, height = UnitFrames.SV.TargetBarHeight },
        companion = { width = UnitFrames.SV.CompanionWidth, height = UnitFrames.SV.CompanionHeight },
        SmallGroup1 = { width = UnitFrames.SV.GroupBarWidth, height = UnitFrames.SV.GroupBarHeight },
        RaidGroup1 = { width = UnitFrames.SV.RaidBarWidth, height = UnitFrames.SV.RaidBarHeight },
        PetGroup1 = { width = UnitFrames.SV.PetWidth, height = UnitFrames.SV.PetHeight },
        boss1 = { width = UnitFrames.SV.BossBarWidth, height = UnitFrames.SV.BossBarHeight },
        AvaPlayerTarget = { width = UnitFrames.SV.AvaTargetBarWidth, height = UnitFrames.SV.AvaTargetBarHeight },
    }

    local coords, scaleFactors = UnitFrames.CalculateDynamicPositioning(screenWidth, screenHeight, baseCoordinates, frameDimensions)

    -- if LUIE.IsDevDebugEnabled() then
    --     local aspectRatio = screenWidth / screenHeight
    --     local uiGlobalScale = GetUIGlobalScale()
    --     local pixelWidth = screenWidth * uiGlobalScale
    --     local pixelHeight = screenHeight * uiGlobalScale
    --     LUIE:Log("Debug","Unit Frames: UI Canvas " .. screenWidth .. LUIE_TINY_X_FORMATTER .. screenHeight .. " UI units (" .. string_format("%.0f", pixelWidth) .. LUIE_TINY_X_FORMATTER .. string_format("%.0f", pixelHeight) .. " pixels, scale: " .. string_format("%.2f", uiGlobalScale) .. ")")
    --     LUIE:Log("Debug","Unit Frames: Aspect ratio: " .. string_format("%.4f", aspectRatio) .. (scaleFactors.isMultiMonitorLikely and " [EXTREME ASPECT RATIO - Capped to prevent multi-monitor spread]" or ""))
    --     LUIE:Log("Debug","Unit Frames: Width scale: " .. string_format("%.3f", scaleFactors.widthResolutionScale) .. ", Height scale: " .. string_format("%.3f", scaleFactors.heightResolutionScale) .. ", Aspect ratio scale: " .. string_format("%.3f", scaleFactors.aspectRatioScale))
    --     LUIE:Log("Debug","Unit Frames: Player frame dimensions: " .. frameDimensions.player.width .. "x" .. frameDimensions.player.height .. " UI units (base: 300x30)")
    --     LUIE:Log("Debug","Unit Frames: Player calculated position: " .. string_format("%.1f", coords.player[1]) .. ", " .. string_format("%.1f", coords.player[2]) .. " UI units")
    -- end

    if UnitFrames.SV.PlayerFrameOptions == 1 then
        default_anchors["player"] = { TOPLEFT, CENTER, coords.player[1], coords.player[2] }
        default_anchors["reticleover"] = { TOPLEFT, CENTER, coords.reticleover[1], coords.reticleover[2] }
    else
        default_anchors["player"] = { CENTER, CENTER, coords.playerCenter[1], coords.playerCenter[2] }
        default_anchors["reticleover"] = { CENTER, CENTER, coords.reticleoverCenter[1], coords.reticleoverCenter[2] }
    end
    default_anchors["companion"] = { TOPLEFT, CENTER, coords.companion[1], coords.companion[2] }
    default_anchors["SmallGroup1"] = { TOPLEFT, CENTER, coords.SmallGroup1[1], coords.SmallGroup1[2] }
    default_anchors["RaidGroup1"] = { TOPLEFT, CENTER, coords.RaidGroup1[1], coords.RaidGroup1[2] }
    default_anchors["PetGroup1"] = { TOPLEFT, CENTER, coords.PetGroup1[1], coords.PetGroup1[2] }
    default_anchors["boss1"] = { TOPLEFT, CENTER, coords.boss1[1], coords.boss1[2] }
    default_anchors["AvaPlayerTarget"] = { CENTER, CENTER, coords.AvaPlayerTarget[1], coords.AvaPlayerTarget[2] }

    local customFramesShared = LUIE.CustomFramesShared
    for keyIndex = 1, #customFramesShared.MOVER_ANCHOR_REGISTRY_KEYS do
        local unitTag = customFramesShared.MOVER_ANCHOR_REGISTRY_KEYS[keyIndex]
        if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag].tlw then
            local savedPos = UnitFrames.SV[UnitFrames.CustomFrames[unitTag].tlw.customPositionAttr]
            local anchors = (savedPos ~= nil and #savedPos == 2) and { TOPLEFT, TOPLEFT, savedPos[1], savedPos[2] } or default_anchors[unitTag]
            UnitFrames.CustomFrames[unitTag].tlw:ClearAnchors()
            UnitFrames.CustomFrames[unitTag].tlw:SetAnchor(anchors[1], GuiRoot, anchors[2], anchors[3], anchors[4])
            if UnitFrames.CustomFrames[unitTag].tlw.preview.anchorLabel then
                UnitFrames.CustomFrames[unitTag].tlw.preview.anchorLabel:SetText((savedPos ~= nil and #savedPos == 2) and zo_strformat("<<1>>, <<2>>", savedPos[1], savedPos[2]) or "default")
            end
        end
    end
end

--- Position SV key per unitTag (used by console X/Y sliders and getter).
UnitFrames.CustomFramePositionAttr =
{
    player = "CustomFramesPlayerFramePos",
    reticleover = "CustomFramesTargetFramePos",
    companion = "CustomFramesCompanionFramePos",
    SmallGroup1 = "CustomFramesGroupFramePos",
    RaidGroup1 = "CustomFramesRaidFramePos",
    boss1 = "CustomFramesBossesFramePos",
    AvaPlayerTarget = "AvaCustFramesTargetFramePos",
    PetGroup1 = "CustomFramesPetFramePos",
}

--- Unhide a custom frame top-level window only when layout explicitly requests it (e.g. init). LAM should pass requestedUnhide false so settings changes do not force the HUD to show unrelated frames.
--- topLevelUnitTag matches keys in UnitFrames.CustomFramePositionAttr / CustomFramesSetMovingState.
--- @param topLevelUnitTag string
--- @param requestedUnhide boolean|nil
function UnitFrames.CustomFramesTryUnhideTlw(topLevelUnitTag, requestedUnhide)
    if not requestedUnhide then
        return
    end
    local customFrame = UnitFrames.CustomFrames[topLevelUnitTag]
    if customFrame and customFrame.tlw then
        customFrame.tlw:SetHidden(false)
    end
end

--- Get current position for a custom frame (for console X/Y sliders).
--- @param unitTag string
--- @return number left
--- @return number top
function UnitFrames.CustomFramesGetPosition(unitTag)
    local attr = UnitFrames.CustomFramePositionAttr[unitTag]
    if not attr then
        return 0, 0
    end
    local pos = UnitFrames.SV[attr]
    if pos and #pos == 2 then
        return pos[1], pos[2]
    end
    local frame = UnitFrames.CustomFrames[unitTag]
    if frame and frame.tlw then
        return frame.tlw:GetLeft(), frame.tlw:GetTop()
    end
    return 0, 0
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

--- Tint STAT_POWER / possession halo textures on a bar backdrop (same API as in-game `/script` on the halo control).
--- @param backdrop BackdropControl
--- @param colorRGB number[] { r, g, b, a } in 0..1
--- @param alpha number|nil
--- @param backgroundMultiplier number|nil multiplier for _PowerHaloTrack only
function UnitFrames.ApplyBarBackdropHaloColors(backdrop, colorRGB, alpha, backgroundMultiplier)
    if not backdrop or not colorRGB then
        return
    end
    alpha = alpha or colorRGB[4] or 0.9
    backgroundMultiplier = backgroundMultiplier or 0.1

    local r, g, b = colorRGB[1], colorRGB[2], colorRGB[3]

    local powerHaloTrack = backdrop:GetNamedChild("_PowerHaloTrack")
    if powerHaloTrack then
        powerHaloTrack:SetColor(backgroundMultiplier * r, backgroundMultiplier * g, backgroundMultiplier * b, alpha)
    end

    local increasedPowerHalo = backdrop:GetNamedChild("_IncreasedPowerHalo")
    if increasedPowerHalo then
        increasedPowerHalo:SetColor(r, g, b, alpha)
    end

    local possessionHalo = backdrop:GetNamedChild("_PossessionHalo")
    if possessionHalo then
        possessionHalo:SetColor(r, g, b, alpha)
    end
end

-- Helper function to apply colors directly to bar and backdrop
local function ApplyBarColors(bar, backdrop, colorRGB, alpha, backgroundMultiplier)
    alpha = alpha or 0.9
    backgroundMultiplier = backgroundMultiplier or 0.1

    local r, g, b = colorRGB[1], colorRGB[2], colorRGB[3]
    bar:SetColor(r, g, b, alpha)
    backdrop:SetCenterColor(backgroundMultiplier * r, backgroundMultiplier * g, backgroundMultiplier * b, alpha)

    UnitFrames.ApplyBarBackdropHaloColors(backdrop, colorRGB, alpha, backgroundMultiplier)
end

function UnitFrames.CustomFramesApplyColorsSingle(unitTag)
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
            local thb = unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH]

            local roleColor
            if role == 1 then
                roleColor = UnitFrames.SV.CustomColourDPS
            elseif role == 4 then
                roleColor = UnitFrames.SV.CustomColourHealer
            elseif role == 2 then
                roleColor = UnitFrames.SV.CustomColourTank
            else
                roleColor = UnitFrames.SV.CustomColourHealth
            end

            ApplyBarColors(thb.bar, thb.backdrop, roleColor)
        end
    end
end

function UnitFrames.CustomFramesApplyReactionColor(isPlayer)
    if not UnitFrames.CustomFrames["reticleover"] then
        return
    end

    local unitFrame = UnitFrames.CustomFrames["reticleover"]
    local thb = unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH]

    -- Class color takes priority
    if isPlayer and UnitFrames.SV.FrameColorClass then
        local classId = GetUnitClassId("reticleover")
        local classColors =
        {
            [1] = UnitFrames.SV.CustomColourDragonknight,
            [2] = UnitFrames.SV.CustomColourSorcerer,
            [3] = UnitFrames.SV.CustomColourNightblade,
            [4] = UnitFrames.SV.CustomColourWarden,
            [5] = UnitFrames.SV.CustomColourNecromancer,
            [6] = UnitFrames.SV.CustomColourTemplar,
            [117] = UnitFrames.SV.CustomColourArcanist,
        }

        local classColor = classColors[classId]
        if classColor then
            ApplyBarColors(thb.bar, thb.backdrop, classColor)
            return
        end
    end

    -- Reaction color
    if UnitFrames.SV.FrameColorReaction then
        local reaction = GetUnitReactionColorType("reticleover")
        local reactionColors =
        {
            [UNIT_REACTION_COLOR_PLAYER_ALLY] = UnitFrames.SV.CustomColourPlayer,
            [UNIT_REACTION_COLOR_DEFAULT] = UnitFrames.SV.CustomColourFriendly,
            [UNIT_REACTION_COLOR_FRIENDLY] = UnitFrames.SV.CustomColourFriendly,
            [UNIT_REACTION_COLOR_NPC_ALLY] = UnitFrames.SV.CustomColourFriendly,
            [UNIT_REACTION_COLOR_HOSTILE] = UnitFrames.SV.CustomColourHostile,
            [UNIT_REACTION_COLOR_NEUTRAL] = UnitFrames.SV.CustomColourNeutral,
            [UNIT_REACTION_COLOR_COMPANION] = UnitFrames.SV.CustomColourCompanion,
        }

        local reactionColor = reactionColors[reaction]

        -- Override with guard color only for hostile guards
        if reaction == UNIT_REACTION_COLOR_HOSTILE and IsUnitInvulnerableGuard("reticleover") then
            reactionColor = UnitFrames.SV.CustomColourGuard
        end

        if reactionColor then
            ApplyBarColors(thb.bar, thb.backdrop, reactionColor)
        end
    else
        -- Default health color
        ApplyBarColors(thb.bar, thb.backdrop, UnitFrames.SV.CustomColourHealth)
    end
end

local function CustomFramesLayoutCalculatePlayerFrameHeight(phb)
    local height = UnitFrames.SV.PlayerBarHeightHealth
    local shieldHeight = phb.shieldbackdrop and UnitFrames.SV.CustomShieldBarHeight or 0
    if UnitFrames.SV.PlayerFrameOptions == 1 then
        if not UnitFrames.SV.HideBarMagicka then
            height = height + UnitFrames.SV.PlayerBarHeightMagicka + UnitFrames.SV.PlayerBarSpacing
        end
        if not UnitFrames.SV.HideBarStamina then
            height = height + UnitFrames.SV.PlayerBarHeightStamina + UnitFrames.SV.PlayerBarSpacing
        end
    end
    return height + shieldHeight
end

local function CustomFramesLayoutSetupPlayerCommon(player, buffsWidth)
    player.topInfo:SetWidth(UnitFrames.SV.PlayerBarWidth)
    player.botInfo:SetWidth(UnitFrames.SV.PlayerBarWidth)
    player.buffAnchor:SetWidth(UnitFrames.SV.PlayerBarWidth)
    player.buffs:SetWidth(buffsWidth or UnitFrames.SV.PlayerBarWidth)
    player.debuffs:SetWidth(buffsWidth or UnitFrames.SV.PlayerBarWidth)
    local showName = UnitFrames.SV.PlayerEnableYourname
    player.name:SetHidden(not showName)
    player.level:SetHidden(not showName)
    if player.levelIcon then
        player.levelIcon:SetHidden(not showName)
    end
    if player.veterancyRankIcon then
        player.veterancyRankIcon:SetHidden(not showName)
    end
    player.classIcon:SetHidden(not showName)
    if player.frameCategory == "player" then
        FrameObject.LayoutTopInfoPlayer(player)
    end
end

local function CustomFramesLayoutSetupShieldBackdrop(shieldbackdrop, healthBackdrop, width, anchorPoint)
    if shieldbackdrop then
        shieldbackdrop:ClearAnchors()
        shieldbackdrop:SetAnchor(anchorPoint or TOP, healthBackdrop, BOTTOM, 0, 0)
        shieldbackdrop:SetDimensions(width, UnitFrames.SV.CustomShieldBarHeight)
    end
end

local function CustomFramesLayoutPositionResourceStacked(phb, pmb, psb, useLeftRightAnchors)
    local spacing = UnitFrames.SV.PlayerBarSpacing
    local reversed = UnitFrames.SV.ReverseResourceBars
    local firstBar = reversed and psb or pmb
    local secondBar = reversed and pmb or psb
    local firstHidden = reversed and UnitFrames.SV.HideBarStamina or UnitFrames.SV.HideBarMagicka
    local secondHidden = reversed and UnitFrames.SV.HideBarMagicka or UnitFrames.SV.HideBarStamina
    local firstHeight = reversed and UnitFrames.SV.PlayerBarHeightStamina or UnitFrames.SV.PlayerBarHeightMagicka
    local secondHeight = reversed and UnitFrames.SV.PlayerBarHeightMagicka or UnitFrames.SV.PlayerBarHeightStamina
    local anchorBase = phb.shieldbackdrop or phb.backdrop
    local anchorPoint = useLeftRightAnchors and BOTTOMLEFT or BOTTOM

    if phb.shieldbackdrop then
        CustomFramesLayoutSetupShieldBackdrop(phb.shieldbackdrop, phb.backdrop, UnitFrames.SV.PlayerBarWidth)
    end

    firstBar.backdrop:ClearAnchors()
    if not firstHidden then
        firstBar.backdrop:SetAnchor(TOP, anchorBase, anchorPoint, 0, spacing)
        firstBar.backdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, firstHeight)
    end

    secondBar.backdrop:ClearAnchors()
    if not secondHidden then
        if not firstHidden then
            local secondAnchor = useLeftRightAnchors and BOTTOMRIGHT or BOTTOM
            secondBar.backdrop:SetAnchor(TOP, useLeftRightAnchors and anchorBase or firstBar.backdrop, secondAnchor, 0, spacing)
        else
            secondBar.backdrop:SetAnchor(TOP, anchorBase, anchorPoint, 0, spacing)
        end
        secondBar.backdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, secondHeight)
    end
end

local function CustomFramesLayoutPositionResourceSideBySide(phb, pmb, psb)
    local reversed = UnitFrames.SV.ReverseResourceBars
    CustomFramesLayoutSetupShieldBackdrop(phb.shieldbackdrop, phb.backdrop, UnitFrames.SV.PlayerBarWidth)

    local leftBar = reversed and psb or pmb
    local leftHidden = reversed and UnitFrames.SV.HideBarStamina or UnitFrames.SV.HideBarMagicka
    local leftHeight = reversed and UnitFrames.SV.PlayerBarHeightStamina or UnitFrames.SV.PlayerBarHeightMagicka
    local leftHPos = reversed and UnitFrames.SV.AdjustStaminaHPos or UnitFrames.SV.AdjustMagickaHPos
    local leftVPos = reversed and UnitFrames.SV.AdjustStaminaVPos or UnitFrames.SV.AdjustMagickaVPos
    leftBar.backdrop:ClearAnchors()
    if not leftHidden then
        leftBar.backdrop:SetAnchor(RIGHT, phb.backdrop, LEFT, -leftHPos, leftVPos)
        leftBar.backdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, leftHeight)
    end

    local rightBar = reversed and pmb or psb
    local rightHidden = reversed and UnitFrames.SV.HideBarMagicka or UnitFrames.SV.HideBarStamina
    local rightHeight = reversed and UnitFrames.SV.PlayerBarHeightMagicka or UnitFrames.SV.PlayerBarHeightStamina
    local rightHPos = reversed and UnitFrames.SV.AdjustMagickaHPos or UnitFrames.SV.AdjustStaminaHPos
    local rightVPos = reversed and UnitFrames.SV.AdjustMagickaVPos or UnitFrames.SV.AdjustStaminaVPos
    rightBar.backdrop:ClearAnchors()
    if not rightHidden then
        rightBar.backdrop:SetAnchor(LEFT, phb.backdrop, RIGHT, rightHPos, rightVPos)
        rightBar.backdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, rightHeight)
    end
end

local function CustomFramesLayoutSetBarLabelDimensions(phb, pmb, psb)
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

-- Set dimensions of custom player frame only.
--- @param unhide boolean|nil When true, show the player TLW after layout.
function UnitFrames.CustomFramesApplyLayoutPlayerFrame(unhide)
    if not UnitFrames.CustomFrames.player then
        return
    end
    local player = UnitFrames.CustomFrames.player
    local phb = player[COMBAT_MECHANIC_FLAGS_HEALTH]
    local pmb = player[COMBAT_MECHANIC_FLAGS_MAGICKA]
    local psb = player[COMBAT_MECHANIC_FLAGS_STAMINA]
    local alt = player.alternative

    local frameHeight = CustomFramesLayoutCalculatePlayerFrameHeight(phb)
    player.tlw:SetDimensions(UnitFrames.SV.PlayerBarWidth, frameHeight)
    player.control:SetDimensions(UnitFrames.SV.PlayerBarWidth, frameHeight)

    phb.backdrop:SetDimensions(UnitFrames.SV.PlayerBarWidth, UnitFrames.SV.PlayerBarHeightHealth)
    phb.backdrop:SetHidden(UnitFrames.SV.HideBarHealth)
    pmb.backdrop:SetHidden(UnitFrames.SV.HideBarMagicka)
    psb.backdrop:SetHidden(UnitFrames.SV.HideBarStamina)

    local altW = zo_ceil(UnitFrames.SV.PlayerBarWidth * 2 / 3)
    alt.backdrop:SetWidth(altW)

    if UnitFrames.SV.PlayerFrameOptions == 1 then
        CustomFramesLayoutSetupPlayerCommon(player, UnitFrames.SV.PlayerBarWidth)
        CustomFramesLayoutPositionResourceStacked(phb, pmb, psb, false)
        CustomFramesLayoutSetBarLabelDimensions(phb, pmb, psb)
    elseif UnitFrames.SV.PlayerFrameOptions == 2 then
        CustomFramesLayoutSetupPlayerCommon(player, 1000)
        CustomFramesLayoutPositionResourceSideBySide(phb, pmb, psb)
        CustomFramesLayoutSetBarLabelDimensions(phb, pmb, psb)
    else
        CustomFramesLayoutSetupPlayerCommon(player, 1000)
        CustomFramesLayoutPositionResourceStacked(phb, pmb, psb, true)
        CustomFramesLayoutSetBarLabelDimensions(phb, pmb, psb)
    end

    UnitFrames.CustomFramesTryUnhideTlw("player", unhide)
    UnitFrames.PlayerDodgePrediction.Refresh()
end

-- Only AvA rank label/icon on custom reticleover. Do not call full UpdateStaticControls from layout:
-- it reanchors buffs/debuffs and clashes with the anchors set in CustomFramesApplyLayoutReticleoverFrame.
local function CustomFramesLayoutApplyAvaRankStaticToFrame(target, unitTag)
    if not target or not target.avaRank or not target.avaRankIcon then
        return
    end
    if not UnitFrames.SV.TargetEnableRankIcon then
        target.avaRank:SetHidden(true)
        target.avaRankIcon:SetHidden(true)
        return
    end
    if not DoesUnitExist(unitTag) or not IsUnitPlayer(unitTag) then
        target.avaRank:SetHidden(true)
        target.avaRankIcon:SetHidden(true)
        return
    end
    local rank = GetUnitAvARank(unitTag)
    target.avaRank:SetText(tostring(rank))
    if rank > 0 then
        target.avaRankIcon:SetTexture(GetAvARankIcon(rank))
        target.avaRankIcon:SetColor(GetAllianceColor(GetUnitAlliance(unitTag)):UnpackRGBA())
        target.avaRank:SetHidden(false)
        target.avaRankIcon:SetHidden(false)
    else
        target.avaRank:SetHidden(true)
        target.avaRankIcon:SetHidden(true)
    end
end

local function CustomFramesLayoutRefreshReticleoverAvaRankOnly(unitTag)
    unitTag = unitTag or "reticleover"
    CustomFramesLayoutApplyAvaRankStaticToFrame(UnitFrames.CustomFrames.reticleover, unitTag)
    if UnitFrames.SV.AvaCustFramesTarget and UnitFrames.CustomFrames.AvaPlayerTarget then
        CustomFramesLayoutApplyAvaRankStaticToFrame(UnitFrames.CustomFrames.AvaPlayerTarget, unitTag)
        local avaPlayerTargetFrame = UnitFrames.CustomFrames.AvaPlayerTarget
        if avaPlayerTargetFrame.frameCategory == "avaTarget" then
            FrameObject.LayoutTopInfoAvaTarget(avaPlayerTargetFrame)
        end
    end
end

-- Set dimensions of custom reticleover (target) frame only.
--- @param unhide boolean|nil When true, show the frame TLW and control after layout.
function UnitFrames.CustomFramesApplyLayoutReticleoverFrame(unhide)
    if not UnitFrames.CustomFrames.reticleover then
        return
    end
    local target = UnitFrames.CustomFrames.reticleover
    local thb = target[COMBAT_MECHANIC_FLAGS_HEALTH]

    local frameHeight = UnitFrames.SV.TargetBarHeight + (thb.shieldbackdrop and UnitFrames.SV.CustomShieldBarHeight or 0)
    target.tlw:SetDimensions(UnitFrames.SV.TargetBarWidth, frameHeight)
    target.control:SetDimensions(UnitFrames.SV.TargetBarWidth, frameHeight)
    target.topInfo:SetWidth(UnitFrames.SV.TargetBarWidth)
    target.botInfo:SetWidth(UnitFrames.SV.TargetBarWidth)
    target.buffAnchor:SetWidth(UnitFrames.SV.TargetBarWidth)
    target.title:SetWidth(UnitFrames.SV.TargetBarWidth - 50)

    local buffsWidth = UnitFrames.SV.PlayerFrameOptions == 1 and UnitFrames.SV.TargetBarWidth or 1000
    target.buffs:SetWidth(buffsWidth)
    target.debuffs:SetWidth(buffsWidth)

    local showTitle = UnitFrames.SV.TargetEnableTitle or UnitFrames.SV.TargetEnableRank
    target.title:SetHidden(not showTitle)

    local enableBuffAnchor = showTitle or UnitFrames.SV.TargetEnableRankIcon
    local buffsAnchor = enableBuffAnchor and target.buffAnchor or target.control
    if UnitFrames.SV.PlayerFrameOptions == 1 then
        target.buffs:ClearAnchors()
        target.buffs:SetAnchor(TOP, buffsAnchor, BOTTOM, 0, 5)
    else
        target.debuffs:ClearAnchors()
        target.debuffs:SetAnchor(TOP, buffsAnchor, BOTTOM, 0, 5)
    end

    if target.frameCategory == "avaTarget" then
        FrameObject.LayoutTopInfoAvaTarget(target)
    elseif target.frameCategory == "target" then
        FrameObject.LayoutTopInfoTarget(target)
    end
    target.skull:SetDimensions(2 * UnitFrames.SV.TargetBarHeight, 2 * UnitFrames.SV.TargetBarHeight)

    thb.backdrop:SetDimensions(UnitFrames.SV.TargetBarWidth, UnitFrames.SV.TargetBarHeight)
    CustomFramesLayoutSetupShieldBackdrop(thb.shieldbackdrop, thb.backdrop, UnitFrames.SV.TargetBarWidth)

    thb.labelOne:SetDimensions(UnitFrames.SV.TargetBarWidth - 50, UnitFrames.SV.TargetBarHeight - 2)
    thb.labelTwo:SetDimensions(UnitFrames.SV.TargetBarWidth - 50, UnitFrames.SV.TargetBarHeight - 2)

    CustomFramesLayoutRefreshReticleoverAvaRankOnly(target.unitTag or "reticleover")

    UnitFrames.CustomFramesTryUnhideTlw("reticleover", unhide)
    if unhide then
        local reactionType = DoesUnitExist("reticleover") and GetUnitReaction("reticleover") or nil
        target.control:SetHidden(UnitFrames.ShouldShowAvaPlayerTargetForReticleover(reactionType))
    end
end

-- Set dimensions of custom AvA player-target frame only.
--- @param unhide boolean|nil When true, show the frame TLW and control after layout.
function UnitFrames.CustomFramesApplyLayoutAvaPlayerTargetFrame(unhide)
    if not UnitFrames.CustomFrames.AvaPlayerTarget then
        return
    end
    local target = UnitFrames.CustomFrames.AvaPlayerTarget
    local thb = target[COMBAT_MECHANIC_FLAGS_HEALTH]

    local frameHeight = UnitFrames.SV.AvaTargetBarHeight + (thb.shieldbackdrop and UnitFrames.SV.CustomShieldBarHeight or 0)
    target.tlw:SetDimensions(UnitFrames.SV.AvaTargetBarWidth, frameHeight)
    target.control:SetDimensions(UnitFrames.SV.AvaTargetBarWidth, frameHeight)
    target.topInfo:SetWidth(UnitFrames.SV.AvaTargetBarWidth)
    target.botInfo:SetWidth(UnitFrames.SV.AvaTargetBarWidth)
    target.buffAnchor:SetWidth(UnitFrames.SV.AvaTargetBarWidth)

    if target.frameCategory == "avaTarget" then
        FrameObject.LayoutTopInfoAvaTarget(target)
    end

    thb.backdrop:SetDimensions(UnitFrames.SV.AvaTargetBarWidth, UnitFrames.SV.AvaTargetBarHeight)
    CustomFramesLayoutSetupShieldBackdrop(thb.shieldbackdrop, thb.backdrop, UnitFrames.SV.AvaTargetBarWidth)

    thb.label:SetHeight(UnitFrames.SV.AvaTargetBarHeight - 2)
    thb.labelOne:SetHeight(UnitFrames.SV.AvaTargetBarHeight - 2)
    thb.labelTwo:SetHeight(UnitFrames.SV.AvaTargetBarHeight - 2)

    CustomFramesLayoutRefreshReticleoverAvaRankOnly(target.unitTag or "reticleover")

    UnitFrames.CustomFramesTryUnhideTlw("AvaPlayerTarget", unhide)
    if unhide then
        local reactionType = DoesUnitExist("reticleover") and GetUnitReaction("reticleover") or nil
        target.control:SetHidden(not UnitFrames.ShouldShowAvaPlayerTargetForReticleover(reactionType))
    end
end

-- Applies layout for player, reticleover, and AvA custom TLWs with one unhide flag (e.g. initial setup).
--- @param unhide boolean|nil When true, show all three frames after layout.
function UnitFrames.CustomFramesApplyLayoutPlayer(unhide)
    UnitFrames.CustomFramesApplyLayoutPlayerFrame(unhide)
    UnitFrames.CustomFramesApplyLayoutReticleoverFrame(unhide)
    UnitFrames.CustomFramesApplyLayoutAvaPlayerTargetFrame(unhide)
end

--- Applies layout across custom frame categories (single orchestration site).
--- @class UnitFrames.CustomFramesApplyAllLayoutsOptions
--- @field unhide boolean|nil Shorthand for unhidePlayer
--- @field unhidePlayer boolean|nil
--- @field unhideReticle boolean|nil
--- @field unhideAva boolean|nil
--- @field group boolean|nil Unhide flag for group layout
--- @field raid boolean|nil Unhide flag for raid layout
--- @field layoutAllRaidSlots boolean|nil Passed to CustomFramesApplyLayoutRaid
--- @field playerTriadOnly boolean|nil When true, only player / reticleover / AvA layouts run
--- @field includeGroup boolean|nil Default true unless playerTriadOnly
--- @field includeRaid boolean|nil Default false
--- @field includeCompanion boolean|nil Default matches includeGroup
--- @field includePet boolean|nil Default matches includeGroup
--- @field includeBosses boolean|nil Default false
--- @field includeCompanionPetUpdates boolean|nil Default false
--- @param options UnitFrames.CustomFramesApplyAllLayoutsOptions|nil
function UnitFrames.CustomFramesApplyAllLayouts(options)
    options = options or {}
    local unhidePlayer = options.unhidePlayer
    if unhidePlayer == nil then
        unhidePlayer = options.unhide
    end
    if unhidePlayer == nil then
        unhidePlayer = false
    end
    local unhideReticle = options.unhideReticle
    if unhideReticle == nil then
        unhideReticle = unhidePlayer
    end
    local unhideAva = options.unhideAva
    if unhideAva == nil then
        unhideAva = unhideReticle
    end

    UnitFrames.CustomFramesApplyLayoutPlayerFrame(unhidePlayer)
    UnitFrames.CustomFramesApplyLayoutReticleoverFrame(unhideReticle)
    UnitFrames.CustomFramesApplyLayoutAvaPlayerTargetFrame(unhideAva)

    if options.playerTriadOnly then
        return
    end

    local includeGroup = options.includeGroup
    if includeGroup == nil then
        includeGroup = true
    end
    if includeGroup then
        local groupUnhide = options.group
        if groupUnhide == nil then
            groupUnhide = unhidePlayer
        end
        UnitFrames.CustomFramesApplyLayoutGroup(groupUnhide)
    end

    if options.includeRaid then
        local raidUnhide = options.raid
        if raidUnhide == nil then
            raidUnhide = unhidePlayer
        end
        UnitFrames.CustomFramesApplyLayoutRaid(raidUnhide, options.layoutAllRaidSlots)
    end

    local includeCompanion = options.includeCompanion
    if includeCompanion == nil then
        includeCompanion = includeGroup
    end
    if includeCompanion then
        UnitFrames.CustomFramesApplyLayoutCompanion(unhidePlayer)
    end

    local includePet = options.includePet
    if includePet == nil then
        includePet = includeGroup
    end
    if includePet then
        UnitFrames.CustomFramesApplyLayoutPet(unhidePlayer)
    end

    if options.includeCompanionPetUpdates then
        UnitFrames.CustomPetUpdate()
        UnitFrames.CompanionUpdate()
        UnitFrames.CustomFramesApplyCompanionInCombat(true)
        UnitFrames.UpdateCompanionCombatGlow()
        UnitFrames.CustomFramesApplyPetInCombat(true)
        UnitFrames.UpdatePetCombatGlow()
    end

    if options.includeBosses then
        UnitFrames.CustomFramesApplyLayoutBosses(unhidePlayer)
    end
end

-- Re-apply shield, trauma, and no-healing overlay visibility after shield mode or layout changes.
function UnitFrames.RefreshCustomFrameShields()
    if not UnitFrames.savedHealth then
        return
    end
    for unitTag, saved in pairs(UnitFrames.savedHealth) do
        UnitFrames.ForEachVisualizerForUnit(unitTag, function (visualizer)
            local vizTag = visualizer.GetUnitTag and visualizer:GetUnitTag() or unitTag
            if vizTag and DoesUnitExist(vizTag) then
                UnitFrames.InvalidateAttributeVisualEffectCache(vizTag)
                visualizer:OnUnitChanged()
                return
            end

            if not visualizer.visualModules then
                return
            end

            local shieldValue = saved[4] or 0
            local traumaValue = saved[5] or 0
            local healthEffectiveMax = saved[3] or 1
            for module in pairs(visualizer.visualModules) do
                if module.UpdateShield then
                    module:UpdateShield(unitTag, shieldValue, healthEffectiveMax)
                end
                if module.UpdateTrauma then
                    module:UpdateTrauma(unitTag, traumaValue, healthEffectiveMax)
                end
                if module.UpdateNoHealing then
                    module:UpdateNoHealing(unitTag, 0)
                end
            end
        end)
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

-- Set dimensions of custom group frame and anchors or raid group members
function UnitFrames.CustomFramesApplyLayoutGroup(unhide)
    if not UnitFrames.CustomFrames["SmallGroup1"] or not UnitFrames.CustomFrames["SmallGroup1"].tlw then
        return
    end

    local groupBarHeight = UnitFrames.SV.GroupBarHeight
    local sampleHealth = UnitFrames.CustomFrames["SmallGroup1"][COMBAT_MECHANIC_FLAGS_HEALTH]
    if sampleHealth and sampleHealth.shieldbackdrop then
        groupBarHeight = groupBarHeight + UnitFrames.SV.CustomShieldBarHeight
    end

    -- Add extra height for resource bars if enabled
    local resourceBarsHeight = 0
    if UnitFrames.GroupResources then
        resourceBarsHeight = UnitFrames.GroupResources.GetResourceBarsHeight(false)
    end

    local group = UnitFrames.CustomFrames["SmallGroup1"].tlw
    local totalFrameHeight = groupBarHeight + resourceBarsHeight
    group:SetDimensions(UnitFrames.SV.GroupBarWidth, totalFrameHeight * 4 + UnitFrames.SV.GroupBarSpacing * 3.5)
    if group.preview then
        group.preview:SetDimensions(group:GetWidth(), group:GetHeight())
    end

    -- Build player list (sorted by role if enabled)
    local playerList = {}
    if UnitFrames.SV.SortRoleGroup then
        local roles = { LFG_ROLE_TANK, LFG_ROLE_HEAL, LFG_ROLE_DPS, LFG_ROLE_INVALID }
        for _, value in ipairs(roles) do
            insertRole(playerList, value)
        end
    end

    for i = 1, 4 do
        local index = UnitFrames.SV.SortRoleGroup and playerList[i] or i
        local unitFrame = UnitFrames.CustomFrames["SmallGroup" .. index]

        -- Only process if frame exists (skip invalid indices from role sorting)
        if unitFrame then
            local unitTag = GetGroupUnitTagByIndex(index)
            local ghb = unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH]

            -- Position and size frame
            unitFrame.control:ClearAnchors()
            unitFrame.control:SetAnchor(TOPLEFT, group, TOPLEFT, 0, 0.5 * UnitFrames.SV.GroupBarSpacing + (totalFrameHeight + UnitFrames.SV.GroupBarSpacing) * (i - 1))
            unitFrame.control:SetDimensions(UnitFrames.SV.GroupBarWidth, totalFrameHeight)
            unitFrame.topInfo:SetWidth(UnitFrames.SV.GroupBarWidth - 5)

            local isLeader = IsUnitGroupLeader(unitTag)
            if isLeader then
                unitFrame.leader:SetTexture(leaderIcons[1])
            else
                unitFrame.leader:SetTexture(leaderIcons[0])
            end
            if unitFrame.frameCategory == "smallGroup" then
                FrameObject.LayoutTopInfoSmallGroup(unitFrame)
            end

            -- Health bar dimensions
            ghb.backdrop:SetDimensions(UnitFrames.SV.GroupBarWidth, UnitFrames.SV.GroupBarHeight)
            CustomFramesLayoutSetupShieldBackdrop(ghb.shieldbackdrop, ghb.backdrop, UnitFrames.SV.GroupBarWidth)

            -- Role icon and label positioning
            local role = GetGroupMemberSelectedRole(unitTag)
            local showRoleIcon = UnitFrames.SV.RoleIconSmallGroup and role
            local labelWidth = showRoleIcon and (UnitFrames.SV.GroupBarWidth - 52) or (UnitFrames.SV.GroupBarWidth - 72)
            local labelAnchorX = showRoleIcon and 25 or 5

            ghb.labelOne:SetDimensions(labelWidth, UnitFrames.SV.GroupBarHeight - 2)
            ghb.labelOne:SetAnchor(LEFT, ghb.backdrop, LEFT, labelAnchorX, 0)
            ghb.labelTwo:SetDimensions(UnitFrames.SV.GroupBarWidth - 50, UnitFrames.SV.GroupBarHeight - 2)

            unitFrame.dead:ClearAnchors()
            unitFrame.dead:SetAnchor(LEFT, ghb.backdrop, LEFT, labelAnchorX, 0)
            unitFrame.roleIcon:SetHidden(not showRoleIcon)
        end
    end

    UnitFrames.CustomFramesTryUnhideTlw("SmallGroup1", unhide)
    UnitFrames.RefreshCustomFrameShields()
end

--- @param index number
--- @param itemsPerColumn number
--- @param spacerHeight number
--- @param resourceBarsHeight number
--- @param frameWidth number Total width of frame (including integration icons)
--- @param frameSpacing number Vertical spacing between each frame
--- @return number xOffset
--- @return number yOffset
local function calculateFramePosition(index, itemsPerColumn, spacerHeight, resourceBarsHeight, frameWidth, frameSpacing)
    local column = zo_floor((index - 1) / itemsPerColumn)
    local row = (index - 1) % itemsPerColumn + 1
    local xOffset = frameWidth * column
    local totalFrameHeight = UnitFrames.SV.RaidBarHeight + resourceBarsHeight
    local yOffset = (totalFrameHeight + frameSpacing) * (row - 1)

    -- Add extra spacers if enabled (every 4 members)
    if UnitFrames.SV.RaidSpacers then
        local spacersInCurrentColumn = zo_floor((row - 1) / 4)
        yOffset = yOffset + (spacerHeight * spacersInCurrentColumn)
    end

    return xOffset, yOffset
end

-- Compact-frame name labels are anchored inside the _Health backdrop, so the
-- layout normally caps their height to BarHeight - 2. When the caption font is
-- larger than the bar height, ESO auto-shrinks the rendered glyphs unless the
-- label is grown to fit the font. This returns the height the label needs.
local function resolveCompactNameHeight(category, barHeight)
    local base = barHeight - 2
    local sizeCaption = UnitFrames.GetCustomFrameCaptionSize and UnitFrames.GetCustomFrameCaptionSize(category)
    if not sizeCaption or sizeCaption <= 0 then
        return base
    end
    local needed = math.ceil(2 * sizeCaption)
    return zo_max(base, needed)
end

-- Applies a (possibly clipped) width/height to a name label. ESO's
-- Control:SetDimensions silently ignores values <= 0 on labels in
-- TEXT_WRAP_MODE_TRUNCATE mode and falls back to auto-sizing-to-text, so the
-- *_NameClip sliders need to explicitly hide the label when the user dials the
-- clip past the available room. Returning the label to visible whenever a
-- positive width is available keeps the slider symmetric across its full range.
local function ApplyClippedNameWidth(nameLabel, computedWidth, height)
    if not nameLabel then return end
    if computedWidth <= 0 then
        nameLabel:SetHidden(true)
        return
    end
    nameLabel:SetHidden(false)
    nameLabel:SetDimensions(computedWidth, height)
end
UnitFrames.ApplyClippedNameWidth = ApplyClippedNameWidth

-- Determines which icon to show and configures name positioning accordingly
local function applyIconSettings(unitFrame, unitTag, role, healthBackdrop)
    -- Clamp to >= 0 so extreme RaidNameClip values produce a 0-wide (invisible)
    -- name label instead of a negative SetDimensions arg that ESO silently ignores.
    local nameWidth = zo_max(0, UnitFrames.SV.RaidBarWidth - UnitFrames.SV.RaidNameClip - 27)
    local nameHeight = resolveCompactNameHeight("raid", UnitFrames.SV.RaidBarHeight)
    local iconOption = UnitFrames.SV.RaidIconOptions or 1

    -- Determine which icon to show (if any)
    local showRoleIcon = false
    local showClassIcon = false

    if iconOption == 2 then
        -- Always show class icon
        showClassIcon = true
    elseif iconOption == 3 then
        -- Show role icon if player has a role
        showRoleIcon = role ~= nil
    elseif iconOption == 4 then
        -- PvP: class icon, PvE: role icon (if has role)
        if LUIE.ResolvePVPZone() then
            showClassIcon = true
        else
            showRoleIcon = role ~= nil
        end
    elseif iconOption == 5 then
        -- PvP: role icon (if has role), PvE: class icon
        if LUIE.ResolvePVPZone() then
            showRoleIcon = role ~= nil
        else
            showClassIcon = true
        end
    end

    -- Apply settings based on what we're showing
    if showRoleIcon or showClassIcon then
        ApplyClippedNameWidth(unitFrame.name, nameWidth, nameHeight)
        unitFrame.name:SetAnchor(LEFT, healthBackdrop, LEFT, 22, 0)
        unitFrame.roleIcon:SetHidden(not showRoleIcon)
        unitFrame.classIcon:SetHidden(not showClassIcon)
    else
        -- No icon shown
        ApplyClippedNameWidth(unitFrame.name, zo_max(0, UnitFrames.SV.RaidBarWidth - UnitFrames.SV.RaidNameClip - 10), nameHeight)
        unitFrame.name:SetAnchor(LEFT, healthBackdrop, LEFT, 5, 0)
        unitFrame.roleIcon:SetHidden(true)
        unitFrame.classIcon:SetHidden(true)
    end
end

-- Calculate additional width needed for LibGroupBroadcast integration icons (raid frames)
-- Raid frames only show resource bars now, no integration icons
local function GetRaidIntegrationWidth()
    -- No integration icons on raid frames anymore (only resource bars)
    return 0
end

--- @param unhide boolean When true, unhides the raid TLW after layout.
--- @param layoutAllRaidSlots boolean? When true, lay out all 12 raid slots using SavedVariables (RaidLayout, spacers, bar sizes) even if the group has fewer members (UnitFrames slash debug preview). Uses unitTag `player` for role / leader / online checks so RaidIconOptions behave consistently.
function UnitFrames.CustomFramesApplyLayoutRaid(unhide, layoutAllRaidSlots)
    if not UnitFrames.CustomFrames["RaidGroup1"] or not UnitFrames.CustomFrames["RaidGroup1"].tlw then
        return
    end

    local spacerHeight = 3
    -- Add extra height for resource bars if enabled
    local resourceBarsHeight = 0
    local resourceBarsAreEnabled = false
    if UnitFrames.GroupResources then
        resourceBarsHeight = UnitFrames.GroupResources.GetResourceBarsHeight(true)
        resourceBarsAreEnabled = resourceBarsHeight > 0
    end

    -- Vertical spacing between each frame. Only add the larger gap when resource sharing is active.
    local frameSpacing = 0
    if resourceBarsAreEnabled then
        local raidResourceSettings = UnitFrames.SV.GroupResources
        local raidBarHeight = raidResourceSettings and raidResourceSettings.raidBarHeight or 0
        frameSpacing = 1 + raidBarHeight
    end

    -- Add extra width for integration icons if enabled
    local integrationWidth = GetRaidIntegrationWidth()

    -- Determine layout dimensions
    local columns, rows
    if UnitFrames.SV.RaidLayout == "6 x 2" then
        columns, rows = 6, 2
    elseif UnitFrames.SV.RaidLayout == "3 x 4" then
        columns, rows = 3, 4
    elseif UnitFrames.SV.RaidLayout == "2 x 6" then
        columns, rows = 2, 6
    else
        columns, rows = 1, 12
    end

    local itemsPerColumn = rows
    local raid = UnitFrames.CustomFrames["RaidGroup1"].tlw
    local totalFrameHeight = UnitFrames.SV.RaidBarHeight + resourceBarsHeight
    local totalFrameWidth = UnitFrames.SV.RaidBarWidth + integrationWidth

    -- Calculate dimensions (add spacing between frames)
    local totalWidth = totalFrameWidth * columns
    local totalHeight = (totalFrameHeight + frameSpacing) * rows - frameSpacing -- Subtract last spacing

    if UnitFrames.SV.RaidSpacers then
        totalWidth = totalWidth + (spacerHeight * (rows / 4))
        totalHeight = totalHeight + (spacerHeight * zo_floor((rows - 1) / 4))
    end

    raid:SetDimensions(totalWidth, totalHeight)
    raid.preview:SetDimensions(totalFrameWidth * columns, totalHeight)

    -- Build player list (sorted by role if enabled)
    local playerList = {}
    if UnitFrames.SV.SortRoleRaid then
        local roles = { LFG_ROLE_TANK, LFG_ROLE_HEAL, LFG_ROLE_DPS, LFG_ROLE_INVALID }
        for _, value in ipairs(roles) do
            insertRole(playerList, value)
        end
    end

    -- Always iterate all 12 raid slots so dimensions/anchors stay in sync with current SV
    -- (RaidBarWidth, RaidBarHeight, RaidNameClip, RaidIconOptions). This mirrors
    -- CustomFramesApplyLayoutGroup which always iterates 1..4. Without this, moving the
    -- RaidNameClip slider while solo (GetGroupSize() == 0) wouldn't update preview frames
    -- and any slot beyond the real group size would keep stale geometry.
    local realGroupSize = GetGroupSize()

    for i = 1, 12 do
        local index
        local unitTag

        if layoutAllRaidSlots then
            index = i
            unitTag = "player"
        else
            if UnitFrames.SV.SortRoleRaid then
                -- playerList only contains entries for actually grouped members; for empty
                -- slots fall back to the natural slot index so we still update geometry.
                index = playerList[i] or i
            else
                index = i
            end
            if i <= realGroupSize then
                unitTag = GetGroupUnitTagByIndex(index)
            else
                unitTag = nil
            end
        end

        local unitFrame = UnitFrames.CustomFrames["RaidGroup" .. index]
        if unitFrame then
            local rhb = unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH].backdrop

            -- Calculate position and set frame dimensions
            local xOffset, yOffset = calculateFramePosition(i, itemsPerColumn, spacerHeight, resourceBarsHeight, totalFrameWidth, frameSpacing)
            unitFrame.control:ClearAnchors()
            unitFrame.control:SetAnchor(TOPLEFT, raid, TOPLEFT, xOffset, yOffset)
            unitFrame.control:SetDimensions(totalFrameWidth, totalFrameHeight)

            -- Apply icon settings (uses RaidIconOptions, not unitTag-specific for iconOpt=2/3)
            local role = unitTag and GetGroupMemberSelectedRole(unitTag) or nil
            applyIconSettings(unitFrame, unitTag, role, rhb)

            local raidNameHeight = resolveCompactNameHeight("raid", UnitFrames.SV.RaidBarHeight)

            -- Override for group leader (only when slot has a real, leadered member)
            if unitTag and IsUnitGroupLeader(unitTag) then
                ApplyClippedNameWidth(unitFrame.name, zo_max(0, UnitFrames.SV.RaidBarWidth - UnitFrames.SV.RaidNameClip - 27), raidNameHeight)
                unitFrame.name:SetAnchor(LEFT, rhb, LEFT, 22, 0)
                unitFrame.roleIcon:SetHidden(true)
                unitFrame.classIcon:SetHidden(true)
                unitFrame.leader:SetTexture(leaderIcons[1])
            else
                unitFrame.leader:SetTexture(leaderIcons[0])
            end

            -- Set label dimensions (always — driven purely by SV geometry)
            unitFrame.dead:SetDimensions(UnitFrames.SV.RaidBarWidth - 50, UnitFrames.SV.RaidBarHeight - 2)
            unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH].label:SetDimensions(UnitFrames.SV.RaidBarWidth - 50, UnitFrames.SV.RaidBarHeight - 2)

            -- Override for offline players (only meaningful when slot has a real member)
            if unitTag and not IsUnitOnline(unitTag) then
                ApplyClippedNameWidth(unitFrame.name, zo_max(0, UnitFrames.SV.RaidBarWidth - UnitFrames.SV.RaidNameClip), raidNameHeight)
                unitFrame.name:SetAnchor(LEFT, rhb, LEFT, 5, 0)
                unitFrame.classIcon:SetHidden(true)
            end
        end
    end

    UnitFrames.CustomFramesTryUnhideTlw("RaidGroup1", unhide)
    UnitFrames.RefreshCustomFrameShields()
end

-- Set dimensions of custom companion frame and anchors
function UnitFrames.CustomFramesApplyLayoutCompanion(unhide)
    if not UnitFrames.CustomFrames["companion"] or not UnitFrames.CustomFrames["companion"].tlw then
        return
    end

    local companion = UnitFrames.CustomFrames["companion"].tlw
    local unitFrame = UnitFrames.CustomFrames["companion"]
    local chb = unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH]

    local barHeight = UnitFrames.SV.CompanionHeight
    local barWidth = UnitFrames.SV.CompanionWidth
    local shieldHeight = chb.shieldbackdrop and UnitFrames.SV.CustomShieldBarHeight or 0
    local abilityExtra = 0
    if UnitFrames.companionAbilityTrack then
        abilityExtra = UnitFrames.companionAbilityTrack:GetCompanionFrameExtraHeight()
    end
    local totalHeight = barHeight + shieldHeight + abilityExtra

    companion:SetDimensions(barWidth, totalHeight)
    unitFrame.control:ClearAnchors()
    unitFrame.control:SetAnchorFill(companion)
    unitFrame.control:SetDimensions(barWidth, totalHeight)

    local healthBackdrop = chb.backdrop
    healthBackdrop:ClearAnchors()
    healthBackdrop:SetAnchor(TOPLEFT, unitFrame.control, TOPLEFT)
    healthBackdrop:SetDimensions(barWidth, barHeight)
    CustomFramesLayoutSetupShieldBackdrop(chb.shieldbackdrop, healthBackdrop, barWidth)

    local companionNameHeight = resolveCompactNameHeight("companion", barHeight)
    ApplyClippedNameWidth(unitFrame.name, zo_max(0, barWidth - UnitFrames.SV.CompanionNameClip - 10), companionNameHeight)
    unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH].label:SetDimensions(barWidth - 50, barHeight - 2)

    if UnitFrames.companionAbilityTrack then
        UnitFrames.companionAbilityTrack:ApplyLayout()
    end

    UnitFrames.CustomFramesTryUnhideTlw("companion", unhide)
end

-- Set dimensions of custom pet frame and anchors
function UnitFrames.CustomFramesApplyLayoutPet(unhide)
    if not UnitFrames.CustomFrames["PetGroup1"] or not UnitFrames.CustomFrames["PetGroup1"].tlw then
        return
    end

    local pet = UnitFrames.CustomFrames["PetGroup1"].tlw
    pet:SetDimensions(UnitFrames.SV.PetWidth, UnitFrames.SV.PetHeight * 7 + 21)

    local petNameHeight = resolveCompactNameHeight("pet", UnitFrames.SV.PetHeight)
    for i = 1, 7 do
        local unitFrame = UnitFrames.CustomFrames["PetGroup" .. i]
        unitFrame.control:ClearAnchors()
        unitFrame.control:SetAnchor(TOPLEFT, pet, TOPLEFT, 0, (UnitFrames.SV.PetHeight + 3) * (i - 1))
        unitFrame.control:SetDimensions(UnitFrames.SV.PetWidth, UnitFrames.SV.PetHeight)
        ApplyClippedNameWidth(unitFrame.name, zo_max(0, UnitFrames.SV.PetWidth - UnitFrames.SV.PetNameClip - 10), petNameHeight)
        unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH].label:SetDimensions(UnitFrames.SV.PetWidth - 50, UnitFrames.SV.PetHeight - 2)
    end

    UnitFrames.CustomFramesTryUnhideTlw("PetGroup1", unhide)
end

-- Set dimensions of custom boss frame and anchors
--- @param requestedUnhide boolean|nil When true, show the boss TLW after layout (e.g. init).
function UnitFrames.CustomFramesApplyLayoutBosses(requestedUnhide)
    if not UnitFrames.CustomFrames["boss1"] or not UnitFrames.CustomFrames["boss1"].tlw then
        return
    end

    local bosses = UnitFrames.CustomFrames["boss1"].tlw
    local spacing = UnitFrames.SV.BossBarSpacing or 2
    local barHeight = UnitFrames.SV.BossBarHeight
    local bossSlotCount = BOSS_RANK_ITERATION_END - BOSS_RANK_ITERATION_BEGIN + 1
    local bossesTotalHeight = barHeight * bossSlotCount + spacing * zo_max(0, bossSlotCount - 1) + (UnitFrames.bossThresholdMechanicPadding or 0)
    bosses:SetDimensions(UnitFrames.SV.BossBarWidth, bossesTotalHeight)

    local bossNameHeight = resolveCompactNameHeight("boss", UnitFrames.SV.BossBarHeight)
    for i = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
        local unitFrame = UnitFrames.CustomFrames["boss" .. i]
        unitFrame.control:ClearAnchors()
        unitFrame.control:SetAnchor(TOPLEFT, bosses, TOPLEFT, 0, (barHeight + spacing) * (i - BOSS_RANK_ITERATION_BEGIN))
        unitFrame.control:SetDimensions(UnitFrames.SV.BossBarWidth, UnitFrames.SV.BossBarHeight)
        unitFrame.name:SetDimensions(UnitFrames.SV.BossBarWidth - 50, bossNameHeight)
        unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH].label:SetDimensions(UnitFrames.SV.BossBarWidth - 50, UnitFrames.SV.BossBarHeight - 2)
    end

    UnitFrames.ApplyBossThresholdMarkersFromCache()

    UnitFrames.CustomFramesTryUnhideTlw("boss1", requestedUnhide)
end

local function CustomFramesApplyAlphaAndBuffs(frame, idle, oocAlpha, incAlpha, hideBuffsOoc)
    if not frame or not frame.tlw then return end
    local alpha = idle and oocAlpha or incAlpha
    local spellCastBuffs = LUIE.SpellCastBuffs
    local deferBuffRegionAlphaToScb = spellCastBuffs
        and spellCastBuffs.SV
        and spellCastBuffs.SV.lockPositionToUnitFrames
        and (frame == UnitFrames.CustomFrames.player or frame == UnitFrames.CustomFrames.reticleover)

    if deferBuffRegionAlphaToScb and spellCastBuffs.SetLockedContainerAlphaForUnit then
        local unitKind = (frame == UnitFrames.CustomFrames.player) and "player" or "target"
        spellCastBuffs.SetLockedContainerAlphaForUnit(unitKind, alpha)
    end

    frame.control:SetAlpha(alpha)
    if hideBuffsOoc and frame.buffs and frame.debuffs then
        frame.buffs:SetHidden(idle)
        frame.debuffs:SetHidden(idle)
    else
        local buffRegionAlpha = deferBuffRegionAlphaToScb and 1 or alpha
        if frame.buffs then
            frame.buffs:SetHidden(false)
            frame.buffs:SetAlpha(buffRegionAlpha)
        end
        if frame.debuffs then
            frame.debuffs:SetHidden(false)
            frame.debuffs:SetAlpha(buffRegionAlpha)
        end
    end
end

-- Cache so we only apply when idle state actually changes (avoids 17 frame updates on every power event)
local lastCustomFramesApplyInCombatPlayerIdle = nil
local lastCustomFramesApplyInCombatTargetIdle = nil

local function CustomFramesComputeOocIdle(useMissingPowerAsCombat)
    if useMissingPowerAsCombat then
        local idle = true
        for _, value in pairs(UnitFrames.statFull) do
            idle = idle and value
        end
        return idle == true
    end
    return UnitFrames.statFull.combat == true
end

--- OOC/INC alpha (0–1) for SpellCastBuffs containers locked to player/target UF buff regions.
--- @param containerKey string
--- @return number|nil nil when not a locked player/target buff container
function UnitFrames.GetSpellCastBuffsLockedContainerAlpha(containerKey)
    if containerKey == "player1" or containerKey == "player2" then
        local idle = CustomFramesComputeOocIdle(UnitFrames.SV.PlayerOocAlphaPower)
        return idle and (0.01 * UnitFrames.SV.PlayerOocAlpha) or (0.01 * UnitFrames.SV.PlayerIncAlpha)
    end
    if containerKey == "target1" or containerKey == "target2" then
        local idle = CustomFramesComputeOocIdle(UnitFrames.SV.TargetOocAlphaPower)
        return idle and (0.01 * UnitFrames.SV.TargetOocAlpha) or (0.01 * UnitFrames.SV.TargetIncAlpha)
    end
    return nil
end

-- This function reduces opacity of custom frames when player is out of combat and has full attributes
--- @param force boolean|nil When true, always reapply alpha/buffs (e.g. LAM changed SV); skips idle-only cache.
function UnitFrames.CustomFramesApplyInCombat(force)
    local playerIdle = CustomFramesComputeOocIdle(UnitFrames.SV.PlayerOocAlphaPower)
    local targetIdle = CustomFramesComputeOocIdle(UnitFrames.SV.TargetOocAlphaPower)

    if  not force
    and playerIdle == lastCustomFramesApplyInCombatPlayerIdle
    and targetIdle == lastCustomFramesApplyInCombatTargetIdle then
        return
    end
    lastCustomFramesApplyInCombatPlayerIdle = playerIdle
    lastCustomFramesApplyInCombatTargetIdle = targetIdle

    CustomFramesApplyAlphaAndBuffs(
        UnitFrames.CustomFrames["player"],
        playerIdle,
        0.01 * UnitFrames.SV.PlayerOocAlpha,
        0.01 * UnitFrames.SV.PlayerIncAlpha,
        UnitFrames.SV.HideBuffsPlayerOoc
    )
    CustomFramesApplyAlphaAndBuffs(
        UnitFrames.CustomFrames["AvaPlayerTarget"],
        targetIdle,
        0.01 * UnitFrames.SV.TargetOocAlpha,
        0.01 * UnitFrames.SV.TargetIncAlpha,
        false
    )
    CustomFramesApplyAlphaAndBuffs(
        UnitFrames.CustomFrames["reticleover"],
        targetIdle,
        0.01 * UnitFrames.SV.TargetOocAlpha,
        0.01 * UnitFrames.SV.TargetIncAlpha,
        UnitFrames.SV.HideBuffsTargetOoc
    )

    local oocAlphaBoss = 0.01 * UnitFrames.SV.BossOocAlpha
    local incAlphaBoss = 0.01 * UnitFrames.SV.BossIncAlpha
    for i = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
        CustomFramesApplyAlphaAndBuffs(
            UnitFrames.CustomFrames["boss" .. i],
            playerIdle,
            oocAlphaBoss,
            incAlphaBoss,
            false
        )
    end
end

local lastCompanionIdle = nil
local lastPetIdleByUnitTag = {}

local function IsUnitIdleForCombatAlpha(unitTag)
    if not unitTag or not DoesUnitExist(unitTag) then
        return true
    end
    return not (IsUnitActivelyEngaged(unitTag) or IsUnitInCombat(unitTag))
end

--- Applies OOC/in-combat transparency from the companion unit's own combat state.
--- @param force boolean|nil When true, always reapply alpha; skips idle cache.
function UnitFrames.CustomFramesApplyCompanionInCombat(force)
    local companionFrame = UnitFrames.CustomFrames["companion"]
    if not companionFrame or not companionFrame.tlw or not DoesUnitExist("companion") then
        return
    end
    local idle = IsUnitIdleForCombatAlpha("companion")
    if force or lastCompanionIdle ~= idle then
        lastCompanionIdle = idle
        CustomFramesApplyAlphaAndBuffs(
            companionFrame,
            idle,
            0.01 * UnitFrames.SV.CompanionOocAlpha,
            0.01 * UnitFrames.SV.CompanionIncAlpha,
            false
        )
    end
end

--- Applies OOC/in-combat transparency from each active pet unit's own combat state.
--- @param force boolean|nil When true, always reapply alpha; skips per-unit idle cache.
function UnitFrames.CustomFramesApplyPetInCombat(force)
    local oocAlphaPet = 0.01 * UnitFrames.SV.PetOocAlpha
    local incAlphaPet = 0.01 * UnitFrames.SV.PetIncAlpha
    for i = 1, 7 do
        local frame = UnitFrames.CustomFrames["PetGroup" .. i]
        if frame and frame.tlw and not frame.control:IsHidden() and frame.unitTag and DoesUnitExist(frame.unitTag) then
            local unitTag = frame.unitTag
            local idle = IsUnitIdleForCombatAlpha(unitTag)
            if force or lastPetIdleByUnitTag[unitTag] ~= idle then
                lastPetIdleByUnitTag[unitTag] = idle
                CustomFramesApplyAlphaAndBuffs(frame, idle, oocAlphaPet, incAlphaPet, false)
            end
        end
    end
end

local function CustomFramesSetGroupMemberAlpha(unitTag, alphaGroup, alphaGroupOutOfRange)
    local frame = UnitFrames.CustomFrames[unitTag]
    if frame and frame.tlw then
        local alpha = IsUnitInGroupSupportRange(frame.unitTag) and alphaGroup or alphaGroupOutOfRange
        frame.control:SetAlpha(alpha)
    end
end

function UnitFrames.CustomFramesGroupAlpha()
    local alphaGroup = 0.01 * UnitFrames.SV.GroupAlpha
    local alphaGroupOutOfRange = alphaGroup / 2
    for i = 1, 4 do
        CustomFramesSetGroupMemberAlpha("SmallGroup" .. i, alphaGroup, alphaGroupOutOfRange)
    end
    for i = 1, 12 do
        CustomFramesSetGroupMemberAlpha("RaidGroup" .. i, alphaGroup, alphaGroupOutOfRange)
    end
end

function UnitFrames.CustomFramesReloadLowResourceThreshold()
    UnitFrames.healthThreshold = UnitFrames.SV.LowResourceHealth
    UnitFrames.magickaThreshold = UnitFrames.SV.LowResourceMagicka
    UnitFrames.staminaThreshold = UnitFrames.SV.LowResourceStamina

    local playerFrame = UnitFrames.CustomFrames["player"]
    if not playerFrame then return end

    if playerFrame[COMBAT_MECHANIC_FLAGS_HEALTH] then
        playerFrame[COMBAT_MECHANIC_FLAGS_HEALTH].threshold = UnitFrames.healthThreshold
    end
    if playerFrame[COMBAT_MECHANIC_FLAGS_MAGICKA] then
        playerFrame[COMBAT_MECHANIC_FLAGS_MAGICKA].threshold = UnitFrames.magickaThreshold
    end
    if playerFrame[COMBAT_MECHANIC_FLAGS_STAMINA] then
        playerFrame[COMBAT_MECHANIC_FLAGS_STAMINA].threshold = UnitFrames.staminaThreshold
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
    if DoesUnitExist("reticleover") then
        UnitFrames.LayoutDefaultReticleoverTargetIcons()
    end
end
