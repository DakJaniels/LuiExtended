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

--- - **EVENT_PLAYER_ACTIVATED **
-- Startup Info string.
--- @param eventId integer
--- @param initial boolean
local function LoadScreen(eventId, initial)
    eventManager:UnregisterForEvent(LUIE.name, eventId)
    if not LUIE.SV.StartupInfo and initial then
        LUIE.PrintToChat(zo_strformat("|cFFFFFF<<1>> by|r |c00C000<<2>>|r |cFFFFFFv<<3>>|r", LUIE.name, LUIE.author, LUIE.version), true)
    end
    if LibDebugLogger then
        LibDebugLogger:ClearLog()
    end
end

--- - **EVENT_ADD_ON_LOADED **
-- LuiExtended Initialization.
eventManager:RegisterForEvent(LUIE.name, EVENT_ADD_ON_LOADED, function (eventId, addonName)
    -- Only initialize our own addon
    if addonName == LUIE.name then
        -- -----------------------------------------------------------------------------
        -- Load saved variables
        -- Addon options
        LUIE.SV = ZO_SavedVars:NewAccountWide(LUIE.SVName, LUIE.SVVer, nil, LUIE.Defaults)
        if LUIE.SV.CharacterSpecificSV then
            LUIE.SV = ZO_SavedVars:New(LUIE.SVName, LUIE.SVVer, nil, LUIE.Defaults)
        end
        -- -----------------------------------------------------------------------------
        LUIE.UpdateGuildData(nil, nil, nil, nil)
        -- -----------------------------------------------------------------------------
        -- Initialize Hooks
        LUIE.API_Hooks()
        LUIE.HookActionButton()
        LUIE.HookSynergy()
        LUIE.InitializeHooksSkillAdvisor()
        LUIE.HookGamePadIcons()
        LUIE.HookGamePadStats()
        LUIE.HookGamePadMap()
        --
        LUIE.OtherAddonCompatability.isActionDurationReminderEnabled = LUIE.IsItEnabled("ActionDurationReminder")
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
        LUIE.CreateConsoleSettings()
        LUIE.ChatAnnouncements.CreateConsoleSettings()
        LUIE.ActionBar.CreateConsoleSettings()
        LUIE.CombatInfo.CreateConsoleSettings()
        LUIE.CombatText.CreateConsoleSettings()
        LUIE.InfoPanel.CreateConsoleSettings()
        LUIE.UnitFrames.CreateConsoleSettings()
        LUIE.SpellCastBuffs.CreateConsoleSettings()
        LUIE.SlashCommands.CreateConsoleSettings()
        -- -----------------------------------------------------------------------------
        -- Register global event listeners
        eventManager:RegisterForEvent(LUIE.name, EVENT_PLAYER_ACTIVATED, LoadScreen)

        -- Event registrations
        if LUIE.SV.SlashCommands_Enable or LUIE.SV.ChatAnnouncements_Enable then
            eventManager:RegisterForEvent(LUIE.name .. "ChatAnnouncements", EVENT_GUILD_SELF_JOINED_GUILD, LUIE.UpdateGuildData)
            eventManager:RegisterForEvent(LUIE.name .. "ChatAnnouncements", EVENT_GUILD_SELF_LEFT_GUILD, LUIE.UpdateGuildData)
        end
        -- -----------------------------------------------------------------------------
        eventManager:UnregisterForEvent(addonName, eventId)
    end
end)
