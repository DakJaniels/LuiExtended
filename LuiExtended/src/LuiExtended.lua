-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- **LuiExtended** namespace
---
--- @class (partial) LuiExtended
--- @field __index LuiExtended
--- @field Combat LUIE.CombatInfo
--- @field SpellCastBuffs LUIE.SpellCastBuffs
--- @field name string The addon name
--- @field log_to_chat boolean Whether to output logs to chat
--- @field logger LibDebugLogger|NOP The logger instance
--- @field author string The addon author
--- @field version string The addon version
--- @field SVName string SavedVariables name
--- @field SVVer number SavedVariables version
--- @field Defaults LUIE_Defaults_SV Default settings
--- @field SV LUIE_Defaults_SV Current saved variables
--- @field UI LUIE.UI
--- @field GridOverlay LUIE.GridOverlay
LUIE = {}
LUIE.__index = LUIE
-- -----------------------------------------------------------------------------
--- @class (partial) LuiExtended
local LUIE = LUIE
-- -----------------------------------------------------------------------------
LUIE.tag = "LUIE"
LUIE.name = "LuiExtended"
LUIE.version = "7.1.4.5"
LUIE.addonVersion = 7145
LUIE.author = "ArtOfShred, DakJaniels, psypanda, Saenic & SpellBuilder"
LUIE.website = "https://www.esoui.com/downloads/info818-LuiExtended.html"
LUIE.github = "https://github.com/DakJaniels/LuiExtended"
LUIE.feedback = "https://github.com/DakJaniels/LuiExtended/issues"
LUIE.translation = "https://github.com/DakJaniels/LuiExtended/tree/translations"
LUIE.donation = "https://paypal.me/dakjaniels"
-- -----------------------------------------------------------------------------
if not IsConsoleUI() then
    LUIE.LAM = LibAddonMenu2
end
-- -----------------------------------------------------------------------------
-- Saved variables options
--- @diagnostic disable-next-line: missing-fields
LUIE.SV = {}
LUIE.SV.Migrations = {}
LUIE.SVVer = nil
if IsConsoleUI() then
    LUIE.SVVer = 3
else
    LUIE.SVVer = 2
end
LUIE.SVName = "LUIESV"
-- -----------------------------------------------------------------------------
-- Components
LUIE.Components = {}
-- -----------------------------------------------------------------------------
-- Table to hold cached values so we don't have to ask addon manager each time we run a function.
LUIE.OtherAddonCompatability =
{
    isActionDurationReminderEnabled = false,
    isFancyActionBarEnabled = false,
    isFancyActionBarPlusEnabled = false,
    isWritCreatorEnabled = false
}
-- -----------------------------------------------------------------------------
-- Default Settings
--- @class LUIE_Defaults_SV
LUIE.Defaults =
{
    CustomIcons               = true,
    CharacterSpecificSV       = false,
    StartupInfo               = false,
    HideAlertFrame            = false,
    AlertFrameAlignment       = 3,
    HideXPBar                 = false,
    TempAlertHome             = false,
    TempAlertCampaign         = false,
    TempAlertOutfit           = false,
    WelcomeVersion            = 0,
    ShowChangeLog             = false,

    -- Modules
    UnitFrames_Enabled        = true,
    InfoPanel_Enabled         = true,
    ActionBar_Enabled         = true,
    CombatInfo_Enabled        = true,
    CombatText_Enabled        = true,
    SpellCastBuff_Enable      = true,
    ChatAnnouncements_Enable  = true,
    SlashCommands_Enable      = true,

    -- Grid settings
    snapToGrid_default        = false,
    snapToGridSize_default    = 15,
    snapToGrid_unitFrames     = false,
    snapToGridSize_unitFrames = 15,
    snapToGrid_buffs          = false,
    snapToGridSize_buffs      = 15,
    -- snapToGrid_combatText     = false,
    -- snapToGridSize_combatText = 15,
}

-- -----------------------------------------------------------------------------

-- Get media from LuiMedia addon (LuiMedia handles all LibMediaProvider registration)
LUIE.Fonts = LuiMedia.GetFonts()
LUIE.Sounds = LuiMedia.GetSounds()
LUIE.StatusbarTextures = LuiMedia.GetStatusbarTextures()

-- -----------------------------------------------------------------------------
local function readonlytable(t)
    return setmetatable({},
                        {
                            __index = t,
                            __newindex = function (_, key, value)
                                error("Attempt to modify read-only table")
                            end,
                            __metatable = false
                        })
end

--- @class DevEntry
--- @field enabled boolean Whether this developer has special access enabled
--- @field debug boolean Whether debug mode is enabled for this developer

--- @type table<string, DevEntry>
local DEVS = readonlytable
    {
        ["@ArtOfShred"] =
        {
            enabled = false,
            debug = false,
        },
        ["@ArtOfShredPTS"] =
        {
            enabled = false,
            debug = false,
        },
        ["@ArtOfShredLegacy"] =
        {
            enabled = false,
            debug = false,
        },
        ["@HammerOfGlory"] =
        {
            enabled = false,
            debug = false,
        },
        ["@dack_janiels"] =
        {
            enabled = false,
            debug = false,
        },
        ["@dack_janiels.luie"] =
        {
            enabled = false,
            debug = false,
        },
    }

-- @type table<string, DevEntry>
-- LUIE.DEVS = DEVS

-- -----------------------------------------------------------------------------
-- Helper function to check if debug is enabled for current user
function LUIE.IsDevDebugEnabled()
    local currentUser = zo_strformat("<<1>>", GetUnitDisplayName("player"))
    return DEVS[currentUser] and DEVS[currentUser].enabled and DEVS[currentUser].debug
end

-- -----------------------------------------------------------------------------

-- do
--     local g_loggingEnabled = true
--     function ZO_Scene:Log(message)
--         if g_loggingEnabled then
--             CHAT_ROUTER:AddSystemMessage(string.format("%s - %s - %s", ZO_Scene_GetOriginColor():Colorize(GetString("SI_SCENEMANAGERMESSAGEORIGIN", ZO_REMOTE_SCENE_CHANGE_ORIGIN)), self.name, message))
--         end
--     end

--     function ZO_SceneManager_Follower:Log(message, sceneName)
--         if g_loggingEnabled then
--             if sceneName then
--                 CHAT_ROUTER:AddSystemMessage(string.format("%s - %s - %s", ZO_Scene_GetOriginColor():Colorize(GetString("SI_SCENEMANAGERMESSAGEORIGIN", ZO_REMOTE_SCENE_CHANGE_ORIGIN)), message, sceneName))
--             else
--                 CHAT_ROUTER:AddSystemMessage(string.format("%s - %s", ZO_Scene_GetOriginColor():Colorize(GetString("SI_SCENEMANAGERMESSAGEORIGIN", ZO_REMOTE_SCENE_CHANGE_ORIGIN)), message))
--             end
--         end
--     end
-- end
