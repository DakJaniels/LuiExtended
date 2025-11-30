-- -----------------------------------------------------------------------------
--  LuiExtended
--  Distributed under The MIT License (MIT) (see LICENSE file)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Local references for better performance
local zo_strformat = zo_strformat
local eventManager = GetEventManager()
local windowManager = GetWindowManager()

-- Ensure LibMediaProvider is initialized
local LMP = LibMediaProvider

local LUIE_InitControl = windowManager:CreateControl("LUIE_TempInitControl", GuiRoot, CT_CONTROL)

-- Load saved settings.
local function LoadSavedVars()
    -- Addon options
    LUIE.SV = ZO_SavedVars:NewAccountWide(LUIE.SVName, LUIE.SVVer, nil, LUIE.Defaults)
    if LUIE.SV.CharacterSpecificSV then
        LUIE.SV = ZO_SavedVars:New(LUIE.SVName, LUIE.SVVer, nil, LUIE.Defaults)
    end
end

-- Load additional media from LMP using centralized SettingsAPI
local function LoadMedia()
    LUIE.ConsoleSettingsAPI:LoadAllMedia()
end

--- - **EVENT_PLAYER_ACTIVATED **
-- Startup Info string.
--- @param eventId integer
--- @param initial boolean
local function LoadScreen(eventId, initial)
    LUIE_InitControl:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
    if not LUIE.SV.StartupInfo then
        LUIE.PrintToChat(zo_strformat("|cFFFFFF<<1>> by|r |c00C000<<2>>|r |cFFFFFFv<<3>>|r", LUIE.name, LUIE.author, LUIE.version), true)
    end
end

-- Register events.
local function RegisterEvents()
    LUIE_InitControl:RegisterForEvent(EVENT_PLAYER_ACTIVATED, LoadScreen)

    -- Existing event registrations
    if LUIE.SV.SlashCommands_Enable or LUIE.SV.ChatAnnouncements_Enable then
        eventManager:RegisterForEvent(LUIE.name .. "ChatAnnouncements", EVENT_GUILD_SELF_JOINED_GUILD, LUIE.UpdateGuildData)
        eventManager:RegisterForEvent(LUIE.name .. "ChatAnnouncements", EVENT_GUILD_SELF_LEFT_GUILD, LUIE.UpdateGuildData)
    end
end

function LUIE:InitializeHooks()
    self.API_Hooks()
    self.HookActionButton()
    self.HookSynergy()
    self.InitializeHooksSkillAdvisor()
    self.HookGamePadIcons()
    self.HookGamePadStats()
    self.HookGamePadMap()
end

-- Heavy initialization function
local function InitializeAddon()
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
    -- Initialize EditModeController for console
    LUIE.EditModeController:InitializeKeybindStrip()
    eventManager:RegisterForEvent(LUIE.name .. "_EditMode", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function ()
        LUIE.EditModeController:OnGamepadPreferredModeChanged()
    end)
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
    -- Display changelog screen
    if LUIE.SV.ShowChangeLog == true then
        LUIE.ChangelogScreen()
    end
    -- -----------------------------------------------------------------------------
    -- Register global event listeners
    RegisterEvents()
end


--- - **EVENT_ADD_ON_LOADED **
-- LuiExtended Initialization.
LUIE_InitControl:RegisterForEvent(EVENT_ADD_ONS_LOADED, function (eventId)
    d("EVENT_ADD_ONS_LOADED")
    -- -----------------------------------------------------------------------------
    -- Load saved variables
    LoadSavedVars()
    LUIE.UpdateGuildData(nil, nil, nil, nil)
    -- -----------------------------------------------------------------------------
    -- Register for LibMediaProvider media registration callbacks
    LUIE:RegisterCallback("LibMediaProvider_Registered", function (mediatype, key)
        LUIE.ConsoleSettingsAPI:HandleMediaRegistration(mediatype, key)
    end)
    -- -----------------------------------------------------------------------------
    -- Load additional media from LMP
    LoadMedia()
    -- -----------------------------------------------------------------------------
    -- Initialize Hooks
    LUIE:InitializeHooks()
    --
    LUIE.OtherAddonCompatability.isActionDurationReminderEnabled = LUIE.IsItEnabled("ActionDurationReminder")
    LUIE.OtherAddonCompatability.isFancyActionBarEnabled = LUIE.IsItEnabled("FancyActionBar")
    LUIE.OtherAddonCompatability.isFancyActionBarPlusEnabled = LUIE.IsItEnabled("FancyActionBar\43")
    LUIE.OtherAddonCompatability.isWritCreatorEnabled = LUIE.IsItEnabled("DolgubonsLazyWritCreator")

    -- Check if game has focus, if not wait for focus before doing heavy initialization
    if DoesGameHaveFocus() then
        d("Game has focus, initializing...")
        InitializeAddon()
    else
        d("Game doesn't have focus, waiting...")
        LUIE_InitControl:RegisterForEvent(EVENT_GAME_FOCUS_CHANGED, function (_, hasFocus)
            if hasFocus then
                d("Game gained focus, initializing...")
                LUIE_InitControl:UnregisterForEvent(EVENT_GAME_FOCUS_CHANGED)
                InitializeAddon()
            end
        end)
    end

    LUIE_InitControl:UnregisterForEvent(EVENT_ADD_ONS_LOADED)
end)
