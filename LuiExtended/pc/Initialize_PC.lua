--- @diagnostic disable: duplicate-set-field
-- -----------------------------------------------------------------------------
--  LuiExtended
--  Distributed under The MIT License (MIT) (see LICENSE file)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Local references for better performance
local GetString = GetString
local zo_strformat = zo_strformat
local eventManager = GetEventManager()

-- Load saved settings.
local function LoadSavedVars()
    LUIE.SavedVarsProfile = GetWorldName()
    LUIE.MigrateDisplaySubtreeFromLegacyProfile()
    local profile = LUIE.SavedVarsProfile
    -- Addon options
    LUIE.SV = ZO_SavedVars:NewAccountWide(LUIE.SVName, LUIE.SVVer, nil, LUIE.Defaults, profile)
    if LUIE.IsCharacterSpecificSavedVarsEnabled() then
        LUIE.SV = ZO_SavedVars:New(LUIE.SVName, LUIE.SVVer, nil, LUIE.Defaults, profile)
    end
    -- -----------------------------------------------------------------------------

    LUIE.MigrateSplitModuleSavedVarsFromLuiESV()
    LUIE.RepairSplitModuleSavedVarsFromLegacy()
    LUIE.SeedCharacterModuleSavedVarsFromAccountWide()
    LUIE.PruneLegacyLuiESVDefaultProfileBranch()
    LUIE.MigrateChatOutputToCore()
    LUIE.MigrateTempSlashAlertsToChatAnnouncements()
end

--- - **EVENT_PLAYER_ACTIVATED **
-- Startup Info string.
--- @param eventId integer
--- @param initial boolean
local function LoadScreen(eventId, initial)
    eventManager:UnregisterForEvent(LUIE.name, eventId)
    -- Set Positions for moved Default UI elements
    LUIE.SetElementPosition()
    if not LUIE.SV.StartupInfo then
        LUIE.ChatOutput:Print(LUIE.FormatStartupChatMessage(), true)
    end
    if LUIE.SV.ShowChangeLog == true then
        LUIE.ChangelogScreen()
    end
end

-- Register events.
local function RegisterEvents()
    eventManager:RegisterForEvent(LUIE.name, EVENT_PLAYER_ACTIVATED, LoadScreen)
    -- -----------------------------------------------------------------------------
    -- Event registrations
    if LUIE.SV.SlashCommands_Enable or LUIE.SV.ChatAnnouncements_Enable then
        eventManager:RegisterForEvent(LUIE.name .. "ChatAnnouncements", EVENT_GUILD_SELF_JOINED_GUILD, LUIE.UpdateGuildData)
        eventManager:RegisterForEvent(LUIE.name .. "ChatAnnouncements", EVENT_GUILD_SELF_LEFT_GUILD, LUIE.UpdateGuildData)
    end
    -- LUIE.ApplySceneLogOverrides()
end

function LUIE:InitializeHooks()
    self.API_Hooks()
    self.HookActionButton()
    -- self.HookSynergy() --TODO: Disabled due to performance issue. Investigating.
    self.InitializeHooksSkillAdvisor()
    self.HookGamePadIcons()
    self.HookGamePadStats()
    self.HookGamePadMap()

    self.HookKeyboardIcons()
    self.HookKeyboardStats()
    self.HookKeyboardMap()

    self.RegisterDebugEnvironmentLogoutHooks()
end

