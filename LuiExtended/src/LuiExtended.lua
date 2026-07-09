-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
--- **LuiExtended** namespace
---
--- @class (partial) LuiExtended
--- @field __index LuiExtended
--- @field Combat LUIE.CombatInfo
--- @field SpellCastBuffs LUIE.SpellCastBuffs
--- @field name string The addon name
--- @field log_to_chat boolean Whether to output logs to chat
--- @field logger LibDebugLogger The logger instance
--- @field author string The addon author
--- @field version string The addon version
--- @field SVName string SavedVariables name
--- @field SVVer number SavedVariables version
--- @field Defaults LUIE_Defaults_SV Default settings
--- @field SV LUIE_Defaults_SV Current saved variables
--- @field GridOverlay LUIE.GridOverlay
--- @field chatOutputSettingsUI LUIE_ChatOutputSettingsUI|nil
--- @field ChatOutput LUIE_ChatOutput
--- @field ChatOutputClass LUIE_ChatOutput
LUIE = {}
LUIE.__index = LUIE
LUIE.tag = "LUIE"
LUIE.name = "LuiExtended"
LUIE.version = "7.2.6.2"
LUIE.addonVersion = 7262
LUIE.author = "@dack_janiels[PC]"
LUIE.legacyAuthors = "ArtOfShred, psypanda, Saenic & SpellBuilder"
LUIE.website = "https://www.esoui.com/downloads/info818-LuiExtended.html"
LUIE.github = "https://github.com/DakJaniels/LuiExtended"
LUIE.license = "https://github.com/DakJaniels/LuiExtended/blob/master/LICENSE"
LUIE.feedback = "https://github.com/DakJaniels/LuiExtended/issues"
LUIE.translation = "https://github.com/DakJaniels/LuiExtended/blob/master/docs/LOCALIZATION.md"
LUIE.donation = "https://paypal.me/dakjaniels"
if not ZO_IsConsoleOrGameCoreUI() then
    LUIE.LAM = LibAddonMenu2
end
-- -----------------------------------------------------------------------------

--- @return string
function LUIE.FormatStartupChatMessage()
    return zo_strformat(GetString(LUIE_STRING_CORE_STARTUP_CHAT), LUIE.name, LUIE.author, LUIE.version)
end

--- @return string
function LUIE.FormatChangelogWindowTitle()
    return zo_strformat(GetString(LUIE_STRING_CORE_CHANGELOG_WINDOW_TITLE), LUIE.name)
end

--- @param moduleStringId integer
--- @return string
function LUIE.FormatAddonSettingsPanelTitle(moduleStringId)
    return zo_strformat("<<1>> - <<2>>", LUIE.name, GetString(moduleStringId))
end

--- @param moduleStringId integer
--- @return string
function LUIE.FormatAddonSettingsPanelDisplayName(moduleStringId)
    return zo_strformat("<<1>> <<2>>", LUIE.name, GetString(moduleStringId))
end

--- Stock ZOS font for movable-frame coordinate overlays (readable on gamepad / console UI scale).
--- @return string
function LUIE.GetPositionLabelFont()
    if ZO_IsConsoleOrGameCoreUI() then
        return "ZoFontGamepad22"
    end
    return "ZoFontGameSmall"
end

--- @param label LabelControl|nil
function LUIE.ApplyPositionLabelFont(label)
    if label and label.SetFont then
        label:SetFont(LUIE.GetPositionLabelFont())
    end
end

--- Mover preview title labels (e.g. "Player Preview") use the same gamepad sizing as coord overlays.
--- @param label LabelControl|nil
function LUIE.ApplyFramePreviewLabelFont(label)
    LUIE.ApplyPositionLabelFont(label)
end

--- XML default for mover overlay labels (`_Preview/_Label`, `_AnchorLabel`); PC init overrides via GetPositionLabelFont().
LUIE.MOVER_OVERLAY_FONT_XML = "ZoFontGamepad22"

