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
--- @field logger LibDebugLogger The logger instance
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
LUIE.version = "7.2.1.2"
LUIE.addonVersion = 7212
LUIE.author = "@dack_janiels[PC]"
LUIE.legacyAuthors = "ArtOfShred, psypanda, Saenic & SpellBuilder"
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
    isCrutchAlertsEnabled = false,
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

    Migrations                = {}
}

-- -----------------------------------------------------------------------------

-- Get media from LuiMedia addon (LuiMedia handles all LibMediaProvider registration)
LUIE.Fonts = LuiMedia.GetFonts()
LUIE.Sounds = LuiMedia.GetSounds()
LUIE.StatusbarTextures = LuiMedia.GetStatusbarTextures()

-- -----------------------------------------------------------------------------
-- GLOBAL TABLE CACHE SYSTEM
-- Provides high-performance table recycling across all LUIE modules
-- Eliminates thousands of table allocations per second in hot code paths
-- -----------------------------------------------------------------------------

--- @type table<table, boolean>
local g_tableCache = setmetatable({}, { __mode = "k" }) -- Weak keys for automatic cleanup

--- Get a recycled table from cache or create a new one
--- Use this in hot code paths (event handlers, update loops) to eliminate allocations
--- @return table t A clean table ready for use
--- @usage local myTable = LUIE.GetCachedTable()
---        myTable.foo = "bar"
---        -- ... use table ...
---        LUIE.RecycleTable(myTable)  -- Return to cache when done
function LUIE.GetCachedTable()
    local t = next(g_tableCache)
    if t then
        g_tableCache[t] = nil
        -- Clear any remaining contents
        for k in pairs(t) do
            t[k] = nil
        end
    else
        t = {}
    end
    return t
end

--- Return a table to the cache for future reuse
--- Always call this when you're done with a cached table to enable recycling
--- @param t table The table to recycle
--- @usage LUIE.RecycleTable(myTable)
function LUIE.RecycleTable(t)
    if t then
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
--- @field nameColor number[]|nil `{ r, g, b [, a] }`
--- @field nameGradientFrom number[]|nil paired with `nameGradientTo` for markup gradient
--- @field nameGradientTo number[]|nil

--- Default RGBA when a DevEntry omits `nameColor`.
local DEV_NAME_COLOR_DEFAULT = { 1, 0.85, 0.35, 1 }

--- UTF-8 code units (ZOS provides no public iterator for addon UI strings).
local function utf8Chars(s)
    local chars = {}
    local pos = 1
    local len = #s
    while pos <= len do
        local byte = string.byte(s, pos)
        local cpLen = 1
        if byte >= 0xF0 then
            cpLen = 4
        elseif byte >= 0xE0 then
            cpLen = 3
        elseif byte >= 0xC0 then
            cpLen = 2
        end
        chars[#chars + 1] = string.sub(s, pos, pos + cpLen - 1)
        pos = pos + cpLen
    end
    return chars
end

--- Per-character gradient via `ZO_ColorDef` (`Libraries/Utility/ZO_ColorDef.lua`).
local function formatDevNameGradientMarkup(plainText, r1, g1, b1, r2, g2, b2)
    local leading = ""
    local core = plainText
    local startIdx, endIdx = plainText:find("|t%d+:%d+:[^|]*|t")
    if startIdx == 1 and endIdx then
        leading = plainText:sub(1, endIdx)
        core = plainText:sub(endIdx + 1)
    end
    core = core:match("^%s*(.-)%s*$") or core
    local chars = utf8Chars(core)
    local n = #chars
    if n == 0 then
        return plainText
    end
    local colorFrom = ZO_ColorDef:New(r1, g1, b1, 1)
    local colorTo = ZO_ColorDef:New(r2, g2, b2, 1)
    local colorScratch = ZO_ColorDef:New(0, 0, 0, 1)
    local parts = {}
    parts[#parts + 1] = leading
    if leading ~= "" and core ~= "" then
        parts[#parts + 1] = " "
    end
    for i = 1, n do
        local t = (n <= 1) and 0 or (i - 1) / (n - 1)
        colorScratch:SetRGB(ZO_ColorDef.LerpRGB(colorFrom, colorTo, t))
        parts[#parts + 1] = colorScratch:Colorize(chars[i])
    end
    return table.concat(parts)
end

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
            nameGradientFrom = { 0.35, 0.85, 1 },
            nameGradientTo = { 1, 0.45, 0.9 },
        },
        ["@dack_janiels.luie"] =
        {
            enabled = false,
            debug = false,
            nameGradientFrom = { 0.45, 1, 0.55 },
            nameGradientTo = { 1, 0.75, 0.2 },
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

--- If `displayName` is in `DEVS`, returns styled text (gradient markup when configured) and RGBA for name + class labels; otherwise returns `plainText` only.
function LUIE.ApplyListedDevUnitFrameName(displayName, plainText)
    if not displayName or displayName == "" then
        return plainText
    end
    local entry = DEVS[zo_strformat("<<1>>", displayName)]
    if not entry then
        return plainText
    end
    local gf, gt = entry.nameGradientFrom, entry.nameGradientTo
    local nr, ng, nb, na, cr, cg, cb, ca
    if gf and gt then
        nr, ng, nb, na = 1, 1, 1, 1
        cr, cg, cb, ca = gt[1], gt[2], gt[3], 1
        plainText = formatDevNameGradientMarkup(plainText, gf[1], gf[2], gf[3], gt[1], gt[2], gt[3])
    else
        local c = entry.nameColor
        nr, ng, nb, na = DEV_NAME_COLOR_DEFAULT[1], DEV_NAME_COLOR_DEFAULT[2], DEV_NAME_COLOR_DEFAULT[3], DEV_NAME_COLOR_DEFAULT[4]
        if c then
            nr, ng, nb, na = c[1], c[2], c[3], c[4] or 1
        end
        cr, cg, cb, ca = nr, ng, nb, na
    end
    return plainText, nr, ng, nb, na, cr, cg, cb, ca
end

-- -----------------------------------------------------------------------------

do
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
