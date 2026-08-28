local NAME = "AntiClankerAddonConsortiumUpdateChecker"
local VERSION = 10

if type(_G[NAME]) == "number" and _G[NAME] >= VERSION then return end
_G[NAME] = VERSION

local KNOWN_VERSIONS = {
    -- Kyzeragon
    ["CrutchAlerts"]          = 22400,
    ["KyzderpsDerps"]         = 1520,

    -- code65536
    ["CharacterKnowledge"]    = 301010,
    ["CollectiblesTracker"]   = 306000,
    ["CombatAlerts"]          = 206010,
    ["GroupBuffPanels"]       = 203000,
    ["ItemBrowser"]           = 407010,
    ["LootLog"]               = 409060,
    ["Raidificator"]          = 407020,

    -- M0R_Gaming
    ["M0RMarkers"]            = 222,

    -- DakJaniels
    ["LuiExtended"]           = 7263,

    -- m00nyONE
    ["LibGroupCombatStats"]   = 20260726,
}

local MESSAGE = {
    default = "[ACAC Update Checker] You have the addon “<<1>>” installed, but it is an older version. Your version is <<2>>, while the expected version is <<3>> or newer.",
    de = "[ACAC Update Checker] Du hast das Add-on „<<1>>“ installiert, aber es handelt sich dabei um eine veraltete Version. Deine Version ist <<2>>, während die erwartete Version <<3>> oder neuer ist.",
    es = "[ACAC Update Checker] Tienes una instalación antigua del addon “<<1>>”. Tu instalación es la versión <<2>> mientras que la versión esperada es <<3>> o más reciente.",
    -- fr = "",
    jp = "[ACAC Update Checker] インストールされているアドオン「<<1>>」は古いバージョンです。現在のバージョンは <<2>> ですが、必要なバージョンは <<3>> 以上です。",
    ru = "[ACAC Update Checker] Установленная у вас версия дополнения “<<1>>” устарела. Текущая версия установленного дополнения <<2>>. Установите версию <<3>> или выше.",
    zh = "[ACAC Update Checker] 你当前使用的<<1>>为旧版本。当前的版本为<<2>>，而推荐版本为<<3>>或者更新。",
}
MESSAGE = MESSAGE[GetCVar("Language.2")] or MESSAGE.default


---------------------------------------------------------------------
-- Version check
---------------------------------------------------------------------
-- Addon table like ACACUC_CrutchAlerts = {notifiedVersion = 22300, times = 1}
local SV_PREFIX = "ACACUC_"
local function GetSV(addonName)
    local addonTable = _G[SV_PREFIX .. addonName]
    if (type(addonTable) == "table") then return addonTable end
end

local function CheckVersions( )
    local am = GetAddOnManager()

    for i = 1, am:GetNumAddOns() do
        local addonName, addonTitle, _, _, addonEnabled = am:GetAddOnInfo(i)

        if addonEnabled and KNOWN_VERSIONS[addonName] then
            local installedVersion = am:GetAddOnVersion(i) or 0
            local expectedVersion = KNOWN_VERSIONS[addonName]

            if installedVersion < expectedVersion then
                -- Only notify the same version up to 3 times (assuming the SV table is defined)
                local sv = GetSV(addonName)

                local notifiedVersion = (sv and sv.notifiedVersion) or 0
                local timesNotified = 0
                if (expectedVersion == notifiedVersion) then
                    timesNotified = (sv and sv.times) or 0
                end

                if (timesNotified < 3) then
                    CHAT_ROUTER:AddSystemMessage(zo_strformat(MESSAGE, addonTitle, installedVersion, expectedVersion))

                    -- Save number of times this version has been notified
                    if (not sv) then
                        _G[SV_PREFIX .. addonName] = {}
                        sv = _G[SV_PREFIX .. addonName]
                    end
                    sv.notifiedVersion = expectedVersion
                    sv.times = timesNotified + 1
                end
            end
        end
    end
end


---------------------------------------------------------------------
-- Setting
---------------------------------------------------------------------
local function CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if (not LAM) then return end

    local panelData = {
        type = "panel",
        name = "ACAC Update Checker",
        author = "Kyzeragon, @code65536",
        version = tostring(VERSION),
    }

    local optionsData = {
        {
            type = "description",
            text = "Checks installed add-on versions against known versions.",
        },
        {
            type = "checkbox",
            name = "Enabled",
            tooltip = "Whether to check addon versions on initial load",
            default = true,
            getFunc = function() return ACACUpdateCheckDisabled == nil end,
            setFunc = function(value)
                if (value) then
                    ACACUpdateCheckDisabled = nil
                else
                    ACACUpdateCheckDisabled = {true}
                end
            end,
        },
        {
            type = "description",
            title = "Troubleshooting",
            text = "If you use Minion, it may have stopped tracking addons; search for and install the addons again to fix this.\n\nIf you think you have already updated and reloaded UI, there could be issues with OneDrive confusing ESO / Minion with a second Documents folder. It's recommended to turn off OneDrive if you don't actually use it, but remember to back up your files first!",
        },
    }

    LAM:RegisterAddonPanel(NAME, panelData)
    LAM:RegisterOptionControls(NAME, optionsData)
end


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_PLAYER_ACTIVATED) -- In case we are overriding an older version embedded in another addon

EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, function()
    CreateSettingsMenu()

    if (ACACUpdateCheckDisabled == nil) then
        zo_callLater(CheckVersions, 6000)
    end
end, true)