local MOVER_OVERLAY_TLW_NAMES =
{
    "LUIE_CustomPlayerFrame",
    "LUIE_CustomTargetFrame",
    "LUIE_CustomAvaPlayerTargetFrame",
    "LUIE_CustomSmallGroupFrame",
    "LUIE_CustomRaidGroupFrame",
    "LUIE_CustomPetFrame",
    "LUIE_CustomCompanionFrame",
    "LUIE_CustomBossFrame",
}

--- @param preview Control|nil
local function ApplyMoverPreviewControlFonts(preview)
    if not preview then
        return
    end
    LUIE.ApplyFramePreviewLabelFont(preview:GetNamedChild("_Label"))
    LUIE.ApplyPositionLabelFont(preview:GetNamedChild("_AnchorLabel"))
end

--- Applies console/PC-correct fonts to all mover coord + preview labels (XML defaults + runtime-created controls).
function LUIE.RefreshMoverOverlayFonts()
    for i = 1, #MOVER_OVERLAY_TLW_NAMES do
        local tlw = _G[MOVER_OVERLAY_TLW_NAMES[i]]
        if tlw then
            ApplyMoverPreviewControlFonts(tlw.preview)
            ApplyMoverPreviewControlFonts(tlw:GetNamedChild("_Preview"))
        end
    end

    local alertFrame = _G["LUIE_AlertFrame"]
    if alertFrame then
        ApplyMoverPreviewControlFonts(alertFrame:GetNamedChild("_Preview"))
    end

    for _, panelName in ipairs({ "LUIE_CombatText_Incoming", "LUIE_CombatText_Outgoing" }) do
        local panel = _G[panelName]
        if panel then
            ApplyMoverPreviewControlFonts(panel:GetNamedChild("_Preview"))
        end
    end

    local castBar = _G["LUIE_ACTIONBAR_CASTBAR_TLC"]
    if castBar and castBar.preview then
        LUIE.ApplyFramePreviewLabelFont(castBar.previewLabel)
        LUIE.ApplyPositionLabelFont(castBar.preview.anchorLabel)
    end

    local spellCastBuffs = LUIE.SpellCastBuffs
    if spellCastBuffs and spellCastBuffs.BuffContainers then
        for _, container in pairs(spellCastBuffs.BuffContainers) do
            if container then
                LUIE.ApplyFramePreviewLabelFont(container.previewLabel)
                if container.preview then
                    LUIE.ApplyPositionLabelFont(container.preview.anchorLabel)
                end
            end
        end
    end
end

-- -----------------------------------------------------------------------------
-- Saved variables options
--- @diagnostic disable-next-line: missing-fields
LUIE.SV = {}
LUIE.SVVer = nil
if ZO_IsConsoleOrGameCoreUI() then
    LUIE.SVVer = 3
else
    LUIE.SVVer = 2
end
LUIE.SVName = "LUIESV"
--- ZO_SavedVars `profile` for megaserver-specific account-wide data (`GetWorldName()`). Set during `EVENT_ADD_ON_LOADED` before any `ZO_SavedVars` call.
--- @type string|nil
LUIE.SavedVarsProfile = nil
--- Legacy ZO profile used by older LuiExtended installs (`ZO_SavedVars` default when `profile` is omitted).
LUIE.LegacySavedVarsProfile = "Default"

--- Top-level SavedVariables global name per module (see `## SavedVariables` in the addon manifest).
LUIE.ModuleSavedVarNames =
{
    UnitFrames = "LUIE_UnitFrames_SV",
    CombatText = "LUIE_CombatText_SV",
    ChatAnnouncements = "LUIE_ChatAnnouncements_SV",
    SpellCastBuffs = "LUIE_SpellCastBuffs_SV",
    ActionBar = "LUIE_ActionBar_SV",
    InfoPanel = "LUIE_InfoPanel_SV",
    SlashCommands = "LUIE_SlashCommands_SV",
    CombatInfo = "LUIE_CombatInfo_SV",
    MiniMap = "LUIE_MiniMap_SV",
}

