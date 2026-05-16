--- @diagnostic disable: duplicate-set-field
-- -----------------------------------------------------------------------------
--  LuiExtended
--  Distributed under The MIT License (MIT) (see LICENSE file)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Local references for better performance
local zo_strformat = zo_strformat
local eventManager = GetEventManager()

-- Load saved settings.
local function LoadSavedVars()
    local profile = LUIE.SavedVarsProfile
    -- Addon options
    LUIE.SV = ZO_SavedVars:NewAccountWide(LUIE.SVName, LUIE.SVVer, nil, LUIE.Defaults, profile)
    if LUIE.SV.CharacterSpecificSV then
        LUIE.SV = ZO_SavedVars:New(LUIE.SVName, LUIE.SVVer, nil, LUIE.Defaults, profile)
    end
end

--- - **EVENT_PLAYER_ACTIVATED **
-- Startup Info string.
--- @param eventId integer
--- @param initial boolean
local function LoadScreen(eventId, initial)
    eventManager:UnregisterForEvent(LUIE.name, EVENT_PLAYER_ACTIVATED)
    --
    SLASH_COMMANDS["/luie"] = LUIE.OnLuieSlashCommand
    LUIE.ShowDebugEnvironmentPendingChat()
    --
    -- Set Positions for moved Default UI elements
    LUIE.SetElementPosition()
    if not LUIE.SV.StartupInfo then
        LUIE.PrintToChat(zo_strformat("|cFFFFFF<<1>> by|r |c00C000<<2>>|r |cFFFFFFv<<3>>|r", LUIE.name, LUIE.author, LUIE.version), true)
    end
end

-- Register events.
local function RegisterEvents()
    eventManager:RegisterForEvent(LUIE.name, EVENT_PLAYER_ACTIVATED, LoadScreen)

    -- Event registrations
    if LUIE.SV.SlashCommands_Enable or LUIE.SV.ChatAnnouncements_Enable then
        eventManager:RegisterForEvent(LUIE.name .. "ChatAnnouncements", EVENT_GUILD_SELF_JOINED_GUILD, LUIE.UpdateGuildData)
        eventManager:RegisterForEvent(LUIE.name .. "ChatAnnouncements", EVENT_GUILD_SELF_LEFT_GUILD, LUIE.UpdateGuildData)
    end
    -- LUIE.ApplySceneLogOverrides()
    eventManager:UnregisterForEvent(LUIE.name, EVENT_ADD_ON_LOADED)
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
end

--- - **EVENT_ADD_ON_LOADED **
-- LuiExtended Initialization.
--- @param eventId integer
--- @param addonName string
local function OnAddOnLoaded(eventId, addonName)
    if addonName ~= LUIE.name then
        return
    end
    LUIE.SavedVarsProfile = GetWorldName()
    LUIE.MigrateDisplaySubtreeFromLegacyProfile()
    -- Load saved variables
    LoadSavedVars()
    LUIE.MigrateSplitModuleSavedVarsFromLuiESV()
    LUIE.PruneLegacyLuiESVDefaultProfileBranch()
    LUIE.UpdateGuildData(nil, nil, nil, nil)
    -- -----------------------------------------------------------------------------
    -- Initialize Hooks
    LUIE:InitializeHooks()
    --
    LUIE.OtherAddonCompatability.isActionDurationReminderEnabled = LUIE.IsItEnabled("ActionDurationReminder")
    LUIE.OtherAddonCompatability.isCrutchAlertsEnabled = LUIE.IsItEnabled("CrutchAlerts")
    LUIE.OtherAddonCompatability.isFancyActionBarEnabled = LUIE.IsItEnabled("FancyActionBar")
    LUIE.OtherAddonCompatability.isFancyActionBarPlusEnabled = LUIE.IsItEnabled("FancyActionBar\43")
    LUIE.OtherAddonCompatability.isWritCreatorEnabled = LUIE.IsItEnabled("DolgubonsLazyWritCreator")
    -- -----------------------------------------------------------------------------
    -- Toggle Alert Frame Visibility if needed
    LUIE.SetupAlertFrameVisibility()
    LUIE.PlayerNameRaw = GetRawUnitName("player")
    LUIE.PlayerNameFormatted = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetUnitName("player"))
    LUIE.PlayerDisplayName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetUnitDisplayName("player"))
    LUIE.PlayerFaction = GetUnitAlliance("player")
    -- -----------------------------------------------------------------------------
    -- Initialize this addon modules according to user preferences
    LUIE.ChatAnnouncements.Initialize(LUIE.SV.ChatAnnouncements_Enable)
    LUIE.ActionBar.Initialize(LUIE.SV.ActionBar_Enabled)
    LUIE.CombatInfo.Initialize(LUIE.SV.CombatInfo_Enabled)
    LUIE.CombatText.Initialize(LUIE.SV.CombatText_Enabled)
    LUIE.InfoPanel.Initialize(LUIE.SV.InfoPanel_Enabled)
    LUIE.UnitFrames.Initialize(LUIE.SV.UnitFrames_Enabled)
    LUIE.SpellCastBuffs.Initialize(LUIE.SV.SpellCastBuff_Enable)
    LUIE.SlashCommands.Initialize(LUIE.SV.SlashCommands_Enable)
    -- -----------------------------------------------------------------------------
    -- Load Timestamp Color
    LUIE.UpdateTimeStampColor()
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
    LUIE.SlashCommands.CreateSettings()
    LUIE.SlashCommands.MigrateSettings()
    -- -----------------------------------------------------------------------------
    -- Display changelog screen
    if LUIE.SV.ShowChangeLog == true then
        LUIE.ChangelogScreen()
    end
    -- -----------------------------------------------------------------------------
    -- Register global event listeners
    RegisterEvents()
end

eventManager:RegisterForEvent(LUIE.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
