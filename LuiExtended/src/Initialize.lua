-- -----------------------------------------------------------------------------
--  LuiExtended
--  Distributed under The MIT License (MIT) (see LICENSE file)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Local references for better performance
local zo_strformat = zo_strformat
local eventManager = GetEventManager()

-- Ensure LibMediaProvider is initialized
local LMP = LibMediaProvider
if not LMP then
    error("LibMediaProvider is not initialized", 2)
end

-- Load saved settings.
local function LoadSavedVars()
    -- Addon options
    LUIE.SV = ZO_SavedVars:NewAccountWide(LUIE.SVName, LUIE.SVVer, nil, LUIE.Defaults)
    if LUIE.SV.CharacterSpecificSV then
        LUIE.SV = ZO_SavedVars:New(LUIE.SVName, LUIE.SVVer, nil, LUIE.Defaults)
    end
end

-- Load additional fonts from LMP.
local function UpdateFonts()
    -- First register our own fonts
    for fontName, fontPath in pairs(LUIE.Fonts) do
        LMP:Register(LMP.MediaType.FONT, fontName, fontPath)
    end

    -- Then fetch fonts from other addons
    for _, fontName in pairs(LMP:List(LMP.MediaType.FONT)) do
        if not LUIE.Fonts[fontName] then
            LUIE.Fonts[fontName] = LMP:Fetch(LMP.MediaType.FONT, fontName)
        end
    end
end

-- Load additional status bar textures from LMP.
local function UpdateStatusbarTextures()
    -- First register our own textures
    for textureName, texturePath in pairs(LUIE.StatusbarTextures) do
        LMP:Register(LMP.MediaType.STATUSBAR, textureName, texturePath)
    end

    -- Then fetch textures from other addons
    for _, textureName in pairs(LMP:List(LMP.MediaType.STATUSBAR)) do
        if not LUIE.StatusbarTextures[textureName] then
            LUIE.StatusbarTextures[textureName] = LMP:Fetch(LMP.MediaType.STATUSBAR, textureName)
        end
    end
end

-- Load additional sounds from LMP.
local function UpdateSounds()
    -- First register our own sounds
    for soundName, soundId in pairs(LUIE.Sounds) do
        LMP:Register(LMP.MediaType.SOUND, soundName, soundId)
    end

    -- Then fetch sounds from other addons
    for _, soundName in pairs(LMP:List(LMP.MediaType.SOUND)) do
        if not LUIE.Sounds[soundName] then
            LUIE.Sounds[soundName] = LMP:Fetch(LMP.MediaType.SOUND, soundName)
        end
    end
end

-- Load additional media from LMP.
local function LoadMedia()
    UpdateFonts()
    UpdateStatusbarTextures()
    UpdateSounds()
end

--- - **EVENT_PLAYER_ACTIVATED **
-- Startup Info string.
--- @param eventId integer
--- @param initial boolean
local function LoadScreen(eventId, initial)
    eventManager:UnregisterForEvent(LUIE.name, EVENT_PLAYER_ACTIVATED)
    -- Set Positions for moved Default UI elements
    LUIE.SetElementPosition()
    if not LUIE.SV.StartupInfo then
        LUIE.PrintToChat(zo_strformat("|cFFFFFF<<1>> by|r |c00C000<<2>>|r |cFFFFFFv<<3>>|r", LUIE.name, LUIE.author, LUIE.version), true)
    end
end

-- Register events.
local function RegisterEvents()
    eventManager:RegisterForEvent(LUIE.name, EVENT_PLAYER_ACTIVATED, LoadScreen)

    -- Register for LibMediaProvider media registration callbacks
    if LMP then
        LUIE:RegisterCallback("LibMediaProvider_Registered", function (mediatype, key)
            if mediatype == LMP.MediaType.FONT then
                LUIE.Fonts[key] = LMP:Fetch(mediatype, key)
            elseif mediatype == LMP.MediaType.STATUSBAR then
                LUIE.StatusbarTextures[key] = LMP:Fetch(mediatype, key)
            elseif mediatype == LMP.MediaType.SOUND then
                LUIE.Sounds[key] = LMP:Fetch(mediatype, key)
            end
        end)
    end

    -- Existing event registrations
    if LUIE.SV.SlashCommands_Enable or LUIE.SV.ChatAnnouncements_Enable then
        eventManager:RegisterForEvent(LUIE.name .. "ChatAnnouncements", EVENT_GUILD_SELF_JOINED_GUILD, LUIE.UpdateGuildData)
        eventManager:RegisterForEvent(LUIE.name .. "ChatAnnouncements", EVENT_GUILD_SELF_LEFT_GUILD, LUIE.UpdateGuildData)
    end

    -- Load additional media from LMP and other addons
    LoadMedia()
end

function LUIE:InitializeHooks()
    self.API_Hooks()
    self.HookActionButton()
    self.HookSynergy()
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
eventManager:RegisterForEvent(LUIE.name, EVENT_ADD_ON_LOADED, function (eventId, addonName)
    -- Only initialize our own addon
    if LUIE.name ~= addonName then
        return
    end
    -- Once we know it's ours, lets unregister the event listener
    eventManager:UnregisterForEvent(addonName, eventId)
    -- -----------------------------------------------------------------------------
    -- Load saved variables
    LoadSavedVars()
    LUIE.UpdateGuildData(nil, nil, nil, nil)
    -- -----------------------------------------------------------------------------
    -- Initialize Hooks
    LUIE:InitializeHooks()
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
end)