--- ZO_SavedVars namespace keys previously stored under `LUIESV` before the per-global split.
LUIE.ModuleSavedVarNamespaceKeys =
{
    "UnitFrames",
    "CombatText",
    "ChatAnnouncements",
    "SpellCastBuffs",
    "ActionBar",
    "InfoPanel",
    "SlashCommands",
    "CombatInfo",
    "MiniMap",
}
-- -----------------------------------------------------------------------------
-- Components
LUIE.Components = {}
-- -----------------------------------------------------------------------------
-- Table to hold cached values so we don't have to ask addon manager each time we run a function.
LUIE.OtherAddonCompatability =
{
    isCombatMetricsEnabled = false,
    isActionDurationReminderEnabled = false,
    isCrutchAlertsEnabled = false,
    isFancyActionBarEnabled = false,
    isFancyActionBarPlusEnabled = false,
    isWritCreatorEnabled = false,
    isLibCombatEnabled = false,
    isLibSlashCommanderEnabled = false,
}
-- -----------------------------------------------------------------------------
-- Default Settings
--- @class LUIE_ChatOutputSocialDefaults
--- @field FriendStatusCA boolean
--- @field FriendIgnoreCA boolean

--- @class LUIE_ChatOutputDefaults
--- @field ChatMethod string
--- @field ChatBypassFormat boolean
--- @field ChatTab table<number, boolean>
--- @field TimeStamp boolean
--- @field TimeStampFormat string
--- @field TimeStampColor number[]
--- @field LcmUseLuiExtendedTimestampFormat boolean|nil When true (default), Timestamp Format below drives LUIE proxy time; when false, LibChatMessage preset/os.date drives time.
--- @field Social LUIE_ChatOutputSocialDefaults

--- @class LUIE_Defaults_SV
--- @field DebugEnvironmentActive boolean True while /luie debug on allowlist is applied
--- @field DebugEnvironmentRestore table<string, boolean>|nil Snapshot of addon enabled flags before debug on
--- @field DebugEnvironmentPendingChat string|nil One-shot chat line to show after the next UI reload
--- @field ChatOutput LUIE_ChatOutputDefaults LUIE-wide chat print routing (tabs, timestamps, LCM/pChat)
LUIE.Defaults =
{
    CustomIcons                    = true,
    CharacterSpecificSV            = false,
    StartupInfo                    = false,
    HideAlertFrame                 = false,
    AlertFrameAlignment            = 3,
    HideXPBar                      = false,
    SuppressZOBuffDebuffWhenHidden = false,
    WelcomeVersion                 = 0,
    ShowChangeLog                  = false,

    -- Modules
    UnitFrames_Enabled             = true,
    InfoPanel_Enabled              = true,
    ActionBar_Enabled              = true,
    CombatInfo_Enabled             = true,
    CombatText_Enabled             = true,
    SpellCastBuff_Enable           = true,
    ChatAnnouncements_Enable       = true,
    SlashCommands_Enable           = true,
    MiniMap_Enabled                = false,

    -- Grid settings
    snapToGrid_default             = false,
    snapToGridSize_default         = 15,
    snapToGrid_unitFrames          = false,
    snapToGridSize_unitFrames      = 15,
    snapToGrid_buffs               = false,
    snapToGridSize_buffs           = 15,
    -- snapToGrid_combatText     = false,
    -- snapToGridSize_combatText = 15,

    -- Debug environment (/luie debug): LUIE-core addon allowlist isolation
    DebugEnvironmentActive         = false,
    DebugEnvironmentRestore        = nil,
    DebugEnvironmentPendingChat    = nil,

    ChatOutput                     =
    {
        ChatMethod = "Print to All Tabs",
        ChatBypassFormat = false,
        -- Tab indices 1..N are dynamic (see LUIE.ChatOutput:GetMaxChatTabIndex); defaults keep first five enabled for legacy installs.
        ChatTab = { [1] = true, [2] = true, [3] = true, [4] = true, [5] = true },
        TimeStamp = false,
        TimeStampFormat = "HH:m:s",
        TimeStampColor = { 143 / 255, 143 / 255, 143 / 255 },
        LcmUseLuiExtendedTimestampFormat = true,
        Social =
        {
            FriendStatusCA = true,
            FriendIgnoreCA = true,
        },
    },

    Migrations                     = {}
}