--- - **EVENT_ADD_ON_LOADED **
-- LuiExtended Initialization.
--- @param eventId integer
--- @param addonName string
local function OnAddOnLoaded(eventId, addonName)
    if addonName ~= LUIE.name then
        return
    end
    -- -----------------------------------------------------------------------------
    -- Load saved variables
    LoadSavedVars()
    -- -----------------------------------------------------------------------------
    LUIE.UpdateGuildData(nil, nil, nil, nil)
    -- -----------------------------------------------------------------------------
    -- Initialize Hooks
    LUIE:InitializeHooks()
    --
    LUIE.OtherAddonCompatability.isCombatMetricsEnabled = LUIE.IsItEnabled("CombatMetrics")
    LUIE.OtherAddonCompatability.isActionDurationReminderEnabled = LUIE.IsItEnabled("ActionDurationReminder")
    LUIE.OtherAddonCompatability.isCrutchAlertsEnabled = LUIE.IsItEnabled("CrutchAlerts")
    LUIE.OtherAddonCompatability.isFancyActionBarEnabled = LUIE.IsItEnabled("FancyActionBar")
    LUIE.OtherAddonCompatability.isFancyActionBarPlusEnabled = LUIE.IsItEnabled("FancyActionBar\43")
    LUIE.OtherAddonCompatability.isWritCreatorEnabled = LUIE.IsItEnabled("DolgubonsLazyWritCreator")
    LUIE.OtherAddonCompatability.isLibCombatEnabled = LUIE.IsItEnabled("LibCombat")
    LUIE.OtherAddonCompatability.isLibSlashCommanderEnabled = LUIE.IsItEnabled("LibSlashCommander")
    -- -----------------------------------------------------------------------------
    -- Toggle Alert Frame Visibility if needed
    LUIE.SetupAlertFrameVisibility()
    LUIE.PlayerNameRaw = GetRawUnitName("player")
    LUIE.PlayerNameFormatted = zo_strformat("<<C:1>>", GetUnitName("player"))
    LUIE.PlayerDisplayName = zo_strformat("<<C:1>>", GetUnitDisplayName("player"))
    LUIE.PlayerFaction = GetUnitAlliance("player")
    -- -----------------------------------------------------------------------------
    -- LUIE-wide chat output (LCM / tabs / timestamps); independent of CA module
    LUIE.ChatOutput:InitializePrintRouting()
    -- -----------------------------------------------------------------------------
    -- Initialize this addon modules according to user preferences
    LUIE.ChatAnnouncements.Initialize(LUIE.SV.ChatAnnouncements_Enable)
    LUIE.ActionBar.Initialize(LUIE.SV.ActionBar_Enabled)
    LUIE.CombatInfo.Initialize(LUIE.SV.CombatInfo_Enabled)
    LUIE.CombatText.Initialize(LUIE.SV.CombatText_Enabled)
    LUIE.InfoPanel.Initialize(LUIE.SV.InfoPanel_Enabled)
    LUIE.UnitFrames.Initialize(LUIE.SV.UnitFrames_Enabled)
    LUIE.SpellCastBuffs.Initialize(LUIE.SV.SpellCastBuff_Enable)
    LUIE.MiniMap.Initialize(LUIE.SV.MiniMap_Enabled)
    LUIE.SlashCommands.Initialize(LUIE.SV.SlashCommands_Enable)
    -- -----------------------------------------------------------------------------
    LUIE.ApplyZOBuffDebuffSuppression()
    LUIE.RegisterZOBuffDebuffSuppressionSettingListener()
    -- -----------------------------------------------------------------------------
    -- Load Timestamp Color
    LUIE.ChatOutput:UpdateTimeStampColor()
    -- -----------------------------------------------------------------------------
    -- Create settings menus for our addon
    LUIE.CreateSettings()
    LUIE.ChatAnnouncements.CreateSettings()
    LUIE.ActionBar.CreateSettings()
    LUIE.CombatInfo.CreateSettings()
    LUIE.CombatText.CreateSettings()
    LUIE.InfoPanel.CreateSettings()
    LUIE.UnitFrames.CreateSettings()
    LUIE.SpellCastBuffs.CreateSettings()
    LUIE.MiniMap.CreateSettings()
    LUIE.SlashCommands.CreateSettings()
    LUIE.SlashCommands.MigrateSettings()
    -- -----------------------------------------------------------------------------
    if LUIE.SlashCommandRegistry then
        LUIE.SlashCommandRegistry.ApplyPostInitSlashCommandIntegration()
    else
        SLASH_COMMANDS["/luie"] = LUIE.OnLuieSlashCommand
    end
    -- -----------------------------------------------------------------------------
    -- Register global event listeners
    RegisterEvents()
    LUIE.ScheduleDebugEnvironmentReloadChat()
    -- Dev locale audit: enable lang/_LocalizationCoverage_Dev.lua in LuiExtended.addon, then:
    -- if LUIE_ScheduleLocalizationCoverageReport then LUIE_ScheduleLocalizationCoverageReport() end
    --
    eventManager:UnregisterForEvent(addonName, eventId)
end

eventManager:RegisterForEvent(LUIE.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