-- -----------------------------------------------------------------------------

-- Get media from LuiMedia addon (LuiMedia handles all LibMediaProvider registration)
LUIE.Fonts = LuiMedia.GetFonts()
LUIE.Sounds = LuiMedia.GetSounds()
LUIE.StatusbarTextures = LuiMedia.GetStatusbarTextures()

-- -----------------------------------------------------------------------------
-- GLOBAL TABLE CACHE SYSTEM
-- Weak-key pool: take with next(cache) / pop entry, return with cache[t] = true.
-- Keys are cleared in RecycleTable (not on checkout) so checkout stays cheap;
-- pooled tables are always empty for the next borrower—needed for sparse
-- flag tables consumed with truthy checks (e.g. if flags.isDamage then ...).
--
-- Contract: only pass tables from GetCachedTable() into RecycleTable(t).
-- After RecycleTable(t), do not read or write t (it may be reused elsewhere).
-- -----------------------------------------------------------------------------

--- @type table<table, boolean>
local g_tableCache = setmetatable({}, { __mode = "k" }) -- Weak keys: forgotten tables drop out of the pool

--- Pop a pooled table or allocate a new empty table
--- @return table t Empty: previous owner cleared keys at recycle time
--- @usage local t = LUIE.GetCachedTable(); t.field = 1; ...; LUIE.RecycleTable(t)
function LUIE.GetCachedTable()
    local t = next(g_tableCache)
    if t then
        g_tableCache[t] = nil
    else
        t = {}
    end
    return t
end

--- Clear all keys, then return the table to the pool for reuse
--- @param t table Table previously obtained from GetCachedTable()
--- @usage LUIE.RecycleTable(myTable)
function LUIE.RecycleTable(t)
    if t then
        for k in pairs(t) do
            t[k] = nil
        end
        g_tableCache[t] = true
    end
end

--- Get current cache statistics (for debugging/profiling)
--- @return number count Number of tables currently in cache
function LUIE.GetTableCacheStats()
    local count = 0
    for _ in pairs(g_tableCache) do
        count = count + 1
    end
    return count
end

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
            enabled = true,
            debug = true,
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

local devDebugEnabledCache
local devDebugEnabledCacheForDisplayName

-- Helper function to check if debug is enabled for current user
function LUIE.IsDevDebugEnabled()
    local displayName = GetUnitDisplayName("player")
    if displayName == devDebugEnabledCacheForDisplayName then
        return devDebugEnabledCache
    end
    devDebugEnabledCacheForDisplayName = displayName
    local currentUser = zo_strformat("<<1>>", displayName)
    local devEntry = DEVS[currentUser]
    devDebugEnabledCache = devEntry and devEntry.enabled and devEntry.debug or false
    return devDebugEnabledCache
end

-- -----------------------------------------------------------------------------

do
    function LUIE.ApplySceneLogOverrides()
        local g_loggingEnabled = LUIE.IsDevDebugEnabled()
        if g_loggingEnabled then
            local function ZO_Scene_Log(self, message)
                LUIE:Log("Verbose", string.format("%s - %s - %s", GetString("SI_SCENEMANAGERMESSAGEORIGIN", ZO_REMOTE_SCENE_CHANGE_ORIGIN), self.name, message))
            end
            ZO_Scene.Log = ZO_Scene_Log
            local function ZO_SceneManager_Follower_Log(self, message, sceneName)
                if sceneName then
                    LUIE:Log("Verbose", string.format("%s - %s - %s", GetString("SI_SCENEMANAGERMESSAGEORIGIN", ZO_REMOTE_SCENE_CHANGE_ORIGIN), message, sceneName))
                else
                    LUIE:Log("Verbose", string.format("%s - %s", GetString("SI_SCENEMANAGERMESSAGEORIGIN", ZO_REMOTE_SCENE_CHANGE_ORIGIN), message))
                end
            end
            ZO_SceneManager_Follower.Log = ZO_SceneManager_Follower_Log
        end
    end
end
